classdef CdfHandle < handle
    % Handler class that loads and stores all data from the Cdf Dataset
    
    properties
        nevmax;         % maximum number of events to process
        report;         % number of events between each console report
    end
    
    methods
        function this = CdfHandle()
            this.nevmax = 10000;
            this.report = 100;
        end

        function [events, nev] = load(this, cdfFile)
            dataFile = CdfDataFile(cdfFile);
            events = CdfEvent(this.nevmax);
            nev = 0;
            
            fprintf(1, 'Begin loading\n');
            
            while 1
                ev = dataFile.next();
                if ev.isValid()
                    nev = nev + 1;
                    events(nev) = ev;
                    if nev > this.nevmax                        
                        fprintf(1, 'Number of events reached maximum.\n');
                        break;
                    end

                    if mod(nev, this.report) == 0
                        fprintf(1, '%d, events loaded\n', nev);
                    end
                else
                    fprintf(1, 'Reached the end of data file\n');
                    break;
                end
            end
            
            events = events(1: nev);
            dataFile.close();
        end

        function event = getEventByTrack(~, events, track)
            for ev = events
                for trk = ev.tracks
                    if trk == track
                        event = ev;
                        return;
                    end
                end
            end
            event = -1;
        end
        
        
            
        function createCdfDataFile(~, fileName, events)
            if ~ischar(fileName)
                return
            end
            
            f = fopen(fileName, 'w');
            
            for ev = events
                ntrk = size(ev.tracks, 2);
                fprintf(f, '%d %d %g %g %d\n', ev.runNumber, ev.eventNumber, ev.vertex(1), ev.vertex(2), ntrk);
                for trk = ev.tracks
                    fprintf(f, '%g %g %g %g %g\n', trk.cotTheta, trk.curvature, trk.d0, trk.phi0, trk.z0);
                end
            end
            
            fclose(f);
        end
    end
end