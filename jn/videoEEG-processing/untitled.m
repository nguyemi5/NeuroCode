inputVideoFiles = '\\neurodata2\Large data\Video data\MonitoringVideokompHP\camA\camA__23431782__20210614_09210896*';
inputEEGFiles = '\\neurodata2\Large data\JanaEEGexport_updated\FERDA-PC\Moni ET 430';
outputDirectory = 'E:\outputVideos';

numFiles = 0;
PCName = 'FERDA-PC';
fr = 20;
fs = 250;
subjectIDs = readtable('\\neurodata\Common stuff\Monitoring EEG\subject__monitoringID.xlsx');
stationIDs = readtable('\\neurodata\Common stuff\Monitoring EEG\monitoringID__stationID.xlsx', 'Sheet', PCName);
stations = {'A', 'B', 'C', 'D'};
% open (or create) log files, load converted file names
mismatchFileID = fopen([outputDirectory, '\mismatch_log.txt'], 'a');
convertedListFileID = fopen([outputDirectory, '\convertedList_', num2str(fs), 'Hz.txt'], 'a');
convertedFileList = strsplit(fileread([outputDirectory, '\convertedList_', num2str(fs), 'Hz.txt']), '\n');
notconvertedfd = fopen([outputDirectory, '\notconvertedList_', num2str(fs), 'Hz.txt'], 'a');
directory = dir(inputVideoFiles);
eegDirectory = dir(inputEEGFiles);

for f = 1:length(directory)
    fname = sprintf('%s\\%s', directory(f).folder, directory(f).name);
    si = find(strcmp(stations, directory(f).name(4)));
    disp(fname);
%     if ismember(fname, convertedFileList)
%         disp(sprintf('%s already converted\n', fname));

%         continue
%     end

    v = VideoReader(fname);
    vCam = directory(f).name(4);
    vDate = directory(f).name(17:24);
    vTime = directory(f).name(26:end-4);
    vDnStart = datenum(directory(f).name(17:end-4), 'yyyymmdd_HHMMSSFFF');
    vDnEnd = vDnStart + v.Duration/60/60/24;
    vDateTimeStart = datetime(vDnStart, 'ConvertFrom', 'datenum');
    vDateTimeEnd = datetime(vDnEnd, 'ConvertFrom', 'datenum');
    
    if v.Duration <= 0
        disp(sprintf('%s empty\n', fname));
        fprintf(convertedListFileID, [replace(fname, '\', '\\'),'\n']);
        continue
    end
 
    % check monitoringID with stationIDs
    prevLines = find(stationIDs.date + stationIDs.time < vDateTimeStart + 1/240);
    lineStart = prevLines(end);
    prevLines = find(stationIDs.date + stationIDs.time < vDateTimeEnd);
    lineEnd = prevLines(end);

    for l = lineStart:lineEnd
        thisStationID = stationIDs{l, si};
        subject = subjectIDs.PopisekProVas{subjectIDs.monitoringID == thisStationID};

        % ensure valid filename
        subject = replace(subject, '/', '-');
        subject = replace(subject, '*', 'nar.');

        disp(sprintf('%s\\%s\\%dHz', outputDirectory, subject, fs))
        mkdir(sprintf('%s\\%s\\%dHz', outputDirectory, subject, fs));      

        % search for corresponding .mat files
        eegDirectory = dir(sprintf('%s\\*\\*%s-*', inputEEGFiles, subject));
        for e=1:length(eegDirectory)
            ind = length(subject);
            dnMatFile = datenum(eegDirectory(e).name(ind+2:ind+14), 'yymmdd_HHMMSS');
            if dnMatFile>vDnStart && (dnMatFile + 1/24)<vDnEnd
                eegData = load([eegDirectory(e).folder, '\', eegDirectory(e).name]);
                timeStart = datetime(eegData.dateN, 'ConvertFrom', 'datenum') - vDateTimeStart;
                if exist(sprintf('%s\\%s\\%s-%s.mp4', outputDirectory, subject, subject, eegDirectory(e).name(ind+1:ind+13)), 'file')
                    fprintf('file %s\\%s\\%s-%s.mp4 exists - skipping conversion\n', outputDirectory, subject, subject, eegDirectory(e).name(ind+1:ind+13))
                    continue
                end
                ffmpegCommand = sprintf('-ss %s -i "%s" -t %s -c copy "%s\\%s\\%s-%s.mp4"', timeStart, fname, duration(0,0,eegData.N/eegData.fs), outputDirectory, ...
                    subject, subject, eegDirectory(e).name(ind+1:ind+13))
                ffmpegexec(ffmpegCommand);
                numFiles = numFiles+1;
            else if vDnEnd>(dnMatFile + 1/24) && (dnMatFile + 1/24)>vDnStart
                eegData = load([eegDirectory(e).folder, '\', eegDirectory(e).name]);
                timeStart = datetime(eegData.dateN, 'ConvertFrom', 'datenum') - vDateTimeStart;
                if exist(sprintf('%s\\%s\\%s-%s_b.mp4', outputDirectory, subject, subject, eegDirectory(e).name(ind+1:ind+13)), 'file')
                    fprintf('file %s\\%s\\%s-%s_b.mp4 exists - skipping conversion\n', outputDirectory, subject, subject, eegDirectory(e).name(ind+1:ind+13))
                    continue
                end
                ffmpegCommand = sprintf('-ss %s -i "%s" -t %s -c copy "%s\\%s\\%s-%s_b.mp4"', timeStart, fname, duration(0,0,v.Duration)-timeStart, outputDirectory, ...
                    subject, subject, eegDirectory(e).name(ind+1:ind+13))
                ffmpegexec(ffmpegCommand);
                numFiles = numFiles+1;
            
            else if vDnStart<dnMatFile && dnMatFile<vDnEnd
                eegData = load([eegDirectory(e).folder, '\', eegDirectory(e).name]);
                timeStart = datetime(eegData.dateN, 'ConvertFrom', 'datenum') - vDateTimeStart;
                if exist(sprintf('%s\\%s\\%s-%s_a.mp4', outputDirectory, subject, subject, eegDirectory(e).name(ind+1:ind+13)), 'file')
                    fprintf('file %s\\%s\\%s-%s_a.mp4 exists - skipping conversion\n', outputDirectory, subject, subject, eegDirectory(e).name(ind+1:ind+13))
                    continue
                end
                videoDur = vDnEnd - dnMatFile;
                ffmpegCommand = sprintf('-ss %s -i "%s" -t %s -c copy "%s\\%s\\%s-%s_a.mp4"', duration(0,0,0), fname, duration(videoDur*24, 0, 0), outputDirectory, ...
                    subject, subject, eegDirectory(e).name(ind+1:ind+13))
                ffmpegexec(ffmpegCommand);
                numFiles = numFiles+1;    
            end
            end
            end
        end
    end
    fprintf(convertedListFileID, [replace(fname, '\', '\\'),'\n']);
end
fclose(mismatchFileID);
fclose(convertedListFileID);                
fclose(notconvertedfd);
