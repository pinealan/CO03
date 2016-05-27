classdef Analysis < handle & matlab.mixin.Heterogeneous
    % Analysis prototype class for data analysis.
    %   could be an abstract class or even an interface

    properties
        minpt;      % minimum track tranverse momentum
        minlxy;     % minimum vertex transverse flight distance
        mindpv;     % minimum track impact parameter
        maxd0;      % maximum vertex impact parameter
    end

    methods
        function start(obj)
        end
        function stop(obj)
        end
    end
end
