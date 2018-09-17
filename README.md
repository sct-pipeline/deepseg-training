# deepseg-training
Pipeline for training new models with sct_deepseg_lesion

Here it is assumed to have Input image and its corresponding ground truth masks. If you have ROI from JIM, it is suggested to convert them to mask either using the MATLAB script or write your own script.

Example of Input image and its mask:


Input Image:
![Input Image](https://github.com/sct-pipeline/deepseg-training/blob/master/Figures/Example_Input_image.png)



And its corresponding mask:
![And its corresponding mask](https://github.com/sct-pipeline/deepseg-training/blob/master/Figures/Example_Mask_image.png)




# 1) Pre-processing:

1) If you have ROI from JIM, use the MATLAB script (not generalized yet) to create the mask i.e. ground truth label
2) Once you have the original input image and its corresponding manually segmented mask, follow the below steps for pre-processing: (Look at Preprocessing_script.ipynb for example code)
  
    a) Compute the centerline (i.e. center of the spinal cord, 1 voxel per axial slice): from one of these 3 options 
      (i) sct_get_centerline 
      (ii) sct_deepseg_sc then sct_process_segmentation -p centerline 
      (iii) sct_propseg then sct_process_segmentation -p centerline
      
    b)Set RPI orientation to both the input image and the centerline mask via sct_image -set-orient RPI
    
    c)Set 0.5mm isotropic resolution to both the input image and the centerline mask via sct_resample -mm 0.5x0.5x0.5 or via          https://github.com/neuropoly/spinalcordtoolbox/blob/master/scripts/sct_deepseg_lesion.py#L520

    d) Crop the image around the spinal cord centerline. You can use:                     https://github.com/neuropoly/spinalcordtoolbox/blob/master/scripts/sct_deepseg_lesion.py#L165

    e) Standardize the intensities of the cropped image, via Nyul method, as done here:                https://github.com/neuropoly/spinalcordtoolbox/blob/master/scripts/sct_deepseg_lesion.py#L136


# 2) Re-trianing:

1) First, create a pickle data-frame using the script "save_as_pickle.py""
2) Change the "config_file.py" based on the data directory
3) Run "train_lesion.ipynb" and change the last cell to try different networks.

# 3 running in Rosenberg

nvidia-smi
CUDA_VISIBLE_DEVICES=0 python 
