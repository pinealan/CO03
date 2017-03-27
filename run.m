tic
clear

RUN_NAME = 'washed-no-cut';
ka = K0SAnalysis();

ka.mindpv = 0;
ka.minpt = 0;
ka.minlxy = -999;
ka.maxd0 = 99;

%ka.opts.backup_tracks = 1;
%ka.opts.tracks_fname = strcat('ktrks-', RUN_NAME, '.txt');

loop = Loop('cdf-washed-k20.dat');

loop.run(ka);
saveas(figure(1), strcat('hist-', RUN_NAME, '.fig'));
ka.BackResults(strcat('hist-', RUN_NAME, '.txt'));

toc