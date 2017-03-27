clear;
MAX_TRACKS = 500000;
MAX_EVENTS = 10000;
RUN_NAME = 'full-mass-cut-K-20';

% Reads tracks from cluster files
valid_clusters = zeros(1, 20);
meta = zeros(20, 5);

f_meta = fopen('k-means\results\full-mass-cut-K-20\clusters-meta.txt');
for n = 1:20
    meta(n, :) = fscanf(f_meta, '%d: %d %d %g %% %g %%\n', 5);

    if meta(n, 4) >= 0.1
        valid_clusters(n) = 1;
    end
end
fclose(f_meta);

valid_clusters = find(valid_clusters);
valid_tracks = zeros(MAX_TRACKS, 8);

for cluster = valid_clusters
    f = fopen(strcat('k-means\results\', RUN_NAME, '\cluster-', string(cluster), '.txt'));
    while 1
        s = fgets(f);
        if s == -1
            break;  % end of file
        end
        
        pars = sscanf(s, '%d %d %g %g %g %g %g %g %d', 8);
        ntrks = ntrks + 1;
        valid_tracks(ntrks, :) = pars;
    end
    
    fclose(f);
    fprintf(1, strcat('Loaded cluster ', string(cluster), '\n'));
end

valid_tracks = valid_tracks(1: ntrks, :);

% Initialse handle to cdf dataset
cdf = CdfHandle();
events = cdf.load('cdf.dat');
reconstructed_events = MockEvent(MAX_EVENTS);
nev = 0;

for j = 1:numel(events)
    ev = events(j);
    trks = valid_tracks(valid_tracks(:, 1) == j, :);
    if numel(find(trks)) == 0
        continue;
    end
    reconstructed_events(j).setRunNumber(ev.runNumber);
    reconstructed_events(j).setEventNumber(ev.eventNumber);
    reconstructed_events(j).setVertex(ev.vertex);
    reconstructed_events(j).setTracks(CdfTrack(trks(:, 3:7)'));
    nev = nev + 1;
end

reconstructed_events = reconstructed_events(1:nev);

cdf.createCdfDataFile('cdf-washed-k20.dat', reconstructed_events);