% File: Preview.m @ Preprocessor
% Author: Urs Hofmann
% Mail: hofmannu@ethz.ch
% Date: 20.10.2020

function Preview(pp)

	% generate 

	fig = uifigure('Name', 'Volumetric Preview', 'Position', [100, 100, 1000, 1000]);


	% slice along xy pllabe
	ax{1} = uiaxes(fig, ...
		'Position', [100, 500, 400, 400], ...
		'XLim', [pp.preprocVol.vecX(1), pp.preprocVol.vecX(end)] * 1e3, ...
		'YLim', [pp.preprocVol.vecY(1), pp.preprocVol.vecY(end)] * 1e3);
	ax{1}.Title.String = 'XY section';
	ax{1}.XLabel.String = 'x [mm]';
	ax{1}.YLabel.String = 'y [mm]';
	ax{1}.Colormap = redblue(1024);
	ax{1}.DataAspectRatio = [1, 1, 1];
	slices{1} = imagesc(ax{1}, ...
		pp.preprocVol.vecX * 1e3, pp.preprocVol.vecY * 1e3, ...
		squeeze(pp.preprocVol.vol(1, :, :))');

	% slice along xz plane
	ax{2} = uiaxes(fig, ...
		'Position', [100, 100, 400, 400], ...
		'XLim', [pp.preprocVol.vecX(1), pp.preprocVol.vecX(end)] * 1e3, ...
		'YLim', [pp.preprocVol.vecZ(1), pp.preprocVol.vecZ(end)] * 1e6);
	ax{2}.Title.String = 'XT section';
	ax{2}.XLabel.String = 'x [mm]';
	ax{2}.YLabel.String = 't [micros]';
	ax{2}.Colormap = redblue(1024);
	slices{2} = imagesc(ax{2}, ...
		pp.preprocVol.vecX * 1e3, pp.preprocVol.vecZ * 1e6, ...
		squeeze(pp.preprocVol.vol(:, :, 1)));

	ax{3} = uiaxes(fig, ...
		'Position', [500, 500, 400, 400], ...
		'XLim', [pp.preprocVol.vecY(1), pp.preprocVol.vecY(end)] * 1e3, ...
		'YLim', [pp.preprocVol.vecZ(1), pp.preprocVol.vecZ(end)] * 1e6);
	ax{3}.Title.String = 'YT section';
	ax{3}.XLabel.String = 'y [mm]';
	ax{3}.YLabel.String = 't [micros]';
	ax{3}.Colormap = redblue(1024);
	slices{3} = imagesc(ax{3}, ...
		pp.preprocVol.vecY * 1e3, pp.preprocVol.vecZ * 1e6, ...
		squeeze(pp.preprocVol.vol(:, 1, :)));

	function updateTSlide(sldT, slices)
		% update slice
		sliceXY = squeeze(pp.preprocVol.vol(round(sldT.Value), :, :))';
		set(slices{1}, 'CData', sliceXY);
		% update colorbar limits
		maxAbs = max(abs(sliceXY(:)));
		ax{1}.CLim = [-maxAbs, maxAbs] * 0.4;
		drawnow();
	end

	function updateYSlide(sldY, slices)
		sliceXZ = squeeze(pp.preprocVol.vol(:, :, round(sldY.Value)));
		set(slices{2}, 'CData', sliceXZ);
		% update colorbar limits
		maxAbs = max(abs(sliceXZ(:)));
		ax{2}.CLim = [-maxAbs, maxAbs] * 0.4;
		drawnow();
	end

	function updateXSlide(sldX, slices)
		sliceYZ = squeeze(pp.preprocVol.vol(:, round(sldX.Value), :));
		set(slices{3}, 'CData', sliceYZ);
		% update colorbar sliceYZ
		maxAbs = max(abs(sliceYZ(:)));
		ax{3}.CLim = [-maxAbs, maxAbs] * 0.4;
		drawnow();
	end


	% generate a panel to get position sliders
	pnl = uipanel(fig, ...
		'OuterPosition', ...
		[500, 100, 400, 400], 'Units', 'pixels');
	
	sldT = uislider(pnl, ...
		'Position',[50 50 150 3], ...
		'Limits', [1, pp.preprocVol.nZ], ...
		'Value', round(mean([1, pp.preprocVol.nZ])), ...
		'ValueChangedFcn', @(sldT, event) updateTSlide(sldT, slices));

	sldX = uislider(pnl, ...
		'Position',[50 100 150 3], ...
		'Limits', [1, pp.preprocVol.nX], ...
		'Value', round(mean([1, pp.preprocVol.nX])), ...
		'ValueChangedFcn', @(sldX, event) updateXSlide(sldX, slices));

	sldY = uislider(pnl, ...
		'Position',[50 150 150 3], ...
		'Limits', [1, pp.preprocVol.nY], ...
		'Value', round(mean([1, pp.preprocVol.nY])), ...
		'ValueChangedFcn', @(sldY, event) updateYSlide(sldY, slices));
end