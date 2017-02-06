clear
data_fp = fopen('ktracks.txt');
n = str2double(fgets(data_fp));

X = zeros(n, 5);
Y = zeros(n, 1);
for m = 1:n
    tmp = fscanf(data_fp, '%g %g %g %g %g %d', [1, 6]);
    X(m, :) = tmp(1:5);
    Y(m) = tmp(6);
end

fclose(data_fp);

save('lb_trks_no_cut.mat');