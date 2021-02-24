
filePath = '/mnt/hofmannu/elements/aroam/01_TransducerModelling/2020_01_13_broadIllumination/humanSkin/';
fileName = '298_pakmurs_532_raw.mat';
fullName = [filePath, fileName];

P = Preprocessor();
P.filePath = fullName;
P.Load_Raw_Data();

% define preprocessing settings
P.preprocSett.filterFreq = [5e6, 90e6];

P.Preproc_Data();% preprocess data
P.Preview(); % generate preview
P.Save_Preproc_Data(); % save preprocessed data to file
