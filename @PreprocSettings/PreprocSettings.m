% File: PreprocSettings.m @ Preprocessor
% Author: Urs Hofmann
% Mail: hofmannu@ethz.ch
% Date: 17-Feb-2020

% Description: Preprocessing settings to clean up raw data before moving to
% reconstruction

classdef PreprocSettings < handle

	properties 
		filterFreq(1, 2) double = [1e6, 120e6]; % bandpass filter used [Hz]
		medianFilter(1, 3) uint16 = [1, 1, 1]; % median filter applied after processing
		usCrop(1, 2) = [500, 2000]; % cropping applied to ultrasound signal during loading
		pdCrop(1, 2) = [1, 1000]; % cropping applied to photodiode signal during loading
		SOS(1, 1) single = 1490; % speed of sound in water [m/s]
		flagPdComp(1, 1) logical = 1; % should we compensate for laser power fluct
		flagPdMissingShots(1, 1) logical = 1; % replace missing shots by interp
		flagPdShift(1, 1) logical = 1; % comp for fluctuations in laser timing
		flagFreqFilt(1, 1) logical = 1; % turn frequency domain filter on/off
		flagForcePreproc(1, 1) logical = 1; % forces reprocessing of data even if
		flagMedianFilter(1, 1) logical = 1; % disable or enable median filtering
		flagAnalyzePd(1, 1) logical = 1; % do we need to analyze pd
	end

	properties(Dependent)
		
	end

	methods

		% set and check validity of filterFreq vector
		function set.filterFreq(ps, filterFreq)
			if (length(filterFreq) ~= 2)
				error('Filter frequency needs to be a two-element vector');
			end
			if any(filterFreq < 2)
				error('Filter frequency cannot be lower then 0');
			end
			ps.filterFreq = double(filterFreq);
		end


	end
end
