%  create a channel map file

Nchannels = 32; % number of channels
connected = true(1, Nchannels);
chanMap0ind = 0:(Nchannels - 1);
chanMap   = chanMap0ind + 1;

y_pitch = 75;
xcoords = zeros(size(chanMap));
ycoords = 0:y_pitch:(y_pitch * (Nchannels - 1));
kcoords   = ones(size(chanMap));

name = 'Linear_32_ch_75_pitch_plexon_S';

save(fullfile([name,'.mat']), ...
    'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind', 'name')
