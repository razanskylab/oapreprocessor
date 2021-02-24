% File: Load_Raw_Data.m @ Preprocessor
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 13-Feb-2020

% Changelog:
%  adpat functions for averaging

function Load_Raw_Data(pp)
	

	
	pp.VPrintf('Loading raw data... ', 1);
	
	mFile = matfile(pp.filePath, 'Writable', false);

	% scan settings might either be in object oriented or struct approach
	scanSett = mFile.ScanSettings;
	switch class(scanSett)
		case 'struct'
			pp.scanSett = conv2ScanSett(scanSett);
		case 'ScanSettings'
			 pp.scanSett = scanSett;
		otherwise
			error('ScanSettings comes in invalid data format');
	end

	% check if cropping was applied at all
	nPd = pp.scanSett.pdCrop(2) - pp.scanSett.pdCrop(1) + 1;
	nUs = pp.scanSett.usCrop(2) - pp.scanSett.usCrop(1) + 1;
	sizeUs = size(mFile, 'RawDataUs');
	sizePd = size(mFile, 'RawDataPd');
	
	% before doing anything else check for dimensionality of datasets
	if (length(sizeUs) ~= 4)
		error('Ultrasound dataset has wrong dimensionality');
	end
	if (length(sizePd) ~= 4)
		error('Photodiode dataset has wrong dimensionality');
	end
	
	% this means that cropping was applied correctly during scan
	if ((nPd == sizePd(4)) && (nUs == sizeUs(4)))
		% nothing to do in this case
	elseif ((pp.scanSett.nSamples == sizePd(4)) && (pp.scanSett.nSamples == sizeUs(4)))
		% this means that there is actually no cropping applied during the scan
		pp.scanSett.pdCrop = [1, pp.scanSett.nSamples];
		pp.scanSett.usCrop = [1, pp.scanSett.nSamples];
	else
		error('Invalid matrix dimensions');
	end

	% check if cropping request here exceeds the cropping applied during scan
	if (pp.preprocSett.usCrop(1) < pp.scanSett.usCrop(1))
		warning('Lower cropping requested for ultrasound channel too low.');		
		pp.preprocSett.usCrop(1) = pp.scanSett.usCrop(1);
	end

	if (pp.preprocSett.usCrop(2) > pp.scanSett.usCrop(2))
		warning('Upper cropping requested for ultrasound channel too high');
		pp.preprocSett.usCrop(2) = pp.scanSett.usCrop(2);
	end

	if (pp.preprocSett.pdCrop(1) < pp.scanSett.pdCrop(1))
		warning('Lower cropping requested for photodiode channel too low');
		pp.preprocSett.pdCrop(1) = pp.scanSett.pdCrop(1);
	end

	if (pp.preprocSett.pdCrop(2) > pp.scanSett.pdCrop(2))
		warning('Upper cropping requested for photodiode channel too high');
		pp.preprocSett.pdCrop(2) = pp.scanSett.pdCrop(2);
	end

	% calculate cropping index in z for both matrices
	usStartIdx = 1 + pp.preprocSett.usCrop(1) - pp.scanSett.usCrop(1);
	usStopIdx = 1 + pp.preprocSett.usCrop(2) - pp.scanSett.usCrop(1);
	pdStartIdx = 1 + pp.preprocSett.pdCrop(1) - pp.scanSett.pdCrop(1);
	pdStopIdx = 1 + pp.preprocSett.pdCrop(2) - pp.scanSett.pdCrop(1);

	pp.RawDataPd = mFile.RawDataPd(:, :, :, pdStartIdx:pdStopIdx);
	pp.RawDataPd = permute(pp.RawDataPd, [4, 3, 1, 2]);
	pp.RawDataUs = mFile.RawDataUs(:, :, :, usStartIdx:usStopIdx);
	pp.RawDataUs = permute(pp.RawDataUs, [4, 3, 1, 2]);
	pp.VPrintf('done!\n', 0);
end
