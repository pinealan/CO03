clear;
MAX_TRACKS = 500000;
MAX_EVENTS = 10000;
RUN_NAME = 'full-mass-cut-raw-extended-K-20';

% Initialse handle to cdf dataset
cdf = CdfHandle();

% Loads dataset
data = cdf.load('cdf.dat');
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
        
        pars = sscanf(s, '%g %g %g %g %g\n', 5);
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

