�]q (X)   def get_cifar10(batch_size=16):
    printqX   ("loading cifar10 data ... ")q�qX!       cifar10 = CIFAR10()
    cifarqX   10.fetch(True)q�qX       cifar10.fetch(True)
    trnqX   _labels = []q�q	X       trn_labels = []
    trnq
X   _pixels = []q�qX       trn_pixels = []
    forqX    i in range(1,6):q�qX%       for i in range(1,6):
        dataqX(    = cifar10.unpickle("data_batch_%d" % i)q�qX@           data = cifar10.unpickle("data_batch_%d" % i)
        trnqX   _pixels.append(data['data'])q�qX3           trn_pixels.append(data['data'])
        trnqX   _labels.extend(data['labels'])q�qX1           trn_labels.extend(data['labels'])
    trnqX   _pixels = np.vstack(trn_pixels)q�qX.       trn_pixels = np.vstack(trn_pixels)
    trnqX>   _pixels = trn_pixels.reshape(-1, 3, 32, 32).astype(np.float32)q�qXM       trn_pixels = trn_pixels.reshape(-1, 3, 32, 32).astype(np.float32)
    tstqX&   _data = cifar10.unpickle("test_batch")q �q!X5       tst_data = cifar10.unpickle("test_batch")
    tstq"X   _labels = tst_data["labels"]q#�q$X+       tst_labels = tst_data["labels"]
    tstq%X   _pixels = tst_data["data"]q&�q'X)       tst_pixels = tst_data["data"]
    tstq(X>   _pixels = tst_pixels.reshape(-1, 3, 32, 32).astype(np.float32)q)�q*XO       tst_pixels = tst_pixels.reshape(-1, 3, 32, 32).astype(np.float32)
    printq+X.   ("-- trn shape = %s" % list(trn_pixels.shape))q,�q-XA       print("-- trn shape = %s" % list(trn_pixels.shape))
    printq.X.   ("-- tst shape = %s" % list(tst_pixels.shape))q/�q0X?       print("-- tst shape = %s" % list(tst_pixels.shape))
    trnq1X   , tst = get_cifar10()q2�q3XX   def conv(input_tensor, name, kw, kh, n_out, dw=1, dh=1, activation_fn=tf.nn.relu):
    nq4X(   _in = input_tensor.get_shape()[-1].valueq5�q6X6       n_in = input_tensor.get_shape()[-1].value
    withq7X    tf.variable_scope(name):q8�q9X1       with tf.variable_scope(name):
        weightsq:XV    = tf.get_variable('weights', [kh, kw, n_in, n_out], tf.float32, xavier_initializer())q;�q<Xt           weights = tf.get_variable('weights', [kh, kw, n_in, n_out], tf.float32, xavier_initializer())
        biasesq=XM    = tf.get_variable("bias", [n_out], tf.float32, tf.constant_initializer(0.0))q>�q?Xh           biases = tf.get_variable("bias", [n_out], tf.float32, tf.constant_initializer(0.0))
        convq@XF    = tf.nn.conv2d(input_tensor, weights, (1, dh, dw, 1), padding='SAME')qA�qBXe           conv = tf.nn.conv2d(input_tensor, weights, (1, dh, dw, 1), padding='SAME')
        activationqCX.    = activation_fn(tf.nn.bias_add(conv, biases))qD�qEX           return activation
defqFXF    fully_connected(input_tensor, name, n_out, activation_fn=tf.nn.relu):qG�qHXO   def fully_connected(input_tensor, name, n_out, activation_fn=tf.nn.relu):
    nqIX(   _in = input_tensor.get_shape()[-1].valueqJ�qKX6       n_in = input_tensor.get_shape()[-1].value
    withqLX    tf.variable_scope(name):qM�qNX1       with tf.variable_scope(name):
        weightsqOXN    = tf.get_variable('weights', [n_in, n_out], tf.float32, xavier_initializer())qP�qQXl           weights = tf.get_variable('weights', [n_in, n_out], tf.float32, xavier_initializer())
        biasesqRXM    = tf.get_variable("bias", [n_out], tf.float32, tf.constant_initializer(0.0))qS�qTXj           biases = tf.get_variable("bias", [n_out], tf.float32, tf.constant_initializer(0.0))
        logitsqUX;    = tf.nn.bias_add(tf.matmul(input_tensor, weights), biases)qV�qWXX           logits = tf.nn.bias_add(tf.matmul(input_tensor, weights), biases)
        returnqXX    activation_fn(logits)qY�qZX(           return activation_fn(logits)
defq[X*    pool(input_tensor, name, kh, kw, dh, dw):q\�q]X8   def pool(input_tensor, name, kh, kw, dh, dw):
    returnq^X    tf.nn.max_pool(input_tensor,q_�q`XG       return tf.nn.max_pool(input_tensor,
                          ksizeqaX   =[1, kh, kw, 1],qb�qcXQ                             ksize=[1, kh, kw, 1],
                          stridesqdX   =[1, dh, dw, 1],qe�qfX(                             name=name)
defqgX    loss(logits, onehot_labels):qh�qiX-   def loss(logits, onehot_labels):
    xentropyqjXR    = tf.nn.softmax_cross_entropy_with_logits(logits, onehot_labels, name='xentropy')qk�qlXg       xentropy = tf.nn.softmax_cross_entropy_with_logits(logits, onehot_labels, name='xentropy')
    lossqmX(    = tf.reduce_mean(xentropy, name='loss')qn�qoX       return loss
defqpX&    topK_error(predictions, labels, K=5):qq�qrX5   def topK_error(predictions, labels, K=5):
    correctqsX>    = tf.cast(tf.nn.in_top_k(predictions, labels, K), tf.float32)qt�quXV       correct = tf.cast(tf.nn.in_top_k(predictions, labels, K), tf.float32)
    accuracyqvX    = tf.reduce_mean(correct)qw�qxX0       accuracy = tf.reduce_mean(correct)
    errorqyX    = 1.0 - accuracyqz�q{X       return error
defq|X    average_gradients(grads):q}�q~X)   def average_gradients(grads):
    averageqX   _grads = []q��q�X       average_grads = []
    forq�X    grad_and_vars in zip(*grads):q��q�X           grads = []
        forq�X    g, _ in grad_and_vars:q��q�X7           for g, _ in grad_and_vars:
            expandedq�X   _g = tf.expand_dims(g, 0)q��q�X?               expanded_g = tf.expand_dims(g, 0)
            gradsq�X   .append(expanded_g)q��q�X1               grads.append(expanded_g)
        gradq�X    = tf.concat(0, grads)q��q�X/           grad = tf.concat(0, grads)
        gradq�X    = tf.reduce_mean(grad, 0)q��q�X0           grad = tf.reduce_mean(grad, 0)
        #q�XF    across towers. So .. we will just return the first tower's pointer toq��q�XY           # across towers. So .. we will just return the first tower's pointer to
        vq�X    = grad_and_vars[0][1]q��q�X,           v = grad_and_vars[0][1]
        gradq�X   _and_var = (grad, v)q��q�X0           grad_and_var = (grad, v)
        averageq�X   _grads.append(grad_and_var)q��q�X5           average_grads.append(grad_and_var)
    returnq�X    average_gradsq��q�X   G = tf.Graph()
withq�X    G.as_default():q��q�X   with G.as_default():
    imagesq�X,    = tf.placeholder("float", [1, 224, 224, 3])q��q�XA       images = tf.placeholder("float", [1, 224, 224, 3])
    logitsq�X2    = vgg.build(images, n_classes=10, training=False)q��q�XF       logits = vgg.build(images, n_classes=10, training=False)
    probsq�X    = tf.nn.softmax(logits)q��q�X%       probs = tf.nn.softmax(logits)
defq�X    predict(im):q��q�X   def predict(im):
    labelsq�X4    = ['airplane', 'automobile', 'bird', 'cat', 'deer',q��q�XR       labels = ['airplane', 'automobile', 'bird', 'cat', 'deer',
              'dog'q�X#   , 'frog', 'horse', 'ship', 'truck']q��q�X=                 'dog', 'frog', 'horse', 'ship', 'truck']
    ifq�X    im.shape != (224, 224, 3):q��q�X,       if im.shape != (224, 224, 3):
        imq�X    = resize(im, (224, 224))q��q�X*           im = resize(im, (224, 224))
    imq�X    = np.expand_dims(im, 0)q��q�X'       im = np.expand_dims(im, 0)
    sessq�X    = tf.get_default_session()qq�X/       sess = tf.get_default_session()
    resultsq�X     = sess.run(probs, {images: im})qņq�X6       results = sess.run(probs, {images: im})
    returnq�X    labels[np.argmax(results)]qȆq�X(       return labels[np.argmax(results)]
ifq�X    __name__ == '__main__':qˆq�X%   if __name__ == '__main__':
    parserq�X    = argparse.ArgumentParser()qΆq�X1       parser = argparse.ArgumentParser()
    parserq�XP   .add_argument("-w", "--weights", required=True, help="path to weights.npz file")qцq�Xe       parser.add_argument("-w", "--weights", required=True, help="path to weights.npz file")
    parserq�X0   .add_argument("image", help="path to jpg image")qԆq�XC       parser.add_argument("image", help="path to jpg image")
    argsq�X    = parser.parse_args()q׆q�X%       args = parser.parse_args()
    imq�X    = imread(args.image)qچq�X$       im = imread(args.image)
    sessq�X    = tf.Session(graph=G)q݆q�X'       sess = tf.Session(graph=G)
    withq�X    sess.as_default():q��q�X)       with sess.as_default():
        toolsq�X   .load_weights(G, args.weights)q�q�X9           tools.load_weights(G, args.weights)
        printq�X    predict(im)q�q�X(   def save_weights(graph, fpath):
    sessq�X    = tf.get_default_session()q�q�X1       sess = tf.get_default_session()
    variablesq�X$    = graph.get_collection("variables")q�q�X>       variables = graph.get_collection("variables")
    variableq�X$   _names = [v.name for v in variables]q�q�X;       variable_names = [v.name for v in variables]
    kwargsq�X1    = dict(zip(variable_names, sess.run(variables)))q�q�XB       kwargs = dict(zip(variable_names, sess.run(variables)))
    npq�X   .savez(fpath, **kwargs)q��q�X!       np.savez(fpath, **kwargs)
defq�X    load_weights(graph, fpath):q��q�X(   def load_weights(graph, fpath):
    sessq�X    = tf.get_default_session()q��q�X1       sess = tf.get_default_session()
    variablesq�X$    = graph.get_collection("variables")q��q�X:       variables = graph.get_collection("variables")
    datar   X    = np.load(fpath)r  �r  X!       data = np.load(fpath)
    forr  X    v in variables:r  �r  X"       for v in variables:
        ifr  X    v.name not in data:r  �r  X0           if v.name not in data:
            printr	  X2   ("could not load data for variable='%s'" % v.name)r
  �r  X"               continue
        printr  X   ("assigning %s" % v.name)r  �r  X3           print("assigning %s" % v.name)
        sessr  X   .run(v.assign(data[v.name]))r  �r  X,           sess.run(v.assign(data[v.name]))
defr  X5    iterative_reduce(ops, inputs, args, batch_size, fn):r  �r  XA   def iterative_reduce(ops, inputs, args, batch_size, fn):
    sessr  X    = tf.get_default_session()r  �r  X)       sess = tf.get_default_session()
    Nr  X    = len(args[0])r  �r  X       results = []
    forr  X    i in range(0, N, batch_size):r  �r  X%           batch_start = i
        batchr  X   _end = i + batch_sizer  �r   X4           batch_end = i + batch_size
        minibatchr!  X0   _args = [a[batch_start:batch_end] for a in args]r"  �r#  XP           minibatch_args = [a[batch_start:batch_end] for a in args]
        resultr$  X3    = sess.run(ops, dict(zip(inputs, minibatch_args)))r%  �r&  XQ           result = sess.run(ops, dict(zip(inputs, minibatch_args)))
        resultsr'  X   .append(result)r(  �r)  X*           results.append(result)
    resultsr*  X!    = [fn(r) for r in zip(*results)]r+  �r,  X       return results
classr-  X    StatLogger:r.  �r/  X   class StatLogger:
    defr0  X    __init__(self, fpath):r1  �r2  X'           self.fpath = fpath
        fdirr3  X    = pth.split(fpath)[0]r4  �r5  X-           fdir = pth.split(fpath)[0]
        ifr6  X(    len(fdir) > 0 and not pth.exists(fdir):r7  �r8  XA           if len(fdir) > 0 and not pth.exists(fdir):
            osr9  X   .makedirs(fdir)r:  �r;  X%               os.makedirs(fdir)
    defr<  X    report(self, step, **kwargs):r=  �r>  X               }
            datar?  X   .update(kwargs)r@  �rA  X.               data.update(kwargs)
            fhrB  X   .write(json.dumps(data) + "\n")rC  �rD  X   config = {}
defrE  X4    build_model(input_data_tensor, input_label_tensor):rF  �rG  X?   def build_model(input_data_tensor, input_label_tensor):
    numrH  X    _classes = config["num_classes"]rI  �rJ  X2       num_classes = config["num_classes"]
    imagesrK  X8    = tf.image.resize_images(input_data_tensor, [224, 224])rL  �rM  XM       images = tf.image.resize_images(input_data_tensor, [224, 224])
    logitsrN  X:    = vgg.build(images, n_classes=num_classes, training=True)rO  �rP  XN       logits = vgg.build(images, n_classes=num_classes, training=True)
    probsrQ  X    = tf.nn.softmax(logits)rR  �rS  X*       probs = tf.nn.softmax(logits)
    lossrT  X>    = L.loss(logits, tf.one_hot(input_label_tensor, num_classes))rU  �rV  XP       loss = L.loss(logits, tf.one_hot(input_label_tensor, num_classes))
    errorrW  X4   _top5 = L.topK_error(probs, input_label_tensor, K=5)rX  �rY  XG       error_top5 = L.topK_error(probs, input_label_tensor, K=5)
    errorrZ  X4   _top1 = L.topK_error(probs, input_label_tensor, K=1)r[  �r\  XH       error_top1 = L.topK_error(probs, input_label_tensor, K=1)
    returnr]  X    dict(loss=loss,r^  �r_  X4                   logits=logits,
                errorr`  X   _top5=error_top5,ra  �rb  X<                   error_top5=error_top5,
                errorrc  X   _top1=error_top1)rd  �re  X*                   error_top1=error_top1)
defrf  X    train(train_data_generator):rg  �rh  X/   def train(train_data_generator):
    checkpointri  X   _dir = config["checkpoint_dir"]rj  �rk  X:       checkpoint_dir = config["checkpoint_dir"]
    learningrl  X   _rate = config['learning_rate']rm  �rn  X4       learning_rate = config['learning_rate']
    dataro  X   _dims = config['data_dims']rp  �rq  X-       data_dims = config['data_dims']
    batchrr  X   _size = config['batch_size']rs  �rt  X-       batch_size = config['batch_size']
    numru  X   _gpus = config['num_gpus']rv  �rw  X)       num_gpus = config['num_gpus']
    numrx  X   _epochs = config['num_epochs']ry  �rz  X-       num_epochs = config['num_epochs']
    numr{  X4   _samples_per_epoch = config["num_samples_per_epoch"]r|  �r}  XJ       num_samples_per_epoch = config["num_samples_per_epoch"]
    pretrainedr~  X'   _weights = config["pretrained_weights"]r  �r�  X?       pretrained_weights = config["pretrained_weights"]
    stepsr�  X=   _per_epoch = num_samples_per_epoch // (batch_size * num_gpus)r�  �r�  XN       steps_per_epoch = num_samples_per_epoch // (batch_size * num_gpus)
    numr�  X%   _steps = steps_per_epoch * num_epochsr�  �r�  X;       num_steps = steps_per_epoch * num_epochs
    checkpointr�  X!   _iter = config["checkpoint_iter"]r�  �r�  X>       checkpoint_iter = config["checkpoint_iter"]
    experimentr�  X   _dir = config['experiment_dir']r�  �r�  X7       experiment_dir = config['experiment_dir']
    trainr�  X2   _log_fpath = pth.join(experiment_dir, 'train.log')r�  �r�  XC       train_log_fpath = pth.join(experiment_dir, 'train.log')
    logr�  X'    = tools.MetricsLogger(train_log_fpath)r�  �r�  X4       log = tools.MetricsLogger(train_log_fpath)
    Gr�  X    = tf.Graph()r�  �r�  X       G = tf.Graph()
    withr�  X%    G.as_default(), tf.device('/cpu:0'):r�  �r�  X:       with G.as_default(), tf.device('/cpu:0'):
        fullr�  X0   _data_dims = [batch_size * num_gpus] + data_dimsr�  �r�  XI           full_data_dims = [batch_size * num_gpus] + data_dims
        datar�  X#    = tf.placeholder(dtype=tf.float32,r�  �r�  XS           data = tf.placeholder(dtype=tf.float32,
                              shaper�  X   =full_data_dims,r�  �r�  X9                                 name='data')
        labelsr�  X!    = tf.placeholder(dtype=tf.int32,r�  �r�  XU           labels = tf.placeholder(dtype=tf.int32,
                                shaper�  X   =[batch_size * num_gpus],r�  �r�  X<                                   name='labels')
        splitr�  X#   _data = tf.split(0, num_gpus, data)r�  �r�  X>           split_data = tf.split(0, num_gpus, data)
        splitr�  X'   _labels = tf.split(0, num_gpus, labels)r�  �r�  XF           split_labels = tf.split(0, num_gpus, labels)
        optimizerr�  X(    = tf.train.AdamOptimizer(learning_rate)r�  �r�  XI           optimizer = tf.train.AdamOptimizer(learning_rate)
        replicar�  X   _grads = []r�  �r�  X&           replica_grads = []
        forr�  X    i in range(num_gpus):r�  �r�  X2           for i in range(num_gpus):
            withr�  X9    tf.name_scope('tower_%d' % i), tf.device('/gpu:%d' % i):r�  �r�  X_               with tf.name_scope('tower_%d' % i), tf.device('/gpu:%d' % i):
                modelr�  X.    = build_model(split_data[i], split_labels[i])r�  �r�  XX                   model = build_model(split_data[i], split_labels[i])
                lossr�  X    = model["loss"]r�  �r�  X:                   loss = model["loss"]
                gradsr�  X$    = optimizer.compute_gradients(loss)r�  �r�  XQ                   grads = optimizer.compute_gradients(loss)
                replicar�  X   _grads.append(grads)r�  �r�  X>                   replica_grads.append(grads)
                tfr�  X'   .get_variable_scope().reuse_variables()r�  �r�  XI                   tf.get_variable_scope().reuse_variables()
        averager�  X*   _grad = L.average_gradients(replica_grads)r�  �r�  XF           average_grad = L.average_gradients(replica_grads)
        gradr�  X/   _step = optimizer.apply_gradients(average_grad)r�  �r�  XI           grad_step = optimizer.apply_gradients(average_grad)
        trainr�  X   _step = tf.group(grad_step)r�  �r�  X5           train_step = tf.group(grad_step)
        initr�  X     = tf.initialize_all_variables()r�  �r�  X7           init = tf.initialize_all_variables()
    configr�  X2   _proto = tf.ConfigProto(allow_soft_placement=True)r�  �r�  XE       config_proto = tf.ConfigProto(allow_soft_placement=True)
    sessr�  X+    = tf.Session(graph=G, config=config_proto)r�  �r�  X       sess.run(init)
    tfr�  X%   .train.start_queue_runners(sess=sess)r�  �r�  X4       tf.train.start_queue_runners(sess=sess)
    withr�  X    sess.as_default():r�  �r�  X&       with sess.as_default():
        ifr�  X    pretrained_weights:r�  �r�  X0           if pretrained_weights:
            printr�  X3   ("-- loading weights from %s" % pretrained_weights)r�  �r�  XV               print("-- loading weights from %s" % pretrained_weights)
            toolsr�  X$   .load_weights(G, pretrained_weights)r�  �r�  XA               tools.load_weights(G, pretrained_weights)
        forr�  X    step in range(num_steps):r�  �r�  X6           for step in range(num_steps):
            datar�  X1   _batch, label_batch = train_data_generator.next()r�  �r�  XT               data_batch, label_batch = train_data_generator.next()
            inputsr�  X*    = {data: data_batch, labels: label_batch}r�  �r�  XP               inputs = {data: data_batch, labels: label_batch}
            resultsr�  X'    = sess.run([train_step, loss], inputs)r�  �r�  XL               results = sess.run([train_step, loss], inputs)
            printr�  X(   ("step:%s loss:%s" % (step, results[1]))r�  �r�  XI               print("step:%s loss:%s" % (step, results[1]))
            logr�  X7   .report(step=step, split="TRN", loss=float(results[1]))r�  �r�  XU               log.report(step=step, split="TRN", loss=float(results[1]))
            ifr�  X:    (step % checkpoint_iter == 0) or (step + 1 == num_steps):r�  �r�  X^               if (step % checkpoint_iter == 0) or (step + 1 == num_steps):
                printr�  X   ("-- saving check point")r   �r  XD                   print("-- saving check point")
                toolsr  X?   .save_weights(G, pth.join(checkpoint_dir, "weights.%s" % step))r  �r  XX                   tools.save_weights(G, pth.join(checkpoint_dir, "weights.%s" % step))
defr  X    main(argv=None):r  �r  X   def main(argv=None):
    numr  X   _gpus = config['num_gpus']r	  �r
  X+       num_gpus = config['num_gpus']
    batchr  X   _size = config['batch_size']r  �r  X4       batch_size = config['batch_size']
    checkpointr  X   _dir = config["checkpoint_dir"]r  �r  X<       checkpoint_dir = config["checkpoint_dir"]
    experimentr  X   _dir = config["experiment_dir"]r  �r  X4       experiment_dir = config["experiment_dir"]
    ifr  X     not pth.exists(experiment_dir):r  �r  X1       if not pth.exists(experiment_dir):
        osr  X   .makedirs(experiment_dir)r  �r  X*           os.makedirs(experiment_dir)
    ifr  X     not pth.exists(checkpoint_dir):r  �r  X1       if not pth.exists(checkpoint_dir):
        osr  X   .makedirs(checkpoint_dir)r  �r  X-           os.makedirs(checkpoint_dir)
    trainr   XD   _data_generator, valset = dataset.get_cifar10(batch_size * num_gpus)r!  �r"  XW       train_data_generator, valset = dataset.get_cifar10(batch_size * num_gpus)
    trainr#  X   (train_data_generator)r$  �r%  X"       train(train_data_generator)
ifr&  X    __name__ == '__main__':r'  �r(  X%   if __name__ == '__main__':
    parserr)  X    = argparse.ArgumentParser()r*  �r+  X1       parser = argparse.ArgumentParser()
    parserr,  X?   .add_argument('config_file', help='YAML formatted config file')r-  �r.  XR       parser.add_argument('config_file', help='YAML formatted config file')
    argsr/  X    = parser.parse_args()r0  �r1  X'       args = parser.parse_args()
    withr2  X    open(args.config_file) as fp:r3  �r4  X5       with open(args.config_file) as fp:
        configr5  X   .update(yaml.load(fp))r6  �r7  X.           config.update(yaml.load(fp))
    printr8  X    "Experiment config"r9  �r:  X'       print "Experiment config"
    printr;  X    "------------------"r<  �r=  X(       print "------------------"
    printr>  X    json.dumps(config, indent=4)r?  �r@  X0       print json.dumps(config, indent=4)
    printrA  X    "------------------"rB  �rC  X   config = {}
defrD  X4    build_model(input_data_tensor, input_label_tensor):rE  �rF  X?   def build_model(input_data_tensor, input_label_tensor):
    numrG  X    _classes = config["num_classes"]rH  �rI  X2       num_classes = config["num_classes"]
    weightrJ  X   _decay = config["weight_decay"]rK  �rL  X4       weight_decay = config["weight_decay"]
    imagesrM  X8    = tf.image.resize_images(input_data_tensor, [224, 224])rN  �rO  XM       images = tf.image.resize_images(input_data_tensor, [224, 224])
    logitsrP  X:    = vgg.build(images, n_classes=num_classes, training=True)rQ  �rR  XN       logits = vgg.build(images, n_classes=num_classes, training=True)
    probsrS  X    = tf.nn.softmax(logits)rT  �rU  X*       probs = tf.nn.softmax(logits)
    lossrV  XG   _classify = L.loss(logits, tf.one_hot(input_label_tensor, num_classes))rW  �rX  XX       loss_classify = L.loss(logits, tf.one_hot(input_label_tensor, num_classes))
    lossrY  Xb   _weight_decay = tf.reduce_sum(tf.pack([tf.nn.l2_loss(i) for i in tf.get_collection('variables')]))rZ  �r[  Xs       loss_weight_decay = tf.reduce_sum(tf.pack([tf.nn.l2_loss(i) for i in tf.get_collection('variables')]))
    lossr\  X1    = loss_classify + weight_decay*loss_weight_decayr]  �r^  XC       loss = loss_classify + weight_decay*loss_weight_decay
    errorr_  X4   _top5 = L.topK_error(probs, input_label_tensor, K=5)r`  �ra  XG       error_top5 = L.topK_error(probs, input_label_tensor, K=5)
    errorrb  X4   _top1 = L.topK_error(probs, input_label_tensor, K=1)rc  �rd  XH       error_top1 = L.topK_error(probs, input_label_tensor, K=1)
    returnre  X    dict(loss=loss,rf  �rg  X4                   logits=logits,
                errorrh  X   _top5=error_top5,ri  �rj  X<                   error_top5=error_top5,
                errorrk  X   _top1=error_top1)rl  �rm  X*                   error_top1=error_top1)
defrn  X*    train(trn_data_generator, vld_data=None):ro  �rp  X:   def train(trn_data_generator, vld_data=None):
    learningrq  X   _rate = config['learning_rate']rr  �rs  X:       learning_rate = config['learning_rate']
    experimentrt  X   _dir = config['experiment_dir']ru  �rv  X6       experiment_dir = config['experiment_dir']
    datarw  X   _dims = config['data_dims']rx  �ry  X-       data_dims = config['data_dims']
    batchrz  X   _size = config['batch_size']r{  �r|  X-       batch_size = config['batch_size']
    numr}  X   _epochs = config['num_epochs']r~  �r  X-       num_epochs = config['num_epochs']
    numr�  X4   _samples_per_epoch = config["num_samples_per_epoch"]r�  �r�  XE       num_samples_per_epoch = config["num_samples_per_epoch"]
    stepsr�  X0   _per_epoch = num_samples_per_epoch // batch_sizer�  �r�  XA       steps_per_epoch = num_samples_per_epoch // batch_size
    numr�  X%   _steps = steps_per_epoch * num_epochsr�  �r�  X;       num_steps = steps_per_epoch * num_epochs
    checkpointr�  X.   _dir = pth.join(experiment_dir, 'checkpoints')r�  �r�  XF       checkpoint_dir = pth.join(experiment_dir, 'checkpoints')
    trainr�  X2   _log_fpath = pth.join(experiment_dir, 'train.log')r�  �r�  XC       train_log_fpath = pth.join(experiment_dir, 'train.log')
    vldr�  X   _iter = config["vld_iter"]r�  �r�  X0       vld_iter = config["vld_iter"]
    checkpointr�  X!   _iter = config["checkpoint_iter"]r�  �r�  X>       checkpoint_iter = config["checkpoint_iter"]
    pretrainedr�  X1   _weights = config.get("pretrained_weights", None)r�  �r�  XE       pretrained_weights = config.get("pretrained_weights", None)
    Gr�  X    = tf.Graph()r�  �r�  X       G = tf.Graph()
    withr�  X    G.as_default():r�  �r�  X&       with G.as_default():
        inputr�  X=   _data_tensor = tf.placeholder(tf.float32, [None] + data_dims)r�  �r�  XX           input_data_tensor = tf.placeholder(tf.float32, [None] + data_dims)
        inputr�  X0   _label_tensor = tf.placeholder(tf.int32, [None])r�  �r�  XK           input_label_tensor = tf.placeholder(tf.int32, [None])
        modelr�  X5    = build_model(input_data_tensor, input_label_tensor)r�  �r�  XT           model = build_model(input_data_tensor, input_label_tensor)
        optimizerr�  X(    = tf.train.AdamOptimizer(learning_rate)r�  �r�  XG           optimizer = tf.train.AdamOptimizer(learning_rate)
        gradsr�  X-    = optimizer.compute_gradients(model["loss"])r�  �r�  XG           grads = optimizer.compute_gradients(model["loss"])
        gradr�  X(   _step = optimizer.apply_gradients(grads)r�  �r�  XA           grad_step = optimizer.apply_gradients(grads)
        initr�  X     = tf.initialize_all_variables()r�  �r�  X4           init = tf.initialize_all_variables()
    logr�  X'    = tools.MetricsLogger(train_log_fpath)r�  �r�  X9       log = tools.MetricsLogger(train_log_fpath)
    configr�  X2   _proto = tf.ConfigProto(allow_soft_placement=True)r�  �r�  XE       config_proto = tf.ConfigProto(allow_soft_placement=True)
    sessr�  X+    = tf.Session(graph=G, config=config_proto)r�  �r�  X       sess.run(init)
    tfr�  X%   .train.start_queue_runners(sess=sess)r�  �r�  X4       tf.train.start_queue_runners(sess=sess)
    withr�  X    sess.as_default():r�  �r�  X&       with sess.as_default():
        ifr�  X    pretrained_weights:r�  �r�  X0           if pretrained_weights:
            printr�  X3   ("-- loading weights from %s" % pretrained_weights)r�  �r�  XV               print("-- loading weights from %s" % pretrained_weights)
            toolsr�  X$   .load_weights(G, pretrained_weights)r�  �r�  XA               tools.load_weights(G, pretrained_weights)
        forr�  X    step in range(num_steps):r�  �r�  X7           for step in range(num_steps):
            batchr�  X"   _train = trn_data_generator.next()r�  �r�  XA               batch_train = trn_data_generator.next()
            Xr�  X   _trn = np.array(batch_train[0])r�  �r�  X:               X_trn = np.array(batch_train[0])
            Yr�  X   _trn = np.array(batch_train[1])r�  �r�  X<               Y_trn = np.array(batch_train[1])
            opsr�  X9    = [grad_step] + [model[k] for k in sorted(model.keys())]r�  �r�  X[               ops = [grad_step] + [model[k] for k in sorted(model.keys())]
            inputsr�  X8    = {input_data_tensor: X_trn, input_label_tensor: Y_trn}r�  �r�  X^               inputs = {input_data_tensor: X_trn, input_label_tensor: Y_trn}
            resultsr�  X"    = sess.run(ops, feed_dict=inputs)r�  �r�  XI               results = sess.run(ops, feed_dict=inputs)
            resultsr�  X/    = dict(zip(sorted(model.keys()), results[1:]))r�  �r�  XT               results = dict(zip(sorted(model.keys()), results[1:]))
            printr�  XE   ("TRN step:%-5d error_top1: %.4f, error_top5: %.4f, loss:%s" % (step,r�  �r�  X�               print("TRN step:%-5d error_top1: %.4f, error_top5: %.4f, loss:%s" % (step,
                                                                                 resultsr�  X   ["error_top1"],r�  �r�  X�                                                                                    results["error_top1"],
                                                                                 resultsr�  X   ["error_top5"],r�  �r�  Xr                                                                                    results["loss"]))
            logr�  X   .report(step=step,r�  �r�  X@                          split="TRN",
                       errorr�  X#   _top5=float(results["error_top5"]),r�  �r�  X\                          error_top5=float(results["error_top5"]),
                       errorr�  X#   _top1=float(results["error_top5"]),r�  �r�  X[                          error_top1=float(results["error_top5"]),
                       lossr�  X   =float(results["loss"]))r�  �r�  XB                          loss=float(results["loss"]))
            ifr�  X    (step % vld_iter == 0):r�  �r�  X<               if (step % vld_iter == 0):
                printr�  X&   ("-- running evaluation on vld split")r�  �r�  XM                   print("-- running evaluation on vld split")
                Xr�  X   _vld = vld_data[0]r�  �r   X5                   X_vld = vld_data[0]
                Yr  X   _vld = vld_data[1]r  �r  X:                   Y_vld = vld_data[1]
                inputsr  X*    = [input_data_tensor, input_label_tensor]r  �r  XU                   inputs = [input_data_tensor, input_label_tensor]
                argsr  X    = [X_vld, Y_vld]r  �r	  X9                   args = [X_vld, Y_vld]
                opsr
  X+    = [model[k] for k in sorted(model.keys())]r  �r  XV                   ops = [model[k] for k in sorted(model.keys())]
                resultsr  X[    = tools.iterative_reduce(ops, inputs, args, batch_size=1, fn=lambda x: np.mean(x, axis=0))r  �r  X�                   results = tools.iterative_reduce(ops, inputs, args, batch_size=1, fn=lambda x: np.mean(x, axis=0))
                resultsr  X+    = dict(zip(sorted(model.keys()), results))r  �r  XX                   results = dict(zip(sorted(model.keys()), results))
                printr  XE   ("VLD step:%-5d error_top1: %.4f, error_top5: %.4f, loss:%s" % (step,r  �r  X�                   print("VLD step:%-5d error_top1: %.4f, error_top5: %.4f, loss:%s" % (step,
                                                                                     resultsr  X   ["error_top1"],r  �r  X�                                                                                        results["error_top1"],
                                                                                     resultsr  X   ["error_top5"],r  �r  Xz                                                                                        results["loss"]))
                logr  X   .report(step=step,r  �r  XH                              split="VLD",
                           errorr  X#   _top5=float(results["error_top5"]),r   �r!  Xd                              error_top5=float(results["error_top5"]),
                           errorr"  X#   _top1=float(results["error_top1"]),r#  �r$  Xc                              error_top1=float(results["error_top1"]),
                           lossr%  X   =float(results["loss"]))r&  �r'  XF                              loss=float(results["loss"]))
            ifr(  X:    (step % checkpoint_iter == 0) or (step + 1 == num_steps):r)  �r*  X^               if (step % checkpoint_iter == 0) or (step + 1 == num_steps):
                printr+  X   ("-- saving check point")r,  �r-  XD                   print("-- saving check point")
                toolsr.  X?   .save_weights(G, pth.join(checkpoint_dir, "weights.%s" % step))r/  �r0  X   def main():
    batchr1  X   _size = config['batch_size']r2  �r3  X4       batch_size = config['batch_size']
    experimentr4  X   _dir = config['experiment_dir']r5  �r6  X<       experiment_dir = config['experiment_dir']
    checkpointr7  X.   _dir = pth.join(experiment_dir, 'checkpoints')r8  �r9  XC       checkpoint_dir = pth.join(experiment_dir, 'checkpoints')
    ifr:  X     not pth.exists(experiment_dir):r;  �r<  X1       if not pth.exists(experiment_dir):
        osr=  X   .makedirs(experiment_dir)r>  �r?  X*           os.makedirs(experiment_dir)
    ifr@  X     not pth.exists(checkpoint_dir):rA  �rB  X1       if not pth.exists(checkpoint_dir):
        osrC  X   .makedirs(checkpoint_dir)rD  �rE  X+           os.makedirs(checkpoint_dir)
    trnrF  X;   _data_generator, vld_data = dataset.get_cifar10(batch_size)rG  �rH  XL       trn_data_generator, vld_data = dataset.get_cifar10(batch_size)
    trainrI  X   (trn_data_generator, vld_data)rJ  �rK  X*       train(trn_data_generator, vld_data)
ifrL  X    __name__ == '__main__':rM  �rN  X%   if __name__ == '__main__':
    parserrO  X    = argparse.ArgumentParser()rP  �rQ  X1       parser = argparse.ArgumentParser()
    parserrR  X?   .add_argument('config_file', help='YAML formatted config file')rS  �rT  XR       parser.add_argument('config_file', help='YAML formatted config file')
    argsrU  X    = parser.parse_args()rV  �rW  X'       args = parser.parse_args()
    withrX  X    open(args.config_file) as fp:rY  �rZ  X5       with open(args.config_file) as fp:
        configr[  X   .update(yaml.load(fp))r\  �r]  X2           config.update(yaml.load(fp))
        printr^  X    "Experiment config"r_  �r`  X/           print "Experiment config"
        printra  X    "------------------"rb  �rc  X0           print "------------------"
        printrd  X    json.dumps(config, indent=4)re  �rf  X8           print json.dumps(config, indent=4)
        printrg  X    "------------------"rh  �ri  XM   def build(input_tensor, n_classes=1000, rgb_mean=None, training=True):
    ifrj  X    rgb_mean is None:rk  �rl  X$       if rgb_mean is None:
        rgbrm  X>   _mean = np.array([116.779, 123.68, 103.939], dtype=np.float32)rn  �ro  XP           rgb_mean = np.array([116.779, 123.68, 103.939], dtype=np.float32)
    murp  X)    = tf.constant(rgb_mean, name="rgb_mean")rq  �rr  X8       mu = tf.constant(rgb_mean, name="rgb_mean")
    keeprs  X   _prob = 0.5rt  �ru  X       keep_prob = 0.5
    netrv  X7    = tf.sub(input_tensor, mu, name="input_mean_centered")rw  �rx  XF       net = tf.sub(input_tensor, mu, name="input_mean_centered")
    netry  X4    = L.conv(net, name="conv1_1", kh=3, kw=3, n_out=64)rz  �r{  XC       net = L.conv(net, name="conv1_1", kh=3, kw=3, n_out=64)
    netr|  X4    = L.conv(net, name="conv1_2", kh=3, kw=3, n_out=64)r}  �r~  XC       net = L.conv(net, name="conv1_2", kh=3, kw=3, n_out=64)
    netr  X4    = L.pool(net, name="pool1", kh=2, kw=2, dw=2, dh=2)r�  �r�  XC       net = L.pool(net, name="pool1", kh=2, kw=2, dw=2, dh=2)
    netr�  X5    = L.conv(net, name="conv2_1", kh=3, kw=3, n_out=128)r�  �r�  XD       net = L.conv(net, name="conv2_1", kh=3, kw=3, n_out=128)
    netr�  X5    = L.conv(net, name="conv2_2", kh=3, kw=3, n_out=128)r�  �r�  XD       net = L.conv(net, name="conv2_2", kh=3, kw=3, n_out=128)
    netr�  X4    = L.pool(net, name="pool2", kh=2, kw=2, dh=2, dw=2)r�  �r�  XC       net = L.pool(net, name="pool2", kh=2, kw=2, dh=2, dw=2)
    netr�  X5    = L.conv(net, name="conv3_1", kh=3, kw=3, n_out=256)r�  �r�  XD       net = L.conv(net, name="conv3_1", kh=3, kw=3, n_out=256)
    netr�  X5    = L.conv(net, name="conv3_2", kh=3, kw=3, n_out=256)r�  �r�  XD       net = L.conv(net, name="conv3_2", kh=3, kw=3, n_out=256)
    netr�  X4    = L.pool(net, name="pool3", kh=2, kw=2, dh=2, dw=2)r�  �r�  XC       net = L.pool(net, name="pool3", kh=2, kw=2, dh=2, dw=2)
    netr�  X5    = L.conv(net, name="conv4_1", kh=3, kw=3, n_out=512)r�  �r�  XD       net = L.conv(net, name="conv4_1", kh=3, kw=3, n_out=512)
    netr�  X5    = L.conv(net, name="conv4_2", kh=3, kw=3, n_out=512)r�  �r�  XD       net = L.conv(net, name="conv4_2", kh=3, kw=3, n_out=512)
    netr�  X5    = L.conv(net, name="conv4_3", kh=3, kw=3, n_out=512)r�  �r�  XD       net = L.conv(net, name="conv4_3", kh=3, kw=3, n_out=512)
    netr�  X4    = L.pool(net, name="pool4", kh=2, kw=2, dh=2, dw=2)r�  �r�  XC       net = L.pool(net, name="pool4", kh=2, kw=2, dh=2, dw=2)
    netr�  X5    = L.conv(net, name="conv5_1", kh=3, kw=3, n_out=512)r�  �r�  XD       net = L.conv(net, name="conv5_1", kh=3, kw=3, n_out=512)
    netr�  X5    = L.conv(net, name="conv5_2", kh=3, kw=3, n_out=512)r�  �r�  XD       net = L.conv(net, name="conv5_2", kh=3, kw=3, n_out=512)
    netr�  X5    = L.conv(net, name="conv5_3", kh=3, kw=3, n_out=512)r�  �r�  XD       net = L.conv(net, name="conv5_3", kh=3, kw=3, n_out=512)
    netr�  X4    = L.pool(net, name="pool5", kh=2, kw=2, dw=2, dh=2)r�  �r�  XI       net = L.pool(net, name="pool5", kh=2, kw=2, dw=2, dh=2)
    flattenedr�  X8   _shape = np.prod([s.value for s in net.get_shape()[1:]])r�  �r�  XM       flattened_shape = np.prod([s.value for s in net.get_shape()[1:]])
    netr�  X9    = tf.reshape(net, [-1, flattened_shape], name="flatten")r�  �r�  XH       net = tf.reshape(net, [-1, flattened_shape], name="flatten")
    netr�  X1    = L.fully_connected(net, name="fc6", n_out=4096)r�  �r�  X@       net = L.fully_connected(net, name="fc6", n_out=4096)
    netr�  X     = tf.nn.dropout(net, keep_prob)r�  �r�  X/       net = tf.nn.dropout(net, keep_prob)
    netr�  X1    = L.fully_connected(net, name="fc7", n_out=4096)r�  �r�  X@       net = L.fully_connected(net, name="fc7", n_out=4096)
    netr�  X     = tf.nn.dropout(net, keep_prob)r�  �r�  X/       net = tf.nn.dropout(net, keep_prob)
    netr�  X6    = L.fully_connected(net, name="fc8", n_out=n_classes)r�  �r�  X       return net
ifr�  X    __name__ == '__main__':r�  �r�  X    if __name__ == '__main__':
    xr�  X0    = tf.placeholder(tf.float32, [10, 224, 224, 3])r�  �r�  e.