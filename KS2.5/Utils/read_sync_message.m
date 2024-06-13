function start_time_sample = read_sync_message(sync_message_dir, varargin)
p = inputParser;
p.addParameter('processor_id', '100');
p.addParameter('stream_id', '0');
p.parse(varargin{:});
processor_id = p.Results.processor_id;
stream_id    = p.Results.stream_id;
fid = fopen(fullfile(sync_message_dir.folder, sync_message_dir.name));
start_time_sample = [];
while ~feof(fid)
    line = fgetl(fid);  % Read a line as a string
    if regexp(line, sprintf('Id: %s subProcessor: %s', processor_id, stream_id))
        start_time_text   = regexp(line, 'start time: \d*', 'match');
        start_time_sample = textscan(start_time_text{1}, 'start time: %d64');
        start_time_sample = start_time_sample{1};
    elseif regexp(line, sprintf('\\(%s\\) - %s', processor_id, stream_id))
        start_time_text   = regexp(line, 'Hz: \d*', 'match');
        start_time_sample = textscan(start_time_text{1}, 'Hz: %d64');
        start_time_sample = start_time_sample{1};
    end
end
fclose(fid);
end