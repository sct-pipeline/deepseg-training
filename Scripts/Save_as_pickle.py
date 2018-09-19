
import pandas as pd
import os


#%%
PATH = '/Users/pruthvi_local/Desktop/Lesion_Segmentation/01_preprocess/07Data_organized/'

lst = os.listdir(PATH)
if '.DS_Store' in lst:
    lst.remove('.DS_Store')

n=len(lst)

a="t2"
contrast_lst=((((a)+'\n')*n)[:-1])

#original_df = pd.DataFrame({"subject": lst})


original_df = pd.DataFrame({"subject": lst, "contrast_foldname ": contrast_lst})

original_df

original_df.to_pickle("/Users/pruthvi_local/Desktop/Lesion_Segmentation/01_preprocess/subject_dict.pkl")