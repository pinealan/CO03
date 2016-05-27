classdef Histogram < handle
    % Histogram accumulates data in pre-defined bins

    properties(SetAccess=?Analysis)
        nbins; % number of bins
        xlo; % minimum x
        xhi; % maximum x
        data; % bin contents
        underflow; % underflow counter
        overflow; % overflow counter
        dx; % bin width
    end

    methods
        
        % constructor
        function obj = Histogram(nbins, xlo, xhi)
            obj.nbins = nbins;
            obj.xlo = xlo;
            obj.xhi = xhi;
            obj.data = zeros(1,nbins);
            obj.underflow = 0;
            obj.overflow = 0;
            obj.dx = (xhi - xlo) / nbins;
        end
        
        % return bin low-edges vector
        function b = bins(obj)
            bb = (obj.xlo : obj.dx : obj.xhi);
            b = bb(1:obj.nbins);
        end
        
        % accumulate data
        function fill(obj, v)
            for index = 1:numel(v)
                x = v(index);
                if x < obj.xlo
                    obj.underflow = obj.underflow + 1;
                elseif x >= obj.xhi
                    obj.overflow = obj.overflow + 1;
                else
                    ibin = floor((x-obj.xlo)/obj.dx) + 1;
                    obj.data(ibin) = obj.data(ibin) + 1;
                end
            end
        end
        
        % return total number of data points accumulated
        function n = total(obj)
            n = obj.underflow + sum(obj.data) + obj.overflow;
        end
        
        % return maximum bin contents
        function n = max(obj)
            n = max(obj.data);
        end
        
        % plot the histogram
        function plot(obj)
            figure;
            binranges = obj.bins();
            bar(binranges, obj.data, 'histc');      
            axis([ obj.xlo obj.xhi 0 obj.max()*1.1 ]);
        end
        
    end
end