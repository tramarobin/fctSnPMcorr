clear
close all
clc

% this is a basic example of the funtion, a lot of parameters can be
% changed with optional inputs : see the function fctSnPMcorr itself

% functions path
currentFolder=pwd;
idcs=strfind(currentFolder,'\');
functionPath=currentFolder(1:idcs(end)-1);
addpath(genpath(fullfile(functionPath,'src')))

% data
load data4example.mat

% meanData is the varibale Y corrData is the variable X dimensions is the
% dimension of the spectra [1 Y] or maps [X Y]

% 1D correlation analysis (results will be save on a newly reated RESULTS
% folder)
fctSnPMcorr(meanData,dimensions,corrData,'sub',subjects);

   


