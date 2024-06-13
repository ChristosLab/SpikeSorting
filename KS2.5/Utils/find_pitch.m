function [x_pitch, y_pitch] = find_pitch(channel_positions)
xs = unique(channel_positions(:, 1));
x_pitch = diff(sort(xs));
y_pitch = max(channel_positions(:, 2)) - min(channel_positions(:, 2));
for i = 1:numel(xs)
    y_pitch = min(y_pitch, min(diff(sort(channel_positions(channel_positions(:, 1) == xs(i), 2)))));
end
end