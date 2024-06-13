function plot_delay_evoked_firing_rate(filename)
load(filename, 'MatData');
target_samples       = (MatData.trials(1).photodiode_on_event + MatData.sample_rate * MatData.parameters.stimulusDuration):(MatData.trials(1).photodiode_on_event + MatData.sample_rate * (MatData.parameters.delayDuration + MatData.parameters.stimulusDuration) - 1);
baseline_samples     = (MatData.trials(1).photodiode_on_event - MatData.sample_rate * MatData.parameters.fixationDuration + 1):MatData.trials(1).photodiode_on_event;
target_cells         = find(MatData.cgs > 1);
target_trials        = find([MatData.trials.Statecode] > 6);
target_spike_count   = cell(numel(target_cells), numel(target_trials));
baseline_spike_count = target_spike_count;
for i_target_cell = 1:numel(target_cells)
    i = target_cells(i_target_cell);
    target_spike_count(i, :)   = arrayfun(@(x) sum(x.ss(target_samples, i)), MatData.trials(target_trials), 'UniformOutput', false);
    baseline_spike_count(i, :) = arrayfun(@(x) sum(x.ss(baseline_samples, i)), MatData.trials(target_trials), 'UniformOutput', false);
end
target_fr       = cell2mat(target_spike_count)/numel(target_samples) * MatData.sample_rate;
baseline_fr     = cell2mat(baseline_spike_count)/numel(baseline_samples) * MatData.sample_rate;
evoke_diff_fr  = target_fr - baseline_fr;
evoke_ratio_fr = target_fr./baseline_fr;
[~, trial_order] = sort([MatData.trials(target_trials).Class]);
evoke_diff_fr = evoke_diff_fr(:, trial_order);
evoke_ratio_fr = evoke_ratio_fr(:, trial_order);
target_fr_center = sum(evoke_diff_fr .* (1:size(evoke_diff_fr, 2)), 2) ./ sum(evoke_diff_fr, 2);
[~, neuron_order] = sort(target_fr_center);
evoke_diff_fr  = evoke_diff_fr(neuron_order, :);
evoke_ratio_fr = evoke_ratio_fr(neuron_order, :);
%%
figure('Units', 'inches', 'Position', [2, 2, 8, 8])
subplot(11, 1, 1:5)
imagesc(evoke_diff_fr, [0, 8])
h = colorbar;
h.Label.String = 'Firing rate: delay - baseline (sp/s)';
ylabel('KS single unit Nso.')
xlabel('')
subplot(11, 1, 6)
hold on
box off
plot(arrayfun(@(x) atan2d(x.frame(1).stim.end(2), x.frame(1).stim.end(1)), MatData.ClassStructure([MatData.trials(target_trials(trial_order)).Class])), 'k', 'LineWidth', 2)
xlim([1, numel(trial_order)]);
ylabel(['angle(', char(176), ')'])
xticks([])
subplot(11, 1, 7:11)
imagesc(evoke_ratio_fr, [0, 3])
h = colorbar;
h.Label.String = 'Firing rate: delay/baseline (ratio)';
%
ylabel('KS single unit No.')
xlabel('Class sorted correct trial No.')
sgtitle([MatData.beh_file(1:end-4), ' Evoked delay firing rate'], 'Interpreter', 'none')
set(findobj(gcf, 'type', 'axes'), 'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'Bold', 'LineWidth', 1);
end
