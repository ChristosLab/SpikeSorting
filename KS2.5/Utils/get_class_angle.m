function class_angle = get_class_angle(MatData)
class_angle = arrayfun(@(x) atan2d(x.frame(1).stim.end(2), x.frame(1).stim.end(1)), MatData.ClassStructure);
end