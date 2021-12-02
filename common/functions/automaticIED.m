function automaticLabel = automaticIED(recordingFile, detectorSettings)
% automaticIED labeling with R.Janca's detector
% 'spike_detector_hilbert_v16_byISARG'
%
% by Jana Nguyen 2021
%
% IN:   recordingFile = 'path\to\rawEEG.mat'
%       saveLabelTo = 'path\to\save\output\label.mat'
%                     if not specified, label is only returned as output
%       detectorSettings = settings for spike detector
%                          if not specified, default detector settings are
%                          used: '-bl 10 -bh 60 -w 5*fs'
%                          (chebyshev II 10-60Hz bandpass, 5s window
%                          background estimation)
%       
% OUT:  automaticLabel = label .mat file compatible with KudlajdaViewer
%
    load(recordingFile)

    if nargin>=2 && ~isempty(detectorSettings)
        [DE] = spike_detector_hilbert_v16_byISARG(s', fs, detectorSettings);
    else
        [DE] = spike_detector_hilbert_v16_byISARG(s', fs);
    end

    label = struct();
    label.automatic = struct();
    label.automatic.name = 'automatic';
    label.automatic.color = '0.2 0.4 0.7';
    label.automatic.subject = subject;
    label.automatic.instant = false;
    label.automatic.chanNames = chanNames';
    label.automatic.fileDateN = dateN;
    label.automatic.srcSigFile = recordingFile;
    
    label.automatic.ch01 = struct();
    label.automatic.ch01.posN = DE.pos(DE.chan==1)'/24/60/60+dateN;
    label.automatic.ch01.durN = ones(1,length(label.automatic.ch01.posN))*0.005/24/60/60;
    label.automatic.ch01.chan = 1;
    label.automatic.ch01.chanType = 1;
    label.automatic.ch01.chanName = 'L';
    label.automatic.ch01.value = ones(1,length(label.automatic.ch01.posN))*5;
    label.automatic.ch01.fileDateN = dateN;
    
    label.automatic.ch02 = struct();
    label.automatic.ch02.posN = [];
    label.automatic.ch02.durN =[];
    label.automatic.ch02.chan = 2;
    label.automatic.ch02.chanType = 1;
    label.automatic.ch02.chanName = 'L_hp';
    label.automatic.ch02.value = [];
    label.automatic.ch02.fileDateN = dateN;
    
    label.automatic.ch03 = struct();
    label.automatic.ch03.posN = DE.pos(DE.chan==3)'/24/60/60+dateN;
    label.automatic.ch03.durN = ones(1,length(label.automatic.ch03.posN))*0.005/24/60/60;
    label.automatic.ch03.chan = 3;
    label.automatic.ch03.chanType = 1;
    label.automatic.ch03.chanName = 'C';
    label.automatic.ch03.value = ones(1,length(label.automatic.ch03.posN))*5;
    label.automatic.ch03.fileDateN = dateN;
    
    label.automatic.ch04 = struct();
    label.automatic.ch04.posN = [];
    label.automatic.ch04.durN =[];
    label.automatic.ch04.chan = 4;
    label.automatic.ch04.chanType = 1;
    label.automatic.ch04.chanName = 'C_hp';
    label.automatic.ch04.value = [];
    label.automatic.ch04.fileDateN = dateN;
    
    label.automatic.ch05 = struct();
    label.automatic.ch05.posN = [];
    label.automatic.ch05.durN =[];
    label.automatic.ch05.chan = 5;
    label.automatic.ch05.chanType = 1;
    label.automatic.ch05.chanName = 'Dummy';
    label.automatic.ch05.value = [];
    label.automatic.ch05.fileDateN = dateN;
    
    label.automatic.ch06 = struct();
    label.automatic.ch06.posN = [];
    label.automatic.ch06.durN =[];
    label.automatic.ch06.chan = 6;
    label.automatic.ch06.chanType = 1;
    label.automatic.ch06.chanName = 'Dummy_hp';
    label.automatic.ch06.value = [];
    label.automatic.ch06.fileDateN = dateN;
    
    automaticLabel = label;

end

