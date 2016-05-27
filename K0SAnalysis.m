classdef K0SAnalysis < Analysis
    
    properties(SetAccess=protected)
        mass;       % mass histrogram
        data;
    end
    
    properties(Constant, Hidden = true)
        mpi = 0.13957018;  % pion mass in GeV
    end
    
    methods
        
        % constructor
        function obj = K0SAnalysis(filename)
            if nargin == 1
                obj.GetResults(filename);
            elseif nargin == 0
                obj.mass = Histogram(100, 0.4, 0.6);
            end
            obj.minpt = 1;      % minimum helix transverse momentum
            obj.mindpv = 0.3;   % minimum helix impact parameter
            obj.minlxy = 2;     % minimum vertex transverse distance
            obj.maxd0 = 0.5;    % maximum vertex impact parameter 
        end
        
        % initialise the object for analysis
        function start(obj)
            obj.mass = Histogram(100, 0.4, 0.6);
            fprintf(1,'K-Short analyses initialised\n');
            obj.data = fopen('K_details.dat', 'w');
            fprintf(obj.data,'runNumber eventNumber pt1 pt2 mass\n');
        end
        
        % finishes the analysis by plotting the histogram
        function stop(obj)
            fprintf(1,'K-Short analyses terminated\n');
            if (obj.mass.max() > 0)
                obj.mass.plot();
                xlabel('mass [GeV/c^2]');
                ylabel('entries/(2 MeV/c^2)');
            else
                fprintf('No signal\n');
            end
            if obj.data ~= 0
                fclose(obj.data);
            end
        end
        
        function event(obj, ev)
            ntrk = numel(ev.tracks);
            hlx = Helix(ev.tracks);
            v = zeros(ntrk, 1);
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
                    fprintf(obj.data, '%i %i %f %f %f\n', ev.runNumber, ev.eventNumber, hlx(it).pT(), hlx(jt).pT(), v(nvtx));
                end
            end
            if (nvtx > 0)
                obj.mass.fill(v(1:nvtx));
            end
        end
        
        % creates a text file to store the data
        function BackResults(obj, filename)
            id = fopen(filename, 'w');
            fprintf(id,'%i %g %g %i %i ', obj.mass.nbins, obj.mass.xlo, obj.mass.xhi, obj.mass.underflow, obj.mass.overflow);
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