function rez = find_duplicate_merges(rez)
%Find cross-channel waveforms that are wrongly separated into different
%templates and thus large 0-lag ccg. Should only be performed after
%removing same channel duplicates. Otherwise we run the risk of merging
%small residuals with large spikes.

max_distance = 200;

ops = rez.ops;

[~, templateYs, templateXs, tempAmps] = get_templates(rez);

y_distance_matrix = templateYs - templateYs';
x_distance_matrix = templateXs - templateXs';
inverse_distance_matrix = 1./(1 + sqrt(y_distance_matrix.^2 + x_distance_matrix.^2));
inverse_distance_matrix = inverse_distance_matrix - diag(diag(inverse_distance_matrix)); % remove the diagonal of zeros

% sort by firing rate first
Nk   = numel(templateYs);
nspk = accumarray(rez.st3(:,2), 1, [Nk, 1], @sum);
[~, isort] = sort(nspk); % we traverse the set of neurons in ascending order of firing rates

fprintf('initialized spike counts\n')
remove_idx = false(size(rez.st3(:, 1)));
for j = 1:Nk
    s1_idx = rez.st3(:,2)==isort(j);
    s1 = rez.st3(s1_idx, 1)/ops.fs; % find all spikes from this cluster
    if numel(s1)~=nspk(isort(j))
        fprintf('lost track of spike counts') %this is a check for myself to make sure new cluster are combined correctly into bigger clusters
    end
    % sort all the pairs of this neuron, discarding any that have fewer spikes
    [dsort, ix] = sort(inverse_distance_matrix(isort(j),:) .* (nspk'>numel(s1)), 'descend');
    ienu = find(dsort< 1/max_distance, 1) - 1; % find the first pair which has too far of a distance (300 micrometer)

    % for all pairs closer than max_distance micrometer apart
    for k = 1:ienu
        i = ix(k);
        s2_idx = rez.st3(:,2) == i;
        s2 = rez.st3(s2_idx, 1)/ops.fs; % find the spikes of the pair
        %   Compute the ratio of incidental (less than 1ms apart) spikes.
        %   FYI for a 30k Hz recording, Kilosort uses 2.1 ms of signal for
        %   matching
        [~, cluster_to_keep] = min(tempAmps([isort(j), i]));
        d = any(abs(s1 - s2') < 1/2000, cluster_to_keep);
        if sum(d)/min([numel(s1), numel(s2)]) > 0.1 %   Too much conincident spikes
            % Remove spikes from the cluster with lower amplitude
            if cluster_to_keep == 1
                current_remove = find(s2_idx);
            elseif cluster_to_keep == 2
                current_remove = find(s1_idx);
            end
            remove_idx(current_remove(d)) = true;
%             rez = remove_spikes(rez, remove_idx, 'Incidental between clusters');
            % now merge j into i and move on
            rez.st3(rez.st3(:,2)==isort(j),2) = i; % simply overwrite all the spikes of neuron j with i (i>j by construction)
            nspk(i) = nspk(i) + nspk(isort(j)); % update number of spikes for cluster i
            fprintf('merged %d into %d \n', isort(j), i)
            break; % if a pair is found, we don't need to keep going (we'll revisit this cluster when we get to the merged cluster)
        end
    end
end
rez = remove_spikes(rez,remove_idx,'Duplicates when merged');
fprintf(1, '%d spikes removed in find_duplicate_merges.\n', sum(remove_idx));
end