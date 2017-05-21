% The script finds the relevant signals from the output files and print
% them onto a .txt file

detail = fopen('K_details.dat', 'r');
sig = fopen('K-sig.txt', 'w');

tline = fgets(detail);


while ischar(tline)
    y = str2num(tline);
    if ((y(5) > 0.48) && (y(5) < 0.52))
        fprintf(sig, '%s', tline);
    end
    tline = fgets(detail);
end

fclose(detail);
fclose(sig);
clear detail sig y tline