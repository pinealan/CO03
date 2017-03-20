%% K-means clustering

%% Main Script
clear;

% constants / parameters
PARAS = {'cotThe', 'curv', 'dpv', 'phi0', 'z0'};
CUT_NAME = 'full-mass-cut-raw-extended';
MAT_FILE = strcat('ktrks-', CUT_NAME, '.mat');
K = 20;
MAX_ITER = 80;
FLAG_CREATE_TXT = true;

% loads X = tracks, Y = labels
load(MAT_FILE);

% prepares tracks
X_mod = X(1:5, :);
X_mod(:, [1, 3]) = abs(X_mod(:, [1, 3]));

%X = normaliseFeatures(X);
%range = 1;
range = max(X_mod) - min(X_mod);
X_mod = X_mod ./ (max(X) - min(X_mod));

% Step 1: Initialise centroids + Assign centroids 
centroids = initCentroid(X_mod, K);
id_X = assignCluster(X_mod, centroids);
centroids = updateCentroids(X_mod, id_X, K);

% Step 2: Iteration
for m = 1:MAX_ITER
    id_X = assignCluster(X_mod, centroids);
    centroids = updateCentroids(X_mod, id_X, K);
  %  display(centroids);
end

disp(PARAS);
display(centroids.*range);

% allocates matrix to store cluster meta-info
clusterDetails = zeros(K, 5);

fprintf('Cluster  #Tracks  #K-child  %%K-child  %%K-child-total\n');
% prints results
for m = 1:K
    clusterSize = sum(id_X == m);
    clusterKaon = sum(Y(id_X == m));
    
    clusterDetails(m, :) = [m, clusterSize, clusterKaon, 100*clusterKaon/clusterSize, 100*clusterKaon/sum(Y)];
    
    fprintf('    %2.d: %7d %7d     %-6.3f%%     %5.2f%%\n', clusterDetails(m, :));
    
    
    X_m = X(id_X == m, :);
    %Y_m = Y(id_X == m);
    if (FLAG_CREATE_TXT)
        writeCluster(X_m, m, CUT_NAME, K);
    end
end

if(FLAG_CREATE_TXT)
    writeClusterMeta(clusterDetails, CUT_NAME, K);
end

visualise(X_mod, Y, centroids, CUT_NAME)

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

function writeCluster (X, m, CUT_NAME, K)
    fullpath = mfilename('fullpath');
    folder = strfind(fullpath, '\');
    path = fullpath(1:folder(end));

    % @HARDCODE @CHANGE THIS
    f = fopen(strcat(path, 'results/', CUT_NAME, '-K-', string(K), '/cluster-', string(m), '.txt'), 'w');
    for n = 1:size(X, 1)
        fprintf(f, '%g %g %g %g %g %d %d\n', X(n, 1), X(n, 2), X(n, 3), X(n, 4), X(n, 5), X(n, 6), X(n, 7));
    end
    fclose(f);
end

function writeClusterMeta (clusterDetails, CUT_NAME, K)
    fullpath = mfilename('fullpath');
    folder = strfind(fullpath, '\');
    path = fullpath(1:folder(end));
    
    f = fopen(strcat(path, 'results/', CUT_NAME, '-K-', string(K), '/clusters-meta', '.txt'), 'w');
    for n = 1:size(clusterDetails, 1)
        fprintf(f, '    %2.d: %7d %7d     %-6.3f%%     %5.2f%%\n', clusterDetails(n, :));
    end
    fclose(f);
end

function visualise(X, Y, centroids, CUT_NAME)
    % drops the phi0 and z0 terms
    K = size(centroids, 1);
    centroids = centroids(:, [1, 2, 3]);
    X = X(:, [1, 2, 3]);
    figure();
    hold on
    whitebg('k');
    xlabel('cotThe'); % beamline
    ylabel('curv');
    zlabel('dpv');
    samples = randi(size(X, 1), 1, 10000);
    plot3(X(samples, 1), X(samples, 2), X(samples, 3), 'b.')
    plot3(X(Y == 1, 1), X(Y == 1, 2), X(Y == 1, 3), 'gx')
    plot3(centroids(:, 1), centroids(:, 2), centroids(:, 3), 'm*')
    saveas(figure(1), char(strcat('results/scatter', CUT_NAME, '-K', string(K))), 'fig');
end