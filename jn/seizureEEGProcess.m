%% load data
seizureData = moniSeizureCountAdvanced('\\195.113.42.48\Large data\JanaEEGexport_updated\FERDA-PC\Moni ET 430\s\Moni ET 430*.mat', 3);
date2p = datetime([2021 2021 2021 2021 2021 2021 2021 2021], [6 6 6 7 7 7 7 8], [16 23 30  7 14 21 28 4]);
%%
saveFigsTo = 'figs2';
saveFigs = true;
%% Values vs. time + histogram
figure
subplot(2,1,1)
stem(datetime(seizureData.initTimes, 'ConvertFrom', 'datenum'), seizureData.values)
if ~isempty(date2p)
    hold on
    xline(date2p+1, 'r');
    xlim([datetime(2021, 6, 4) date2p(end)]);
    hold off
end
ylabel('seizure value')
subplot(2,1,2)
histogram(seizureData.values)
xlabel('seizure value')
if saveFigs
    saveas(gcf, sprintf('%s\\ValuevsDate.png', saveFigsTo))
end
%% Durations vs. time + histogram
figure
subplot(2,1,1)
stem(datetime(seizureData.initTimes, 'ConvertFrom', 'datenum'), seizureData.durations)
if ~isempty(date2p)
    hold on
    xline(date2p+1, 'r');
    xlim([datetime(2021, 6, 4) date2p(end)]);
    hold off
end
ylabel('seizure duration (s)')
subplot(2,1,2)
histogram(seizureData.durations, 'BinWidth', 5)
xlabel('seizure duration (s)')
figure
scatter(seizureData.values, seizureData.durations)
xlabel('seizure value')
ylabel('seizure duration (s)')

saveas(gcf, sprintf('%s\\DurationvsDate.png', saveFigsTo))

%% Durations vs time + values color scatterplot
figure
scatter(datetime(seizureData.initTimes, 'ConvertFrom', 'datenum'), seizureData.durations, 'CData', seizureData.values)
colorbar
if ~isempty(date2p)
    hold on
    xline(date2p+1, 'r');
    xlim([datetime(2021, 6, 4) date2p(end)]);
    hold off
end
xlabel('date')
ylabel('seizure duration (s)')
saveas(gcf, sprintf('%s\\DurationvsDatevsValue.png', saveFigsTo))

%% RMS + IQR graphs
seizureRMS = zeros(1, 123);
seizureIQR = zeros(1, 123);
seizureSpects = {};
for i = 1:size(seizureData.values,2)
    rawEEG = seizureData.rawL{i};
    seizureRMS(i) = rms(rawEEG);
    seizureIQR(i) = iqr(rawEEG);
    if seizureData.durations(i) > 1
        [s,w,t] = spectrogram(rawEEG, 250, 125, [], 250);
        seizureSpects{end+1} = s;
    else
        seizureSpects{end+1} = [];
    end
end

figure
subplot(2,1,1)
stem(datetime(seizureData.initTimes, 'ConvertFrom', 'datenum'), seizureRMS)
hold on
xline(date2p+1, 'r');
hold off
xlim([datetime(2021, 6, 4) date2p(end)]);
xlabel('date')
ylabel('RMS')
subplot(2,1,2)
histogram(seizureRMS)
xlabel('RMS')
ylabel('# seizures')
saveas(gcf, sprintf('%s\\RMSvsDate.png', saveFigsTo))

figure
subplot(2,1,1)
stem(datetime(seizureData.initTimes, 'ConvertFrom', 'datenum'), seizureIQR)
hold on
xline(date2p+1, 'r');
hold off
xlim([datetime(2021, 6, 4) date2p(end)]);
xlabel('date')
ylabel('IQR')
subplot(2,1,2)
histogram(seizureRMS)
xlabel('IQR')
ylabel('# seizures')
saveas(gcf, sprintf('%s\\IQRvsDate.png', saveFigsTo))

%%  RMS vs seizure value scatter plot
figure
scatter(seizureData.values, seizureRMS)
xlabel('seizure value')
ylabel('RMS')
saveas(gcf, sprintf('%s\\RMSvsValue.png', saveFigsTo))

