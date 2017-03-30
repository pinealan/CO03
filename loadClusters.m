function [tracks, ntrk] = loadClusters(run_name, cluster_ids, max_tracks)
    ntrk = 0;    
    tracks = zeros(max_tracks, 8);
    
    for cluster = cluster_ids
        f = strcat('k-means\results\', run_name, '\cluster-', string(cluster), '.txt');
        
        [cluster_tracks, cluster_ntrk] = loadCluster(f, max_tracks);
        tracks(ntrk+1: ntrk+cluster_ntrk, :) = cluster_tracks;
        ntrk = ntrk + cluster_ntrk;

        fprintf(1, strcat('Loaded cluster ', string(cluster), '\n'));
    end
    
    tracks = tracks(1:ntrk, :);
end