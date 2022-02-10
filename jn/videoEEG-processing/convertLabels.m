inputFiles = '\\neurodata2\Large data\JanaEEGexport_updated\FERDA-PC\Moni ET 430\s\*.mat';
% outputDirectory = '\\neurodata2\Large data\JanaEEGexport_updated\FERDA-PC\Moni ET 430\s-newformat';
outputDirectory = '\\neurodata\Common stuff\JanaLabels-newformat\Moni ET 430\s';
numFiles = 0;

directory = dir(inputFiles);
for f=1:length(directory)
    labelData = load([directory(f).folder, '\', directory(f).name]);
    eegData = load(labelData.label.s.srcSigFile{1});
    sigInfo = table('Size', [eegData.nCh, 7],...
                'VariableTypes', {'string',       'string',       'string',       'string',       'datetime',  'datetime'  'double'},...
                'VariableNames', {'FileName',     'FilePath',     'Subject',      'ChName',       'SigStart',  'SigEnd',   'Fs'}); % Possible dropouts should be stored in a label class
    [sigFilep, sigFilen, sigFilee] =  fileparts(labelData.label.s.srcSigFile);
    sigInfo.FileName = repelem(string([sigFilen, sigFilee]), eegData.nCh)';
    sigInfo.FilePath = repelem(string(sigFilep)+"\", eegData.nCh)';
    sigInfo.Subject = repelem(string(labelData.label.s.subject), eegData.nCh)';
    sigInfo.ChName = string(labelData.label.s.chanNames);
    sigInfo.ChName(sigInfo.ChName=="") = "RhdX";
    sigInfo.SigStart = repelem(datetime(eegData.dateN, 'ConvertFrom', 'datenum'), eegData.nCh)';
    sigInfo.SigEnd = repelem(datetime(eegData.dateN+(size(eegData.s,2)/eegData.fs/60/60/24), 'ConvertFrom', 'datenum'), eegData.nCh)';
    sigInfo.Fs = repelem(eegData.fs, eegData.nCh)';  

    ClassName = "s";
    ChannelMode = categorical("one"); ChannelMode = addcats(ChannelMode, ["one", "all"]); % one: the label is associated with a channel,
    % all: the label is associated with animal's behavior, power-line glitch, lights on, etc. and displays in all channels (but, in fact, is
    % not associated with them)
    LabelType = categorical("roi"); LabelType = addcats(LabelType, ["point", "roi"]);
    Color = string(labelData.label.s.color);
    lblDef = table(ClassName, ChannelMode, LabelType, Color); 

    lblSet = table('Size', [0 9],...
                'VariableTypes', {'string',      'int16',    'datetime', 'datetime',   'double',      'string',  'logical',   'int64', 'string'},...
                'VariableNames', {'ClassName',   'Channel',  'Start',    'End',        'Value',       'Comment', 'Selected',  'ID',    'SignalFile'});
            %                     E.g. Seizure), Channel,    _______datetime_______,   User-defined,  Comment,   For delete,  Unique,  Signal filepn
    
    if isfield(labelData.label.s, "ch01") & ~isempty(labelData.label.s.ch01) & ~isempty(labelData.label.s.ch01.posN)
        ind1 = size(lblSet,1);
        ind2 = ind1 + size(labelData.label.s.ch01.posN,2);
        lblSet.ClassName(ind1+1:ind2) = repelem("s", ind2-ind1)';
%         lblSet.Channel(ind1+1:ind2) = repelem(labelData.label.s.chanNames{1}, ind2-ind1)';
        lblSet.Channel(ind1+1:ind2) = repelem(1, ind2-ind1)';
        lblSet.Start(ind1+1:ind2) = datetime(labelData.label.s.ch01.posN, 'ConvertFrom', 'datenum')';
        lblSet.End(ind1+1:ind2) = datetime(labelData.label.s.ch01.posN + labelData.label.s.ch01.durN, 'ConvertFrom', 'datenum')';
        lblSet.Value(ind1+1:ind2) = labelData.label.s.ch01.value';
        lblSet.ID(ind1+1:ind2) = (ind1+1:ind2)';
        lblSet.SignalFile(ind1+1:ind2) = repelem(labelData.label.s.srcSigFile, ind2-ind1)';
    end
        
    if isfield(labelData.label.s, "ch02") & ~isempty(labelData.label.s.ch02) & ~isempty(labelData.label.s.ch02.posN)
        ind1 = size(lblSet,1);
        ind2 = ind1 + size(labelData.label.s.ch02.posN,2);
        lblSet.ClassName(ind1+1:ind2) = repelem("s", ind2-ind1)';
%         lblSet.Channel(ind1+1:ind2) = repelem(labelData.label.s.chanNames{2}, ind2-ind1)';
        lblSet.Channel(ind1+1:ind2) = repelem(2, ind2-ind1)';
        lblSet.Start(ind1+1:ind2) = datetime(labelData.label.s.ch02.posN, 'ConvertFrom', 'datenum')';
        lblSet.End(ind1+1:ind2) = datetime(labelData.label.s.ch02.posN + labelData.label.s.ch02.durN, 'ConvertFrom', 'datenum')';
        lblSet.Value(ind1+1:ind2) = labelData.label.s.ch02.value';
        lblSet.ID(ind1+1:ind2) = (ind1+1:ind2)';
        lblSet.SignalFile(ind1+1:ind2) = repelem(labelData.label.s.srcSigFile, ind2-ind1)';
    end

    if isfield(labelData.label.s, "ch03") & ~isempty(labelData.label.s.ch03) & ~isempty(labelData.label.s.ch03.posN)
        ind1 = size(lblSet,1);
        ind2 = ind1 + size(labelData.label.s.ch03.posN,2);
        lblSet.ClassName(ind1+1:ind2) = repelem("s", ind2-ind1)';
%         lblSet.Channel(ind1+1:ind2) = repelem(labelData.label.s.chanNames{3}, ind2-ind1)';
        lblSet.Channel(ind1+1:ind2) = repelem(3, ind2-ind1)';
        lblSet.Start(ind1+1:ind2) = datetime(labelData.label.s.ch03.posN, 'ConvertFrom', 'datenum')';
        lblSet.End(ind1+1:ind2) = datetime(labelData.label.s.ch03.posN + labelData.label.s.ch03.durN, 'ConvertFrom', 'datenum')';
        lblSet.Value(ind1+1:ind2) = labelData.label.s.ch03.value';
        lblSet.ID(ind1+1:ind2) = (ind1+1:ind2)';
        lblSet.SignalFile(ind1+1:ind2) = repelem(labelData.label.s.srcSigFile, ind2-ind1)';
    end
    
    save([outputDirectory, '\', directory(f).name], 'sigInfo', 'lblDef', 'lblSet');

    numFiles = numFiles+1;
end
