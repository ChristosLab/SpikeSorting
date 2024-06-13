%%  Distance matrix of cluster xy position estimated from 2D template
function distance_matrix = compute_xy_distance(sp, varargin)
y_distance_matrix = sp.clusterYs - sp.clusterYs';
x_distance_matrix = sp.clusterXs - sp.clusterXs';
distance_matrix = sqrt(y_distance_matrix.^2 + x_distance_matrix.^2);
end