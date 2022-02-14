function numFiles = sortSmrX(inputFiles, outputDirectory, fs, segmentLength, deleteSmrX, syncTimesLog)
targetSubject = 'Moni ET 430';

% load, resample and sort smrX files from input files to output directory by mice ID    
% by Jana Nguyen 2021
%
% IN:   inputFiles = regexp identification of desired .smrX files
%                    e. g. 'C:\path\to\directory\XY*.smrX'
%                    must be specified             
%                    note: filesystem is not case-sensitive
%       outputDirectory = path to directory where the data should be
%                           exported
%                           default: 'current\directory\output\'
%       fs = required sampling frequency in Hz
%                      default: 250 Hz
%       segmentLength = required segment length in samples
%                       default: 900 000 samples = 1 hours at 250 Hz
%       deleteSmrX = true/false - whether to delete sorted .smrX files
%                     default: false
%       
% OUT:  numFiles = number of created .mat files
%
% EXAMPLE:  sortSmrX('\\195.113.42.48\Large data\EEG data\AMALKA-PC\*\*.smrX', {}, 250, 900000)
%           load and sort all files in AMALKA-PC,                        sample at 250 Hz, save
%           in 1h segments
% input and output parameters - if not specified, the default values are used

% check input, insert default values if unspecified
    if nargin<1 || isempty(inputFiles)
        error('Error: input files not specified');
    else    
        directory = dir(inputFiles);   % list of files to be converted
        if isempty(directory)
            error('Error: input files not found')
        end
    end

    if nargin<2 || isempty(outputDirectory)
        outputDirectory = [pwd, '\output'];
    end
    mkdir(outputDirectory);

    if nargin<3 || isempty(fs)
        fs = 250;
    end

    if nargin<4 || isempty(segmentLength)
        segmentLength = 900000;
    end

    if nargin<5 || isempty(deleteSmrX)
        deleteSmrX = false;
    end

    logVStarts = nargin>=6 && ~isempty(syncTimesLog);

    fr = 20;
    numFiles = 0;
    subjectIDs = readtable('\\neurodata\Common stuff\Monitoring EEG\subject__monitoringID.xlsx');
    stations = ['A', 'B', 'C', 'D'];

    % open (or create) log files, load converted file names
    mismatchFileID = fopen([outputDirectory, '\mismatch_log.txt'], 'a');
    convertedListFileID = fopen([outputDirectory, '\convertedList_', num2str(fs), 'Hz.txt'], 'a');
    convertedFileList = strsplit(fileread([outputDirectory, '\convertedList_', num2str(fs), 'Hz.txt']), '\n');
    notconvertedfd = fopen([outputDirectory, '\notconvertedList_', num2str(fs), 'Hz.txt'], 'a');
    videoTicks = zeros(4,1);
    videoStarts = zeros(4,1);
    videoClock = false(4,1);
    isVideo = false(4,1);

    if logVStarts
        vStartsFileID = fopen(syncTimesLog, 'a');
    end

    for f = 1:length(directory)
        fname = sprintf('%s\\%s', directory(f).folder, directory(f).name);
        disp(fname);
        if ismember(fname, convertedFileList)
            disp(sprintf('%s already converted\n', fname));
            continue
        end

        % find the PC name in the file path
        PC1 = regexp(fname, '\w*-PC');
        PC2 = regexp(fname, '-PC');
        PCName = fname(PC1:PC2+2);
        stationIDs = readtable('\\neurodata\Common stuff\Monitoring EEG\monitoringID__stationID.xlsx', 'Sheet', PCName);

        try
            data = loadSmrxV3(fname);
        catch
            disp(sprintf('%s loading error\n', fname));
            fprintf(notconvertedfd, [replace(fname, '\', '\\'), ' loading error \n']);
            continue
        end

        if data.timeRecDurHod <= 0
            disp(sprintf('%s empty\n', fname));
            fprintf(convertedListFileID, [replace(fname, '\', '\\'),'\n']);
            continue
        end

        % calculate output signal length
        sigLen = ceil(length(data.T.Signal{1}) * fs / max(data.T.SamplingFreq));
%         d = datetime(data.timeRecStartChar);
%         dateStr = data.timeRecStartChar;
%         dateN = data.timeRecStartDn;
        allChanTitles = string(data.T.Title);
        units = 'mV';   % TODO

        for si = 1:4

            d = datetime(data.timeRecStartDn, 'ConvertFrom', 'datenum');
            dateStr = data.timeRecStartChar;
            dateN = data.timeRecStartDn;

            s = stations(si);

            % get subject ID from L-s-XX electrode and monitoringIDs table
            re0 = regexp(string(data.T.Title), ['L-',s,'-']);
            if ~sum(~cellfun(@isempty,re0)) % station not found in this file
                disp('station ID not found')
                disp(allChanTitles)
                continue
            end
            LX = allChanTitles{~cellfun(@isempty,re0)};
            monitoringID = str2num(LX(5:end));
            subject = subjectIDs.PopisekProVas{subjectIDs.monitoringID == monitoringID};
            if ~strcmp(targetSubject, subject)
                continue
            end
            % check monitoringID with stationIDs
            thisStationID = stationIDs{stationIDs.date + stationIDs.time < d + 1/240, si};
            thisStationID = thisStationID(end); % station ID is the last ID preceding the file start time + 10mins
            if thisStationID ~= monitoringID
                fprintf(2, 'Warning: monitoring ID does not match station ID. Data not converted!');
                fprintf(2, 'monitoring ID = %d, stationID = %d', monitoringID, thisStationID);
                fprintf(mismatchFileID, 'Mismatch in subject: %s in file %s, at PC: %s, station: %s, datetime: %s, expected stationID: %d, wired monitoring ID: %d.\n', subject, fname, PCName, s, data.timeRecStartChar, thisStationID, monitoringID);
                continue
            end

            % ensure valid filename
            subject = replace(subject, '/', '-');
            subject = replace(subject, '*', 'nar.');

            fprintf('%s\\%s\\%dHz', outputDirectory, subject, fs);
            mkdir(sprintf('%s\\%s\\%dHz', outputDirectory, subject, fs));          
            
            % get current station channels = *-S channels
            re1 = regexp(allChanTitles, ['-',s]);
            stationChannels = find(~cellfun(@isempty,re1));
            
            % get accelerometer channels = RhdSX channels
            re2 = regexp(allChanTitles, ['Rhd',s,'X']);
            stationChannels2 = find(~cellfun(@isempty,re2));

            if ~isempty(stationChannels)
                nCh1 = length(stationChannels);
                nCh2 = length(stationChannels2);
                chanNames = {};             
                signals = zeros(nCh1+nCh2, sigLen, 'single');
                
                % add EEG data
                for c = 1:nCh1
                    chan = stationChannels(c);
                    chanNames{end+1} = allChanTitles{chan}(1:re1{chan}-1);
                    allChanTitles{chan}
                    if fs == data.T.SamplingFreq(chan)
                        signals(c,:) = data.T.Signal{chan};
                    else
                        signals(c,:) = resample(double(data.T.Signal{chan}), fs, data.T.SamplingFreq(chan));
                    end
                end

                % add accelerometer data
                for c = 1:nCh2
                    chan = stationChannels2(c);
                    chanNames{end+1} = 'RhdX';%allChanTitles{chan}(1:re2{chan}-1);
                    allChanTitles{chan}
                    dataLen = floor(sigLen * data.T.SamplingFreq(chan)/fs);
                    data.T.Signal{chan} = data.T.Signal{chan}(1:dataLen);
                    signals(c+nCh1,:) = resample(double(data.T.Signal{chan}), fs, data.T.SamplingFreq(chan));
                end
                
                nCh = nCh1 + nCh2;
                i = 1;
                ind = 1;
                
                vChanInd = find(strcmp(allChanTitles, ['AUX-', num2str(si)]));
                vTicks = find(diff(data.T.Signal{vChanInd})>2 & [0; diff(data.T.Signal{vChanInd},2)>0])./data.T.SamplingFreq(vChanInd);
                vTicks = vTicks/60/60/24 + dateN;
                vStart = vTicks(diff([dateN;vTicks])>(2/fr/60/60/24));
                ticksCorrect = ~isempty(diff(vTicks)) && median(diff(vTicks) >= 1/2/fr/60/60/24);

                if ~isempty(vStart)
                    fprintf(vStartsFileID, '%s %s\\%s - %c\n', datetime(vStart(end), 'ConvertFrom', 'datenum'), directory(f).folder, directory(f).name, stations(si));
%                     videoTicks(si) = 0;
                    if length(vStart) > 1
                        fprintf(2, 'Warning: more than 1 video start in file: %s\\%s \n', directory(f).folder, directory(f).name);
                        datetime(vStart, 'ConvertFrom', 'datenum')
                        vStart = vStart(end);
                    else
                        fprintf('Video Clock beginning found in file: %s\\%s', directory(f).folder, directory(f).name);
%                         videoStarts(si) = vStart;
                        datetime(vStart, 'ConvertFrom', 'datenum');
                    end
                    videoClock(si) = true;
                else 
                    if videoTicks(si)==0
                        fprintf(2, 'video clock beginning not found for this file: %s\\%s\n', directory(f).folder, directory(f).name);
                        videoClock(si) = false;
%                         continue
                    end
                end
                                
                % save loaded data in segments
                while ind < sigLen
                    s = signals(:, ind:min(ind + segmentLength -1, sigLen));
                    N = min(ind + segmentLength - 1, sigLen) - ind + 1;
                    ind = min(ind + segmentLength);
                    outFName = sprintf('%s\\%s\\%dHz\\%s-%d%02d%02d_%02d%02d%02d-INTN-%dHZ-%03d.mat', ...
                        outputDirectory, subject, fs, subject, ...
                        d.Year-2000, d.Month, d.Day, d.Hour, d.Minute, floor(d.Second), ...
                        fs, i);

                    % add video frame numbers
                    frameStart = 0;
                    frameEnd = 0;
                    frameStartB = 0;
                    frameEndB = 0;
                    isVideo(si) = sum(vTicks>=dateN & vTicks<=(size(s,2)/fs/60/60/24)+dateN)>0;
                    
                    if isVideo(si) && videoClock(si) && abs(videoStarts(si)+videoTicks(si)/fr/60/60/24 - dateN) < 1/24/60
                        frameStart = videoTicks(si);
%                         length(vTicks)
%                         sum(vTicks>=dateN)
%                         sum(vTicks<=(size(s,2)/fs/60/60/24+dateN))
%                         if vStart>dateN & vStart<((size(s,2)/fs/60/60/24)+dateN)
                        if ticksCorrect
                            frameEnd = videoTicks(si) + sum(vTicks>=dateN & vTicks<=dateN+(size(s,2)/fs/60/60/24));
                        else
                            frameEnd = videoTicks(si) + size(s,2)/fs/60/60/24 - max(vStart + dateN, 0);
                        end
                    
                        videoTicks(si) = frameEnd;
                        fprintf('frame numbers found successfully: start=%d end=%d\n', frameStart, frameEnd)
                        videoClock(si) = true;
                    else 
                        if isVideo(si) && videoClock(si) && (vStart>dateN) && (vStart<((size(s,2)/fs/60/60/24)+dateN))
                           videoStarts(si) = vStart;
                           frameStartB = 0;
                           if ticksCorrect
                                frameEndB = sum(vTicks>=max(dateN, vStart) & vTicks<=((size(s,2)/fs/60/60/24)+dateN));
                           else
                                frameEndB = size(s,2)/fs/60/60/24 - vStart + dateN;
                           end
                           videoTicks(si) = frameEndB;
                           videoStarts(si) = vStart;
                           fprintf('video clock initiation successful: start=%d end=%d\n', frameStartB, frameEndB)
                           videoClock(si) = true;
                        else
                           videoClock(si) = false;
                        end
                    end

                    if isVideo(si) && ~videoClock(si)
                       fprintf(2, 'file %s time does not match video clock by %d seconds\n', outFName, abs(videoStarts(si)+videoTicks(si)/fr/60/60/24 - dateN)*60*60*24);
                    end
                    
                    disp(outFName)

                    save(outFName, 'chanNames', 'dateN', 'dateStr', 'fs', 'N', 'nCh', 's', 'subject', 'units', 'frameStart', 'frameEnd', 'frameStartB', 'frameEndB', 'ticksCorrect', 'isVideo', 'videoClock');
                    numFiles = numFiles + 1;
                    i = i+1;
                    
                    dateN = dateN + 1/24;
                    d = datetime(dateN, 'ConvertFrom', 'datenum');
                    dateStr = datestr(d);
                    
                end
            end
        end
%         if deleteSmrX
%             delete(fname)
%         end
        fprintf(convertedListFileID, [replace(fname, '\', '\\'),'\n']);
    end
    fclose(mismatchFileID);
    fclose(convertedListFileID);                
    fclose(notconvertedfd);
    if logVStarts
        fclose(vStartsFileID);
    end
end