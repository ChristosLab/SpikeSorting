function out = find_neuron_count(tbl, subject, session)
match_idx = false([size(tbl, 1), 1]);
if isempty(session)
    filename_key = sprintf('%s', upper(subject));
    match_idx = cellfun(@(x)  contains(x, filename_key), [tbl.Filename]);
else
    while (sum(match_idx) == 0) && session > 0
        filename_key = sprintf('%s%03.f', upper(subject), session);
        match_idx = cellfun(@(x)  contains(x, filename_key), [tbl.Filename]);
        session = session - 1;
    end
end
out = max(tbl.Neuron(match_idx));
end