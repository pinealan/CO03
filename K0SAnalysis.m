classdef K0SAnalysis < Analysis
    
    properties(Constant, Hidden = true)
        mpi = 0.13957018;  % pion mass in GeV
    end
    
    properties
        mass; % mass histrogram
        fsig; % output file: list of found kaon parent signals
        ftrk; % output file: list of tracks and binary classification as kaon chilhren
        hist_paras = [100, 0.4, 0.6];   % array of size 3 of histogram parameters
    end
    
    methods
        
        % Constructor
        function obj = K0SAnalysis(filename)
        
            % initialise kaon analysis parameters
            obj.minpt   = 1;        % minimum helix transverse momentum
            obj.mindpv  = 0.3;      % minimum helix impact parameter
            obj.minlxy  = 2;        % minimum vertex transverse distance
            obj.maxd0   = 0.5;      % maximum vertex impact parameter

            % other hyper parameters, for data analytics/washing
            obj.opts.mass_center = 0.5;
            obj.opts.mass_window = 0.02 ;

            if nargin == 1
                obj.getResult(filename);
            end
        end
        
        function start(obj)
            % empties and reinitialise the histogram
            obj.mass = Histogram(obj.hist_paras(1), obj.hist_paras(2), obj.hist_paras(3));

            % create txt file for storing signals
            if obj.opts.backup_signals
                obj.fsig = fopen(obj.opts.signal_fname, 'w');
            end

            % create txt file for storing all process tracks
            if obj.opts.backup_tracks
                obj.ftrk = fopen(obj.opts.tracks_fname, 'w');
            end
            
            start@Analysis(obj);
        end
        
        function stop(obj)
            % plots graph
            if (obj.mass.max() > 0)
                obj.mass.plot();
                xlabel('mass [GeV/c^2]');
                ylabel('entries/(2 MeV/c^2)');
            else
                fprintf('No signal\n');
            end
            
            % closes output files
            if obj.fsig ~= 0
                fclose(obj.fsig);
            end
            if obj.ftrk ~= 0
                fclose(obj.ftrk);
            end
            
            stop@Analysis(obj);
        end
        
        function event(obj, ev, nev)
            ntrk    = numel(ev.tracks);
            hlxs    = Helix(ev.tracks);
            
            masses    = zeros(ntrk, 1);
            labels  = zeros(ntrk, 1);
            
            nvtx = 0;  % counter number of detected signals (kaon decay vertex)

            % loop over all combinations of track pairs
            for m = 1:(ntrk - 1)
                helix1 = hlxs(m);
                
                for n = (m + 1):ntrk
                    helix2 = hlxs(n);
                    
                    % checks that the tracks are opposite charge
                    if ((helix1.curvature * helix2.curvature) > 0)
                        continue;
                    end
                    
                    % checks the parameter related to each track
                    if (abs(helix1.pT()) < obj.minpt)
                        continue;
                    elseif (abs(helix2.pT()) < obj.minpt)
                        continue;
                    elseif (abs(helix1.dpv(ev)) < obj.mindpv)
                        continue;
                    elseif (abs(helix2.dpv(ev)) < obj.mindpv)
                        continue;
                    end
                    
                    ivtx = Vertex(helix1, helix2);
                    
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
                    masses(nvtx) = ivtx.mass(obj.mpi, obj.mpi);
                    
                    % label tracks from kaon if mass falls in window
                    if obj.genuineMass(masses(nvtx))
                        labels(m) = 1;
                        labels(n) = 1;                    
                    end
                end
            end
            
            if (nvtx > 0)
                obj.mass.fill(masses(1:nvtx));
            end
            
            if obj.opts.backup_tracks
                obj.labelTracks(hlxs, ntrk, ev, nev, labels);
            end
        end

        % checks if a vertex mass falls within pre-defined window
        function res = genuineMass(obj, mass)
            res = mass < obj.opts.mass_center + obj.opts.mass_window && ...
                  mass > obj.opts.mass_center - obj.opts.mass_window;
        end

        % prints labelled tracks to new file
        function labelTracks(obj, hlxs, ntrk, ev, nev, labels)
            for m = 1:ntrk
                fprintf(obj.ftrk, '%d %d %g %g %g %g %g %g %d\n', ...
                    nev, ...
                    m, ...
                    hlxs(m).cotTheta, ...
                    hlxs(m).curvature, ...
                    hlxs(m).d0, ...
                    hlxs(m).phi0, ...
                    hlxs(m).z0, ...
                    hlxs(m).dpv(ev), ...
                    labels(m) ...
                );
            end
        end
        
        % store histogram data in txt file
        function backResult(obj, filename)
            id = fopen(filename, 'w');

            % histogram meta-data
            fprintf(id,'%i %g %g %i %i ', ...
                obj.mass.nbins, obj.mass.xlo, obj.mass.xhi, obj.mass.underflow, obj.mass.overflow);

            % bin data
            for ii = 1:obj.mass.nbins
                fprintf(id, '%i ', obj.mass.data(ii));
            end

            fclose(id);
        end
        
        % retrieve stored histogram data from txt file
        function getResult(obj, filename)
            id = fopen(filename);
            
            n = fscanf(id, '%i', 1);
            head = fscanf(id, '%g %g %i %i', 4);
            xlo = head(1);
            xhi = head(2);
            uf  = head(3);
            of  = head(4);
            pars = fscanf(id, '%i', (n));

            % initialise histogram
            obj.mass = Histogram(n, xlo, xhi);
            obj.mass.underflow = uf;
            obj.mass.overflow = of;
            
            for k = 1:n
                obj.mass.data(k) = pars(k);
            end
            
            fclose(id);
        end
        
    end % methods
end % classdef