tic

ka = K0SAnalysis();
ka.minpt = 0;
ka.minlxy = 0;
loop = Loop('cdf.dat');

loop.run(ka);

toc