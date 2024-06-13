function AllData = add_LFP(AllData, ls, oe, task_counter)
%   Decode task type in behavior data
[~, ~, align_event_order_in_queue] = detect_task_type(AllData);
%   CONVERTS DATA MATRIX IDX TO TIMESTAMP!
fs_raw = oe.oe_info.continuous.sample_rate;
fs_lfp = ls.parameters.fs_LFP;
trial_time_event_in_session = get_event_in_boundary(oe.session_time_event(task_counter, :), oe.trial_time_event);
T = double(ls.time_sample)/fs_raw;
peri_trial_padding_T      = 1;
peri_trial_padding_sample = peri_trial_padding_T * fs_lfp; % 
for i = 1:numel(AllData.trials)
    AllData.trials(i).TrialNum = i;
    trial_time_event_in_trial             = trial_time_event_in_session(i, :);
    photodiode_time_event_in_trial        = get_event_in_boundary(trial_time_event_in_trial, oe.photodiode_time_event);
    [~, lfp_time_sample_in_trial_idx]     = get_event_in_boundary(trial_time_event_in_trial, ls.time_sample);
    lfp_time_sample_peri_trial_idx        = [max(lfp_time_sample_in_trial_idx(1) - peri_trial_padding_sample, 1):min(lfp_time_sample_in_trial_idx(end) + peri_trial_padding_sample, numel(ls.time_sample))];
    if ~isempty(photodiode_time_event_in_trial)
        AllData.trials(i).LFP             = ls.lfp(:, lfp_time_sample_peri_trial_idx);
        %   LFP timestamps are relative to the trial on event
        AllData.trials(i).LFP_timestamps  = T(lfp_time_sample_peri_trial_idx) - double(trial_time_event_in_trial(1))/fs_raw;
        %
        %   Shift Psychtoolbox-generated timestamps by aligning cpu_trial_photodiode_latency w/ real_trial_to_photodiode_latency
        real_trial_to_photodiode_latency  = double(photodiode_time_event_in_trial(1) - trial_time_event_in_trial(1))/fs_raw;
        cpu_trial_to_photodiode_latency   = AllData.trials(i).timestamp_queue(align_event_order_in_queue) - AllData.trials(i).time;
        AllData.trials(i).timestamp_queue = AllData.trials(i).timestamp_queue + (real_trial_to_photodiode_latency - cpu_trial_to_photodiode_latency);
    end
end
end
%%
function [event_in_boundary, event_sample] = get_event_in_boundary(boundary_event, base_event)
event_idx = and(base_event(:, 1) >= boundary_event(1), base_event(:, end) <= boundary_event(2));
event_in_boundary = base_event(event_idx, :);
event_sample = find(event_idx);
end