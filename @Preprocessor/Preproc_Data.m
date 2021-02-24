% File: Preproc_Data.m @ Preprocessor
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 14-Feb-2020

% Description: Performs preprocessing of raw datasets.

function Preproc_Data(pp)

	% get information out of pd measurements
	if pp.preprocSett.flagAnalyzePd
		pp.pdproc.Analyze_Pd(single(pp.RawDataPd));
		t0 = pp.pdproc.Get_Time_Offset(pp.preprocSett.usCrop(1), pp.preprocSett.pdCrop(1), ...
			pp.scanSett.dt);
	end
	% pp.RawDataPd = []; % empty raw data array to save memory 
 
	% correct for pd fluctuations etc
	if pp.preprocSett.flagPdComp
		vol = pp.pdproc.Correct_Matrix(single(pp.RawDataUs));
	else
		vol = single(pp.RawDataUs);
	end
	% pp.RawDataUs = []; % empty raw data array to save memory

	if pp.preprocSett.flagPdShift
		vol = pp.pdproc.Correct_Laser_Jitter(vol);
	end
	
	if pp.preprocSett.flagPdMissingShots
		vol = pp.pdproc.Replace_Missing_Shots(vol);
	end

	% flip every second line due to scan pattern
	% structure of array here: iT, iAv, iX, iY
	vol(:, :, :, 2:2:end) = flip(vol(:, :, :, 2:2:end), 3);

	sizeOld = size(vol);

	% remove dc offset of each b scan
	dcOffset = mean(vol, 1);
	meanVol = repmat(dcOffset, [sizeOld(1), 1, 1, 1]);
	vol = vol - meanVol;

	% store size of volume before reshaping madness
	flatArray = vol(:);

	% frequency domain filtering
	if pp.preprocSett.flagFreqFilt
		pp.VPrintf('Bandpass frequency filtering... ', 1);
		[b, a] = butter(1, pp.preprocSett.filterFreq / ...
			(double(pp.scanSett.samplingFreq) / 2), 'bandpass');
		
		if (any(~isfinite(vol(:))))
			nNF = sum(~isfinite(vol(:))) / length(vol(:));
			warning(['filteredData contains ', num2str(nNF), ...
				' percent non finite elements, setting them to 0']);
			vol(~isfinite(vol)) = 0;
		end

		vol = vol - mean(vol(:));
		
		% perform frequency domain filtering using filtfilt
		% very memory intense, therefore, check if it fits, if not, split up
		SIZE_PERLENGTH = 8 * 8; % size in byte per array length in elements
		MAXMEM = getMemory(); % get available memory in byte
		safetyLimit = 0.9;
		nVoxel = length(vol(:));
		if (((MAXMEM / SIZE_PERLENGTH) * safetyLimit) < nVoxel)

			maxLength = round((MAXMEM / SIZE_PERLENGTH) * safetyLimit); % max length per snippet
			
			% make sure maxLength is dividable by nZ to not cut arrays in center
			nPerSnippet = floor(maxLength / sizeOld(1));
			maxLength = nPerSnippet * sizeOld(1);
			
			startIdx = 1;
			% run through snippets
			while(startIdx < (nVoxel - maxLength))
				range = startIdx:(startIdx + maxLength);
				flatArray(range) = single(filtfilt(b, a, double(flatArray(range))));
				startIdx = startIdx + maxLength;
			end
			flatArray(startIdx:end) = ...
				single(filtfilt(b, a, double(flatArray(startIdx:end))));
		else % fits in memory, run through in one go
			flatArray = single(filtfilt(b, a, double(flatArray)));
		end
		pp.VPrintf('done!\n', 0);
	end
		
	vol = reshape(flatArray, sizeOld); % bring output volume into correct shape
	vol = mean(vol, 2); % perform averaging along second dimension
	vol = reshape(vol, [sizeOld(1), sizeOld(3), sizeOld(4)]);

	% convert volume originally measured in index into voltage in mV
	pp.preprocVol.vol = vol / single(intmax('int16')) * pp.scanSett.sensitivityUs;

	% median filter 
	if (pp.preprocSett.flagMedianFilter)
		if any(pp.preprocSett.medianFilter > 1)
			pp.VPrintf('Median filtering dataset... ', 1);
			pp.preprocVol.vol = medfilt3(pp.preprocVol.vol, pp.preprocSett.medianFilter);
			pp.VPrintf('done!\n', 0);
		else
			pp.VPrintf('Kernel size is 1, no median filtering.\n', 1);
		end
	else
		pp.VPrintf('Median filtering disabled.\n', 1);
	end

	pp.preprocVol.dr = [1 / double(pp.scanSett.samplingFreq), pp.scanSett.dr(1) * 1e-3, ...
		pp.scanSett.dr(2) * 1e-3]; % [t, x, y]
	pp.preprocVol.origin = [t0, 0, 0]; % [t, x, y]
	pp.preprocVol.name = pp.scanSett.scanName;
	
end
