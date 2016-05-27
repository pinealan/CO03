classdef Loop < handle
    %Loop loops over a data file of CDF tracks.
    
    properties(SetAccess=protected)
        file; % CdfDataFile
    end
    
    properties % override these public propertiesn nn
        nevmax; % number of events to process
        report; % number of events between each console report
    end
    
    methods

        % constructor, using the filename of the data file
        function obj = Loop(filename)
            obj.file = CdfDataFile(filename);
            obj.nevmax = 10000; % (provided cdf.dat has 10000 events anyway)
            obj.report = 10;
        end

        % close, just in case we need it
        function close(obj)
            obj.file.close();
        end

        % main loop
        function run(obj, analyses)

            % check if there are multiple analyses to run
            if (iscell(analyses))
                ca = analyses;
            else
                ca = { analyses };
            end

            % check that all the analyses are indeed of the Analysis class
            na = numel(ca);
            for ia = 1:na
                if ~isa(ca{ia}, 'Analysis')
                    fprintf(1,'Analysis list contains non-Analysis objects\n');
                    return;
                end
            end

            % start at the beginning of the data file
            obj.file.rewind();

            fprintf(1,'Begin analyses\n');

            % call start() on each Analysis
            for ia = 1:na
                ca{ia}.start();
            end
                
            % read and analyze events one at a time
            nev = 0; % count events
            while 1
                ev = obj.file.next();
                if ev.isValid()
                    if nev >= obj.nevmax,
                        fprintf(1, 'Number of processed events reached maximum.\n');
                        break;
                    end
                    for ia = 1:na
                        ca{ia}.event(ev);
                    end
                    nev = nev + 1;
                    if mod(nev, obj.report) == 0
                        fprintf(1,'%d events processed\n', nev);
                    end
                else
                    fprintf(1, 'Reached the end of data file\n');
                    break;
                end
            end

            % call stop() on each Analysis
            for ia = 1:na
                ca{ia}.stop();
            end
            fprintf(1,'End analysis:  %d events processed\n', nev);
        end
        
    end % methods
end % classdef