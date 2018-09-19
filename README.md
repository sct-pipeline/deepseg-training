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

It is believed that instead of trying to find the lesion in the whole image, narrowing our search area within the spinal cord (SC) will improve the detection of lesion. To do that, in simple words, first we need to detect the spinal cord from input image using SC detection algorithm and crop the input image around SC then using lesion segmentation algorithm segment the lesion.

So, we need 1) SC detection model 2) cropping the image around SC 3) Lesion segmentation model.

This is explained in the paper Gros et al, 2018 (https://arxiv.org/pdf/1805.06349.pdf).

**Overall process can be visualized in the below figure.**

![Preprocess01](https://github.com/sct-pipeline/deepseg-training/blob/master/Figures/Preprocess01.png)


The following bullet points would help to understand. First as it is mentioned before, we need to narrow our search area for lesion within spinal cord. So, for that we need to find spinal cord by selecting one of these 3 options:
 (i) sct_get_centerline 
 (ii) sct_deepseg_sc then sct_process_segmentation -p centerline -- here it uses deep learning algorithm to find the spinal cord and then we get the 
 (iii) sct_propseg then sct_process_segmentation -p centerline
     
Note that all three would detect the centerline of the spinal cord. If one algorithm fails use the one that suits you.    
     
Since, the orientation of the images could be different for different datasets fom different centres, we need to have data that has same orientation. Therefore, we set the orientation of the input image and centerline mask to RPI 
example: sct_image -set-orient RPI

Later, in order to have same resolution across different datasets, we choose the 0.5mm isotropic resolution to the input image & its corresponding mask and the centerline mask 
example: sct_resample -mm 0.5x0.5x0.5   

Once we have input image and the centerline mask with the istropic resolution of 0.5, as mentioned before we crop the input image and its corresponding mask around the spinal cord centerline.

**Cropped Input image**

![Crop_input01](https://github.com/sct-pipeline/deepseg-training/blob/master/Figures/Cropped_NII01.png)


**Cropped Mask image**

![Crop_mask01](https://github.com/sct-pipeline/deepseg-training/blob/master/Figures/Cropped_Mask01.png)


Later we standardize the intensities of the cropped image such that similar intensities will have similar tissue meaning.

The pre-processed data then needs to be used for retraining.

**Re-trianing:**





1) First, create a pickle data-frame using the script "save_as_pickle.py""
2) Change the "config_file.py" based on the data directory
3) Run "train_lesion.ipynb" and change the last cell to try different networks.

# 3 running in Rosenberg

nvidia-smi
CUDA_VISIBLE_DEVICES=0 python 
