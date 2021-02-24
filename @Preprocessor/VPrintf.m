% File: VPrintf.m @ Preprocessor
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 17-Feb-2020

% Descirption: Deactivatable verbose output for class.

function VPrintf(pp, msg, flagName)

	if pp.flagVerbose
		if flagName
			msg = ['[Preprocessor] ', msg];
		end
		fprintf(msg);
	end

end
