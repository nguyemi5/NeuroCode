subject = '430';
% FOV = 19;
sessions = {'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8'};
sessionRef = 'F3';
FOVRef = [14 19 44 49];
FOVs = [11 19 47 52;    % F1
        12 17 51 56;    % F2
        14 19 44 49;    % F3
        12 20 51 58;    % F4
        12 17 44 48;    % F5
        14 19 41 46;    % F6
        13 18 44 50;    % F7
        12 17 34 38];   % F8
FOV = 14;

switch FOV
    case 14
        %% FOV 14
        FOV = 14;
        dysmorphInd = [1];
        VIPInd = [4 18 2 3];
        pyramInd = setdiff(1:144, [dysmorphInd, VIPInd]);
        neuronN = 144;
        availableSessions = 1:8;
    case 19
        %% FOV 19
        FOV = 19;
        dysmorphInd = [7 56 4 1 2 3];
        VIPInd = [8 54 23 21 64 73 71 67 106 104 103 75 110 17];
        pyramInd = setdiff(1:120, [dysmorphInd, VIPInd]);
        neuronN = 120;
        availableSessions = 1:length(sessions);
    case 44
        %% FOV 44
        FOV = 44;
        dysmorphInd = [];
        VIPInd = [9 10 135 141 55 125 147 82 96 94];
        pyramInd = setdiff(1:220, [dysmorphInd, VIPInd]);
        neuronN = 220;
        availableSessions = [1:5 7:8];
    case 49
        %% FOV 49
        FOV = 49;
        dysmorphInd = [];
        VIPInd = [131 1 8 3 4 2 5 6 7 153];
        pyramInd = setdiff(1:210, [dysmorphInd, VIPInd]);
        neuronN = 210;
        availableSessions = 1:7;
