% File: process_folder.m
% Author: Urs Hofmann
% Mail: hofmannu@ethz.ch
% Date: 27.01.2021

% Description: Batch processing of a full folder

function preprocess_folder(varargin)

	% default input arguments
	folderPath = pwd;

	for iargin = 1:2:nargin
		switch varargin{iargin}
			case 'filePath'
				folderPath = varargin{iargin + 1};
			otherwise
				error('Invalid argument passed to function');
		end
	end

	% find all files which contain the word raw
	fileNames = dir([folderPath, '/*_raw.mat']);

	for iFile = 1:length(fileNames)
		fprintf('Splitting wavelengths for %d... \n', iFile);
		currPath = [fileNames(iFile).folder, '/', fileNames(iFile).name];
		currFile = matfile(currPath);

		sizeUs = size(currFile, 'RawDataUs');

		if length(sizeUs) == 5 % if this is true we should run split multilambda first
			splitMultilambda('path', currPath)
		end
	end

	% run through all of them and if still multiwavelength format --> split
	fileNames = dir([folderPath, '/*_raw.mat']);
	for iFile = 1:length(fileNames)
		fprintf('Preprocessing wavelengths for %d... \n', iFile);
		currPath = [fileNames(iFile).folder, '/', fileNames(iFile).name];
		currFile = matfile(currPath);

		sizeUs = size(currFile, 'RawDataUs');

		if length(sizeUs) == 4 % if this is true we can safly preprocess single wavelength
			P = Preprocessor();
			P.filePath = currPath; % point class to the correct file
			P.Load_Raw_Data(); % load raw data from file
			P.Preproc_Data(); % preprocess raw data
			P.Save_Preproc_Data(); % save preprocessed raw data
			close all;
		end
	end


end