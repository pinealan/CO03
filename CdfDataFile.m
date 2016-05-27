classdef CdfDataFile < handle
    % CdfDataFile wraps CDF track data file.
    % This class reads a CDF track data file sequentially.
    % The format:  each event consists of the following:
    %   line 1:  runNumber eventNumber vertex-x vertex-y numTracks
    %     runNumber = CDF run number
    %     eventNumber = CDF event number within run
    %     vertex-x, vertex-y = transverse location (xy) of primary interaction point
    %     numTracks = number of reconstructed tracks
    %   lines 2 to numTracks-2:  cotTheta curvature d0 phi0 z0
    %     cotTheta = polar angle of track at closest approach to (0,0)
    %     curvature = track curvature (actually 0.5*curvature) in xy plane
    %     d0 = impact parameter with respect to origin at point of closest approach
    %     phi0 = azimuthal angle at point of closest approach
    %     z0 = position along beamline at point of closest approach
    
    properties(Access=protected) 
        id; % file identifier
    end
    
    methods

        % constructor:
        function obj = CdfDataFile(filename)
            obj.id = -1; % invalid
            if ischar(filename)
                % string -> filename
                obj.id = fopen(filename);
            elseif isinteger(filename)
                % integer -> file identifier
                obj.id = filename;
            end
        end

        % return true if file is open (and valid)
        function result = isOpen(obj)
            result = (obj.id > 0);
        end

        % close file
        function close(obj)
            if obj.isOpen()
                fclose(obj.id);
                obj.id = -1;
            end
        end

        % start reading again from the beginning
        function rewind(obj)
            if obj.isOpen()
                frewind(obj.id);
            end
        end

        % get next event
        function event = next(obj)
            event = CdfEvent(); % created in invalid state
            if obj.isOpen()
                while 1
                    str = fgets(obj.id);
                    if str == -1
                        return % end of file - leaves event in invalid state
                    end
                    s = strtrim(str); % trim the leading/ending whitespace
                    if numel(s) <= 0
                        continue % usually just an end of line
                    end
                    if s(1) ~= '#'
                        break; % get on with event
                    else
                        disp(s);
                    end
                end
                % parse event header
                expected = 5;
                [head, n] = sscanf(s, '%d %d %g %g %d', 5);
                if n == expected
                    % read tracks
                    expected = 5 * head(5);
                    [pars, n] = fscanf(obj.id, '%g', [5, head(5)]);
                    if n ~= expected
                        return % unexpected end of track data
                    end
                else % unexpected end of header
                    return % leaves event in invalid state
                end
                event.runNumber = head(1);
                event.eventNumber = head(2);
                event.vertex = head(3:4);
                event.tracks = CdfTrack(pars);
            end
        end

    end % methods
    
end % classdef

