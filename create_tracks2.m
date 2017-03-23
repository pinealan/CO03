% constants, filename, run number, analysis type, version
clear
RUN_NAME = 'full-mass-cut';

% initialise analyses
ka = K0SAnalysis();

%ka.mindpv = 0;
%ka.minpt = 0;
%ka.minlxy = -999;
%ka.maxd0 = 99;

ka.opts.backup_tracks = 1;
ka.tracks_fname = strcat('ktrks-', RUN_NAME, '.txt');

% starts analysis loop
loop = Loop('cdf.dat');
loop.run(ka);

% saves the histogram plot
saveas(figure(1), strcat('hist-', RUN_NAME, '.fig'));

% creates matlab workspace file from labelled tracks file
data_fp = fopen(strcat('ktrks-', RUN_NAME, '.txt'));

% intialise input buffers
n = 500000;
m = 1;
X = zeros(n, 8);
Y = zeros(n, 1);

tmp = fscanf(data_fp, '%d %d %g %g %g %g %g %g %d', [1, 9]);
while (feof(data_fp) == 0)
    X(m, :) = tmp(1:8);
    Y(m) = tmp(9);
    m = m+1;
    
    if mod(m, 1000) == 0
        fprintf(1, 'Number of tracks processed %d', m);
    end
    
    tmp = fscanf(data_fp, '%d %d %g %g %g %g %g %g %d', [1, 9]);
end
X = X(1:m, :);
Y = Y(1:m);

fclose(data_fp);

save(strcat('ktrks-', RUN_NAME, '.mat'));