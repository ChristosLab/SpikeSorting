function MatData = stationarityCheck_wrapper(MatData, varargin)
p = inputParser;
p.addParameter('statecode_threshold', 5);
parse(p, varargin{:});
statecode_threshold = p.Results.statecode_threshold;
[relative_sample, sample_shift] = get_stationary_check_sample(MatData);
[fr, trialnum] = get_firing_rate_sparse(MatData, relative_sample, statecode_threshold, 'sample_shift', sample_shift);
stationary_flag = zeros(size(fr));
for i = 1:size(fr, 1)
    stationary_flag(i, :) = stationarityCheck2(fr(i,:));
end
MatData.stationary = false(numel(MatData.cids), numel(MatData.trials));
MatData.stationary(:, trialnum) = stationary_flag;
end