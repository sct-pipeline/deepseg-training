# deepseg-training
Pipeline for training new models with sct_deepseg_lesion

SCT_DEEPSEG_LESION is deep learning model that segments lesion automatically without human interventions. Please have a look at the paper associated with deepseg_lesion model (https://arxiv.org/pdf/1805.06349.pdf). It has been trained on datasets from Healthy controls (459), Patients with MS or susupected MS (471), Cervical Myelopathy (55), Neuromyelitis optica (19), SCI (4), Amyotrophic lateral sclerosis (32) and syringomyelia (2). This model has been shown to work well with many different datasets.

When we test this model on SCI patients data, the model performs poorly mainly due to variance in the data and also, the initial model was trained with only 4 datasets of SCI patients. Therefore, the model needs to be retrained with the additional datasets when available. This repository explains, how to retrain the model and improve the segmentation process on your dataset, for example from different pathology which the initial model has not seen.

To start with, you need to have data that consists of input image and its corresponding ground truth masks. If you have ROI from JIM, it is suggested to convert them to mask either using the MATLAB script or write your own script.

Example of Input image and its mask:

**Input Image:**

![Input Image](https://github.com/sct-pipeline/deepseg-training/blob/master/Figures/Example_Input_image.png)



**And its corresponding mask:**

![And its corresponding mask](https://github.com/sct-pipeline/deepseg-training/blob/master/Figures/Example_Mask_image.png)




**Then the data needs to be preprocessed.**
# Pre-processing:

It is believed that instead of trying to find the lesion in the whole image, narrowing our search area within the spinal cord (SC) will improve the detection of lesion. To do that, in simple words, first we need to detect the spinal cord from input image using SC detection algorithm and crop the input image around SC then using lesion segmentation algorithm segment the lesion.

So, we need 1) SC detection model 2) cropping the image around SC 3) Lesion segmentation model.

This is explained in the paper Gros et al, 2018 (https://arxiv.org/pdf/1805.06349.pdf).

**Overall process can be visualized in the below figure.**

![Preprocess01](https://github.com/sct-pipeline/deepseg-training/blob/master/Figures/Preprocess01.png)


The following bullet points would help to understand. First as it is mentioned before, we need to narrow our search area for lesion within spinal cord. So, for that we need to find spinal cord by selecting one of these 3 options:
 (i) sct_get_centerline 
 (ii) sct_deepseg_sc then sct_process_segmentation -p centerline -- here it uses deep learning algorithm to find the spinal cord and then we get the 
 (iii) sct_propseg then sct_process_segmentation -p centerline
     
Note that all three would detect the centerline of the spinal cord. If one algorithm fails use the one that suits you. Example centerline image:

![centerline](https://github.com/sct-pipeline/deepseg-training/blob/master/Figures/Centerline001.png)

     
Since, the orientation of the images could be different for different datasets fom different centres, we need to have data that has same orientation. Therefore, we set the orientation of the input image and centerline mask to RPI 
example: sct_image -set-orient RPI

Later, in order to have same resolution across different datasets, we choose the 0.5mm isotropic resolution to the input image & its corresponding mask and the centerline mask 
example: sct_resample -mm 0.5x0.5x0.5   

Example resampled image:
![resampled001](https://github.com/sct-pipeline/deepseg-training/blob/master/Figures/Resampled_inputNII01.png)



Once we have input image and the centerline mask with the istropic resolution of 0.5, as mentioned before we crop the input image and its corresponding mask around the spinal cord centerline.

**Cropped Input image**

![Crop_input01](https://github.com/sct-pipeline/deepseg-training/blob/master/Figures/Cropped_NII01.png)


**Cropped Mask image**

![Crop_mask01](https://github.com/sct-pipeline/deepseg-training/blob/master/Figures/Cropped_Mask01.png)


Later we standardize the intensities of the cropped image such that similar intensities will have similar tissue meaning.

The pre-processed data then needs to be used for retraining.

# Re-trianing:**





1) First, create a pickle data-frame using the script "save_as_pickle.py""
2) Change the "config_file.py" based on the data directory
3) Run "train_lesion.ipynb" and change the last cell to try different networks.





# Running in Rosenberg -- NOTE: Specific to Ecole polytechnique Montreal **

Procedure for connecting to GPU cluster, copying and running scripts:

1) ACCESS:
To access GPU cluster, type :
**ssh USERNAME@rosenberg.neuro.polymtl.ca** in the local terminal
And its associated password

2) COPYING FILES:
Once you access the cluster, it is advised to create a folder to copy your scripts, data etc from local computer to GPU cluster server: **mkdir folder_name**

Now to copy files from local computer to GPU station, first open another local terminal and copy the files using the command
**scp path_src USERNAME@rosenberg.neuro.polymtl.ca:PATH_DESTINATION**

3) RUNNING SCRIPTS and BOOKING GPU SLOT
Once you have the files and scripts that you need in the GPU station, it is time to run them.

At rosenberg terminal:
a)Before running the script, it is advised to create a virtual environment so that you could install the modules that you need in this virtual environment and does not interfere with other libraries. So, to create virtual environment:
**python2 -m virtualenv env** --- here env is the name of virtual environment which can named according to your wish.
Once the virtual environment, it needs to be activated using this command:**source env/bin/activate**
b) Now install the modules that you need to run your script inside the virtual environment using pip install…
c) Check the running GPUs and available GPUs using this command: **nvidia-smi**
d) Then if you want to book specific GPU, then first go to Google calendar (which you need to get access from Alex or Julien) and book the slot.
e) Then run this command: 
**CUDA_VISIBLE_DEVICES=0 jupyter notebook --no-browser --port=8899**
For example, in the above command, GPU =0 has been selected. And the port =8899 has been selected. If the port 8899 is not available then it suggests to use another port. The reason for selecting the port will be explained in the next point.
f) At local terminal: type the command: 
**ssh -N -f -L localhost:8899:localhost:8899 USERNAME@rosenberg.neuro.polymtl.ca**
Here, look at the port number, it is same as the one selected before.
The main idea here is, you are opening the tunnel between local computer and the GPU cluster so that your local computer can communicate with the GPU cluster and also can visualize the folders of GPU cluster in your local computer browser.
g) Now open the script and run them.
