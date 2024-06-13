function [task_type, state_code_threshold, align_event_order_in_queue] = detect_task_type(AllData, varargin)
task_types_to_match = {'odr', 'odrdist', 'biasedodr', 'odr_opto', 'calib', 'fix'};
state_code_threshold_list = [7, 9, 7, 7, -99, 7]; % Correct trial threshold
if numel(varargin) > 0
    task_types_to_match = varargin{1};
end
if numel(varargin) > 1
    state_code_threshold_list = varargin{2};
end
%   Find string overlaps in task type names
hierarchy_mat = cell2mat(cellfun(@(x) ~cellfun(@isempty, regexp(x, task_types_to_match)),task_types_to_match, 'UniformOutput', false)');
%   Find all matches
matched_ = cellfun(@(x) ~isempty(x), regexp(lower(AllData.version), task_types_to_match));
%   Refer matching patterns to overlaps
task_idx             = ismember(hierarchy_mat, matched_, 'rows');
task_type            = task_types_to_match{task_idx};
state_code_threshold = state_code_threshold_list(task_idx);
if state_code_threshold >= 7
    %   Define Cue_OnT as the photodiode alignning event for tasks w/
    %   expected frame count
    align_event_order_in_queue = 3;
else
    align_event_order_in_queue = -99;
end
if ismember(task_types_to_match{task_idx}, {'fix'}) 
    align_event_order_in_queue = 1;
end
end