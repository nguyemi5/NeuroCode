function seizureData = moniSeizureCountAdvanced(inputFiles, thrValue)
% count seizures in set of inputfiles
%
% IN:   inputFiles = regexp identification of label .mat files
%                    e. g. 'C:\path\to\directory\XY*.mat'
%                    must be specified             
%                    note: filesystem is not case-sensitive
%       
% OUT:  seizureData = struct with seizure set specifics
%
% EXAMPLE:  outputData = moniSeizureCount('\\195.113.42.48\Large data\JanaEEGexport_updated\FERDA-PC\Moni ET 430\s\Moni ET 430*.mat')
    if nargin < 2 || isempty(thrValue)
        thrValue = 1;
    end
    directory = dir(inputFiles);   % list of files to be analyzed
    seizureData = struct();
    seizureData.initTimes = [];
    seizureData.durations = [];
    seizureData.values = [];
    seizureData.rawL = {};
%     seizureData.initTimesC = [];
%     seizureData.durationsC = [];
%     seizureData.valuesC = [];
%     seizureData.rawC = {};

    for f = 1:length(directory)
        fname = sprintf('%s\\%s', directory(f).folder, directory(f).name);
        disp(fname);
        load(fname);
        
        % TODO: add sampling frequency as parameter
        rawDataFName = sprintf('%s\\%s\\%s%s', directory(f).folder(1:end-2), '250Hz', directory(f).name(1:end-8), '.mat');
        disp(rawDataFName)
        load(rawDataFName);

        if isfield(label.s, 'ch01') && ~isempty(label.s.ch01)
            label.s.ch01.posN = label.s.ch01.posN(label.s.ch01.value >= thrValue);
            label.s.ch01.durN = label.s.ch01.durN(label.s.ch01.value >= thrValue);
            label.s.ch01.value = label.s.ch01.value(label.s.ch01.value >= thrValue);
            seizureData.initTimes = [seizureData.initTimes, label.s.ch01.posN];
            seizureData.durations = [seizureData.durations, label.s.ch01.durN*24*60*60];
            seizureData.values = [seizureData.values, label.s.ch01.value];
            for i = 1:length(label.s.ch01.posN)
                startSample = ceil(((label.s.ch01.posN(i) - dateN)*24*60*60*fs));
                endSample = ceil((label.s.ch01.posN(i) - dateN + label.s.ch01.durN(i))*24*60*60*fs);
                seizureData.rawL{end+1} = s(strcmp(chanNames, 'L'),startSample:endSample);
            end
        end
        if isfield(label.s, 'ch02') && ~isempty(label.s.ch02)
            label.s.ch02.posN = label.s.ch02.posN(label.s.ch02.value >= thrValue);
            label.s.ch02.durN = label.s.ch02.durN(label.s.ch02.value >= thrValue);
            label.s.ch02.value = label.s.ch02.value(label.s.ch02.value >= thrValue);
            seizureData.initTimes = [seizureData.initTimes, label.s.ch02.posN];
            seizureData.durations = [seizureData.durations, label.s.ch02.durN*24*60*60];
            seizureData.values = [seizureData.values, label.s.ch02.value];
            for i = 1:length(label.s.ch02.posN)
                startSample = max(ceil((label.s.ch02.posN(i) - dateN)*24*60*60*fs), 1);
                endSample = ceil((label.s.ch02.posN(i) - dateN + label.s.ch02.durN(i))*24*60*60*fs);
                seizureData.rawL{end+1} = s(strcmp(chanNames, 'L'),startSample:endSample);
            end
        end
    end   
    date2p = [];
    if contains(fname, 'Moni ET 430')
        date2p = datetime([2021 2021 2021 2021 2021 2021 2021 2021], [6 6 6 7 7 7 7 8], [16 23 30  7 14 21 28 4]);
    end

%     figure
%     subplot(2,1,1)
%     stem(datetime(seizureData.initTimes, 'ConvertFrom', 'datenum'), seizureData.values)
%     if ~isempty(date2p)
%         hold on
%         xline(date2p+1, 'r');
%         xlim([datetime(2021, 6, 4) date2p(end)]);
%         hold off
%     end
%     ylabel('seizure value')
%     subplot(2,1,2)
%     histogram(seizureData.values)
%     xlabel('seizure value')
%     figure
%     subplot(2,1,1)
%     stem(datetime(seizureData.initTimes, 'ConvertFrom', 'datenum'), seizureData.durations)
%     if ~isempty(date2p)
%         hold on
%         xline(date2p+1, 'r');
%         xlim([datetime(2021, 6, 4) date2p(end)]);
%         hold off
%     end
%     ylabel('seizure duration (s)')
%     subplot(2,1,2)
%     histogram(seizureData.durations, 'BinWidth', 5)
%     xlabel('seizure duration (s)')
%     figure
%     scatter(seizureData.values, seizureData.durations)
%     xlabel('seizure value')
%     ylabel('seizure duration (s)')
end

