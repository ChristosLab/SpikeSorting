function trial_angle = get_trial_angle(MatData)
trial_angle = arrayfun(@(x) atan2d(x.frame(1).stim.end(2), x.frame(1).stim.end(1)), MatData.ClassStructure([MatData.trials.Class]));
end