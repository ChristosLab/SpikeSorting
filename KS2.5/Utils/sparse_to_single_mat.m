function [neuron_table, mua_table] = sparse_to_single_mat(MatData_sparse, prev_neuron_count, neuron_table, prev_mua_count, mua_table, neuron_output_dir, mua_output_dir)
MatData_sparse = stationarityCheck_wrapper(MatData_sparse, 'statecode_threshold', MatData_sparse.state_code_threshold - 2); % 2 statecode before trial success are valid trials.
if ~isfield(MatData_sparse, 'isi_violation') % Skip session w/o neurons
    return
end
n_class = numel(MatData_sparse.ClassStructure);
if isfield(MatData_sparse, 'single_units')
    if ~isempty(MatData_sparse.single_units)
        single_units = find(MatData_sparse.single_units);
    end
end
if ~exist('single_units', 'var') % Backward compatible
    single_units = find(or(MatData_sparse.ks_label == 2, and((MatData_sparse.amp_rms >= 5), (MatData_sparse.isi_violation <= 1))));
end
multi_units  = setxor(1:numel(MatData_sparse.ks_label), single_units);
neuron_idx   = prev_neuron_count + (1:numel(single_units));
mua_idx      = prev_mua_count + (1:numel(multi_units));
correct_trials_idx = find([MatData_sparse.trials.Statecode] == MatData_sparse.state_code_threshold);
error_trials_idx   = find(([MatData_sparse.trials.Statecode] >= (MatData_sparse.state_code_threshold - 2)) .* ([MatData_sparse.trials.Statecode] < MatData_sparse.state_code_threshold));

sparse_trials = MatData_sparse.trials(correct_trials_idx);
sparse_error_trials = MatData_sparse.trials(error_trials_idx);
single_MatData_sparse     = cell(size(single_units));
single_MatData_sparse_err = cell(size(single_units));
multi_MatData_sparse      = cell(size(multi_units));
multi_MatData_sparse_err  = cell(size(multi_units));

trial_field_names = fieldnames(MatData_sparse.trials);
T_fieldnames = trial_field_names(cellfun(@(x) contains(x, {'onT','inT','offT'}), trial_field_names));
align_T      = 'Cue_onT';
ntr_temp = struct();
ntr_temp_error = struct();
for i_trial = 1:numel(sparse_trials)
    if isfield(sparse_trials, 'Cue_onT')
        for i_T = 1:numel(T_fieldnames)
            ntr_temp(i_trial).(T_fieldnames{i_T}) = sparse_trials(i_trial).(T_fieldnames{i_T}) - sparse_trials(i_trial).(align_T);
        end
    end
    ntr_temp(i_trial).Class = sparse_trials(i_trial).Class;
end
for i_trial = 1:numel(sparse_error_trials)
    if isfield(sparse_error_trials, 'Cue_onT')
        for i_T = 1:numel(T_fieldnames)
            ntr_temp_error(i_trial).(T_fieldnames{i_T}) = sparse_error_trials(i_trial).(T_fieldnames{i_T}) - sparse_error_trials(i_trial).(align_T);
        end
    end
    ntr_temp_error(i_trial).Class = sparse_error_trials(i_trial).Class;
end

% Single-units
for i_u = 1:numel(single_units)
    single_MatData_sparse{i_u} = ntr_temp;
    single_MatData_sparse_err{i_u} = ntr_temp_error;
    for i_trial = 1:numel(sparse_trials)
        single_MatData_sparse{i_u}(i_trial).TS = (find(sparse_trials(i_trial).ss(:, single_units(i_u))) - double(sparse_trials(i_trial).photodiode_on_event))'/MatData_sparse.sample_rate;
        single_MatData_sparse{i_u}(i_trial).stationary = MatData_sparse.stationary(single_units(i_u), correct_trials_idx(i_trial));
        single_MatData_sparse{i_u}(i_trial).trialnum   = correct_trials_idx(i_trial);
    end
    for i_trial = 1:numel(sparse_error_trials)
        single_MatData_sparse_err{i_u}(i_trial).TS = (find(sparse_error_trials(i_trial).ss(:, single_units(i_u))) - double(sparse_error_trials(i_trial).photodiode_on_event))'/MatData_sparse.sample_rate;
        single_MatData_sparse_err{i_u}(i_trial).stationary = MatData_sparse.stationary(single_units(i_u), error_trials_idx(i_trial));
        single_MatData_sparse_err{i_u}(i_trial).trialnum   = error_trials_idx(i_trial);
    end
    Filename  = MatData_sparse.beh_file(1:end-4);
    save_name = sprintf('%s_%05.f', Filename, neuron_idx(i_u));
    new_row      = {Filename, neuron_idx(i_u), MatData_sparse.cluster_chan(single_units(i_u)), {MatData_sparse.cids(single_units(i_u))}};
    neuron_table = [neuron_table; new_row];
    MatData = struct;
    MatData.ntr = single_MatData_sparse{i_u};
    MatData = sort_and_create_class(MatData, n_class);
    save(fullfile(neuron_output_dir, save_name), 'MatData')
    MatData = struct;
    MatData.ntr = single_MatData_sparse_err{i_u};
    MatData = sort_and_create_class(MatData, n_class);
    save(fullfile(neuron_output_dir, [save_name, '_err']), 'MatData')
end
% Multi-units
for i_u = 1:numel(multi_units)
    multi_MatData_sparse{i_u} = ntr_temp;
    multi_MatData_sparse_err{i_u} = ntr_temp_error;
    for i_trial = 1:numel(sparse_trials)
        multi_MatData_sparse{i_u}(i_trial).TS = (find(sparse_trials(i_trial).ss(:, multi_units(i_u))) - double(sparse_trials(i_trial).photodiode_on_event))'/MatData_sparse.sample_rate;
        multi_MatData_sparse{i_u}(i_trial).stationary = MatData_sparse.stationary(multi_units(i_u), correct_trials_idx(i_trial));
        multi_MatData_sparse{i_u}(i_trial).trialnum   = correct_trials_idx(i_trial);
    end
    for i_trial = 1:numel(sparse_error_trials)
        multi_MatData_sparse_err{i_u}(i_trial).TS = (find(sparse_error_trials(i_trial).ss(:, multi_units(i_u))) - double(sparse_error_trials(i_trial).photodiode_on_event))'/MatData_sparse.sample_rate;
        multi_MatData_sparse_err{i_u}(i_trial).stationary = MatData_sparse.stationary(multi_units(i_u), error_trials_idx(i_trial));
        multi_MatData_sparse_err{i_u}(i_trial).trialnum   = error_trials_idx(i_trial);
    end
    Filename  = MatData_sparse.beh_file(1:end-4);
    save_name = sprintf('%s_mua%05.f', Filename, mua_idx(i_u));
    new_row   = {Filename, mua_idx(i_u), MatData_sparse.cluster_chan(multi_units(i_u)), {MatData_sparse.cids(multi_units(i_u))}};
    mua_table = [mua_table; new_row];
    MatData   = struct;
    MatData.ntr = multi_MatData_sparse{i_u};
    MatData = sort_and_create_class(MatData, n_class);
    save(fullfile(mua_output_dir, save_name), 'MatData')
    MatData   = struct;
    MatData.ntr = multi_MatData_sparse_err{i_u};
    MatData = sort_and_create_class(MatData, n_class);
    save(fullfile(mua_output_dir, [save_name, '_err']), 'MatData')

end

end