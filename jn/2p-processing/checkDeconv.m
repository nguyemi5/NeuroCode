%% see activity in dysmorphic, VIP, and pyramids
subject = '430';
session = 'F8';
sessionRef = 'F3';
%% FOV 14
FOV = 14;
dysmorphInd = [1];
VIPInd = [4 18 2 3];
pyramInd = setdiff(1:144, [dysmorphInd, VIPInd]);

%% FOV 19
FOV = 19;
dysmorphInd = [7 56 4 1 2 3];
VIPInd = [8 54 23 21 64 73 71 67 106 104 103 75 110 17];
pyramInd = setdiff(1:120, [dysmorphInd, VIPInd]);

%% FOV 44
FOV = 44;
dysmorphInd = [];
VIPInd = [9 10 135 141 55 125 147 82 96 94];
pyramInd = setdiff(1:220, [dysmorphInd, VIPInd]);

%% FOV 49
FOV = 49;
dysmorphInd = [];
VIPInd = [131 1 8 3 4 2 5 6 7 153];
pyramInd = setdiff(1:210, [dysmorphInd, VIPInd]);

% %% FOV 1
% FOV = 1;
% dysmorphInd = [1 3 18 26];
% VIPInd = [15 16 19 40 43 53 54 49 4 7 5];
% pyramInd = [ 37 41 44 64 25 24 28 20 17];

