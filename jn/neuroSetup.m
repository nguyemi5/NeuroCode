%% set up paths
codeRoot = 'C:\Users\minht\Desktop\NeuroCode';
addpath(codeRoot)
addpath(genpath([codeRoot, '\common']))
addpath([codeRoot, '\jn'])

dataDir = 'C:\Users\minht\Desktop\NeuroStuff\data';
figsDir = 'C:\Users\minht\Desktop\NeuroStuff\figs';
outDir = 'C:\Users\minht\Desktop\NeuroStuff\out';

neurodataPath = '\\neurodata';
neurodata2Path = '\\neurodata2';

programsDir = 'C:\Users\minht\Desktop\NeuroStuff\prog';
addpath(programsDir)

%% set up global variables ~ neuro struct
pullGitAuto = true;
debug = false;

%% pull from git
if pullGitAuto
    git pull
end

%% init programs
addpath([programsDir, '\OASIS_matlab']);
oasis_setup;

addpath([programsDir, '\baseline_kde']);
addpath([programsDir, '\IED detector']);

% addpath([programsDir, '\cvx']);
% cvx_setup
