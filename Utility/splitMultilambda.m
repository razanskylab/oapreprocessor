% File: splitMultilambda.m
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 22.04.2020

% Description: Takes a multilambda dataset and splits it up into separate wavelengths.

% Input arguments:
% 	path 						specifies the name of our input file
% 	forceOverwrite	flag which forces an overwrite of existing files 	

function splitMultilambda(varargin)

	% structure in multiwavelength dataset
	% it, ilambda, iaverage, ix, iy
	path = [];
	flagOverwrite = 0;

	for iargin = 1:2:(nargin-1)
		switch varargin{iargin}
			case 'path'
				path = varargin{iargin + 1};
			case 'flagOverwrite'
				flagOverwrite = varargin{iargin + 1};
			case 'filePath'
				error('filePath is an invalid option, did you mean path?');
			otherwise
				error('Invalid option passed to function');
	 	end
	end


	if isfile(path)
		mFile = matfile(path); % defines input file
		ScanSettings = mFile.sett;
		
		nRawDataUs = size(mFile, 'RawDataUs');
		if (length(nRawDataUs) ~= 5)
			error('Does not look like a multiwavelength dataset');
		end
		
		nRawDataPd = size(mFile, 'RawDataPd');
		if (length(nRawDataPd) ~= 5)
			error('Does not look like a multiwavelength dataset');
		end

		nLambda = length(ScanSettings.wavelengths);
		nTPd = nRawDataPd(1);
		nTUs = nRawDataUs(1);
		nAv = nRawDataUs(3);
		nX = nRawDataUs(4);
		nY = nRawDataUs(5);

		if (nLambda ~= nRawDataUs(2))
			error('Dimension mismatch between RawDataUs and nLambda');
		end

		if (nLambda ~= nRawDataPd(2))
			error('Dimension mismatch between RawDataPd and nLambda');
		end

		for iLambda = 1:nLambda
			fprintf('[splitMultilambda] Splitting wavelength %i of %i\n', iLambda, nLambda);
			ScanSettings = mFile.sett;
			if (nLambda ~= length(ScanSettings.PPE))
				warning('Dimension mismatch between PPE and nLambda');
				ScanSettings.PPE = ones(1, nLambda);
			end
			ScanSettings.wavelengths = ScanSettings.wavelengths(iLambda);
			ScanSettings.PPE = ScanSettings.PPE(iLambda);
			% generate output path name
			pathOutput = [path(1:end-7), num2str(ScanSettings.wavelengths), '_raw.mat'];
			
			% only generate output file if not already existing
			if (~isfile(pathOutput) | flagOverwrite)
				% Load, reshape and save RawDataPd
				RawDataPd = mFile.RawDataPd(:, iLambda, :, :, :);
				RawDataPd = reshape(RawDataPd, [nTPd, nAv, nX, nY]);
				RawDataPd = permute(RawDataPd, [3, 4, 2, 1]);
				
				save(pathOutput, 'RawDataPd', '-nocompression', '-v7.3');	
				clear RawDataPd;
				
				% Load, reshape and save RawDataUs
				RawDataUs = mFile.RawDataUs(:, iLambda, :, :, :);
				RawDataUs = reshape(RawDataUs, [nTUs, nAv, nX, nY]);
				RawDataUs = permute(RawDataUs, [3, 4, 2, 1]);
				save(pathOutput, 'RawDataUs', '-append');	
				clear RawDataUs;
			
				% save ScanSettings to output file	
				save(pathOutput, 'ScanSettings', '-append');
				clear ScanSettings;
			end
		end

	else
		error('Path is not pointing to a file');
	end

end