%%
directory = dir(sprintf('\\\\neurodata2\\Large data\\Monika 2p\\VIP_tdT\\*%s*\\*%s*\\%sFOV%05d.mat', subject, sessionRef, session, FOV));
load([directory.folder, '\', directory.name])
directory = dir(sprintf('\\\\neurodata2\\Large data\\Monika 2p\\VIP_tdT\\*%s*\\*%s*\\%sFOV%05dVARP.mat', subject, sessionRef, session, FOV));
load([directory.folder, '\', directory.name])
directory = dir(sprintf('C:\\Users\\minht\\Desktop\\code\\autoCaImData\\deconv\\%sFOV%d*KDE.mat', session, FOV));
load([directory.folder, '\', directory.name])
neuronTypes = zeros(neuronN,1);
neuronTypes(pyramInd) = 1;
neuronTypes(VIPInd) = 2;
neuronTypes(dysmorphInd) = 3;
neuronNames = {'pyram', 'VIP', 'dysmorph'};

t = (1:9000)/30;
%%
fig = figure;
neuronIds = 1:3;
tit = sprintf('%s%s', session, FOV);
fig.Name = ['Spikes ', tit];
nn = length(neuronIds);
for n = 1:nn 
    subplot(nn,1,n);
    if reidentificationRecord(neuronIds(n)) == 99
        stem(t, foopsiS(:,neuronIds(n)), 'Marker', 'none')
        title(sprintf('%s neuron %d', neuronNames{neuronTypes(neuronIds(n))}, neuronIds(n)))
    else
        title(sprintf('neuron %c', reidentificationRecord(neuronIds(n))))
    end
    hold on
    yline(17)
    xlabel('time (s)')
    hold off
end

fig = figure;
fig.Name = ['Deconvolved ', tit];
for n = 1:nn
    subplot(nn,1,n)
    plot(t, neuronDf(neuronIds(n),:))
    hold on
    plot(t, foopsiC(:,neuronIds(n)), 'Marker', 'none')    
    title(sprintf('%s neuron %d', neuronNames{neuronTypes(neuronIds(n))}, neuronIds(n)))
    xlabel('time(s)')
    ylabel('dF/F (%)')
    hold off
end

%% check correlation in neuron firing
corrDeconv = corr(foopsiC(:, neuronKeep));
figure
h = heatmap(corrDeconv);
% h.XDisplayLabels = string(neuronTypes(neuronKeep));
% h.YDisplayLabels = string(neuronTypes(neuronKeep));
allIDs = 1:neuronN;
h.XDisplayLabels = string(allIds(neuronKeep));
h.YDisplayLabels = string(allIds(neuronKeep));


% %% check cell size
% sizeThr = 400;
% neuronSizes = zeros(neuronN, 1);
% neuronMask = zeros(512, 'uint8');
% for n=1:neuronN
%     if reidentificationRecord(n) == 99
%         neuronSizes(n) = length(maskStructure(n).WCPixList);
%         neuronMask(maskStructure(n).WCPixList) = (neuronSizes(n) > sizeThr);
%     end
% end
% 
% figure
% imshowpair(imageReferenceNEW, neuronMask*100, 'Scaling', 'none');
% title(sprintf('neurons with size %d', sizeThr))
% 
% binWidth = 50;
% figure
% ax1 = subplot(4,1,1);
% histogram(neuronSizes, 'BinWidth', binWidth)
% title('All neurons sizes')
% ax2 = subplot(4,1,2);
% histogram(neuronSizes(dysmorphInd), 'BinWidth', binWidth)
% title('Dysmorphic neurons sizes')
% ax3 = subplot(4,1,3);
% histogram(neuronSizes(pyramInd), 'BinWidth', binWidth)
% title('Pyramidal neurons sizes')
% ax4 = subplot(4,1,4);
% histogram(neuronSizes(VIPInd), 'BinWidth', binWidth)
% title('VIP interneurons sizes')
% linkaxes([ax1, ax2, ax3, ax4])
% 
% %% check cell size and pix std
% neuronSTD = zeros(neuronN, 1);
% neuronMask = zeros(512, 'uint8');
% STDThr = 6000;
% for n=1:neuronN
%     neuronSTD(n) = std(double(imageReferenceNEW(maskStructure(n).WCPixList)));
%     neuronMask(maskStructure(n).WCPixList) = (neuronSTD(n) > STDThr);
% end
% 
% figure
% imshowpair(imageReferenceNEW, neuronMask*100, 'Scaling', 'none');
% title(sprintf('neurons with pixel std > %d', STDThr))
% 
% binWidth = 500;
% figure
% ax1 = subplot(4,1,1);
% histogram(neuronSTD, 'BinWidth', binWidth)
% title('All neurons STD')
% ax2 = subplot(4,1,2);
% histogram(neuronSTD(dysmorphInd), 'BinWidth', binWidth)
% title('Dysmorphic neurons STD')
% ax3 = subplot(4,1,3);
% histogram(neuronSTD(pyramInd), 'BinWidth', binWidth)
% title('Pyramidal neurons STD')
% ax4 = subplot(4,1,4);
% histogram(neuronSTD(VIPInd), 'BinWidth', binWidth)
% title('VIP interneurons STD')
% 
% linkaxes([ax1, ax2, ax3, ax4])
% %% check averaged cell brightness
% neuronMean = zeros(neuronN, 1);
% neuronMask = zeros(512, 'uint8');
% meanThr = 30000;
% for n=1:neuronN
%     neuronMean(n) = mean(double(imageReferenceNEW(maskStructure(n).WCPixList)));
%     neuronMask(maskStructure(n).WCPixList) = (neuronMean(n) > meanThr);
% end
% 
% figure
% imshowpair(imageReferenceNEW, neuronMask*100, 'Scaling', 'none');
% title(sprintf('neurons with mean pixel brightness > %d', meanThr))
% 
% binWidth = 1000;
% figure
% ax1 = subplot(4,1,1);
% histogram(neuronMean, 'BinWidth', binWidth)
% title('All neurons brigthness')
% ax2 = subplot(4,1,2);
% histogram(neuronMean(dysmorphInd), 'BinWidth', binWidth)
% title('Dysmorphic neurons brightness')
% ax3 = subplot(4,1,3);
% histogram(neuronMean(pyramInd), 'BinWidth', binWidth)
% title('Pyramidal neurons brightness')
% ax4 = subplot(4,1,4);
% histogram(neuronMean(VIPInd), 'BinWidth', binWidth)
% title('VIP interneurons brightness')
% linkaxes([ax1, ax2, ax3, ax4])
% 

    