function numFiles = sortSmrX(inputFiles, outputDirectory, fs, segmentLength, deleteSmrX)
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

    numFiles = 0;
    subjectIDs = readtable('C:\Users\minht\Desktop\spike\subject__monitoringID.xlsx');
    stations = ['A', 'B', 'C', 'D'];

    % open (or create) log files, load converted file names
    mismatchFileID = fopen([outputDirectory, '\mismatch_log.txt'], 'a');
    convertedListFileID = fopen([outputDirectory, '\convertedList_', num2str(fs), 'Hz.txt'], 'a');
    convertedFileList = strsplit(fileread([outputDirectory, '\convertedList_', num2str(fs), 'Hz.txt']), '\n');
    notconvertedfd = fopen([outputDirectory, '\notconvertedList_', num2str(fs), 'Hz.txt'], 'a');

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
        stationIDs = readtable('C:\Users\minht\Desktop\spike\monitoringID__stationID.xlsx', 'Sheet', PCName);

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
                continue
            end
            LX = allChanTitles{~cellfun(@isempty,re0)};
            monitoringID = str2num(LX(5:end));
            subject = subjectIDs.PopisekProVas{subjectIDs.monitoringID == monitoringID};
            
            % check monitoringID with stationIDs
            thisStationID = stationIDs{stationIDs.date + stationIDs.time < d + 1/240, si};
            thisStationID = thisStationID(end); % station ID is the last ID preceding the file start time + 10mins
            if thisStationID ~= monitoringID
                disp('Warning: monitoring ID does not match station ID. Data not converted!');
                disp(sprintf('monitoring ID = %d, stationID = %d', monitoringID, thisStationID));
                fprintf(mismatchFileID, 'Mismatch in subject: %s in file %s, at PC: %s, station: %s, datetime: %s, expected stationID: %d, wired monitoring ID: %d.\n', subject, fname, PCName, s, data.timeRecStartChar, thisStationID, monitoringID);
                continue
            end

            % ensure valid filename
            subject = replace(subject, '/', '-');
            subject = replace(subject, '*', 'nar.');

            disp(sprintf('%s\\%s\\%dHz', outputDirectory, subject, fs))
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
                    chanNames{end+1} = allChanTitles{chan}(1:re1{chan}-1);
                    allChanTitles{chan}
                    dataLen = floor(sigLen * data.T.SamplingFreq(chan)/fs);
                    data.T.Signal{chan} = data.T.Signal{chan}(1:dataLen);
                    signals(c+nCh1,:) = resample(double(data.T.Signal{chan}), fs, data.T.SamplingFreq(chan));
                end
                
                nCh = nCh1 + nCh2;
                i = 1;
                ind = 1;

                % save loaded data in segments
                while ind < sigLen
                    s = signals(:, ind:min(ind + segmentLength -1, sigLen));
                    N = min(ind + segmentLength - 1, sigLen) - ind + 1;
                    ind = min(ind + segmentLength);
                    outFName = sprintf('%s\\%s\\%dHz\\%s-%d%02d%02d_%02d%02d%02d-INTN-%dHZ-%03d.mat', ...
                        outputDirectory, subject, fs, subject, ...
                        d.Year-2000, d.Month, d.Day, d.Hour, d.Minute, floor(d.Second), ...
                        fs, i);

                    disp(outFName)

                    save(outFName, 'chanNames', 'dateN', 'dateStr', 'fs', 'N', 'nCh', 's', 'subject', 'units');
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
end