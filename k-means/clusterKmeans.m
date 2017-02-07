%% K-means clustering

%% Main Script
clear;

load('lb_trks_no_cut.mat');
K = 5;
MAX_ITER = 30;

centroids = initCentroid(X, K);
id_X = assignCluster(X, centroids);
centroids = updateCentroids(X, id_X, K);

for m = 1:MAX_ITER
    id_X = assignCluster(X, centroids);
    centroids = updateCentroids(X, id_X, K);
  %  display(centroids);
end

display(centroids);
for m = 1:K
    fprintf('%d: %d\n', m, sum(id_X == m));
end

%% Helper functions

function centroids = initCentroid(X, K)
    
    centroids = zeros(K, size(X, 2));
    for k = 1:K
        centroids(k, :) = X(randi(size(X, 1)), :);
    end
end

function id_X = assignCluster(X, centroids)
    K = size(centroids, 1);
    [m, n] = size(X);

    x_dist = zeros(m, K);

    for k = 1:K
        centroid = centroids(k, :);
        x_rel = X - ones(m, 1) * centroid;
        x_dist(:, k) = 0;
        for j = 1:n
            x_dist(:, k) = x_dist(:, k) + x_rel(:, j).^2;
        end
    end
    [~, id_X] = min(x_dist, [], 2);
end

function centroids = updateCentroids(X, id_X, K)
    % allocates output
    centroids = zeros(K, size(X, 2));

    % find new centroids
    for k = 1:K
        centroids(k, :) = mean(X(id_X == k, :));
    end
end
