% FOV warping script for lazy lamas like Jana
%% specify reference and target files + load reference and mask
subject = '534';
FOVRef = 1;
sessionRef = 'F2';

d = dir(sprintf('\\\\neurodata2\\Large data\\Monika 2p\\VIP_tdT\\*%s*\\*%s*%s\\file_%05d_aligned*.mat', subject, subject, sessionRef, FOVRef));
load(sprintf('%s\\%s', d.folder, d.name));
imageReference = imadjust(uint16(mean(dataset.aligned, 3)));
load(sprintf('%s\\krouzky_%05d', d.folder, FOVRef));
colorRef = imread(sprintf('%s\\file_%05dc.tif', d.folder, FOVRef+3));

%% load FOV in new session
FOVNew = 1;
sessionNew = 'F4';
% saveVarpTo = sprintf('%s\\%sFOV%05d', subject, sessionNew, FOVRef);
saveVarpTo = 'VarpBlah';
transformationType = 'rigid'; % automatic variants: 'rigid', 'similarity', 'affine'; default: 'polynomial' (manual point selection)

d = dir(sprintf('\\\\neurodata2\\Large data\\Monika 2p\\VIP_tdT\\*%s*\\*%s*%s*\\file_%05d_aligned*.mat', subject, subject, sessionNew, FOVNew));
load(sprintf('%s\\%s', d.folder, d.name));
imageReferenceNEW = imadjust(uint16(mean(dataset.aligned, 3)));
% colorNew = imread(sprintf('%s\\file_%05dc.tif', d.folder, FOVNew+3));

%%
manualPick(imageReference, maskStructInt, imageReferenceNEW, saveVarpTo, transformationType, colorRef);