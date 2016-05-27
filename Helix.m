classdef Helix
    % Helix is a method class for geometric calculations based on CdfTrack.
    % Methods:
    %   obj.radius
    %   obj.center
    %   obj.points[coordinate]
    %   obj.intersect[second helix]
    %   obj.pT      (signed magnitude of transverse momentum)
    %   obj.p       (3-momentum vector)
    %   obj.normp   (signed magnitude of 3-momentum)
    %   obj.dpv     (signed impact parameter)
    %   obj.engy    (energy (always positive))
    
    properties(SetAccess=protected)
        trk;    % CdfTrack
    end
    
    properties(Constant, Hidden=true)
        kpc = 0.002116;
    end

    methods
        %% constructor
        function obj = Helix(in)
            if nargin > 0
                obj(numel(in)) = Helix;     %creates an array of the right size
                for i = 1:numel(in)
                    obj(i).trk = in(i);
                end
            end
        end 
        
        %% finds the radius of the helix in the xy plane
        function out = radius(obj)
            out = 1/(2 * obj.trk.curvature);
        end
        
        %% finds the center of the helix
        function out = center(obj)
            out = (obj.radius() + obj.trk.d0) * exp(1i*(obj.trk.phi0 + pi/2));
        end
        
        %% gives the corresponding coordinates in 3D
        function out = points(obj, arg)      % arg is an (array of) angle
            n = size(arg, 2);
            out = zeros(3, n);
            for index = 1:n
                w = obj.center() - 1i * obj.radius() * exp(1i * (obj.trk.phi0 + arg(index) * sign(obj.trk.curvature)));
                out(1, index) = real(w);    % x-coord
                out(2, index) = imag(w);    % y-coord
                out(3, index) = obj.trk.z0 + abs(obj.radius()) * arg(index) * obj.trk.cotTheta;
            end
        end

        %% checks for intersection in xy plane
        function out = intersect(h1, h2)
            if ~isa(h2, 'Helix') && ~isa(h1, 'Helix')
                disp('Argument of intersect is not a Helix');
                out = [ ]; % no intersection
                return;
            end
            c1 = h1.center();
            c2 = h2.center();
            d = c2 - c1;
            r1 = h1.radius();
            r2 = h2.radius();
            % fixed this cut; didn't consider the other cases of either radius bigger than sum of other radius and center distance
            if (norm(d) > (abs(r1) + abs(r2)) ||  abs(r2) > (abs(r1) + norm(d))|| abs(r1) > (abs(r2) + norm(d)))
                out = [ ]; % no intersection
                return;
            end

            % uses geometry to find the point of intersection            
            cosalpha1 = ((norm(d) ^ 2) + (r1 ^ 2) - (r2 ^ 2))/(2 * norm(d) * abs(r1));
            cosalpha2 = ((norm(d) ^ 2) + (r2 ^ 2) - (r1 ^ 2))/(2 * norm(d) * abs(r2));
            tandelta1 = imag(d) / real(d);
            del = atan(tandelta1);
            alpha1 = acos(cosalpha1);
            alpha2 = acos(cosalpha2);
            
            % the long argument here is to modify the points function into intersection equation; see script
            p1 = (del + alpha1 - h1.trk.phi0) / sign(h1.trk.curvature) + pi/2;
            m1 = (del - alpha1 - h1.trk.phi0) / sign(h1.trk.curvature) + pi/2;
            p2 = (del - alpha2 - h2.trk.phi0) / sign(h2.trk.curvature) + pi/2;
            m2 = (del + alpha2 - h2.trk.phi0) / sign(h2.trk.curvature) + pi/2;

            if (real(c1) - real(c2)) > 0
                p1 = p1 + pi;
                m1 = m1 + pi;
            else
                p2 = p2 + pi;
                m2 = m2 + pi;
            end
            
            p1 = mod(p1, 2*pi);
            m1 = mod(m1, 2*pi);
            p2 = mod(p2, 2*pi);
            m2 = mod(m2, 2*pi);

