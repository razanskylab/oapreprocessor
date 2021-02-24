% File: Preprocessor.m @ Preprocessor
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 13-Feb-2020

% Description: Class used to preprocess datasets acquired with the AR 
% microscope

classdef Preprocessor < handle

	properties
		flagVerbose(1, 1) logical = 1;
		flagDisplay(1, 1) logical = 1;
		scanSett(1, 1) ScanSettings; % settings of scan procedure	
		preprocSett(1, 1) PreprocSettings; % settings for preprocessing
		filePath(1, :) char; % path pointing to raw data file
		preprocVol(1, 1) VolumetricDataset;
		deltaZ(:, :) single = [];
		surfMeasured(:, :) single = [];
		surfFit(:,  :) single = [];
	end

	properties (SetAccess = private)
		pdproc(1, 1) PdProcessor;
		RawDataUs int16; % ultrasound raw data
		RawDataPd int16; % photodiode raw data
		tPoints single; % time points at which the individual datapoints were acquired
	end
	
	properties (Dependent)
		preprocPath(1, :) char; % path pointing to preproc mat file
		preprocPathH5(1, :) char; % path pointing to preproc h5 file
	end

	methods

		function preprocPath = get.preprocPath(pp)
			preprocPath = [pp.filePath(1:end-7), 'preproc.mat'];
		end

		function preprocPathH5 = get.preprocPathH5(pp)
			preprocPathH5 = [pp.filePath(1:end-7), 'preproc.h5'];
		end

		function set.filePath(pp, filePath)
			if (~isfile(filePath))
				error('Path you just defined is not pointing to a file.');
			else
				pp.filePath = filePath;
			end
		end

		VPrintf(pp, msg, flagName);
		Load_Raw_Data(pp); % loads raw data into workspace
		Save_Preproc_Data(pp, varargin); % save prepocessed data to file
		Load_Preproc_Data(pp); % load preprocessed data from file
		result = Comp_Preproc_Data(pp); % compare preprocessing settings
		% returns 1 if settings stayed the same
		Preproc_Data(pp); % performs actual preprocessing of datasets
		Save_Preproc_Data_H5(pp, varargin);
		Detect_Surface(pp, varargin);

		Preview(pp);

	end

end
