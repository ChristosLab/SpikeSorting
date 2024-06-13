function plot_cue_delay_firing_rate(filename)
load(filename, 'MatData');
target_samples     = MatData.trials(1).photodiode_on_event:(MatData.trials(1).photodiode_on_event + MatData.sample_rate * (MatData.parameters.delayDuration + MatData.parameters.stimulusDuration) - 1);
target_cells       = find(MatData.cgs > 1);
target_trials      = find([MatData.trials.Statecode] > 6);
target_spike_count = cell(numel(target_cells), numel(target_trials));
for i_target_cell = 1:numel(target_cells)
    i = target_cells(i_target_cell);
    target_spike_count(i, :) = arrayfun(@(x) sum(x.ss(target_samples, i)), MatData.trials(target_trials), 'UniformOutput', false);
end
target_fr        = cell2mat(target_spike_count)/numel(target_samples) * MatData.sample_rate;
[~, trial_order] = sort([MatData.trials(target_trials).Class]);
target_fr        = target_fr(:, trial_order);
target_fr_center = sum(target_fr .* (1:size(target_fr, 2)), 2) ./ sum(target_fr, 2);
[~, neuron_order] = sort(target_fr_center);
target_fr = target_fr(neuron_order, :);
%%
figure('Units', 'inches', 'Position', [2, 2, 8, 8])
subplot(11, 1, 1:5)
imagesc(target_fr, [0, 50])
h = colorbar;
h.Label.String = 'Firing rate';
ylabel('KS good neuron No.')
xlabel('')
subplot(11, 1, 6)
axis off
% plot(arrayfun(@(x) atan(x.frame(1).stim.end(2)/x.frame(1).stim.end(1)), MatData.ClassStructure([MatData.trials([MatData.trials.Statecode] > 6).Class])), '--.')
subplot(11, 1, 7:11)
% imagesc(target_fr./mean(target_fr, 2), [0, 2])
% h = colorbar;
% h.Label.String = 'Firing rate relative to mean';
%
imagesc((target_fr - mean(target_fr, 2))./std(target_fr, 0, 2), [0, 2])
h = colorbar;
h.Label.String = 'Norm. firing rate';
%
ylabel('KS single unit No.')
xlabel('Correct trial No.')
sgtitle([MatData.beh_file(1:end-4), ' Cue delay firing rate'], 'Interpreter', 'none')
set(findobj(gcf, 'type', 'axes'), 'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'Bold', 'LineWidth', 1);
end
