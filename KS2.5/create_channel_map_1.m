%  create a channel map file

Nchannels = 1; % number of channels
connected = true(1, Nchannels);
chanMap0ind = 0:(Nchannels - 1);
chanMap   = chanMap0ind + 1;

y_pitch = 150;
xcoords = zeros(size(chanMap));
ycoords = 0:y_pitch:(y_pitch * (Nchannels - 1));
kcoords   = ones(size(chanMap));

name = 'tungsten_1';

save(fullfile([name,'.mat']), ...
    'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind', 'name')
