classdef K0SLife < Analysis
    % version 2 of Lifetime Analysis, now stores lxy as well
    
    properties(SetAccess=protected)
        ct;         % main band histrogram
        ctside;     % side band histogram
        lxy;        % main band transverse distance
        lxyside;    % side band transverse distance
        %maindata;
        %sidedata;
    end
    
    properties(Constant, Hidden = true)
        mpi = 0.13957018;   % pion mass in GeV
        mk = 0.497614;      % kaon mass in GeV
        ups = 0.54;         % upper side band limit
        upm = 0.52;         % upper main band limit
        lowm = 0.48;        % lower main band limit
        lows = 0.46;        % lower side band limit
    end
    
    methods
        
        % constructor
        function obj = K0SLife(filename)
            if nargin == 1
                obj.GetResults(filename);
            end
            obj.minpt = 1;      % minimum helix transverse momentum
            obj.mindpv = 0;     % minimum helix impact parameter
            obj.minlxy = -999;  % minimum vertex transverse distance
            obj.maxd0 = 0.5;    % maximum vertex impact parameter 
        end
        
        function start(obj)
            obj.ct = Histogram(100, 0, 5);
            obj.ctside = Histogram(100, 0, 5);
            obj.lxy = Histogram(100, 0, 40);
            obj.lxyside = Histogram(100, 0, 40);
            fprintf(1,'K-Short lifetime analyses initialised\n');
            %obj.maindata = fopen('KLife_main_detail.dat', 'w');
            %obj.sidedata = fopen('KLife_side_detail.dat', 'w');
        end
        
        function stop(obj)
            fprintf(1,'K-Short lifetime analyses terminated\n');
            obj.plotct();
            obj.plotlxy();
            obj.plotsurf(20 : 3 : 200, 1 : 0.2 : 5);
            %fclose(obj.maindata);
            %fclose(obj.sidedata);
        end
        
        function event(obj, ev, nev)
            ntrk = numel(ev.tracks);
            hlx = Helix(ev.tracks);
            
            vctmain = zeros(ntrk, 1);
            vctside = zeros(ntrk, 1);
            vlxymain = zeros(ntrk, 1);
            vlxyside = zeros(ntrk, 1);
            
            side = 0; % counter for number of side band lifetimes
            main = 0; % counter for number of main band lifetimes
            
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
                    end
                    
                    ivtx = Vertex(hlx(it), hlx(jt));
                    
                    % stops if tracks does not intersect
                    if isempty(ivtx.vtx)
                        continue;
                    end
                    
                    ilxy = ivtx.Lxy(ev);
                    % cuts vertex transverse distance and impact parameter
                    if (ilxy < obj.minlxy)
                        continue;
                    elseif (abs(ivtx.d0(ev)) > obj.maxd0)
                        continue;
                    end
                    
                    % passed all tests, find and store mass of vertex
                    m = ivtx.mass(obj.mpi, obj.mpi);

                    if and((m >= obj.lowm), (m <= obj.upm))
                        main = main + 1;
                        vctmain(main) = ivtx.ct(ilxy, obj.mk);
                        vlxymain(main) = ilxy;
                        %fprintf(obj.maindata, '%i %i %f %f %f %f %f\n', ev.runNumber, ev.eventNumber, m, ilxy, ivtx.ct(ilxy, obj.mk), hlx(it).dpv(ev), hlx(jt).dpv(ev));
                    elseif or(and((m > obj.lows), (m < obj.lowm)), and((m > obj.upm), (m < obj.ups)))
                        side = side + 1;
                        vctside(side) = ivtx.ct(ilxy, obj.mk);
                        vlxyside(side) = ilxy;
                        %fprintf(obj.sidedata, '%i %i %f %f %f %f %f\n', ev.runNumber, ev.eventNumber, m, ilxy, ivtx.ct(ilxy, obj.mk), hlx(it).dpv(ev), hlx(jt).dpv(ev));
                    end
                end
            end
            if (main > 0)
                obj.ct.fill(vctmain(1:main));
                obj.lxy.fill(vlxymain(1:main));
            end
            if (side > 0)
                obj.ctside.fill(vctside(1:side));
                obj.lxyside.fill(vlxyside(1:side));
            end
        end
        
        % plots ct, the lifetime distritubtion
        function plotct(obj)
            x = obj.ct.bins();
            sig = obj.ct.data - obj.ctside.data;
            err = sqrt(obj.ct.data + obj.ctside.data);
            figure();
            errorbar(x, sig, err);
            xlabel('c\tau [cm]');
            ylabel('Signals');
        end
        
        % plots lxy, the tranversed distance
        function plotlxy(obj)
            x = obj.lxy.bins();
            sig = obj.lxy.data - obj.lxyside.data;
            err = sqrt(obj.lxy.data + obj.lxyside.data);
            figure();
            errorbar(x, sig, err);
            xlabel('L_{xy} [cm]');
            ylabel('Signals');
        end
        
        % variance between data and model with testing A ctau values
        function out = variance(obj, A, ctau)
            out = 0;
            n = obj.ct.bins();
            sig = obj.ct.data - obj.ctside.data;
            err = sqrt(obj.ct.data + obj.ctside.data);
            for j = 1:obj.ct.nbins()
                if err(j)~=0
                    out = out + (sig(j) - (A / ctau) * exp(-n(j) / ctau))^2 / err(j);
                end
            end
        end
        
        % plots surface of variance function with varying A and ctau
        function plotsurf(obj, A, ctau)
            n = max(size(A));
            m = max(size(ctau));
            Z = zeros(m, n);
            for j = 1:n
                for k = 1:m
                    Z(k, j) = obj.variance(A(j), ctau(k));
                end
            end
            figure();
            surf(A, ctau, Z); 
            xlabel('A');
            ylabel('c\tau [cm]');
        end
        
        % ezplot for variance function (old)
        function ezplotsurf(obj)
            var = @(x, y) obj.variance(x, y);
            figure();
            ezsurf(var, [50, 1000, 0.5, 5]);
            xlabel('A');
            ylabel('c\tau [cm]');
        end
        
        % creates a text file to store the data
        function BackResults(obj, filename)
            id = fopen(filename, 'w');
            
            % print main band data to file
            % the first five numbers stored are histogram parameters:
            % bins number, lower bound, upper bound, underflow count, overflow count
            % then prints data of the lifetime, then transverse distance
            fprintf(id, '%i %g %g %i %i ', obj.ct.nbins, obj.ct.xlo, obj.ct.xhi, obj.ct.underflow, obj.ct.overflow, obj.lxy.nbins, obj.lxy.xlo, obj.lxy.xhi, obj.lxy.underflow, obj.lxy.overflow);
            for ii = 1:obj.ct.nbins
                fprintf(id, '%i ', obj.ct.data(ii));
            end
            for ii = 1:obj.lxy.nbins
                fprintf(id, '%i ', obj.lxy.data(ii));
            end
            fprintf(id, '\n');
            
            % print side band data to file
            % same format as above
            fprintf(id, '%i %g %g %i %i ', obj.ctside.nbins, obj.ctside.xlo, obj.ctside.xhi, obj.ctside.underflow, obj.ctside.overflow, obj.lxyside.nbins, obj.lxyside.xlo, obj.lxyside.xhi, obj.lxyside.underflow, obj.lxyside.overflow);
            for ii = 1:obj.ctside.nbins
                fprintf(id, '%i ', obj.ctside.data(ii));
            end
            for ii = 1:obj.lxyside.nbins
                fprintf(id, '%i ', obj.lxyside.data(ii));
            end
            fclose(id);
        end
        
        % gets the data from a data file
        function GetResults(obj, filename)
            id = fopen(filename);
            
            n = fscanf(id, '%i', 1);        % extract ct historgram
            parameters = fscanf(id, '%g %g %i %i', 4);
            obj.ct = Histogram(n, parameters(1), parameters(2));
            obj.ct.underflow = parameters(3);
            obj.ct.overflow = parameters(4);
            
            m = fscanf(id, '%i', 1);        % extract lxy histogram
            parameters = fscanf(id, '%g %g %i %i', 4);
            obj.lxy = Histogram(n, parameters(1), parameters(2));
            obj.lxy.underflow = parameters(3);
            obj.lxy.overflow = parameters(4);
            
            v = fscanf(id, '%i', m + n);
            for ii = 1:n
                obj.ct.data(ii) = v(ii);
            end
            for ii = 1:m
                obj.lxy.data(ii) = v(ii + n);
            end

            n = fscanf(id, '%i', 1);        % extract ctside historgram
            parameters = fscanf(id, '%g %g %i %i', 4);
            obj.ctside = Histogram(n, parameters(1), parameters(2));
            obj.ctside.underflow = parameters(3);
            obj.ctside.overflow = parameters(4);
            
            m = fscanf(id, '%i', 1);        % extract lxyside histogram
            parameters = fscanf(id, '%g %g %i %i', 4);
            obj.lxyside = Histogram(n, parameters(1), parameters(2));
            obj.lxyside.underflow = parameters(3);
            obj.lxyside.overflow = parameters(4);
            
            v = fscanf(id, '%i', m + n);
            for ii = 1:n
                obj.ctside.data(ii) = v(ii);
            end
            for ii = 1:m
                obj.lxyside.data(ii) = v(ii + n);
            end
            
            fclose(id);
        end
            
    end % methods
end % classdef