classdef CdfEvent < handle
    % CdfEvent contains CDF event data

    properties(SetAccess=?CdfDataFile)
        runNumber    % integer:  CDF run number
        eventNumber  % integer:  CDF event number within run
        vertex       % 2x1 float:  transverse location (xy) of primary interaction vertex
    end
    
    properties(SetAccess=public)
        tracks       % array of CdfTrack object
    end
    
    methods
        % constructor:  create CdfEvent in invalid state
        function obj = CdfEvent(varargin)
            if nargin == 0
                obj.runNumber = -1;
                obj.eventNumber = -1;
                obj.vertex = [0; 0];
                obj.tracks = [];
            elseif nargin == 1
                obj(varargin{1}) = CdfEvent;
            elseif nargin == 4
                obj.runNumber = varargin{1};
                obj.eventNumber = varargin{2};
                obj.vertex = [varargin{3}, varargin{4}];
            end
        end

        % overload equality operator
        function b = eq(ev1, ev2)
            b = true;
            if ev1.runNumber ~= ev2.runNumber
                b = false;
            elseif ev1.eventNumber ~= ev2.eventNumber
                b = false;
            end
        end
        
        % test if this event is valid
        function valid = isValid(obj)
            valid = (obj.runNumber >= 0);
        end
        
        % 3deventdisplay for single event
        function Display3d(in)
            n = numel(in.tracks);
            hold off
            figure(1);
            for index = 1:n
                v = points(Helix(in.tracks(index)), 0:pi/100:pi/4);
                plot3(v(3, :), v(1, :), v(2, :), 'b');
                if index == 1
                    hold on; % superimpose subsequent tracks
                    axis([-100 100 -100 100 -100 100]); % tracking volume radius ~1m
                    xlabel('z [cm]'); % beamline
                    ylabel('x [cm]');
                    zlabel('y [cm]');
                    title(['3D Run ', num2str(in.runNumber), '   Event ', num2str(in.eventNumber)]);
                    grid on
                end
            end
        end
        
        % 2deventdisplay for single event
        function Display2d(in)
            n = numel(in.tracks);
            hold off
            for index = 1:n     % index is the track number
                v = points(Helix(in.tracks(index)), 0:pi/100:pi/4);
                plot(v(1, :), v(2, :), 'b');
                if index == 1
                    hold on;    % superimpose subsequent tracks
                    axis([-100 100 -100 100]);      % tracking volume radius ~1m
                    xlabel('x [cm]');
                    ylabel('y [cm]');
                    title(['2D Run ', num2str(in.runNumber), '   Event ', num2str(in.eventNumber)]);
                    grid on
                end
            end
        end
        
        %3deventdisplay for GUI
        function sketch(in)
            n = numel(in.tracks);
            hold off
            for index = 1:n
                v = points(Helix(in.tracks(index)), 0:pi/100:pi/4);
                plot3(v(3, :), v(1, :), v(2, :), 'b');
                if index == 1
                    hold on; % superimpose subsequent tracks
                    axis([-100 100 -100 100 -100 100]); % tracking volume radius ~1m
                    xlabel('z [cm]'); % beamline
                    ylabel('x [cm]');
                    zlabel('y [cm]');
                    grid on
                end
            end
        end

    end % methods

end % classdef
