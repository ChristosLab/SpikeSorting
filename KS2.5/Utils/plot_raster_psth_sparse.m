function plot_raster_psth_sparse(MatData, target_neuron, statecode_threshold, ax_main, align_event)
%Plot raster and psth over trials w/ unsorted class
% ax_title = axes(ax_main.Parent, 'Units', 'normalized','Position', [0 ,0 ,1, 1], 'Visible', 'off', 'Box','off');
% hold(ax_title, 'on');
% ax_title.XLim = [0, 1];
% ax_title.YLim = [0, 1];
% title_positions = [0.1, 0.9; 0.9, 0.9; 0.1, 0.1; 0.9, 0.1];

color = [0 0 1];
max_psth        = 0;
all_mean_psth = squeeze(nanmean(MatData.psth(:, target_neuron, :), 1));
max_psth      = max(max_psth, max(all_mean_psth, [], 'all')) + 1;
statcode_mask = [MatData.trials.Statecode] >= statecode_threshold;
align_event_mask = cellfun(@(x) ~isempty(x), {MatData.trials.(align_event)});
target_trials = find(statcode_mask .* align_event_mask);

x_to_plot = [];
y_to_plot = [];
yyaxis(ax_main, 'left');
plotted_counter = 0;
for j = target_trials
    plotted_counter = plotted_counter + 1;
    current_x = (find(MatData.trials(j).ss(:, target_neuron)) - double(MatData.trials(j).(align_event)))/MatData.sample_rate;
    current_y = plotted_counter + zeros(size(current_x));
    x_to_plot = [x_to_plot, current_x'];
    y_to_plot = [y_to_plot, current_y'];
end
ax_main.YAxis(1).Limits = [0, plotted_counter + 1];

plot(x_to_plot, y_to_plot, '.', 'MarkerSize', .1, 'Parent', ax_main, 'Color', 0.4 .* color);
yyaxis(ax_main, 'right');
plot(MatData.t_centers, all_mean_psth, '-', 'Parent', ax_main, 'Color', color, 'LineWidth', 1.2);

ax_main.YAxis(2).Limits = [0, max_psth];
ax_main.XAxis(1).Limits = [min(MatData.t_centers), max(MatData.t_centers)];
ax_main.YAxis(2).Label.String = 'Firing rate (spikes/s)';
ax_main.YAxis(1).Label.String = 'Trial No.';
ax_main.XAxis(1).Label.String = 'Time from laser onset (s)';
ax_main.YAxis(2).Color = [0, 0, 0];
ax_main.YAxis(1).Color = [0, 0, 0];
ax_main.XAxis(1).Color = [0, 0, 0];
% text(ax_title, title_positions(mod(i_neuron - 1, numel(colors) ) + 1, 1), title_positions(mod(i_neuron - 1, numel(colors) ) + 1, 2), sprintf('%s\nAmplitude: %.2fmV KSLabel: %s', make_plain_text(MatData.neuron_filename), MatData.amplitude * 0.195/1000, MatData.kslabel), ...
%     'FontSize', 6, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Color', colors(mod(i_neuron - 1, numel(colors) ) + 1, :));
end
