function out_trials = verbose_timestamps(in_trials, task)
out_trials = in_trials;
switch task
    case {'odr', 'biasedodr', 'odr_opto', 'fix'}
        timestamp_names = {'Fix_onT', 'Fix_inT', 'Cue_onT', 'Cue_offT', 'Fix_offT', 'Target_inT'};
    case 'odrdist'
        timestamp_names = {'Fix_onT', 'Fix_inT', 'Cue_onT', 'Cue_offT', 'Dist_onT', 'Dist_offT', 'Fix_offT', 'Target_inT'};
end
for i = 1:numel(out_trials)
    for j = 1:numel(out_trials(i).timestamp_queue)
        out_trials(i).(timestamp_names{j}) = out_trials(i).timestamp_queue(j) - out_trials(i).time;
    end
end
end