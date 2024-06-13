function [regress_out] = noise_color(psdPerChannel, varargin)
p = inputParser;
p.addParameter('f', [], @isnumeric);
p.parse(varargin{:});
f = p.Results.f;
noise_f = 500;
start_f = 500;
stop_f  = 7500;
n_f = numel(f);
n_chan = numel(psdPerChannel)/n_f;
f   = reshape(f, [n_f, 1]);
f_dim = find(size(psdPerChannel) == n_f);
chan_dim = find(size(psdPerChannel) == n_chan);
psdPerChannel = permute(psdPerChannel, [f_dim, chan_dim]);
valid_idx = find(mod(f, noise_f) .* (f >= start_f) .* (f <= stop_f));
regress_out = zeros(2, n_chan);
for i = 1:n_chan
regress_out(:, i) = regress(log10(psdPerChannel(valid_idx, i)), [log10(f(valid_idx)), ones(size(f(valid_idx)))]);
end
end