function [tracks, ntrk] = loadCluster(f_name, max_tracks)
    ntrk = 0;
    tracks = zeros(max_tracks, 8);
    f = fopen(f_name);

    while 1
        s = fgets(f);
        if s == -1
            break;  % end of file
        end

        pars = sscanf(s, '%d %d %g %g %g %g %g %g %d', 8);
        ntrk = ntrk + 1;
        tracks(ntrk, :) = pars;
    end
    tracks = tracks(1:ntrk, :);
    fclose(f);
end