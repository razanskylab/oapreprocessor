% File: Detect_Surface.m @ Preprocessor
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 26.12.2020

% Description: Detects the surface of the skin based on different methods and generates
% a z shift array

% Literature: 

function Detect_Surface(pp, varargin)

	% default argumemts
	SOS = pp.preprocSett.SOS;
	noiseFact = 1;
	kernelSize = [5, 5, 3]; % size for kernel used to segment surface area
	boundaries = [50, 5];
	
	% read in user defined settings
	for iargin = 1:2:(nargin - 1)
		switch varargin{iargin}
			case 'SOS'
				SOS = varargin{iargin + 1};
			otherwise
				error("Invalid argument passed to function");
		end
	end

	% Make sure to load raw data and preprocess with low pass filter
	oldFilterFreq =  pp.preprocSett.filterFreq;
	pp.preprocSett.filterFreq = [0.5e6, 25e6];
	pp.Load_Raw_Data();
	pp.Preproc_Data();
	pp.preprocSett.filterFreq = oldFilterFreq;

	[nT, nX, nY] = size(pp.preprocVol.vol);

	% generate hilbert transformation of volume
	pp.VPrintf('Calculating hilbert transform of dataset... ', 1);
	data = pp.preprocVol.vol;
	data = reshape(data, [nT, nX * nY]);
	data = abs(hilbert(data));
	data = reshape(data, [nT, nX, nY]);
	pp.VPrintf('done!\n', 0);

	% median fitler to generate segmentation mask {strong ifilter}
	dataFit = medfilt3(data, kernelSize);
	noiseVec = data(:);
	noiseLvl = std(noiseVec) * noiseFact

	% find stratum corneum region
	
	% [~, firstLight] = max(dataFit > noiseLvl, [], 1);
	[~, firstLight] = max(dataFit, [], 1);
	firstLight = reshape(firstLight, [nX, nY]);
	
	% generate smoothened surface
	pp.VPrintf('Generating B scan wise fit functions... ', 1);
	% gridX = repmat(pp.preprocVol.vecX', [1, nY]);
	% gridY = repmat(pp.preprocVol.vecY, [nX, 1]);
	% [sf, gof] = fit([double(gridX(:)), double(gridY(:))], double(firstLight(:)), ...
	% 	'poly55');
	% fitSurface = sf(gridX(:), gridY(:));
	% fitSurface = reshape(fitSurface, [nX, nY]);

	bscanFit = zeros(nX, nY);
	vecX = pp.preprocVol.vecX';
	for (iY = 1:nY)
		sf = fit(double(vecX), double(firstLight(:, iY)), 'poly2');
		bscanFit(:, iY) = sf(vecX);
	end
	pp.VPrintf('done!\n', 0);

	% set far away regions to 0
	gridX = repmat(pp.preprocVol.vecX', [1, nY]);
	gridY = repmat(pp.preprocVol.vecY, [nX, 1]);
	[sf, gof] = fit([double(gridX(:)), double(gridY(:))], double(bscanFit(:)), ...
		'poly55');
	fitSurface = sf(gridX(:), gridY(:));
	fitSurface = reshape(fitSurface, [nX, nY]);

	data = reshape(data, [nT, nX * nY]);
	fitSurface = reshape(fitSurface, [1, nX * nY]);
	for iAScan = 1:(nX * nY)
		idxStart = round(fitSurface(iAScan)) - boundaries(1);
		if (idxStart < 1)
			idxStart = 1;
		end
		if (idxStart > nT)
			idxStart = nT;
		end
		idxEnd = round(fitSurface(iAScan)) + boundaries(2);
		if (idxEnd < 1)
			idxEnd = 1;
		end
		if (idxEnd > nT)
			idxEnd = nT;
		end

		data(1:idxStart, iAScan) = 0;
		data(idxEnd:end, iAScan) = 0;
	end

	[~, firstLight] = max(data, [], 1);
	firstLight = reshape(firstLight, [nX, nY]);
	
	% generate smoothened surface
	pp.VPrintf('Generating B scan wise fit functions... ', 1);
	bscanFit = zeros(nX, nY);
	vecX = pp.preprocVol.vecX';
	for (iY = 1:nY)
		sf = fit(double(vecX), double(firstLight(:, iY)), 'poly2');
		bscanFit(:, iY) = sf(vecX);
	end
	pp.VPrintf('done!\n', 0);

	pp.VPrintf('Generating smoothed skin surface... ', 1);
	gridX = repmat(pp.preprocVol.vecX', [1, nY]);
	gridY = repmat(pp.preprocVol.vecY, [nX, 1]);
	[sf, gof] = fit([double(gridX(:)), double(gridY(:))], double(bscanFit(:)), ...
		'poly55');
	fitSurface = sf(gridX(:), gridY(:));
	fitSurface = reshape(fitSurface, [nX, nY]);
	pp.VPrintf('done!', 0);

	% convert delta between fit and firstLight into shift matrix
	pp.surfMeasured = bscanFit;
	pp.surfFit = fitSurface;
	pp.deltaZ = (fitSurface - bscanFit);
	pp.deltaZ = pp.deltaZ / pp.scanSett.samplingFreq;
	pp.deltaZ = pp.deltaZ * pp.preprocSett.SOS;

	% for now testwise shift volume
	% temp = reshape(pp.preprocVol.vol, [nT, nX * nY]);
	% shiftVec = round(fitSurface - firstLight);
	% shiftVec = reshape(shiftVec, [1, nX * nY]);
	% for (iAScan = 1:(nX * nY))
	% 	temp(:, iAScan) = circshift(temp(:, iAScan), shiftVec(iAScan));
	% end
	% pp.preprocVol.vol = reshape(temp, [nT, nX, nY]);

	if pp.flagDisplay()
		% generate random plot positiions along x and y
		randX = randi(nX);
		randY = randi(nY);

		% shift two planes to show effect
		pp.VPrintf('Run example shift... ', 1);
		% shiftedX = abs(squeeze(pp.preprocVol.vol(:, centerX, :)));
		shiftedX = abs(squeeze(pp.preprocVol.vol(:, :, randY)));
		shiftedX = reshape(shiftedX, [nT, nX]);
		shiftVec = round(fitSurface(:, randY) - bscanFit(:, randY));
		for (iX = 1:nX)
			shiftedX(:, iX) = circshift(shiftedX(:, iX), shiftVec(iX));
		end

		% shiftedY = abs(squeeze(pp.preprocVol.vol(:, :, randY)));
		shiftedY = abs(squeeze(pp.preprocVol.vol(:, randX, :)));
		shiftedY = reshape(shiftedY, [nT, nY]);
		shiftVec = round(fitSurface(randX, :) - bscanFit(randX, :));
		for (iY = 1:nY)
			shiftedY(:, iY) = circshift(shiftedY(:, iY), shiftVec(iY));
		end
		pp.VPrintf('done!\n', 0);

		figure();

		ax1 = subplot(2, 2, 1);
		sliceX = abs(squeeze(pp.preprocVol.vol(:, :, randY)));
		imagesc(sliceX);
		hold on
		plot(firstLight(:, randY), 'g-');
		plot(bscanFit(:, randY), 'r--');
		plot(bscanFit(:, randY) - boundaries(1), 'r:');
		plot(bscanFit(:, randY) + boundaries(2), 'r:');
		colormap(ax1, bone(1024));
		colorbar

		ax2 = subplot(2, 2, 2);
		sliceY = abs(squeeze(pp.preprocVol.vol(:, randX, :)));
		imagesc(sliceY);
		hold on
		plot(firstLight(randX, :), 'g-');
		plot(bscanFit(randX, :), 'r--');
		plot(bscanFit(randX, :) - boundaries(1), 'r:');
		plot(bscanFit(randX, :) + boundaries(2), 'r:');
		colormap(ax2, bone(1024));
		colorbar

		ax3 = subplot(2, 2, 3);
		imagesc(shiftedX);
		colormap(ax3, bone(1024))

		ax4 = subplot(2, 2, 4);
		imagesc(shiftedY)
		colormap(ax4, bone(1024))

		drawnow();
	end

end