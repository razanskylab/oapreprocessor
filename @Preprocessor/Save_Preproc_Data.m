% File: Save_Preproc_Data.m @ Preprocessor
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 14-Jan-2020

% Changelog
% 		- added surface export and optional output path

function Save_Preproc_Data(pp, varargin)

	% default arguments
	preprocPath = pp.preprocPath;

	% read in user specific arguments
	for (iargin = 1:2:(nargin -1))
		switch varargin{iargin}
			case 'preprocPath'
				preprocPath = varargin{iargin + 1};
			otherwise
				error('Invalid argument passed to function');
		end
	end

	pp.VPrintf('Saving preprocessed data... ', 1);	

	% save preprocessed volume to file
	pp.preprocVol.Save_To_File(preprocPath);

	% save scan settings to file
	scanSett = pp.scanSett;
	save(preprocPath, 'scanSett', '-append');
	clear scanSett;

	% save settings for preprocessing to file
	preprocSett = pp.preprocSett;
	save(preprocPath, 'preprocSett', '-append');
	clear preprocSett;

	% save path to file
	filePath = pp.filePath;
	save(preprocPath, 'filePath', '-append');
	clear filePath;

	% safe surface to file
	deltaZ = pp.deltaZ;
	save(preprocPath, 'deltaZ', '-append');

	pp.VPrintf('done!\n', 0);

end
