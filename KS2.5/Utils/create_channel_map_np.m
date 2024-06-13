function fname = create_channel_map_np(xml_ch_map, channel_index)
Nchannels = numel(channel_index); % number of channels
% Re-indexing channels for kilosort.
[~, chanMap] = sort(channel_index);
chanMap0ind = chanMap - 1;
global_map  = false(1, xml_ch_map.elec_n);
global_map(channel_index(~isnan(channel_index)) + 1) = true;
global_map_hex = bin2edge(global_map);
% Non-ephys channel (sync) inherits the coordinates of CH0 for convenience.
channel_index_no_nan = channel_index;
channel_index_no_nan(isnan(channel_index_no_nan)) = 0;
xml_oe_mapping = ismember_locb(channel_index_no_nan, xml_ch_map.electrode_index);
xcoords = xml_ch_map.electrode_xpos(xml_oe_mapping);
ycoords = xml_ch_map.electrode_ypos(xml_oe_mapping);
connected = xml_ch_map.electrode_connected(xml_oe_mapping);
% Non-ephys channel turned off.
connected(isnan(channel_index)) = 0;
% No channel grouping for now.
kcoords = ones(size(xcoords));

name = xml_ch_map.probe_name;
fname = [name, '_',  global_map_hex, '.mat'];
save(fname, ...
    'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind', 'name')
end
function out = bin2edge(bin_in)
on_edges  = find(diff([0, bin_in]) == 1); % First on channels in block
off_edges = find(diff([bin_in]) == -1); % Last on channels in block
out = dec2hex(sort([on_edges, off_edges]));
out = reshape(out', [1, numel(out)]);
end