tic
clear

RUN_NAME = 'washed-pt-cut';
ka = K0SAnalysis();

ka.mindpv = 0;
%ka.minpt = 0;
ka.minlxy = -999;
%ka.maxd0 = 99;

%ka.opts.backup_tracks = 1;
%ka.opts.tracks_fname = strcat('ktrks-', RUN_NAME, '.txt');

loop = Loop('cdf-washed-k20.dat');

loop.run(ka);
saveas(figure(2), strcat('hist-', RUN_NAME, '.fig'));
saveas(figure(2), strcat('fig/hist-', RUN_NAME, '.png'), 'png');
ka.backResult(strcat('hist-', RUN_NAME, '.txt'));

toc