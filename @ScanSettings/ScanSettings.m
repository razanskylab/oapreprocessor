% File: ScanSettings.m @ ScanSettings
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 26.05.2020

% Description: Settings defined for ThorScan procedure

classdef ScanSettings < handle

	properties
		scanName(1, :) char = 'scanId';
		transducer(1, :) char = 'transducerName';
		fiber(1, :) char = 'fiberName';
		rawPath(1, :) char;
		
		% multiwavlength and PPE settings
		PPE(1, :) single; % per pulse energy [microJ]
		wavelengths(1, :) single;
		laserPower(1, :) single;
		
		% scan geometry
		ctr(1, 2) single = [25, 25]; % center point of scan field of view
		width(1, 2) single = [10,	5]; % size of scan window [mm]
		dr(1, 2) single = [0.02, 0.02]; % step size of scan in x and y [mm]

		vel(1, 2) single; % stage velocity in x and y [mm/s]
		mass(1, 2) single; % mass carried by stage [g]
		nAverages(1, 1) = 1; % number of averages at each position
		nSamples(1, 1) uint32 = 2048; % number of samples acquired
		samplingFreq(1, 1) single = 250e6;
		temp(1, 1) single = 23; % temperature of coupling medium [degC]
		
		% data acquisition card settings
		sensitivityPd(1, 1) = 5000; % sensitivity of DAC on photodiode channel
		sensitivityUs(1, 1) = 1000; % sensitivity of DAC on ultrasound channel
		delayDac(1, 1) = 0;

		maxPRF(1, 1) single; % maximum permitted prf [Hz]

		pdCrop(1, 2) = [1, 200]; % cropping applied to photodiode signal during scan
		usCrop(1, 2) = [500, 2048]; % cropping applied to ultrasound signal during scan

		flagReadSettings(1, 1) logical = 1;
		flagSaveData(1, 1) logical = 1;
		flagPdComp(1, 1) logical = 1;
	end

	properties(Dependent)
		dX(1, 1);
		dY(1, 1);
		dt(1, 1);
		nLambda(1, 1);
	end

	methods

		function nLambda = get.nLambda(ss)
			nLambda = length(ss.wavelengths);
		end

		function dt = get.dt(ss)
			dt = 1 / ss.samplingFreq;
		end

		function dX = get.dX(ss)
			dX = ss.dr(1);
		end

		function set.dX(ss, dX)
			ss.dr(1) = dX;
		end

		function dY = get.dY(ss)
			dY = ss.dr(2);
		end

		function set.dY(ss, dY)
			ss.dr(2) = dY;
		end
	end


end