end
%%
% directory = dir(sprintf('C:\\Users\\minht\\Desktop\\code\\autoCaImData\\*FOV%dkeep.mat', FOV));
% load([directory.folder, '\', directory.name])
% neuronN = length(neuronKeep);
neuronTypes = zeros(1,neuronN);
neuronTypes(pyramInd) = 1;
neuronTypes(VIPInd) = 2;
neuronTypes(dysmorphInd) = 3;
neuronNames = {'pyram', 'VIP', 'dysmorph'};
% neuronIds = 1:neuronN;
% neuronIds = neuronIds(neuronKeep);
nSpikes = zeros(length(sessions), neuronN);
spectsL = zeros(1000, length(sessions));
spectsC = zeros(1000, length(sessions));
spectsLhp = zeros(1000, length(sessions));
spectsChp = zeros(1000, length(sessions));
thrDf = 17;
neuronKeep = ones(1,neuronN);
nIEDsL = zeros(1,length(sessions));
nIEDsLhp = zeros(1,length(sessions));
nIEDsC = zeros(1,length(sessions));
nIEDsChp = zeros(1,length(sessions));

tformsA = zeros(10, length(sessions));
tformsB = zeros(10, length(sessions));
for si = availableSessions
    subject = '430';
    session = sessions{si}
    if ~strcmp(sessionRef, session)
        directory = dir(sprintf('\\\\neurodata2\\Large data\\Monika 2p\\VIP_tdT\\*%s*\\*%s*\\%sFOV%05d.mat', subject, sessionRef, session, FOV));
        load([directory.folder, '\', directory.name])
        directory = dir(sprintf('\\\\neurodata2\\Large data\\Monika 2p\\VIP_tdT\\*%s*\\*%s*\\%sFOV%05dVARP.mat', subject, sessionRef, session, FOV));
        load([directory.folder, '\', directory.name])
        neuronKeep = neuronKeep & reidentificationRecord==99;
    end
    
    directory = dir(sprintf('C:\\Users\\minht\\Desktop\\code\\autoCaImData\\deconv\\%sFOV%dFOOPSI*KDE*.mat', session, FOV));
    load([directory.folder, '\', directory.name])
        
    for n=1:neuronN
        nSpikes(si,n) = sum(floor(foopsiS(:,n)/thrDf));
    end
    sum(reidentificationRecord==99)
    directory = dir(sprintf('\\\\neurodata2\\Large data\\Monika 2p\\VIP_tdT\\*%s*\\*%s*\\file*%04d.h5*.mat', subject, session, FOVs(si,FOVRef==FOV)));
    load([directory.folder, '\', directory.name])
    px = pwelch(s(strcmp(chanNames, 'L'), :), fs/2, [], [], fs);
    spectsL(:, si) = px(1:1000);
    px = pwelch(s(strcmp(chanNames, 'L_hp'), :), fs/2, [], [], fs);
    spectsLhp(:, si) = px(1:1000);
    px = pwelch(s(strcmp(chanNames, 'C'), :), fs/2, [], [], fs);
    spectsC(:, si) = px(1:1000);
    px = pwelch(s(strcmp(chanNames, 'C_hp'), :), fs/2, [], [], fs);
    spectsChp(:, si) = px(1:1000);
    [DE] = spike_detector_hilbert_v16_byISARG(s(strcmp(chanNames, 'L'), :)', fs);
    nIEDsL(si) = size(DE.pos,1);
    [DE] = spike_detector_hilbert_v16_byISARG(s(strcmp(chanNames, 'L_hp'), :)', fs);
    nIEDsLhp(si) = size(DE.pos,1);
    [DE] = spike_detector_hilbert_v16_byISARG(s(strcmp(chanNames, 'C'), :)', fs);
    nIEDsC(si) = size(DE.pos,1);
    [DE] = spike_detector_hilbert_v16_byISARG(s(strcmp(chanNames, 'C_hp'), :)', fs);
    nIEDsChp(si) = size(DE.pos,1);

    tformsA(:,si) = tform.A;
    tformsB(:,si) = tform.B;
    
end

% [~,fx] = pwelch(s(strcmp(chanNames, 'C_hp'), :), [], [], [], fs);
% fx = fx(1:1000);

fig = figure;
fig.Name = sprintf('# spikes in FOV %d - pyramids', FOV);
imagesc(nSpikes(:,neuronTypes==1 & neuronKeep)')
xlabel('Week')
ylabel('neuron number')
yticks(1:sum(neuronTypes==1 & neuronKeep))
yticklabels(find(neuronTypes==1 & neuronKeep))
title(sprintf('# spikes in FOV %d - pyramids', FOV))
colorbar

fig = figure;
fig.Name = sprintf('# spikes in FOV %d - VIP', FOV);
imagesc(nSpikes(:,neuronTypes==2 & neuronKeep)')
xlabel('Week')
ylabel('neuron number')
yticks(1:sum(neuronTypes==2 & neuronKeep))
yticklabels(find(neuronTypes==2 & neuronKeep))
title(sprintf('# spikes in FOV %d - VIP', FOV))
colorbar

fig = figure;
fig.Name = sprintf('# spikes in FOV %d - dysmorph', FOV);
imagesc(nSpikes(:,neuronTypes==3 & neuronKeep)')
xlabel('Week')
ylabel('neuron number')
yticks(1:sum(neuronTypes==3 & neuronKeep))
yticklabels(find(neuronTypes==3 & neuronKeep))
title(sprintf('# spikes in FOV %d - dysmorph', FOV))
colorbar

fig = figure;
fig.Name = sprintf('EEG spectrogram in FOV %d - L', FOV);
imagesc(spectsL)
xlabel('Week')
ylabel('frequency')
% yticks(1:1000)
% yticklabels(fx)
title(sprintf('EEG spectrogram in FOV %d - L', FOV));
colorbar

fig = figure;
fig.Name = sprintf('EEG spectrogram in FOV %d - L_hp', FOV);
imagesc(spectsLhp)
xlabel('Week')
ylabel('frequency')
% yticks(1:1000)
% yticklabels(fx)
title(sprintf('EEG spectrogram in FOV %d - L_hp', FOV));
colorbar

fig = figure;
fig.Name = sprintf('EEG spectrogram in FOV %d - C', FOV);
imagesc(spectsL)
xlabel('Week')
ylabel('frequency')
% yticks(1:1000)
% yticklabels(fx)
title(sprintf('EEG spectrogram in FOV %d - C', FOV));
colorbar

fig = figure;
fig.Name = sprintf('EEG spectrogram in FOV %d - C_hp', FOV);
imagesc(spectsLhp)
xlabel('Week')
ylabel('frequency')
% yticks(1:1000)
% yticklabels(fx)
title(sprintf('EEG spectrogram in FOV %d - C_hp', FOV));
colorbar

% %%
% fig = figure;
% fig.Name = sprintf('# spikes in FOV %d', FOV);
% axs = [];
% nShow = 10;
% for n=21:27
%     ax = subplot(10, 1, n-20);
%     axs = [axs ax];
%     plot(nSpikes(:,n))
%     title(sprintf('%s neuron %d', neuronNames{neuronTypes(neuronIds(n))}, neuronIds(n)))
% end
% linkaxes(axs, 'xy')
% xlabel('Week')
% % ylabel('# spikes in 5 mins')
% 
% 
% 
% 
% %%
% t = (1:9000)/30;
% neuronTypes = zeros(1,neuronN);
% neuronTypes(pyramInd) = 1;
% neuronTypes(VIPInd) = 2;
% neuronTypes(dysmorphInd) = 3;
% neuronNames = {'pyram', 'VIP', 'dysmorph'};
% fig = figure;
% neuronIds = 1:10;
% tit = sprintf('%s%s', session, FOV);
% fig.Name = ['Spikes ', tit];
% nn = length(neuronIds);
% for n = 1:nn 
%     subplot(nn,1,n);
%     if reidentificationRecord(neuronIds(n)) == 99
%         stem(t, foopsiS(:,neuronIds(n)), 'Marker', 'none')
%         title(sprintf('%s neuron %d', neuronNames{neuronTypes(neuronIds(n))}, neuronIds(n)))
%     else
%         title(sprintf('neuron %c', reidentificationRecord(neuronIds(n))))
%     end
% end
% 
% fig = figure;
% fig.Name = ['Deconvolved ', tit];
% for n = 1:nn
%     subplot(nn,1,n)
%     plot(t, neuronDf(neuronIds(n),:))
%     hold on
%     plot(t, foopsiC(:,neuronIds(n)), 'Marker', 'none')    
%     title(sprintf('%s neuron %d', neuronNames{neuronTypes(neuronIds(n))}, neuronIds(n)))
%     hold off
% end
