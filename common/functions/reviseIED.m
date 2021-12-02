function revisedLabel = reviseIED(s, fs, label)
% automaticIED labeling with R.Janca's detector
% 'spike_detector_hilbert_v16_byISARG'
%
% by Jana Nguyen 2021
%
% IN:   s = recording signal matrix
%       fs = samplign frequency of the recording
%       label = label struct with .automatic to be revised 
%       
% OUT:  revisedLabel = label struct compatible with KudlajdaViewer
%

    label.revised = label.automatic;
    label.revised.color = '0.7 0.3 0.3';
    labelsL = (label.automatic.ch01.posN-label.automatic.fileDateN)*60*60*24;
    labelsC = (label.automatic.ch03.posN-label.automatic.fileDateN)*60*60*24;
    figHandle = figure;
    t = (1:length(s))/fs;
    axL = subplot(2,1,1, 'Parent', figHandle);
    plot(axL, t, s(1,:));
    hold on
    xline(axL, labelsL, 'LineStyle','--', 'Alpha', 0.5, 'Color', 'r')
    hold off
    ylabel(axL, 'L')
    xlabel(axL, 'time (s)')

    axC = subplot(2,1,2, 'Parent', figHandle);
    plot(axC, t, s(1,:));
    hold on
    ylabel(axC, 'C')
    xlabel(axC, 'time (s)')

    linkaxes([axL, axC], 'x')

    recordL = zeros(length(label.automatic.ch01.posN));
    
    for i=1:length(label.automatic.ch01.posN)
        xlim([labelsL(i)-0.075 labelsL(i)+0.075])
        w = waitforbuttonpress;
        while w~=1
            w = waitforbuttonpress;
        end
        recordL(i) = double(get(figHandle,'CurrentCharacter'));
    end   
    label.revised.ch01.posN = label.automatic.ch01.posN(recordL>48)+0.005/24/60/60;
    label.revised.ch01.durN = label.automatic.ch01.durN(recordL>48);
    label.revised.ch01.value = recordL(recordL>48)-48;

    plot(axL, t, s(1,:));
    xline(axC, labelsC, 'LineStyle','--', 'Alpha', 0.5, 'Color', 'r')
    recordC = zeros(length(label.automatic.ch03.posN));
    for i=1:length(label.automatic.ch03.posN)
        xlim([labelsC(i)-0.075 labelsC(i)+0.075])
        w = waitforbuttonpress;
        while w~=1
            w = waitforbuttonpress;
        end
        recordC(i) = double(get(figHandle,'CurrentCharacter'));
    end   
    label.revised.ch03.posN = label.automatic.ch03.posN(recordL>48)+0.005/24/60/60;
    label.revised.ch03.durN = label.automatic.ch03.durN(recordL>48);
    label.revised.ch03.value = recordC(recordL>48)-48;
    revisedLabel = label;
end