% File: conv2ScanSett.m
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 23.06.2020

function scanSettClass = conv2ScanSett(scanSett)

	scanSettClass = ScanSettings();

	scanSettClass.scanName = scanSett.scanName;
	scanSettClass.transducer = scanSett.transducer;
	scanSettClass.fiber = scanSett.fiber;
	scanSettClass.rawPath = scanSett.rawPath;
		
	% multiwavlength and PPE settings
	scanSettClass.PPE = scanSett.PPE;
	scanSettClass.wavelengths = scanSett.wavelengths;
	scanSettClass.laserPower = scanSett.laserPower;
		
	% scan geometry
	scanSettClass.ctr = scanSett.ctr;
	scanSettClass.width = scanSett.width;
	scanSettClass.dr = scanSett.dr;

	scanSettClass.nAverages = scanSett.nAverages;
	scanSettClass.nSamples = scanSett.nSamples;
	scanSettClass.samplingFreq = scanSett.samplingFreq;
	scanSettClass.temp = scanSett.temp;
	
	scanSettClass.sensitivityPd = scanSett.sensitivityPd;
	scanSettClass.sensitivityUs = scanSett.sensitivityUs;
	scanSettClass.delayDac = scanSett.delayDac;

	scanSettClass.maxPRF = scanSett.maxPRF;

	scanSettClass.pdCrop = scanSett.pdCrop;
	scanSettClass.usCrop = scanSett.usCrop;

end