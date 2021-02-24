% File: test_surface_detection.m
% Author: Urs Hofmann
% Mail: hofmannu@ethz.ch
% Date: 26.12.2020

% Description: small script to test our surface detection algorithm

close all; clear all; % for debugging

rawpath = '/mnt/hofmannu/elements/aroam/06_HumanSkin/20201014_newTransducerSkinScans/037_urs_palm_532_raw.mat';
rawpath = '/mnt/hofmannu/elements/aroam/009_wristUrs_532_raw.mat'

P = Preprocessor();
P.preprocSett.usCrop = [1000, 1800];
P.preprocSett.pdCrop = [1, 500];
P.filePath = rawpath;

% detect skin surface
P.Detect_Surface();

% preprocess data properly and save everthing
P.Load_Raw_Data();
P.preprocSett.filterFreq = [10e6, 120e6];
P.Preproc_Data(); 

% pseudo shift dataset in time domain
[nT, nX, nY] = size(P.preprocVol.vol);
temp = reshape(P.preprocVol.vol, [nT, nX * nY]);
shiftVec = round(P.surfFit - P.surfMeasured);
shiftVec = reshape(shiftVec, [1, nX * nY]);
for (iAScan = 1:(nX * nY))
	temp(:, iAScan) = circshift(temp(:, iAScan), shiftVec(iAScan));
end
P.preprocVol.vol = reshape(temp, [nT, nX, nY]);

% save preprocessed data to reconstruct
P.Save_Preproc_Data('preprocPath', '/home/hofmannu/TempData/skinPreproc.mat');
