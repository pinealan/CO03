clear;
RUN_NAME = 'full-mass-cut-K-20';
MAX_TRACKS = 500000;
PION_MASS = 0.13957018;

cdf = CdfService();
cdf.report = 1000;
events = cdf.load('cdf.dat');

valid_clusters = zeros(20, 1);
meta = zeros(20, 5);

% load cluster meta info
f_meta = fopen('k-means\results\full-mass-cut-K-20\clusters-meta.txt');
for n = 1:20
    meta(n, :) = fscanf(f_meta, '%d: %d %d %g %% %g %%\n', 5);

    % picks out cluster with more significant proportion of kaon children
    if meta(n, 4) >= 0.1
        valid_clusters(n) = 1;
    end
end
fclose(f_meta);

valid_clusters = find(valid_clusters);
N = numel(valid_clusters);
mass = cell(20, 1);
for n = 1:N
    mass{n} = Histogram(100, 0.4, 0.6);
end

% set analysis parameters
params.minpt    = 1;
params.mindpv   = 0.3;
params.minlxy   = 2;
params.maxd0    = 0.5;

% analysis each cluster one by one
for n = 1:N
    cluster = valid_clusters(n);
    f = strcat('k-means\results\', RUN_NAME, '\cluster-', string(cluster), '.txt');
    [track_params, ntrk] = loadCluster(f, MAX_TRACKS);

    nvtx = 0;
    masses = zeros(ntrk, 1);
    
    % pair up each track in cluster with all other tracks (in their event)
    for track1_param = track_params'
        track1 = CdfTrack(track1_param(3:7));
        helix1 = Helix(track1);

        m = track1_param(1);
        ev = events(m);
        k = 0;

        % loop through event tracks
        while k < numel(ev.tracks)
            k = k+1;
            track2 = ev.tracks(k);
            helix2 = Helix(track2);

            % skips self-crossing pair and remove the track from cdf events to
            % prevent double-counting
            if (track1 == track2)
                ev.tracks = ev.tracks([1:k-1, k+1:end]);
                continue;
            end

            % cut on track parameters
            if(~passTrackCut(helix1, helix2, ev, params))
                continue
            end

            vertex = Vertex(helix1, helix2);

            % stops if tracks does not intersect
            if isempty(vertex.vtx)
                continue;
            end

            % cut on vertex transverse distance and impact parameter
            if (vertex.Lxy(ev) < params.minlxy)
                continue;
            elseif (abs(vertex.d0(ev)) > params.maxd0)
                continue;
            end

            nvtx = nvtx + 1;
            masses(nvtx) = vertex.mass(PION_MASS, PION_MASS);
        end
    end
    
    fprintf(1, 'Cluster %d processed\n', cluster);

    if nvtx == 0
        continue;
    end
    
    mass{n}.fill(masses(1:nvtx));
    mass{n}.plot();
    xlabel('mass [GeV/c^2]');
    ylabel('entries/(2 MeV/c^2)');
    
end