%             if p1 > pi
%                 p1 = p1 - 2*pi;
%             end
%             if m1 > pi
%                 m1 = m1 - 2*pi;
%             end
%             if p2 > pi
%                 p2 = p2 - 2*pi;
%             end
%             if m2 > pi
%                 m2 = m2 - 2*pi;
%             end
            
            wp1 = h1.points(p1);
            wm1 = h1.points(m1);
            wp2 = h2.points(p2);
            wm2 = h2.points(m2);

            out = [wp1(1:2)', (wp1(3) + wp2(3))/2, (wp1(3) - wp2(3)); wm1(1:2)', (wm1(3) + wm2(3))/2, (wm1(3) - wm2(3))]';
        end

        %% signed magnitude of transverse momentum in GeV/c
        function out = pT(obj)
            out = obj.kpc / obj.trk.curvature;
        end

        %% helix momentum vector (x; y; z)
        function out = p(obj, pos)
            out = zeros(3,1);
            pT = abs(obj.pT());
            out(1) = pT * ((1 + 2 * obj.trk.curvature * obj.trk.d0) * cos(obj.trk.phi0) - 2 * obj.trk.curvature * pos(2));
            out(2) = pT * ((1 + 2 * obj.trk.curvature * obj.trk.d0) * sin(obj.trk.phi0) + 2 * obj.trk.curvature * pos(1));
            out(3) = pT * obj.trk.cotTheta;
        end
        
        %% magnitude of momentum of helix
        function out = normp(obj)
            out = obj.pT() * sqrt(1 + obj.trk.cotTheta ^ 2);
        end
        
        %% impact parameter with respect to true impact center
        function out = dpv(obj, ev)
            cen = obj.center();
            out = norm([real(cen); imag(cen)] - ev.vertex)- abs(radius(obj));
        end

        %% gives energy of track in electron volts, expects mass in GeV/c^2
        function out = engy(obj, mass)
            out = sqrt((obj.normp() ^ 2) + (mass ^ 2));
        end

    end % methods
end % classdef

% previous methods for the intersection code

%             % makes sure that the angle is the closest approach
%             if (mod(abs(p1), pi) > pi/2)
%                 p1 = (mod(abs(p1), pi) - pi)*sign(p1)
%             else
%                 p1 = mod(abs(p1), pi)*sign(p1)
%             end
%             if (mod(abs(m1), pi) > pi/2)
%                 m1 = (mod(abs(m1), pi) - pi)*sign(m1)
%             else
%                 m1 = mod(abs(m1), pi)*sign(m1)
%             end
%             if (mod(abs(p2), pi) > pi/2)
%                 p2 = (mod(abs(p2), pi) - pi)*sign(p2)
%             else
%                 p2 = mod(abs(p2), pi)*sign(p2)
%             end
%             if (mod(abs(p1), pi) > pi/2)
%                 m2 = (mod(abs(p1), pi) - pi)*sign(m2)
%             else
%                 m2 = mod(abs(m2), pi)*sign(m2)
%             end
% 
%             wp1 = h1.points(p1)
%             wm1 = h1.points(m1)
%             wp2 = h2.points(p2)
%             wm2 = h2.points(m2)

%             % found all the signals for lifetime, but fails mass and gets
%             % wrong Lxy for some large flight distance
%             wp1 = h1.points(mod(abs(p1), pi)*sign(p1));
%             wm1 = h1.points(mod(abs(m1), pi)*sign(m1));
%             wp2 = h2.points(mod(abs(p2), pi)*sign(p2));
%             wm2 = h2.points(mod(abs(m2), pi)*sign(m2));

%             % another version of the method, this worked for mass analysis
%             wp1 = h1.points(mod(p1, pi))
%             wm1 = h1.points(mod(m1, pi))
%             wp2 = h2.points(mod(p2, pi))
%             wm2 = h2.points(mod(m2, pi))
            
%             % old original flawed method; fails when abs(angle) > pi
%             wp1 = h1.points((del + alpha1 - h1.trk.phi0) / sign(h1.trk.curvature) + pi/2)
%             wm1 = h1.points((del - alpha1 - h1.trk.phi0) / sign(h1.trk.curvature) + pi/2)
%             wp2 = h2.points((del - alpha2 - h2.trk.phi0) / sign(h2.trk.curvature) + pi/2)
%             wm2 = h2.points((del + alpha2 - h2.trk.phi0) / sign(h2.trk.curvature) + pi/2)