classdef MockEvent < CdfEvent
    methods
        function obj = MockEvent(varargin)
            if nargin == 0
                return;
            elseif nargin == 1
                n = varargin{1};
            end
            obj(n) = MockEvent;
        end
        
        function setRunNumber(obj, n)
            obj.runNumber = n;
        end
        
        function setEventNumber(obj, n)
            obj.eventNumber = n;
        end
        
        function setVertex(obj, v)
            obj.vertex = v;
        end
    end
end