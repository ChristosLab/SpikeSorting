function sp = assign_session_probe_info(sp, session_table, probe_table)
probe_record   = probe_table(ismember(probe_table.OE_Filename, sp.session_name), :);
session_record = session_table(ismember(session_table.OE_Filename, sp.session_name), :);
[~, probe_record_order] = sort(probe_record.Probe_order);
probe_record = probe_record(probe_record_order, :);
sp.probe_record = probe_record;
sp.session_record = session_record;
channel_count = 0;
channel_area = {};
channel_hemisphere = {};
channel_AP = [];
channel_LR = [];
channel_depth_from_1st_spike = [];
for i = 1:size(probe_record, 1)
    channel_count(i + 1) = get_channel_count(probe_record{i, 'Probe'});
    probe_area = probe_record{i, 'Area'};
    probe_hemisphere = probe_record{i, 'Hemisphere'};
    if isempty(probe_area)
        probe_area = {'NA'};
    end
    if isempty(probe_hemisphere)
        probe_hemisphere = {'NA'};
    end
    channel_area = [channel_area, repmat(probe_area, [1, channel_count(i + 1)])];
    channel_hemisphere = [channel_hemisphere, repmat(probe_hemisphere, [1, channel_count(i + 1)])];
    channel_AP = [channel_AP, repmat(probe_record{i, 'AP'}, [1, channel_count(i + 1)])];
    channel_LR = [channel_LR, repmat(probe_record{i, 'LR'}, [1, channel_count(i + 1)])];
    % sp.channel_map is always 0-indexed and monotonic in Kilosort output,
    % regardless of supplied channel map. With the channels first sorted by
    % probe, and then by ycoords and lastly by xcoords, so that the deepest
    % channel in the first probe is indicated by channel_map == 0, followed
    % by the shallower contacts on the same probe. Ties are broken by
    % placing the contact with the smaller xcoord first.
    % Human records should always follow the same rule, except for 1)
    % the CHs are 1-indexed. 2) Deep channels have larger depth numbers
    % instead of smaller depth numbers as would kilosort channel maps.
    current_probe_sp_idx = channel_count(i) + [1:channel_count(i + 1)];
    spike_CH_sp_idx = find(sp.channel_map == (probe_record{i, 'Spike_CH'} - 1));
    if isempty(spike_CH_sp_idx)
        channel_depth_from_1st_spike = [channel_depth_from_1st_spike, nan(size(current_probe_sp_idx))];
    else
        channel_depth_from_1st_spike = [channel_depth_from_1st_spike, (probe_record{i, 'Record_depth'} - probe_record{i, 'Spike_depth'}) - (sp.ycoords(current_probe_sp_idx)' - sp.ycoords(spike_CH_sp_idx)')];
    end
    % Depth is converted from kilosort convention to human convention
end
sp.cluster_area = channel_area(sp.cluster_chan);
sp.cluster_hemisphere = channel_hemisphere(sp.cluster_chan);
sp.cluster_AP = channel_AP(sp.cluster_chan);
sp.cluster_LR = channel_LR(sp.cluster_chan);
sp.cluster_ketamine = zeros(size(sp.cluster_chan)) + session_record{1, 'Ketamine'};
sp.cluster_opto = zeros(size(sp.cluster_chan)) + session_record{1, 'Optogenetics'};
sp.cluster_depth_from_1st_spike = channel_depth_from_1st_spike(sp.cluster_chan);
end
function out = get_channel_count(probe)
probe_list = {'Plexon-32S', 'Plexon-16V', 'FHC-tungsten', 'DBC-DA128-2', 'DBC-DA128-2-fiber', 'NP1010', 'NP1015'};
channel_count_list = [32, 16, 1, 128, 128, 384, 384];
out = channel_count_list(ismember(probe_list, probe));
end