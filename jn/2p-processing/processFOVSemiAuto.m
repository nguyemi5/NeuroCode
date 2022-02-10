%% specify reference and target files + load reference and mask
subject = '534';

FOVs = [40, 41];
sessions = {'F1', 'F2'};

d = dir(sprintf('\\\\neurodata2\\Large data\\Monika 2p\\VIP_tdT\\*%s*\\*%s*%s\\file_%05d_aligned*.mat', subject, subject, sessionRef, FOVRef));
load(sprintf('%s\\%s', d.folder, d.name));
imageReference = imadjust(uint16(mean(dataset.aligned, 3)));
load(sprintf('%s\\krouzky_%05d', d.folder, FOVRef));
colorRef = imread(sprintf('%s\\file_%05dc.tif', d.folder, FOVRef+3));
