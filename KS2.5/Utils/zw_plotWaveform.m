function zw_plotWaveform(wf, xcoords, ycoords, varargin)
% wf is nWf X nChan x nTimePoints
% color must be 3-element vector

wf = double(wf);

p = inputParser;
p.addParameter('n_chan', 3);
p.addParameter('color', [1, 0, 0]);
p.addParameter('line_width', 0.1);
p.addParameter('alpha', 0.015);
p.parse(varargin{:});

n_chan = p.Results.n_chan;
color = p.Results.color;
alpha = p.Results.alpha;
max_alpha = alpha * 3;
line_width = p.Results.line_width;

median_wf = squeeze(nanmedian(wf, 1));
chanAmps = max(median_wf,[],2)-min(median_wf, [], 2);
[maxAmp, maxChan] = max(chanAmps);

[~, chan_dist_order] = sort((xcoords - xcoords(maxChan)) .^2 + (ycoords - ycoords(maxChan)) .^2);
inclChans = chan_dist_order(1:n_chan);

[x_pitch, y_pitch] = find_pitch([xcoords, ycoords]);
if isempty(x_pitch)
    x_pitch = y_pitch; % Scale x the same as y is there is only a single column
end

n_pts = size(wf, 3);
pts_to_plot = 1:n_pts;
x_pts = linspace(-x_pitch/2, x_pitch/2, numel(pts_to_plot));
y_scale = y_pitch/maxAmp/2;
% y_scale = y_pitch/5500;

for ch = 1:n_chan
    thisCh = inclChans(ch);
    thisWF = squeeze(wf(:, thisCh,:)) * y_scale;
    scaled_alpha = max_alpha - (max_alpha - alpha) * sum(all(~isnan(thisWF), 2))/size(thisWF, 1);
    plot(x_pts + xcoords(thisCh), thisWF + ycoords(thisCh), 'k', 'Color', [color, scaled_alpha], 'LineWidth', line_width);
end
xlim([min(xcoords(inclChans)), max(xcoords(inclChans))] + [-1.5 ,1.5] .* x_pitch);
ylim([min(ycoords(inclChans)), max(ycoords(inclChans))] + [-1.5 ,1.5] .* y_pitch);
xlabel('(\mum)', 'FontWeight','bold')
ylabel('Distance from tip (\mum)','FontWeight','bold')
end