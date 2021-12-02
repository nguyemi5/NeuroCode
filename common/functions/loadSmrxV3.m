function S = loadSmrxV3(fpname,regexp_title)
% load smrx file
% Jan Emsik Chvojka 2021, the best programmer of all time
% expression ... regexpi that filters channel Title name
% commentNames ... cell of subject names that should match Comment
% fpname ... file and path to the smrx file

switch nargin
    case 2

    case 1
        regexp_title=['.*'];
    otherwise

end

warning off

%regexpi('aRhdA','^Rhd*')
addpath('C:\CEDMATLAB\CEDS64ML');
CEDS64LoadLib('C:\CEDMATLAB\CEDS64ML');

fhand1 = CEDS64Open( fpname );
if (fhand1 <= 0)
    disp('nejde to na?íst'); 
    CEDS64ErrorMessage(fhand1); 
    unloadlibrary ceds64int; 
    return; 
end
maxchans = CEDS64MaxChan( fhand1 );
%timebase = CEDS64TimeBase( fhand1 );
maxTimeTicks = CEDS64MaxTime( fhand1 )+2;
[ iOk, TimeDateOut ] = CEDS64TimeDate( fhand1 );
TimeDateOut = double(TimeDateOut);
%   The structure of the time-date vector is:
%   element 1 - hundredths of seconds (0-99)
%   element 2 - seconds (0-59)
%   element 3 - minutes (0-59)
%   element 4 - hours (0-23)
%   element 5 - day of the month (1-31)
%   element 6 - month of the year (1-12)
%   element 7 - year (1980-2200)
timeRecStartedDn = datenum(TimeDateOut(7),TimeDateOut(6),TimeDateOut(5),TimeDateOut(4),TimeDateOut(3),TimeDateOut(2)+0.01*TimeDateOut(1));

maxpoints=maxTimeTicks;


S=struct;
varTypes = {'categorical','categorical','categorical','double','double','double','double','cell'};
varNames = {'Title','Comment','Units','SamplingFreq','StartDn','EndDn','DurDn','Signal'};
S.T = table('Size',[1,numel(varNames)],'VariableTypes',varTypes,'VariableNames',varNames);



%%%%%%%%%%%%%%%%%%%%%%%%%
% loop through all channels in fhand1 and copy them to fhand2
id=0;
for m = 1:maxchans
    chan = CEDS64ChanType( fhand1, m );
    if (chan > 0) % is there a channel m?
        chandiv = CEDS64ChanDiv( fhand1, m );
        fs = CEDS64IdealRate( fhand1, m ); 
        
        [ iOk, sComment ] = CEDS64ChanComment( fhand1, m );
        [ iOk, dOffset ] = CEDS64ChanOffset( fhand1, m );
        [ iOk, dScale ] = CEDS64ChanScale( fhand1, m );
        [ iOk, sTitle ] = CEDS64ChanTitle( fhand1, m );
        [ iOk, sUnits ] = CEDS64ChanUnits( fhand1, m );
        sTitle
        if ~isempty(regexp(sTitle,regexp_title))
            % load based on type of data
            switch(chan)
                case 0 % there is no channel with this number
                    %disp('error zero'); 
                case 1  % ADC channel
                    id=id+1;
                    [shortread, shortvals, shorttime] = CEDS64ReadWaveS( fhand1, m, maxpoints, 0 );
                    %disp('loaded');
                    % save all for one channel
                    S.T.Title(id)=sTitle;
                    S.T.Comment(id)=sComment;
                    S.T.Units(id) = sUnits;
                    S.T.SamplingFreq(id) = fs;
                    S.T.StartDn(id) = timeRecStartedDn;
                    S.T.EndDn(id) = timeRecStartedDn + sec2dn(numel(shortvals)/fs);
                    S.T.DurDn(id) = S.T.EndDn(id) - S.T.StartDn(id);
                    S.T.Signal(id)= {5*single(shortvals)/32767};   
                otherwise
                    %disp('error other'); 
            end
 


        end
    end
end




S.timeRecStartDn=timeRecStartedDn;
S.timeRecEndDn= max(S.T.EndDn(S.T.Title~='Keyboard'));
S.timeRecDurDn = max(S.T.DurDn(S.T.Title~='Keyboard'));
S.timeRecDurHod = max(S.T.DurDn(S.T.Title~='Keyboard'))*24;


S.timeRecStartChar=datestr(S.timeRecStartDn);
S.timeRecEndChar=datestr(S.timeRecEndDn);

maxSamples=max(cellfun(@length,S.T.Signal));
S.Nchanels=size(S.T,1);
for i=1:S.Nchanels
    samplesOneCh=size(S.T.Signal{i},1);
    if samplesOneCh<maxSamples
        samplesOneCh
        S.T.Signal{i}=[S.T.Signal{i}; single(zeros(maxSamples-samplesOneCh,1))];
    end
end

% close both files
CEDS64CloseAll();
% unload ceds64int.dll
unloadlibrary ceds64int;

end
