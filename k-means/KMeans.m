%%
% Redesign data structures to accommodate detailed analysis on tracks 
%

%%
classdef KMeans


    properties(Access=private)
        cut;        % data set to be used (with cut)
        k;          % number of clusters
        max_iter;   % max iterations to terminate updates
        X;          % track parameters
        Y;          % track labels
        x_id;       % cluster assigned to track
        centroids;
    end
    
    properties(Constant)
        PARAS = {'cotThe', 'curv', 'dpv', 'phi0', 'z0'};
    end
    
    methods
        % Constructor
        function obj = KMeans()
            [X, Y] = load(MAT_FILE, {'X', 'Y'});
        end
        
        function run()
        end
        
        function initCentroids()
            
        end
 
        function iterate()
            
        end
        
        function updateCentroids()
        
        end
        
        function writeCluster()
        
        end
        
        function visualise()
            
        end
    end

end