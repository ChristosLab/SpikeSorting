function plot_fixation_firing_rate_with_stationarity_3_panel(filename)
statecode_threshold            = 4;
load(filename, 'MatData');
MatData                        = stationarityCheck_wrapper(MatData, 'statecode_threshold', statecode_threshold);
target_samples                 = (MatData.trials(1).photodiode_on_event - MatData.sample_rate * MatData.parameters.fixationDuration + 1):MatData.trials(1).photodiode_on_event;
[target_fr,     target_trials] = get_firing_rate_sparse(MatData, target_samples, statecode_threshold);
target_cells                   = find(MatData.cgs > 1);
target_fr                      = target_fr(target_cells, :);
[target_fr, sort_order] = sort_center_of_mass(target_fr, 1);

%%
figure('Units', 'inches', 'Position', [2, 2, 8, 8])
subplot(11, 1, 1:5)
imagesc(target_fr, [0, 30])
h = colorbar;
h.Label.String = 'Firing rate';
ylabel('KS good neuron No.')
xlabel('')
subplot(11, 1, 6)
axis off
% plot(arrayfun(@(x) atan(x.frame(1).stim.end(2)/x.frame(1).stim.end(1)), MatData.ClassStructure([MatData.trials([MatData.trials.Statecode] > 6).Class])), '--.')
subplot(11, 1, 7:11)
imagesc(target_fr ./ mean(target_fr, 2) .* MatData.stationary(target_cells(sort_order), target_trials) - ~MatData.stationary(target_cells(sort_order), target_trials), [-1, 2]);
h = colorbar;
h.Label.String = 'Firing rate relative to mean';
ylabel('KS single unit No.')
xlabel('Correct trial No.')
sgtitle([MatData.beh_file(1:end-4), ' fixation firing rate'], 'Interpreter', 'none')
set(findobj(gcf, 'type', 'axes'), 'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'Bold', 'LineWidth', 1);
end
