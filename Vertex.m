classdef Vertex
    % Vertex is method class that finds the "better" intersection of two
    % helices then find the properties of their parent particle
    % Methods:
    %   obj.Lxy     (absolute transverse distance travelled)
    %   obj.d0      (impact parameter)
    %   obj.mass    (mass)
    %   obj.ct      (lifetime)

    properties(SetAccess=protected)
        vtx;    % the "better" decay position 2x1 float
        p;      % momentum of parent particle
        pT;     % magnetide of tranverse momentum of parent particle
        hlxs;   % original helices
    end

    methods
        %% constructor
        function obj = Vertex(h1, h2)
            vertex = intersect(h1, h2);
            
            % sanity check if the helices did cross
            if isempty(vertex)  
                obj.vtx = [ ];
                obj.p = -1;
                return;
            end
            
            % compares the w+ w- and selects the best intersection 
            if abs(vertex(4, 1)) > abs(vertex(4, 2))
                obj.vtx = vertex(1:2, 2);
            else
                obj.vtx = vertex(1:2, 1);
            end
            
            % momentum of vertex is sum of pt of daughter helices
            obj.p = h1.p(obj.vtx) + h2.p(obj.vtx);
            obj.pT = norm(obj.p(1:2));
            obj.hlxs = [h1, h2];
        end

        %% transverse flight distance of a vertex from primary vertex
        function out = Lxy(obj, ev)
            out = dot((obj.vtx - ev.vertex), obj.p(1:2)) / obj.pT;
        end
        
        %% true impact parameter d0 of the vertex from primary vertex
        function out = d0(obj, ev)
            out = norm(cross(([obj.vtx; 0] - [ev.vertex; 0]), [obj.p(1:2); 0])) / obj.pT;
        end
 
        %% gives invariant mass associated with a vertex
        function out = mass(obj, mass1, mass2)
            out = sqrt((mass1 ^ 2) + (mass2 ^ 2) + 2 * (obj.hlxs(1).engy(mass1) * obj.hlxs(2).engy(mass2) - dot(obj.hlxs(1).p(obj.vtx), obj.hlxs(2).p(obj.vtx))));
        end
        
        %% proper lifetime of a particle in rest frame
        function out = ct(obj, Lxy, mass)
            out = Lxy * mass / obj.pT;
        end
        
    end % methods
end % classdef