import os
from random import shuffle
import sys
import numpy as np

def get_training_and_validation_generators(data_file, batch_size,
                                           augment=False, augment_flip=True):
    """
    Creates the generator that can be used when training the model.
    
    Input:
        - data_file: List of 2 numpy arrays which contain the patches of image and groundtruth
        - batch_size: Size of the batches that the generator will provide.
        - augment_flip: if True and augment is True, then the data will be randomly flipped along the x, y and z axis
        - augment: If True, training data will be distorted on the fly so as to avoid over-fitting.

    Output:
        Data generator, number of steps
    """
    index_list = list(range(data_file[0].shape[0]))
    _generator = data_generator(data_file, index_list=index_list, batch_size=batch_size,
                                        augment=augment, augment_flip=augment_flip)
    num_steps = len(index_list)//batch_size
    return _generator, num_steps


def data_generator(data_file, index_list, batch_size=1, augment=False, augment_flip=True):
    while True:
        x_list = list()
        y_list = list()
        shuffle(index_list)
        for index in index_list:
            add_data(x_list, y_list, data_file, index, augment=augment, augment_flip=augment_flip)
            if len(x_list) == batch_size:
                yield convert_data(x_list, y_list, batch_size)
                x_list = list()
                y_list = list()


def convert_data(x_list, y_list, batch_size):
    x = np.asarray(x_list)
    y = np.asarray(y_list)
    y[y > 0] = 1
    
    if len(x.shape) != len(y.shape):
        sys.exit('convert data')
    return x, y               
                
                
def add_data(x_list, y_list, data_file, index, augment=False, augment_flip=True):
    data = data_file[0][index]
    truth = data_file[1][index, 0, :, :, :]
    
    if augment:
        data, truth = augment_data(data, truth, flip=augment_flip)
        
    truth = truth[np.newaxis]

    x_list.append(data)
    y_list.append(truth)


def flip_image(image, axis):
    new_data = image
    for axis_index in axis:
        new_data = np.flip(new_data, axis=axis_index)
    return new_data


def random_flip_dimensions(n_dimensions):
    axis = list()
    for dim in range(n_dimensions):
        if random_boolean():
            axis.append(dim)
    return axis


def random_boolean():
    return np.random.choice([True, False])


def augment_data(data, truth, flip=True):
    n_dim = len(truth.shape)

    if flip:
        flip_axis = random_flip_dimensions(n_dim)
    else:
        flip_axis = None

    data_list = list()
    for data_index in range(data.shape[0]):
        data_list.append(flip_image(data[data_index], flip_axis))
        
    data = np.asarray(data_list)
    
    truth_data = flip_image(truth, flip_axis)
    return data, truth_data
