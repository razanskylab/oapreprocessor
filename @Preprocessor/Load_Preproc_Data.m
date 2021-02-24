% File: Load_Preproc_Data.m
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 20-Feb-2020

% Description: Loads preprocessed datasets into our workspace

function Load_Preproc_Data(pp)

	if (isfile(pp.preprocPath))
		pp.VPrintf('Loading preprocessed data from file... ', 1);
		pp.preprocVol.Load_From_File(pp.preprocPath);
		
		load(pp.preprocPath, 'scanSett');
		pp.scanSett = scanSett;
		
		load(pp.preprocPath, 'preprocSett');
		pp.preprocSett = preprocSett;

		load(pp.preprocPath, 'deltaZ');
		pp.deltaZ = deltaZ;
	
		% NOTE this does not work this way since we use different workstations
		% load(pp.preprocPath, 'filePath');
		% pp.filePath = filePath;
		
		pp.VPrintf('done!\n', 0);
	else
		error('Cannot load from non-existing file');
	end



end
