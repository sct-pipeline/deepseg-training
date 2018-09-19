# deepseg-training
Pipeline for training new models with sct_deepseg_lesion

- [Pre-processing](#pre-processing)
- [Re-training](#re-training)
- [Contributors](#contributors)
- [License](#license)

`sct_deepseg_lesion` is a deep learning based function that segments lesions automatically without human interventions. For more information please see the [article](https://arxiv.org/pdf/1805.06349.pdf). The model distributed with SCT v3.2.4 was trained on datasets from Healthy controls (459), Patients with MS or susupected MS (471), Cervical Myelopathy (55), Neuromyelitis optica (19), SCI (4), Amyotrophic lateral sclerosis (32) and syringomyelia (2). This model has been shown to work well with many different datasets.

When we test this model on SCI patients data, the model performs poorly mainly due to variance in the data and also, the initial model was trained with only 4 datasets of SCI patients. Therefore, the model needs to be retrained with the additional datasets when available. This repository explains how to retrain the model and improve the segmentation process on your dataset, for example from different pathologies which the initial model has not seen.

To get start, you need to have data that consists of input image and its corresponding ground truth masks. If you have ROI from [JIM](http://www.xinapse.com/j-im-7-software/), it is suggested to convert them to Nifti binary masks either using the [MATLAB script](https://github.com/sct-pipeline/deepseg-training/blob/master/Scripts/Creating_MASKS_from_ROI_JIM.m) or write your own script.

Example of Input image and its mask:

**Input Image:**

![Input Image](https://github.com/sct-pipeline/deepseg-training/blob/master/Figures/Input01.png)

**And its corresponding mask:**

![And its corresponding mask](https://github.com/sct-pipeline/deepseg-training/blob/master/Figures/Mask01.png)

**Then the data needs to be preprocessed.**

## Pre-processing

It is believed that instead of trying to find the lesion in the whole image, narrowing our search area within the spinal cord (SC) will improve the detection of lesion. To do that, in simple words, first we need to detect the spinal cord from input image using SC detection algorithm and crop the input image around SC then using lesion segmentation algorithm segment the lesion.

So, we need 1) SC detection model 2) cropping the image around SC 3) Lesion segmentation model.

This is explained in the paper Gros et al, 2018 (https://arxiv.org/pdf/1805.06349.pdf).

The step-by-step procedure is described in [Preprocessing_script.ipynb](https://github.com/sct-pipeline/deepseg-training/blob/master/Scripts/Preprocessing_script.ipynb).

**Overall process can be visualized in the below figure.**

![Preprocess01](https://github.com/sct-pipeline/deepseg-training/blob/master/Figures/Preprocess01.png)

The following bullet points would help to understand. First as it is mentioned before, we need to narrow our search area for lesion within spinal cord. So, for that we need to find spinal cord by doing one of these options:
- `sct_get_centerline`: coarse centerline detection based on SVM. For more details see [Gros et al. MIA 2017](https://www.sciencedirect.com/science/article/pii/S136184151730186X).
- `sct_propseg` or `sct_deepseg_sc` (to segment the spinal cord) followed by `sct_process_segmentation -p centerline` (to compute the center of mass of the segmentation). This approach produces more accurate centerlines than the previous approach.

![centerline](https://github.com/sct-pipeline/deepseg-training/blob/master/Figures/Centerline001.png)

Since, the orientation of the images could vary across datasets/centers, we need to systematically set the orientation of the input image, mask and centerline mask to Right-Left, Posterior-Anterior, Inferior-Superior (RPI):

~~~
sct_image -i IMAGE -set-orient RPI
~~~

Then, resolution should be set to 0.5mm isotropic for all images, masks and centerline:
~~~
sct_resample -i IMAGE -mm 0.5x0.5x0.5
~~~

Next step consists in cropping the resampled image and mask around the resampled spinal cord centerline.

**Cropped Input image**

![Crop_input01](https://github.com/sct-pipeline/deepseg-training/blob/master/Figures/Cropped_NII01.png)

**Cropped Mask image**

![Crop_mask01](https://github.com/sct-pipeline/deepseg-training/blob/master/Figures/Cropped_Mask01.png)

**NOTE:** Sometimes the cropping of resampled image gives out null voxels and this can be resolved by changing the resampling strategy as explained in this issue: (https://github.com/neuropoly/spinalcordtoolbox/issues/2003#issuecomment-418499887)

Later we standardize the intensities of the cropped image such that similar intensities will have similar tissue meaning.

The pre-processed data needs to organized in as shown below:

~~~
Sub001/Cont01/Cont01.nii.gz
Sub001/Cont02/Cont02.nii.gz
Sub002/Cont01/Cont01.nii.gz
Sub002/Cont02/Cont02.nii.gz
.
.
.
.
Sub00N/Cont0N/Cont0N.nii.gz
Sub00N/Cont0N/Cont0N.nii.gz
~~~

Then a dictionary or Panda dataframe, saved as pickle file should be created in order to use the following re-training pipeline.

## Re-training
Files that are necessary for re-training are:
- [config_file.py](https://github.com/sct-pipeline/deepseg-training/blob/master/Scripts/config_file.py): Global parameters. They need to be changed according to the need.
- [generator.py](https://github.com/sct-pipeline/deepseg-training/blob/master/Scripts/generator.py): Define data augmentation (e.g., flipping, distorting).
- [utils.py](https://github.com/sct-pipeline/deepseg-training/blob/master/Scripts/utils.py): Collection of functions that are called in the main script. E.g.: extracting 3D patches.
- [Main_file.ipynb](https://github.com/sct-pipeline/deepseg-training/blob/master/Scripts/Main_file.ipynb): Notebook to re-train the network with new data-set. The last cell of this file needs to be changes according to the need and to explore different networks.

If you are located at NeuroPoly lab, please consult the documentation on how to train on our local GPU cluster.


## Contributors
This project exists thanks to all the people who contributed (https://github.com/sct-pipeline/deepseg-training/graphs/contributors).


## License

The MIT License (MIT)

Copyright (c) 2018 École Polytechnique, Université de Montréal

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