%% PCA + tSNE embedding -> clusters from amplitude frequency spectrum
seizurePSD = [];
for i = 1:size(seizureData.rawL,2)
    if seizureData.durations(i) > 1
        seizurePSD(end+1,:) = mean(abs(seizureSpects{i}'));
    end
end

mu = mean(seizurePSD);
sigma = std(seizurePSD);
[standard_data, mu, sigma] = zscore(seizurePSD);     % standardize data so that the mean is 0 and the variance is 1 for each variable
[coeff, score, ~]  = pca(standard_data);     % perform PCA
% new_C = (C-mu)./sigma*coeff;     % apply the PCA transformation to the centroid data
figure
scatter(score(:, 1), score(:, 2), [],seizureData.values(seizureData.durations>1))     % plot 2 principal components of the cluster data (three clusters are shown in different colors)
colorbar
title('PCA')
saveas(gcf, sprintf('%s\\PCASpect.png', saveFigsTo))

figure
score = tsne(standard_data);
scatter(score(:, 1), score(:, 2), [], seizureData.values(seizureData.durations>1))     % plot 2 principal components of the cluster data (three clusters are shown in different colors)
title('tSNE')
colorbar
saveas(gcf, sprintf('%s\\tSNESpect.png', saveFigsTo))

%% plot # seizures vs. weeks
seizureWeekValues = {};
seizureWeekDurations = {};
seizureWeekValuesStacked = zeros(length(date2p)-1,7);
date2pdn = datenum(date2p);
figure
for i=1:size(date2pdn,2)-1
    inds = seizureData.initTimes>date2pdn(i) & seizureData.initTimes<date2pdn(i+1);
    seizureWeekDurations{end+1} = seizureData.durations(inds);
    seizureWeekValues{end+1} = seizureData.values(inds);
    seizureWeekValuesStacked(i,:) = sum(seizureWeekValues{end}'==3:9);
end

% line plot
figure
plot(date2p(1:end-1), sum(seizureWeekValuesStacked'))
xlabel('date')
ylabel('# seizures')
saveas(gcf, sprintf('%s\\SeizureNumLinePlot.png', saveFigsTo))

% simple bargraph
figure
bar(date2p(1:end-1), sum(seizureWeekValuesStacked'))
xlabel('date')
ylabel('# seizures')
saveas(gcf, sprintf('%s\\SeizureNumBarGraph.png', saveFigsTo))

% stacked bargraph
figure
bar(date2p(1:end-1), seizureWeekValuesStacked, 'stacked')
xlabel('date')
ylabel('# seizures')
legend('3','4','5','6','7','8','9', 'Location', 'best')
saveas(gcf, sprintf('%s\\SeizureNumBarStacked.png', saveFigsTo))

%% plot # seizures vs. weeks
seizureWeekValues = {};
seizureWeekDurations = {};
seizureWeekValuesStacked = zeros(length(date2p)-1,3);
seizureValuesThrLow = [3, 5, 7];
seizureValuesThrHigh = [4, 6, 9];
date2pdn = datenum(date2p);
figure
for i=1:size(date2pdn,2)-1
    inds = seizureData.initTimes>date2pdn(i) & seizureData.initTimes<date2pdn(i+1);
    seizureWeekDurations{end+1} = seizureData.durations(inds);
    seizureWeekValues{end+1} = seizureData.values(inds);
    seizureWeekValuesStacked(i,:) = sum(seizureWeekValues{end}'>=seizureValuesThrLow & seizureWeekValues{end}'<=seizureValuesThrHigh);
end

% line plot
figure
yyaxis left
plot([datetime(2021, 6, [2 9]), date2p(1:end-1)], [0 0 sum(seizureWeekValuesStacked')], 'LineWidth', 1.5, 'Marker','s')
ylabel('# seizures')
ylim([0 40])
yyaxis right
severeRatio = seizureWeekValuesStacked(:,end)'./sum(seizureWeekValuesStacked');
severeRatio(isnan(severeRatio)) = 0;
plot(date2p(1:end-1), severeRatio, 'LineWidth', 1.5, 'Marker', 's')
ylabel('severe seizures ratio')
ylim([0 1])
% legend('low', 'medium', 'high', 'Location', 'best')
xlabel('date')
% xlim([datetime(2021, 6, 4) date2p(end-1)]);
pbaspect([3 1 1])
print(gcf, 'SeizureLevelLinePlot3.png', '-dpng', '-r300')

%%
% stacked bargraph
figure
bar(date2p(1:end-1), seizureWeekValuesStacked, 'stacked')
xlabel('date')
ylabel('# seizures')
legend('low', 'medium', 'high', 'Location', 'best')
saveas(gcf, sprintf('%s\\SeizureLevelBarStacked.png', saveFigsTo))
    

    