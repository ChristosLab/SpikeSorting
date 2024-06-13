function D = loadData(oebin_file, varargin)
p = inputParser;
addParameter(p, 'processor_idx', 1, @isnumeric);
p.parse(varargin{:});
processor_idx = p.Results.processor_idx;
D = load_open_ephys_binary_timestamp_rescue(oebin_file,'continuous',processor_idx, 'mmap'); % load data in memory mapped mode
end
