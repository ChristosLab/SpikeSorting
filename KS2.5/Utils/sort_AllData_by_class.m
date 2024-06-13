function MatData = sort_AllData_by_class(AllData, state_code_threshold)
n_class = numel(AllData.ClassStructure);
MatData.ClassStructure = AllData.ClassStructure;
MatData.class = struct(zeros([0, n_class]));
class_trial_counter = zeros(1, n_class); % Keeps track of trials assigned to each class
for i_trial = 1:numel(AllData.trials)
    current_class_ = AllData.trials(i_trial).Class;
    AllData.trials(i_trial).trialnum = i_trial;
    if AllData.trials(i_trial).Statecode < state_code_threshold
        continue % Only includes trials advanced to a certain state code
    end
    class_trial_counter(current_class_) = class_trial_counter(current_class_) + 1;
    MatData.class(current_class_).ntr(class_trial_counter(current_class_)) = AllData.trials(i_trial);
end