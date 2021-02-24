% File: ReconSettings.m @ ReconSettings
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 22-Jan-2020

% Description: Class used to represent the settings of model based
% reconstruction

classdef ReconSettings < handle

	properties
		flagDisplay(1, 1) logical = 1; % enable / disable visual output
		flagVerbose(1, 1) logical = 1; % enable / disable verbose output
		SOS(1, 1) single = 1490; % speed of sound in water [m/s]
		fSampling(1, 1) single = 250e6; % sampling frequency [Hz]
		rRes(1, 1) single = 1e-6; % radial resolution of model matrix
		downsampling(1, 3) uint32 = [1, 1, 1]; % downsampling applied to input vol

		% definition of output volume
		cropM(3, 2) single = [6e-3, 8.8e-3; 0e-3, 10e-3; 0e-3, 10e-3]; 
		res(1, 3) single = [5e-6, 5e-6, 5e-6];
		
		% LSQR settings
		nIter(1, 1) uint8 = 20; % number of iterations for model based reconstruction
	
		% Tikhonov regularization strength
		flagRegularization(1, 1) logical = 1;	
		lambda(1, 1) single = 0.5;
		regMethod = 'tv';

		% threshold applied to model matrix to determine start and stop index
		threshold(1, 1) single = 0.01;

		% number of elements used for transducer discretization
		nElements(1, 1) single = 100e3;

		% fluence compensation / inclusion into model matrix
		flagFluenceComp(1, 1) logical = 0;
		surfaceEstim(1, :) char = 'none';
		% options:
		%		none	no estimated surface, set surface depth to deepest z voxel
		%   const	estimate surface as constant depth layer
		% 	calc	calculate irregular surface depth depending on OA signal
		surfLvl(1, 1) single = 6.5e-3; % constant assumed surface level [m]
	end

	properties(Dependent = true)
		zCropM(1, 2); % output region we would like to reconstruct
		xCropM(1, 2);
		yCropM(1, 2);

		% vectors for reconstructed volume
		zRecon(1, :);
		yRecon(1, :);
		xRecon(1, :);
		
		% number of elements in reconstructed volume
		nZRecon(1, 1);
		nXRecon(1, 1);
		nYRecon(1, 1);
		dimRecon(1, 3); % number of elements in reconstructed matrix
	end

	methods

		% overwrite equality operator
		function isEqual = eq(objA, objB)
			% define equality as true, then compare different settings
			isEqual = 1;

			if (objA.SOS ~= objB.SOS)
				isEqual = 0;
			end

			if (objA.rRes ~= objB.rRes)
				isEqual = 0;
			end
			
			if any(objA.downsampling ~= objB.downsampling)
				isEqual = 0;
			end
			
			if any(objA.cropM(:) ~= objB.cropM(:))
				isEqual = 0;
			end

			if any(objA.res ~= objB.res)
				isEqual = 0;
			end

			if (objA.nIter ~= objB.nIter)
				isEqual = 0;
			end

			if (objA.flagRegularization ~= objB.flagRegularization)
				isEqual = 0;
			else % only compare regularization settings if true
				if objA.flagRegularization
					if (objA.lambda ~= objB.lambda)
						isEqual = 0;
					end

					if ~strcmp(objA.regMethod, objB.regMethod)
						isEqual = 0;
					end	
				end
			end

			if (objA.nElements ~= objB.nElements)
				isEqual = 0;
			end

			if (objA.threshold ~= objB.threshold)
				isEqual = 0;
			end	
			
			if (objA.flagFluenceComp ~= objB.flagFluenceComp)
				isEqual = 0;
			end

			if ~strcmp(objA.surfaceEstim, objB.surfaceEstim)
				isEqual = 0;
			else
				if strcmp(objA.surfaceEstim, 'const')
					if (objA.surfLvl ~= objB.surfLvl)
						isEqual = 0;
					end
				end
			end
			
		end

		function zCropM = get.zCropM(mbs)
			zCropM = squeeze(mbs.cropM(1, :));
		end
		
		function xCropM = get.xCropM(mbs)
			xCropM = squeeze(mbs.cropM(2, :));
		end
		
		function yCropM = get.yCropM(mbs)
			yCropM = squeeze(mbs.cropM(3, :));
		end

		function xRecon = get.xRecon(mbs)
			xRecon = mbs.cropM(2, 1):mbs.res(2):mbs.cropM(2, 2);
		end

		function yRecon = get.yRecon(mbs)
			yRecon = mbs.cropM(3, 1):mbs.res(3):mbs.cropM(3, 2);
		end

		function zRecon = get.zRecon(mbs)
			zRecon = mbs.cropM(1, 1):mbs.res(1):mbs.cropM(1, 2);
		end

		function nXRecon = get.nXRecon(mbs)
			nXRecon = length(mbs.xRecon);
		end

		function nYRecon = get.nYRecon(mbs)
			nYRecon = length(mbs.yRecon);
		end

		function nZRecon = get.nZRecon(mbs)
			nZRecon = length(mbs.zRecon);
		end

	end

end
