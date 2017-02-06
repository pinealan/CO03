classdef Analysis < handle & matlab.mixin.Heterogeneous
    % Analysis prototype class for data analysis.
    %   could be an abstract class or even an interface

    properties
        minpt;      % minimum track tranverse momentum
        minlxy;     % minimum vertex transverse flight distance
        mindpv;     % minimum track impact parameter
        maxd0;      % maximum vertex impact parameter        
        mass;       % mass histrogram
        fsig;       % output file:  list of found kaon parent signals
        ftrk;       % output file:  list of tracks and binary classification as kaon chilhren
    end

    properties (Abstract)
        histParas;  % array of size 3 of histogram parameters
    end
    
    methods
        
        % Abstract constructor
        function obj = Analysis(filename)
            if nargin == 1
                obj.GetResults(filename);
            end
        end

        % initialise analysis
        function start(obj)
            % empties and reinitialise the histogram
            obj.mass = Histogram(obj.histParas(1), obj.histParas(2), obj.histParas(3));
            
            % write to stdout
            fprintf(1, strcat(class(obj), ' initialised\n'));            
        end
        
        % cleans up analysis
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
            
            % writes to stdout
            fprintf(1, strcat(class(obj), ' terminated\n'));
        end
        
    end
    
    methods (Abstract)
        event(obj, ev);
        GetResults(obj, filename);
        BackResults(obj, filename);
    end
end
