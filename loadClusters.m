function [tracks, ntrks] = loadClusters(run_name, cluster_ids, max_tracks)
    ntrks = 0;    
    tracks = zeros(max_tracks, 8);
    
    for cluster = cluster_ids
        f = fopen(strcat('k-means\results\', run_name, '\cluster-', string(cluster), '.txt'));
        
        while 1
            s = fgets(f);
            if s == -1
                break;  % end of file
            end

            pars = sscanf(s, '%d %d %g %g %g %g %g %g %d', 8);
            ntrks = ntrks + 1;
            tracks(ntrks, :) = pars;
        end

        fclose(f);
        fprintf(1, strcat('Loaded cluster ', string(cluster), '\n'));
    end
    tracks = tracks(1:ntrks, :);
end