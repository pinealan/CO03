%% Anomoly Detection
%  Treats kaon tracks as anomalous tracks, attemping to fit a set of data
%  and finds the best threshold standard deviation for high F1 score
%

%% 
%  Use readTrack.m to first create X, Y, the tracks and their labels
load('labelled_tracks.mat');

% training set
Xtrain = X(1:50000, :);
Ytrain = Y(1:50000, :);

% cross valadation set
Xcross = X(50001:100000, :);
Ycross = Y(50001:100000);

% finds sample mean and variance
[mu, var] = estimateGaussian(Xtrain);
ptrain = multivariateGaussian(Xtrain, mu, var);
pcross = multivariateGaussian(Xcross, mu, var);

[epsilon, F1] = selectThreshold(Ycross, pcross);

fprintf('Best epsilon found using cross-validation: %e\n', epsilon);
fprintf('Best F1 on Cross Validation Set:  %f\n', F1);
fprintf('# Outliers found: %d\n', sum(ptrain < epsilon));