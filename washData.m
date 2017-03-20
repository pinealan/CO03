clear;
MAX_TRACKS = 500000;
MAX_EVENTS = 10000;
RUN_NAME = 'full-mass-cut-raw-extended-K-20';

% Initialse handle to cdf dataset
cdf = CdfHandle();

% Loads dataset
events = cdf.load('cdf.dat');

% Reads tracks from cluster files
validClusterTracks = CdfTrack(zeros(5, MAX_TRACKS));
validClusters = {'1', '6', '7', '8', '11', '16', '17', '20'};
%f_meta = fopen('k-means\results\full-mass-cut-K-20\clusters-meta.txt');
ntrks = 0;

for cluster = validClusters
    f = fopen(strcat('k-means\results\', RUN_NAME, '\cluster-', cluster{1}, '.txt'));
    while 1
        s = fgets(f);
        if s == -1
            break;  % end of file
        end
        
        pars = sscanf(s, '%g %g %g %g %g %d %d\n', 5);
        track = CdfTrack(pars);
        ntrks = ntrks + 1;
        validClusterTracks(ntrks) = track;

        % @IMPORTANT
        % Note to self:
        %  Never in matlab resize big arrays, dynamic memory allocation is
        %  horrendous and run time can increased to exponential time
        %  (not sure about that, but it felt like it behaved that way)
        %
        %  The following was a benchmark, it took over half an hour to load
        %  1 cluster when the track array was dynamically sized, but only 2
        %  seconds to load 10 clusters when it was pre-allocated
        
%         if ntrks > MAX_TRACKS
%             validClusterTracks = [validClusterTracks track];
%         else
%             validClusterTracks(ntrks) = track;
%         end
    end
    
    fclose(f);
    fprintf(1, strcat('Loaded cluster ', cluster{1}, '\n'));
end

validClusterTracks = validClusterTracks(1: ntrks);
reconstructedEvents = CdfEvent(MAX_EVENTS);
evIds = zeros(1, MAX_EVENTS);
nev = 0;
ntrk = 0;
reconEvTrks = zeros(1, MAX_EVENTS);

for track = validClusterTracks
    ev = cdf.getEventByTrack(events, track);

    ntrk = ntrk + 1;
    if mod(ntrk, 100) == 0
        fprintf(1, '%d, tracks examined\n', ntrk);
    end
    
    if isinteger(ev)
        continue
    end
    
    evId = ev.eventNumber;
    if sum(evIds == evId) == 0
        nev = nev + 1;
        evIds(nev) = ev.eventNumber;
        reconstructedEvents(nev) = CdfEvent(ev.runNumber, ev.eventNumber, ev.vertex(1), ev.vertex(2));
        reconstructedEvents(nev).tracks = CdfTrack(zeros(5, 250));
    end
    reconEvTrks(evIds == evId) = reconEvTrks(evIds == evId) + 1;
    reconstructedEvents(evIds == evId).tracks(reconEvTrks(evIds == evId)) = track;
end

resconstructedEvents = resconstructedEvents(1:nev);
for n = 1:nev
    resconstructedEvents(n).tracks = resconstructedEvents(n).tracks(1:reconEvTrks(n));
end

cdf.createCdfDataFile('cdf-washed-k20.dat', resconstructedEvents);
