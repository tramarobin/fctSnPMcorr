function [self] = Southampton3tworm()
self.www     = 'http://www.southampton.ac.uk/~cpd/anovas/datasets/Doncaster&Davey%20-%20Model%206_5%20Three%20factor%20model%20with%20RM%20on%20two%20cross%20factors.txt';
self.A       = [1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3]';
self.B       = [1, 1, 1, 1, 2, 2, 2, 2, 1, 1, 1, 1, 2, 2, 2, 2, 1, 1, 1, 1, 2, 2, 2, 2]';
self.C       = [1, 1, 2, 2, 1, 1, 2, 2, 1, 1, 2, 2, 1, 1, 2, 2, 1, 1, 2, 2, 1, 1, 2, 2]';
subj         = [1, 2, 1, 2, 1, 2, 1, 2];
self.SUBJ    = [subj, subj+10, subj+20]';
self.Y       = [-3.8558, 4.4076, -4.1752, 1.4913, 5.9699, 5.2141, 9.1467, 5.8209, 9.4082, 6.0296, 15.3014, 12.1900, 6.9754, 14.3012, 10.4266, 2.3707, 19.1834, 18.3855, 23.3385, 21.9134, 16.4482, 11.6765, 17.9727, 15.1760]';
self.z       = [44.34, 0.01, 1.10,     5.21, 0.47, 1.04,    2.33];
self.df      = {[2,3], [1,3], [1,3],   [2,3],[2,3],[1,3], [2,3]};
self.p       = [0.006,0.921,0.371,   0.106,0.666,0.383,   0.245];
end