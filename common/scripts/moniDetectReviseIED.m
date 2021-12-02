% automatic labeling + revision

[recordingFiles, recPath] = uigetfile('*.mat', 'Select EEG Recordings', 'MultiSelect','on');
[saveAutomaticLabelTo, autoLabelPath] = uiputfile('*.mat', 'Save Automatic Labels to');
[saveRevisedLabelTo, revLabelPath] = uiputfile('*.mat', 'Save Revised Labels to');

if iscell(recordingFiles)
     for i=1:length(recordingFiles)
         recFile = recordingFiles{i};
         load([recPath, recFile])
         label = automaticIED(recordingFile);
         save([autoLabelPath, recFile, saveAutomaticLabelTo], 'label')
         label = reviseIED(s, fs, label);
         save([revLabelPath, recFile, saveRevisedLabelTo], 'label')
     end
else
    load([recPath, recordingFiles])
    label = automaticIED(recordingFiles);
    save([autoLabelPath, recordingFiles, saveAutomaticLabelTo], 'label')
    label = reviseIED(s, fs, label);
    save([revLabelPath, recordingFiles, saveRevisedLabelTo], 'label')
end


