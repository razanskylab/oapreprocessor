% get available memory on system in Byte

function freemem = getMemory()

	[~, out] = system('cat /proc/meminfo');

	k = strfind(out, 'MemFree:');
	out = out(k+8:end);
	k = strfind(out, ' kB');
	freemem = str2num(out(1:k)) * 1024;

end
