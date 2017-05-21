tic

clear;
RUN_NAME = 'full-mass-cut-K-20';
MAX_TRACKS = 500000;
PION_MASS = 0.13957018;

cdf = CdfService();
cdf.report = 1000;
events = cdf.load('cdf.dat');

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
tracks_params = loadClusters(RUN_NAME, valid_clusters, MAX_TRACKS);

params.minpt    = 0;
params.mindpv   = 0;
params.minlxy   = -999;
params.maxd0    = 99;

ntrk = size(tracks_params, 1);
nvtx = 0;
masses = zeros(ntrk, 1);
report = 10000;
k = 0; % counter

for track1_param = tracks_params'
    track1 = CdfTrack(track1_param(3:7));
    helix1 = Helix(track1);

    m = track1_param(1);
    n = 0;
    k = k + 1;
    ev = events(m);

    while n < numel(ev.tracks)
        n = n+1;
        track2 = ev.tracks(n);
        helix2 = Helix(track2);
        
        % skips self-crossing pair and remove the track from cdf events to
        % prevent double-counting
        if (track1 == track2)
            ev.tracks = ev.tracks([1:n-1, n+1:end]);
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
    
    if mod(k, report) == 0
        fprintf(1, '%d tracks processed\n', k);
    end
end

toc

mass = Histogram(100, 0.4, 0.6);
mass.fill(masses(1:nvtx));
mass.plot();

xlabel('mass [GeV/c^2]');
ylabel('entries/(2 MeV/c^2)');

%saveas(figure(1), 'fig/hist-mixed-pt-cut', 'fig');
%saveas(figure(1), 'fig/hist-mixed-pt-cut', 'png');

ka = K0SAnalysis();
ka.mass     = mass;
ka.minpt    = params.minpt;
ka.mindpv   = params.mindpv;
ka.minlxy   = params.minlxy;
ka.maxd0    = params.maxd0;

ka.backResult('hist-mixed-no-cut.txt');