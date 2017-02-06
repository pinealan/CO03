classdef K0SAnalysis < Analysis
    
    properties(Access=public)
        signal_fname;
        tracks_fname;
        FLAG_PRINT_EVENT_DETAILS;
    end
    
    properties(Constant, Hidden = true)
        mpi = 0.13957018;  % pion mass in GeV
    end
    
    properties
        histParas = [100, 0.4, 0.6];  % array of size 3 of histogram parameters
    end
    
    methods
        
        % Constructor
        function obj = K0SAnalysis(filename)
            if nargin == 1
                supargs = filename;
            else
                supargs = {};
            end
            obj = obj@Analysis(supargs{:});
            obj.minpt = 1;      % minimum helix transverse momentum
            obj.mindpv = 0.3;   % minimum helix impact parameter
            obj.minlxy = 2;     % minimum vertex transverse distance
            obj.maxd0 = 0.5;    % maximum vertex impact parameter
            obj.signal_fname = 'K_details.txt';
            obj.tracks_fname = 'K_tracks.txt';
            obj.FLAG_PRINT_EVENT_DETAILS = 0;
        end
        
        function start(obj)
            obj.start@Analysis();
            
            % prepares reconstruced parents output file
            obj.fsig = fopen(obj.signal_fname, 'w');
            fprintf(obj.fsig,'runNumber eventNumber pt1 pt2 mass\n');

            % prepares labelled data output file
            obj.ftrk = fopen(obj.tracks_fname, 'w');
        end
        
        function event(obj, ev)
            ntrk = numel(ev.tracks);
            hlx = Helix(ev.tracks);
            v = zeros(ntrk, 1);
            labels = zeros(ntrk, 1);
            
            nvtx = 0;  % counter for number of detected decays (signal)

            % loop over all combinations of track pairs
            for it = 1:(ntrk - 1)
                for jt = (it + 1):ntrk
                    
                    % checks that the tracks are opposite charge
                    if ((ev.tracks(it).curvature * ev.tracks(jt).curvature) > 0)
                        continue;
                    end
                    
                    % checks the parameter related to each track
                    if (abs(hlx(it).pT()) < obj.minpt)
                        continue;
                    elseif (abs(hlx(jt).pT()) < obj.minpt)
                        continue;
                    elseif (abs(hlx(it).dpv(ev)) < obj.mindpv)
                        continue;
                    elseif (abs(hlx(jt).dpv(ev)) < obj.mindpv)
                        continue;
                    end
                    
                    ivtx = Vertex(hlx(it), hlx(jt));
                    
                    % stops if tracks does not intersect
                    if isempty(ivtx.vtx)
                        continue;
                    end
                    
                    % cuts vertex transverse distance and impact parameter
                    if (ivtx.Lxy(ev) < obj.minlxy)
                        continue;
                    elseif (abs(ivtx.d0(ev)) > obj.maxd0)
                        continue;
                    end
                    
                    % passed all tests, find and store mass of vertex
                    nvtx = nvtx + 1;
                    v(nvtx) = ivtx.mass(obj.mpi, obj.mpi);
                    fprintf(obj.fsig, '%i %i %f %f %f\n', ...
                        ev.runNumber, ev.eventNumber, hlx(it).pT(), hlx(jt).pT(), v(nvtx));

                    % labels whether track came from kaon or not
                    labels(it) = 1;
                    labels(jt) = 1;                    
                end
            end
            if (nvtx > 0)
                obj.mass.fill(v(1:nvtx));
            end
            
            obj.labelTracks(ev, ntrk, labels);
        end
        
        % prints labelled tracks to new file
        function labelTracks(obj, ev, ntrk, labels)
            if obj.FLAG_PRINT_EVENT_DETAILS == 1
                fprintf(obj.ftrk, '%d %d %g %g %d\n', ...
                ev.runNumber, ev.eventNumber, ev.vertex(1), ev.vertex(2), ntrk);
            end
            
            for m = 1:ntrk
                fprintf(obj.ftrk, '%g %g %g %g %g %d\n', ...
                    ev.tracks(m).cotTheta, ...
                    ev.tracks(m).curvature, ...
                    ev.tracks(m).d0, ...
                    ev.tracks(m).phi0, ...
                    ev.tracks(m).z0, ...
                    labels(m) ...
                );
            end
        end
        
        % creates a text file to store the data
        function BackResults(obj, filename)
            id = fopen(filename, 'w');
            fprintf(id,'%i %g %g %i %i ', ...
                obj.mass.nbins, obj.mass.xlo, obj.mass.xhi, obj.mass.underflow, obj.mass.overflow);
            for ii = 1:obj.mass.nbins
                fprintf(id, '%i ', obj.mass.data(ii));
            end
            fclose(id);
        end
        
        % gets the data from a data file
        function GetResults(obj, filename)
            id = fopen(filename);
            n = fscanf(id, '%i', 1);
            xbnd = fscanf(id, '%g %g', 2);
            v = fscanf(id, '%i', (n + 2));
            obj.mass = Histogram(n, xbnd(1), xbnd(2));
            obj.mass.underflow = v(1);
            obj.mass.overflow = v(2);
            for ii = 3:(n + 2)
                obj.mass.data(ii - 2) = v(ii);
            end
            fclose(id);
        end
        
    end % methods
end % classdef