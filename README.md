# ARPreprocessor

MATLAB based preprocessing procedure to load and process datasets acquired with the AR microscopy system. All object oriented.

This class depends on two other repositories in the lib folder. Upon installation please run

```
git submodule init
git submodule update
```

to initialize the submodules.

## Basic usage

Even though there are many different options to configure, the lines below should get you started.

```MATLAB
P = Preprocessor(); % declare class for preprocessing
P.filePath = 'testThis.mat'; % point class to the correct file
P.Load_Raw_Data(); % load raw data from file
P.Preproc_Data(); % preprocess raw data
P.Save_Preproc_Data(); % save preprocessed raw data
```

## Basic functionalities included

*  correction for photodiode energy fluctuations
*  correction for laser jitter (temporal fluctuation)
*  frequency domain filtering
*  removing DC offset
*  median filtering

## Helper functions

*  `splitMultilambda` function used to convert multiwavelength datasets as coming from the data acquisition into single wavelength datasets
*  `process_folder` batch processing of an entire folder (including wavelength split if required)

## Frequently known issues

### Error while loading raw data due to wrong format

During scans performed with the acoustic resolution microscopy system, data is stored in a 5D format[it, iav, ilambda, ix, iy]`. The preprocessor class is written to only handle 4D formats for a single wavelength. If you try to run the class directly onto a 4D set, an error will occur. To convert the file into a usable format use the function `splitMultilambda`.
# oapreprocessor
