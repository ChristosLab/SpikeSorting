function [relative_sample, sample_shift] = get_stationary_check_sample(MatData, varargin)
% Get the sample range to be used for stationarity check
p = inputParser;
parse(p, varargin{:});
task_type = detect_task_type(MatData);
sample_shift = arrayfun(@(x) [double(x.photodiode_on_event), nan * find(isempty(x.photodiode_on_event))], MatData.trials);
switch task_type
    case {'odr', 'biasedodr', 'odrdist'}
        relative_sample = (- MatData.sample_rate * MatData.parameters.fixationDuration + 1):0;
    case 'fix'
        relative_sample = 0:(MatData.sample_rate * MatData.parameters.fixationDuration - 1);
    case 'odr_opto'
        relative_sample = (- MatData.sample_rate * MatData.parameters.fixationDuration + 1):(- MatData.sample_rate * MatData.parameters.fixationDuration / 2);
end
end