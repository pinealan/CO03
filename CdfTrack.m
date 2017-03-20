classdef CdfTrack
    % CdfTrack contains CDF track parameters

    properties(SetAccess=protected)
        cotTheta   % polar angle of track at closest approach to (0,0)
        curvature  % track curvature (actually 0.5*curvature) in xy plane (1/cm)
        d0         % transverse impact parameter at closest approach (cm)
        phi0       % angle in transverse plane at closest approach (radians)
        z0         % position along beamline at closest approach (cm)
    end

    methods

        % constructor:  accepts a 5xN matrix of track parameters
        function obj = CdfTrack(v)
            if nargin > 0
                n = size(v,2); % number of tracks
                obj(n) = CdfTrack; % preallocate array of objects

                if (size(v,1) == 5)
                    for i = 1:n
                        obj(i).cotTheta  = v(1,i);
                        obj(i).curvature = v(2,i);
                        obj(i).d0        = v(3,i);
                        obj(i).phi0      = v(4,i);
                        obj(i).z0        = v(5,i);
                    end
                else
                    % invalid inputs, so create array of invalid tracks
                    for i = 1:n
                        obj(i) = CdfTrack();
                    end
                end
            else
                % no arguments - create an invalid CdfTrack
                obj.cotTheta = -999.0;
                obj.curvature = -999.0;
                obj.d0 = -999.0;
                obj.phi0 = -999.0;
                obj.z0 = -999.0;
            end
        end

        % overload equality operator
        function b = eq(trk1, trk2)
            b = true;
            if trk1.cotTheta ~= trk2.cotTheta
                b = false;
            elseif trk1.curvature ~= trk2.curvature
                b = false;
            elseif trk1.d0 ~= trk2.d0
                b = false;
            elseif trk1.phi0 ~= trk2.phi0
                b = false;
            elseif trk1.z0 ~= trk2.z0
                b = false;
            end
        end
        
        % check if this object is valid
        function valid = isValid(obj)
            valid = (obj.cotTheta == -999.0);
        end

    end % methods
end % classdef