ka = K0SAnalysis();
ka.minpt = 0;
ka.minlxy = 0;
ka.tracks_fname = 'ktrks_no_cut.txt';
loop = Loop('cdf.dat');

loop.run(ka);

clear
data_fp = fopen('ktrks_no_cut.txt');

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

save('lb_trks_no_cut.mat');