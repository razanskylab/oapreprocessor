% Function: Comp_Preproc_Data.m @ Preprocessor
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 14-Feb-2020

% Description: Checks if existing preprocessed datasets have same processing
% settings
% result = 1 --> same settings
% result = 0 --> not same settings

function result = Comp_Preproc_Data(pp)

	if isfile(pp.preprocPath)
		load(pp.preprocPath, 'preprocSett');
		preprocSett
		if isequal(preprocSett, pp.preprocSett)
			result = 1;
		else
			result = 0;
		end
	else
		warning('No previously processed dataset found');
		result = 0;
	end

end
