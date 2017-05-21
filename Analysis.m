classdef Analysis < handle & matlab.mixin.Heterogeneous
    % Analysis prototype class for data analysis.
    %   could be an abstract class or even an interface

    properties(Access=public)
        opts;
    end
    
    properties
        minpt;      % minimum track tranverse momentum
        minlxy;     % minimum vertex transverse flight distance
        mindpv;     % minimum track impact parameter
        maxd0;      % maximum vertex impact parameter        
    end

    methods

        % Abstract constructor
        function obj = Analysis()
            % defaults all analysis to not backup results
            obj.opts.backup_signals = 0;
            obj.opts.backup_tracks = 0;
        end

        % initialise analysis
        function start(obj)
            % finish initialisation
            fprintf(1, strcat(class(obj), ' initialised\n'));            
        end
        
        % cleans up analysis
        function stop(obj)
            % writes to stdout
            fprintf(1, strcat(class(obj), ' terminated\n'));
        end
        
    end
    
    methods (Abstract)
        getResult(obj, filename);
        backResult(obj, filename);
    end
end
