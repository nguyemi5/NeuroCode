d = dir('\\neurodata2\Large data\Monika 2p\Jana scripts\EEGData\file*.mat');
for i=1:length(d)
    recordingFile = ['\\neurodata2\Large data\Monika 2p\Jana scripts\EEGData\', d(i).name];
    saveLabelFile = ['\\neurodata2\Large data\Monika 2p\Jana scripts\EEGData\lbl\', d(i).name(1:end-4), '-lbl.mat'];
    detectIEDTrial;
end
