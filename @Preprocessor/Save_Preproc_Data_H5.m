% File: Save_Preproc_Data_H5.m
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 04.08.2020

% Description: Saves the preprocessed data in h5 file version readable by C

% optional input arguments
% 		outputPath - path where we should store the dataset
% 		flagOverwrite - if file already exists should we overwrite


function Save_Preproc_Data_H5(pp, varargin)

	outputPath = pp.preprocPathH5;
	flagOverwrite = 1;

	for iargin = 1:2:(nargin - 1)
		switch varargin{iargin}
			case 'filePath'
				outputPath = filePath;
			otherwise
				error('Invalid argument passed to function');
		end
	end

	% check if file already exists
	if isfile(outputPath) && ~flagOverwrite
		warning('Output file already exists, not gonna overwrite');
	else
		h5create()
		h5write();
	end

end