clear

% Retrieve histograms
k_norm  = K0SAnalysis('hist-normal-no-cut.txt');
k_mix   = K0SAnalysis('hist-mixed-no-cut.txt');
k_wash  = K0SAnalysis('hist-washed-no-cut.txt');

% These histogram parameters were hardcoded into the K0SAnaylsis class
nbins = 100;
start = 0.4;
final = 0.6;
bin_size = (final - start) / nbins;

datasets = {k_norm, k_mix, k_wash};
for data = datasets

    % Fill the X-axis with bin centers and Y-axis with histogram bins
    X = start+bin_size/2: bin_size : final-bin_size/2;
    Y = data{1}.mass.data;

    % Find background as linear fit
    bkg_id = [1:40, 61:100];
    bkg = zeros(nbins - 20, 2);
    bkg(:, 1) = [start : bin_size : 0.48-bin_size, 0.52+bin_size : bin_size : final];
    bkg(:, 2) = Y(bkg_id);

    % Y = m*X + C
    p = polyfit(bkg(:, 1), bkg(:, 2), 1);
    m = p(1);
    c = p(2);
    signal = Y - m*X - c;
    
    display(p);

    % Fit the results respectively
    gaussEqn = 'a*exp(-((x-b)/c)^2)';
    start_points = [max(signal) - min(signal)/2, 0.499, 0.01];
    
    %exclude = signal < mean(signal);
    %f = fit(X', signal', gaussEqn, 'Start', start_points, 'Exclude', exclude);
    f = fit(X', signal', gaussEqn, 'Start', start_points);

    display(f);
    figure();
    %plot(f, X, signal, 'o', exclude, 'g+');
    plot(f, X, signal, 'o');
end