function [APs, drifting, dataRow_filt,APsFiner, dataRowFiner, dataRowFinerOrig, baseline]=peeling_test(dataRow_filt, sampleRate)

[~, dataRow_filt, ~, baseline, ~, ~]=baselineCorrector2_test(dataRow_filt, sampleRate);

[dataRow_filt, d] = lowpass(dataRow_filt,5,sampleRate,'ImpulseResponse','iir','Steepness',0.95);
%%%Upsampling
upCoefficient=3;
x=linspace(1,length(dataRow_filt), length(dataRow_filt));
xx=linspace(1/upCoefficient,length(dataRow_filt),upCoefficient*length(dataRow_filt));
dataRowFiner=interp1(x,dataRow_filt,xx);
dataRowFinerOrig=dataRowFiner;
sampleRate=upCoefficient*sampleRate;

%"peeling" algorithm developed by prof. Helmchen and published
%in (Grewe et al. 2010). The algorithm was slightly adapted,
% the precise onset-fitting is absent.

%MAIN ADJUSTABLE INNER PARAMETERS

hit=15;%6; %higher int. treshold can be made depandable on s.d. from PBest
lit=5; %lower int. treshold can be made depandable on s.d. from PBest
eventTime=0.35;%0.07; %how long does the signal have to stay above the "lit" after crossing the "hit" [seconds]
integralsRatio=0.7; %minimum realspike-modelspike integral ratio
% maximum allowed baseline/history slope [%/second];
drifting=0;


[integralModel, intX, intY, secondsOfIntegral]=APCaModelInt_test(sampleRate, hit); % calling the model-based calcium spike
%the function returns the integral value of the model-based
%calcium spike and its points according the given sampling
%rate.

APsFiner=zeros(size(dataRowFiner));
APs=zeros(size(dataRow_filt));

eventHalfLength=ceil(eventTime*sampleRate);
% eventLenght=ceil(2*eventTime*sampleRate);
futurePointsSubstracted=length(intX);

index=1;
while index<=(length(dataRowFiner)-futurePointsSubstracted)
    
    if dataRowFiner(index)>hit % first condition - a putative onset of spike
        %disp('condition 1 met')
        %index
        if isempty(find((dataRowFiner(index:index+eventHalfLength))<lit, 1)) %second condition - duration
            %disp('condition 2 met')
            
            integralSignal=sum(dataRowFiner(index:index+round(secondsOfIntegral*sampleRate)-1));
            
            if integralSignal>integralsRatio*integralModel %third condition - integrals ratio
                %disp('condition 3 met')
%                 integralSignal
%                 integralModel
                if sum(dataRowFiner(index:index+futurePointsSubstracted-1)-intY)>=0 % forth condition nonnegativeness of the residuum in futureTimeTaken window
                    dataRowFiner(index:index+futurePointsSubstracted-1)=dataRowFiner(index:index+futurePointsSubstracted-1)-intY;
                    APsFiner(index)=APsFiner(index)+1;
                    %disp('condition 4 met')
                    if (index-1)<=1

                    else
                    index=index-1; %reversing
                    end
                    
                    
                else
                    index=index+1;
                    
                end
            else
            index=index+1;    
            end
        else    
            index=index+1;
            
        end
    else    
        index=index+1;
    end
   
end
for downIndex=1:length(dataRow_filt)
APs(downIndex)=sum(APsFiner(upCoefficient*(downIndex-1)+1:upCoefficient*downIndex));
end
% APsFiner
% APs
% pause
% 
% time=linspace(0,length(dataRow)/sampleRate,length(dataRow));
% time10=linspace(0,length(dataRow)/sampleRate,upCoefficient*length(dataRow));
% plot(time,dataRow);
% hold on
% plot(time,APs*10,'r');
% grid minor
% plot(time10,dataRowFiner, 'g')
% pause;
% close;
end