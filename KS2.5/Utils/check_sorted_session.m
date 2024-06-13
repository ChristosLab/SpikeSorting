function check_sorted_session(sessions, varargin)
p = inputParser;
p.addParameter('sorted_folder', 'Z:\Development_project_2019\VanderbiltDAQ\KS_out');
p.parse(varargin{:});
sorted_folder = p.Results.sorted_folder;
sorted_sessions = dir(fullfile(sorted_folder, '*', '*_*'));
name_sorted_sessions = {sorted_sessions.name};
name_sessions_to_sort = arrayfun(@(x) x.daq_folder.name, sessions, 'UniformOutput', false);
overlap_idx = ismember(name_sorted_sessions, name_sessions_to_sort);
for i = find(overlap_idx)
    error(sprintf('session %s is already sorted under %s\n', name_sorted_sessions{i}, sorted_sessions(i).folder))
end
end