% FOV manual neuron selection script for lazy lamas like Jana
%% specify target files + load reference
subject = '696';
FOVRef = 8;
sessionRef = 'F3';

saveHSTo = 'blah';

[maskFile, maskPath] = uigetfile('*.mat', 'Select HS File');
load([maskPath, maskFile]);

d = dir(sprintf('\\\\neurodata2\\Large data\\Monika 2p\\VIP_tdT*\\*%s*\\*%s*%s\\file_%05d_aligned*.mat', subject, subject, sessionRef, FOVRef));
load(sprintf('%s\\%s', d.folder, d.name));
imageReference = uint16(mean(dataset.aligned, 3));
% saveHSTo = sprintf('%s\\%sFOV%05dHS', d.folder, sessionRef, FOVRef);


manualPick(imageReference, maskStructInt, [], saveHSTo, [], []);