function add_adc_channel_map(channel_map_fname, n_adc)
%   ADC channels are assumed to follow contact channels in the binary
%   data
[orig_dir, orig_fname, orig_ext] = fileparts(channel_map_fname);
added_fname = [orig_fname, sprintf('_%dadc', n_adc)];
load(channel_map_fname);
n_contact = numel(chanMap);
chanMap     = [chanMap, n_contact + [1:n_adc]];
chanMap0ind = chanMap - 1;
connected   = [connected, false([1, n_adc])];
kcoords     = [kcoords, max(kcoords) + zeros(1, n_adc)];
name        = [name, sprintf('_%dadc', n_adc)];
xcoords     = [xcoords, zeros(1, n_adc)];
ycoords     = [ycoords, zeros(1, n_adc)];
save(fullfile(orig_dir, added_fname), 'chanMap', 'chanMap0ind', 'connected', 'kcoords', 'name', 'xcoords', 'ycoords');
end