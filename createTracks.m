% constants, filename, run number, analysis type, version
clear
RUN_NAME = 'mass_pt_lxy_cut';

% initialise analyses
ka = K0SAnalysis();
ka.mindpv = 0;
%ka.minpt = 0;
%ka.minlxy = -999;
ka.maxd0 = 99;
ka.FLAG_CREATE_DETAILS_FILE = 0;
ka.tracks_fname = strcat('ktrks_', RUN_NAME, '.txt');

% starts analysis loop
loop = Loop('cdf.dat');
loop.run(ka);

% saves the histogram plot
saveas(figure(1), strcat('hist_', RUN_NAME, '.fig'));

% prepares to create matlab workspace file from labelled tracks file

data_fp = fopen(strcat('ktrks_', RUN_NAME, '.txt'));

% intialise input buffers
n = 500000;
m = 1;
X = zeros(n, 5);
Y = zeros(n, 1);

tmp = fscanf(data_fp, '%g %g %g %g %g %d', [1, 6]);
while (feof(data_fp) == 0)
    
    X(m, :) = tmp(1:5);
    Y(m) = tmp(6);
    
    % doubles buffer size when overflowing
    m = m+1;
    if m > n
        X = [X; zeros(n, 5)];
        Y = [Y; zeros(n, 1)];
        n = n*2;
    end
        
    tmp = fscanf(data_fp, '%g %g %g %g %g %d', [1, 6]);
end
X = X(1:m, :);
Y = Y(1:m);

fclose(data_fp);

save(strcat('ktrks_', RUN_NAME, '.mat'));