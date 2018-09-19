
import pandas as pd
import os

#%%
PATH = 'DATA_FOLDER' #% Data should be organized in this way -->Sub001/Cont01/Cont01.nii.gz; Sub001/Cont02/Cont02.nii.gz

lst = os.listdir(PATH)
if '.DS_Store' in lst:
    lst.remove('.DS_Store')

n=len(lst)
a="t2"
contrast_lst=((((a)+'\n')*n)[:-1])
original_df = pd.DataFrame({"subject": lst, "contrast_foldname ": contrast_lst})
original_df.to_pickle("/subject_dict.pkl") #% Path to save the pickle file
