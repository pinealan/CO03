classdef LambdaAnalysis < Analysis
    
    properties(SetAccess=protected)
        mass;       % mass histrogram        
        data;
    end
    
    properties(Constant, Hidden)
        mpi = 0.13957018;  % pion mass in GeV/c^2
        mp = 0.937272046;  % proton mass in GeV/c^2
    end
    
    methods
        
        % constructor
        function obj = LambdaAnalysis(filename)
            if nargin == 1
                obj.GetResults(filename);
            elseif nargin == 0
                obj.mass = Histogram(100, 1, 1.2);
            end
            obj.minpt = 2;
            obj.mindpv = 0.2;
            obj.minlxy = 2;
            obj.maxd0 = 0.5;
        end
        
        % initialise the object for analysis
        function start(obj)
            obj.mass = Histogram(100, 1, 1.2);
            fprintf(1,'Lambda analyses initialised\n');
            obj.data = fopen('L_details.dat', 'w');
            fprintf(obj.data,'runNumber eventNumber pt1 pt2 mass');
        end
        
        function stop(obj)
            fprintf(1,'Lambda analyses terminated\n');
            if (obj.mass.max() > 0)
                obj.mass.plot();
                xlabel('mass [GeV/c^2]');
                ylabel('entries/(2 MeV/c^2)');
            end
            fclose(obj.data);
        end
        
        function event(obj, ev)
            ntrk = numel(ev.tracks);
            hlx = Helix(ev.tracks);
            v = zeros(ntrk, 1);
            rlvtx = 0;  % counter for number of detected decays
            
            % loop over all combinations of track pairs
            for it = 1:(ntrk - 1)
                for jt = (it + 1):ntrk
                    
                    % checks that the tracks are opposite charge
                    if (ev.tracks(it).curvature * ev.tracks(jt).curvature > 0)
                        continue;
                    end
                    
                    % checks the parameter related to each track
                    pt1 = hlx(it).pT();
                    pt2 = hlx(jt).pT();
                    
                    if and((pt1 < obj.minpt), (pt2 < obj.minpt))
                        continue;
                    elseif (hlx(it).dpv(ev) < obj.mindpv)
                        continue;
                    elseif (hlx(jt).dpv(ev) < obj.mindpv)
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
                    
                    % passed all tests, calculate invariant mass of vertex
                    rlvtx = rlvtx + 1;
                    if (pt1 > pt2)
                        v(rlvtx) = ivtx.mass(obj.mp, obj.mpi);
                    else
                        v(rlvtx) = ivtx.mass(obj.mpi, obj.mp);
                    end
                    fprintf(obj.data, '%i %i %g %g %g\n', ev.runNumber, ev.eventNumber, hlx(it).pT(), hlx(jt).pT(), v(rlvtx));
                end
            end
            if (rlvtx > 0)
                obj.mass.fill(v(1:rlvtx));
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
        
    end
end