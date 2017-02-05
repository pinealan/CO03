%% Anomoly Detection
%   Treats kaon tracks as anomalous tracks, attemping to fit a set of data
%   and finds the best threshold standard deviation for high F1 score
%

%% Main Script
%   ReadTrack.m should first be ran to create X, Y, the tracks and their labels
clear;
load('labelled_tracks.mat');

% training set
Xtrain = X(1:50000, :);
Ytrain = Y(1:50000);

% cross valadation set
Xcross = X(50001:100000, :);
Ycross = Y(50001:100000);

% feature normalisation
Xtrain = Xtrain ./ (max(Xtrain) - min(Xtrain));     % only works in MATLAB 2016

% finds sample mean and variance
[mu, var] = estimateGaussian(Xtrain);
pcross = computeProb(Xcross, mu, var);

[epsilon, F1] = selectThreshold(Ycross, pcross);

fprintf('Detects anomaly in 5D feature-space\n')
fprintf('Best epsilon found using cross-validation: %e\n', epsilon);
fprintf('Best F1 on Cross Validation Set:  %f\n', F1);
fprintf('# Outliers found: %d / %d\n\n', sum(pcross < epsilon), size(Xtrain, 1));

para = {'cotTheta', 'curvature', 'd0', 'phi0', 'z0'};

for m = 1:1
    for n = 2:3
        Xtrain_2d = Xtrain(:, [m, n]);
        
        Xcross_2d = Xcross(:, [m, n]);
        
        [mu, var] = estimateGaussian(Xtrain_2d);
        ptrain_2d = computeProb(Xtrain_2d, mu, var);
        pcross_2d = computeProb(Xcross_2d, mu, var);

        [epsilon, F1] = selectThreshold(Ycross, pcross_2d);

        visualiseFit(Xtrain_2d, mu, var);
        findOutliers(Xtrain_2d, ptrain_2d, epsilon);
        
        fprintf(['Anomlies in featureas ', para{m}, ' vs ', para{n}, '\n']);
        fprintf('Best epsilon found using cross-validation: %e\n', epsilon);
        fprintf('Best F1 on Cross Validation Set:  %f\n', F1);
        fprintf('# Outliers found: %d / %d\n\n', sum(ptrain_2d < epsilon), size(Xtrain_2d, 1));
        xlabel(para{m})
        ylabel(para{n})
        
    end
end

%% Helper functions

function [mu, sigma2] = estimateGaussian(X)
% This function estimates the parameters of a Gaussian distribution using the data in X
%   [mu sigma2] = estimateGaussian(X), 
%   The input X is the dataset with each n-dimensional data point in one row
%   The output is an n-dimensional vector mu, the mean of the data set
%   and the variances sigma^2, an n x 1 vector
% 
    m = size(X, 1);

    mu = mean(X);
    sigma2 = 1/m*(sum((X - ones(m, 1)*mu).^2));
end

function visualiseFit(X, mu, var)
% Visualize the dataset and its estimated distribution.
%   This visualization shows you the probability density function of the Gaussian distribution. 
%   Each example has a location (x1, x2) that depends on its feature values.
%
    [X1,X2] = meshgrid(0:.1:1.2);
    Z = computeProb([X1(:) X2(:)],mu,var);
    Z = reshape(Z,size(X1));

    figure();
    plot(X(:, 1), X(:, 2),'bx');
    hold on;
    % Do not plot if there are infinities
    if (sum(isinf(Z)) == 0)
        contour(X1, X2, Z, 10.^(-20:3:0)');
    end
    hold off;
end

function findOutliers(X, p, epsilon)
    outliers = find(p < epsilon);
    
    hold on
    plot(X(outliers, 1), X(outliers, 2), 'ro', 'LineWidth', 1, 'MarkerSize', 8);
    hold off
end