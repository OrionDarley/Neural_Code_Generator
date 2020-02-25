import ray
ray.init()
import pickle, os, math
from itertools import filterfalse
from tqdm import tqdm
import pathlib, logging
from rule_based_retriever.index import *
from DataClass.data_utils import set_logger
from collections import namedtuple

def generate_datasets(opt, max_lines = 10000):
    """
    Check if processed datasets exist.

    If so, read. Otherwise, generate and save to the path.
    """
    print(f"\n[generate_datasets] Processing {opt.path}")
    options = to_string_opt(opt)
    path_dataset = os.path.join(opt.path, f"dataset_{options}.p")
    path_dataset_edit = os.path.join(opt.path, f"dataset_edit_{options}.p")

    if os.path.exists(path_dataset) and os.path.exists(path_dataset_edit) and not opt.overwrite:
        print("[generate_datasets] Read from pickled files")
        dataset = read_from_pickle(path_dataset)
        dataset_edit = read_from_pickle(path_dataset_edit)
    else:
        sources, num_file = read_data(opt.path)

        dataset = construct_dataset(sources)  # D_proj = {(x, y)}
        if len(dataset) > max_lines:
            print(f"[generate_datasets] Skipping too large project (|dataset| = {len(dataset)})")
            dataset_edit = []
        else:
            dataset_edit = [ray.remote(opt, example) for example in dataset]
            res = ray.get(dataset_edit)
            dataset_edit = list(filterfalse(lambda x: len(x) == 0, res)) #D_edit = {(x, y, x', y')}

            print(f"\n[generate_datasets] Number of examples: {len(dataset)} ({len(set(dataset))} unique examples)")
            print(f"[generate_datasets] Number of examples for edit: {len(dataset_edit)} ({len(set(dataset_edit))} unique examples)\n")

            # dataset_edit = construct_dataset_edit(opt, dataset)  # D_edit = {(x, y, x', y')}

            # Save datasets for future use
            if opt.save:
                save_as_pickle(path_dataset, dataset)
                save_as_pickle(path_dataset_edit, dataset_edit)

    print(f"\n[generate_datasets] Number of examples: {len(dataset)} ({len(set(dataset))} unique examples)")
    print(f"[generate_datasets] Number of examples for edit: {len(dataset_edit)} ({len(set(dataset_edit))} unique examples)\n")

    return dataset, dataset_edit

def get_params(p, debug = False, save = True, overwrite = False, verbose = False,
               unit = 'line', min_len = 10, distance_metric_x = 'nc',
               distance_threshold_x = math.inf, distance_metric_y = 'c',
               distance_threshold_y = math.inf, n_leftmost_tokens = 1, max_num_candidates = 1,
               check_exact_match_suffix = False):
    opt = namedtuple('opt', ['path', 'debug', 'save', 'overwrite', 'verbose', 'unit', 'min_len',
                             'distance_metric_x', 'distance_threshold_x', 'distance_metric_y',
                             'distance_threshold_y', 'n_leftmost_tokens', 'max_num_candidates',
                             'check_exact_match_suffix'])
    param = opt(p, debug, save, overwrite, verbose, unit, min_len, distance_metric_x,
               distance_threshold_x, distance_metric_y,
               distance_threshold_y, n_leftmost_tokens, max_num_candidates, check_exact_match_suffix)
    return param

def load_saved_datasets(dataset_path, dataset_edit_path = None):
    if dataset_edit_path is not None:
        with open(dataset_edit_path, 'rb') as f:
            dataset_edit = pickle.load(f)
        f.close()

    with open(dataset_path, 'rb') as f:
        dataset = pickle.load(f)
    f.close()
    return dataset, dataset_edit

def save_pickle(filename, obj):
    with open(filename, 'wb') as file:
        pickle.dump(obj, file , protocol=pickle.HIGHEST_PROTOCOL)
    file.close()

def run_example(example, examples_with_suffix, opt):

    # Process example
    x = example[0].replace("&lt;", "<").replace("&gt;", ">").replace("&amp;", "&")
    y = example[1].replace("&lt;", "<").replace("&gt;", ">").replace("&amp;", "&")
    # x, y = process_example(x, y)


    # Get metadata
    x_suffix = get_suffix(x)
    example_edits = rank_based_on_distance(opt,
                                           (x, y),
                                           examples_with_suffix[x_suffix],
                                           check_exact_match_suffix=False,  # No need to check if passing examples_with_suffix
                                           include_unsatisfying_examples=False,
                                           exclude_same_context=False,
                                           exclude_same_example=True)

    example_edits = [{
                        'edit_distance_x': f'{edit_distance_x:.2f}',
                        'edit_distance_y': f'{edit_distance_y:.2f}',
                        'x': x,
                        'y': y,
                    }
                    for (edit_distance_x, edit_distance_y, x, y) in example_edits]
    data = {
            'x': x,
            'y': y,
        'example_edits': example_edits,
    }
    return data

@ray.remote
def main(line, opt, examples_with_suffix, i, top_k = 10):
    all_data = {}
    data = run_example(line, examples_with_suffix, opt)
    all_data[(i, line[0], line[1])] = data['example_edits'][:top_k]
    return all_data

def to_iterator(obj_ids):
    while obj_ids:
        done, obj_ids = ray.wait(obj_ids)
        yield ray.get(done[0])

def parallel_retriever(subdirectory):
    opt = get_params(str(subdirectory))
    print(opt)
    logging.info(f'Params is : {opt}')
    print("[main] Executing main function with options")
    sources, num_files = read_data(opt.path)
    dataset = construct_dataset(sources)  # D_proj = {(x, y)}

    examples_with_suffix = construct_examples_with_suffix(dataset)  # For metadata
    dir_name = opt.path.split('/')[-1]
    logging.info(f"Processing Directory {dir_name} ... ")

    output = [main.remote(line, opt, examples_with_suffix, i) for i, line in enumerate(dataset)]
    result = [x for x in tqdm(to_iterator(output), total = len(output)) if len(x) != 0 ]
    if opt.save:
        fname_dataraw = ''.join([str(opt.path), '_', 'dataset.pkl'])
        fname_edit_output = ''.join([str(opt.path), '_', 'dataset_edit.pkl'])
        save_pickle(fname_dataraw, dataset)
        save_pickle(fname_edit_output, result)
    return result

if __name__ == '__main__':

    # log_dir = pathlib.Path.cwd() / 'logs'
    # if not os.path.exists(log_dir):
    #     os.makedirs(log_dir)

    output_dir = pathlib.Path.cwd() / 'output'
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # set_logger(log_dir / 'rule_based.log')
    p = pathlib.Path.cwd() / 'github_data'
    subdirs = [x for x in p.iterdir() if x.is_dir()]
    retrieved_examples = {}
    for i, subdir in enumerate(subdirs):
        name = str(subdir).split('/')[-1]
        if i % 100 == 0:
            print(f'Completed {i // len(subdirs)}')
        retrieved_examples[subdir] = parallel_retriever(subdir)

    filename = ''.join([to_string_opt(opt), '.pkl'])
    save_pickle(retrieved_examples, filename)
