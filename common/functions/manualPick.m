function [maskStructure, imageCN, outerSpace, neuronR]=manualPick(imageReference, maskStructIntOld, imageReferenceNEW, FOVandSessionName, transformationType, colorRef, colorNew)
percentile=0.995; % Brightness level for normalization
LImageDim=300; %Real length of the longer FOV side [um]
filtKerSize=75; %Size of the image filtration kernell [um]
filtKerSigm=30;
filtKerSizeMain=3;
filtKerSigmMain=1;
neuronSizeOut=20; % Body diameter of a typical neuron representing given brain area; e.g.in L2/3 cortex it is 12-15um,
neuronSizeIn=8.5; % Nucleus diameter of a typical neuron representing given brain area; e.g. in L2/3 cortex it is 8-10um



%%%% Precalculations
[RImagePix, CImagePix]=size(imageReference);
LImagePix=max(RImagePix, CImagePix);
pixelation=LImagePix/LImageDim; %Pixels per micron.
neuronR=ceil(neuronSizeOut*pixelation/2);
mask=zeros(size(imageReference));
outerSpace=mask;



%%% Image preparation
image=double(imageReference); %Unfortunately inevitable for image statistics.
filtKer=fspecial('gaussian', round(filtKerSize*pixelation), round(filtKerSigm*pixelation));
background=imfilter(image, filtKer);
normFactor=1./background;
imageC=double(image).*normFactor; %Compensated image

pixels=sort(imageC(:)); %%%% This line and the following one are faster than "prctile" function from Statistics Toolbox from Mathworks
THR=pixels(round(length(pixels)*percentile)); 
imageCN=uint8(255*imageC/THR); % Compensated and Normalized image
checkOutImage=cat(3,imageCN,imageCN,imageCN);
imageCN=imadjust(imageReference);

%imshow(imageCN);
% filtMain=fspecial('gaussian', round(filtKerSizeMain*pixelation), round(filtKerSigmMain*pixelation));
% imageCNFilt=imfilter(imageCN, filtMain);
% %imageCNS=single(imageCN);
% imageCNS=single(imageCNFilt);
% %%%
if isempty(imageReferenceNEW)
    if isempty(maskStructIntOld)
        maskStructure=[];
    else
        maskStructure=maskStructIntOld;
    end
%     imshow(imageCN);
    set (gcf, 'Units', 'normalized', 'Position', [0,0,1,1]);
    w=0;
    fig = gcf;
    for index=1:size(maskStructure,2)
        roundVert=maskStructure(1,index).ringPixListSub;
        for blueIndex=1:size(roundVert,1)
            checkOutImage(roundVert(blueIndex,2),roundVert(blueIndex,1),:)=[255 0 0];   
        end
    end
    imshow(checkOutImage)
    index = size(maskStructure,2)+1;
    while index<9999
        while w==0
            %disp('cekam')
            keydown = waitforbuttonpress;
            %disp('jedu')
            if keydown ~=0
            w = double(get(fig,'CurrentCharacter'));
            end
            if w==32
                % name=['h' sprintf('%04d',index)];
                % eval([name '= impoly;']);
                h=impoly;
                while w~=1
                    w=waitforbuttonpress;
                end
                try
                    vertices=getPosition(h);
                catch
                    continue
                end

                %vertices = eval(['getPosition(' name ');']);
                roundVert=round(vertices);
                for blueIndex=1:size(roundVert,1)
                    checkOutImage(roundVert(blueIndex,2),roundVert(blueIndex,1),:)=[255 0 0];   
                end
                maskStructure(1,index).ringPixListSub=roundVert;
                maskStructure(1,index).ringPixList= sub2ind([RImagePix, CImagePix], roundVert(:,2), roundVert(:,1));
                BW=createMask(h);
                %eval(['BW = createMask(' name ');']);
                outerSpace=outerSpace+double(BW);
                maskStructure(1,index).WCPixList=find(BW);
                RP=regionprops(BW);
                maskStructure(1,index).CenterCoor=RP.Centroid;
                break;
            elseif w==113
                break;
            else
                w=0;
            end
        end

        if w==113    
            break;
            commandwindow;
        end
        w=0;
        if mod(index,20)==0    
            close
            imshow(checkOutImage);
            set (gcf, 'Units', 'normalized', 'Position', [0,0,1,1]);
            fig = gcf;
        end
        index = index+1;
    end
    imwrite(checkOutImage, 'checkOutImage.tif', 'tiff');
    reidentificationRecord=zeros(1,size(maskStructure,2));
else
    maskStructure=[];
    if nargin<5 || isempty(transformationType)
        [maskStructure]=maskStructIntTRANSFORMER(maskStructIntOld, imageReference, imageReferenceNEW, FOVandSessionName);
    else
        [maskStructure]=maskStructIntTRANSFORMER(maskStructIntOld, imageReference, imageReferenceNEW, FOVandSessionName, transformationType);
    end

%     maskStructure=test;
    %%% Image preparation   
    image=double(imageReferenceNEW); %Unfortunately inevitable for image statistics.
    filtKer=fspecial('gaussian', round(filtKerSize*pixelation), round(filtKerSigm*pixelation));
    background=imfilter(image, filtKer);
    normFactor=1./background;
    imageC=double(image).*normFactor; %Compensated image
    
    pixels=sort(imageC(:)); %%%% This line and the following one are faster than "prctile" function from Statistics Toolbox from Mathworks
    THR=pixels(round(length(pixels)*percentile)); 
    imageCN=uint8(255*imageC/THR); % Compensated and Normalized image
    checkOutImage=cat(3,imageCN,imageCN,imageCN);
    
    imageRef=double(imageReference);
    backgroundRef=imfilter(imageRef, filtKer);
    normFactorRef=1./backgroundRef;
    imageCRef=double(imageRef).*normFactor; %Compensated image
    pixelsRef=sort(imageCRef(:)); %%%% This line and the following one are faster than "prctile" function from Statistics Toolbox from Mathworks
    THRRef=pixelsRef(round(length(pixelsRef)*percentile)); 
    imageCNRef=uint8(255*imageCRef/THRRef); % Compensated and Normalized image
    if nargin>=6 & ~isempty(colorRef)
        imageCNRefC=colorRef;
    else
        imageCNRefC=imageCNRef;
    end
    
    figHandle = figure;
    axNew = subplot(2,3,[1 2 4 5], 'Parent', figHandle);
    imshow(imageCN, 'Parent', axNew)
    hold(axNew, 'on')
    title('New FOV', 'Parent', axNew)

    axRefC = subplot(2,3,3, 'Parent', figHandle);
    imshow(imageCNRefC, 'Parent', axRefC)
    hold(axRefC, 'on')
    title('Reference FOV', 'Parent', axRefC)

    axRef = subplot(2,3,6, 'Parent', figHandle);
    imshow(imageCNRef, 'Parent', axRef)
    hold(axRef, 'on')
% 	title('Reference FOV', 'Parent', axRef)

    set (figHandle, 'Units', 'normalized', 'Position', [0,0,1,1]);
    reidentificationRecord=zeros(1,size(maskStructure,2));
    Nindex = 1;
    while Nindex<=size(maskStructIntOld,2)
        neuronTMPPoints=maskStructure(1,Nindex).ringPixListSub;
        neuronTMP_Y=round(maskStructure(1,Nindex).CenterCoor(2));
        neuronTMP_X=round(maskStructure(1,Nindex).CenterCoor(1));
        if (neuronTMP_X-2*neuronR)<1
            XlimLeft=1;
        else
            XlimLeft=neuronTMP_X-2*neuronR;   
        end
        
        if (neuronTMP_X+2*neuronR)>CImagePix
            XlimRight=CImagePix;
        else
            XlimRight=neuronTMP_X+2*neuronR;   
        end
        
        if (neuronTMP_Y-2*neuronR)<1
            YlimTop=1;
        else
            YlimTop=neuronTMP_Y-2*neuronR;   
        end
        
        if (neuronTMP_Y+2*neuronR)>RImagePix
            YlimDown=RImagePix;
        else
            YlimDown=neuronTMP_Y+2*neuronR;   
        end
        h= impoly(axNew, neuronTMPPoints);
        text(round(maskStructure(1,Nindex).CenterCoor(1)),round(maskStructure(1,Nindex).CenterCoor(2)),num2str(Nindex),'Color','cyan','FontWeight','bold', 'Parent', axNew)
        xlim (axNew, [XlimLeft XlimRight]);
        ylim(axNew, [YlimTop YlimDown]);

	    refNeuronTMPPoints=maskStructIntOld(1,Nindex).ringPixListSub;
        refNeuronTMP_Y=round(maskStructIntOld(1,Nindex).CenterCoor(2));
        refNeuronTMP_X=round(maskStructIntOld(1,Nindex).CenterCoor(1));
        if (refNeuronTMP_X-2*neuronR)<1
            XlimLeft=1;
        else
            XlimLeft=refNeuronTMP_X-2*neuronR;   
        end
        
        if (refNeuronTMP_X+2*neuronR)>CImagePix
            XlimRight=CImagePix;
        else
            XlimRight=refNeuronTMP_X+2*neuronR;   
        end
        
        if (refNeuronTMP_Y-2*neuronR)<1
            YlimTop=1;
        else
            YlimTop=refNeuronTMP_Y-2*neuronR;   
        end
        
        if (refNeuronTMP_Y+2*neuronR)>RImagePix
            YlimDown=RImagePix;
        else
            YlimDown=refNeuronTMP_Y+2*neuronR;   
        end
	    hRef= impoly(axRef, refNeuronTMPPoints);
        text(round(maskStructIntOld(1,Nindex).CenterCoor(1)),round(maskStructIntOld(1,Nindex).CenterCoor(2)),num2str(Nindex),'Color','cyan','FontWeight','bold', 'Parent', axRef)
        xlim (axRef, [XlimLeft XlimRight]);
        ylim(axRef, [YlimTop YlimDown]);
	    
        hRefC= impoly(axRefC, refNeuronTMPPoints);
        text(round(maskStructIntOld(1,Nindex).CenterCoor(1)),round(maskStructIntOld(1,Nindex).CenterCoor(2)),num2str(Nindex),'Color','cyan','FontWeight','bold', 'Parent', axRefC)
        xlim (axRefC, [XlimLeft XlimRight]);
        ylim(axRefC, [YlimTop YlimDown]);

        reidentificationRecord(Nindex)=0;
        pomocna=[];
        reidentC=nan;
        w = 0;
        while isempty(pomocna) || (pomocna~=13 && pomocna~=28) || w==0
            w = waitforbuttonpress;
            reidentC = pomocna;
            pomocna = double(get(figHandle,'CurrentCharacter'));
        end
        if pomocna==28
            Nindex = max(1, Nindex - 1);
            disp('go back')
            delete(h);
            delete(hRef);
            delete(hRefC);
            continue
        end
        if isempty(reidentC)
            reidentificationRecord(Nindex) = nan;
        else
            reidentificationRecord(Nindex) = reidentC;
        end
        
        vertices =getPosition(h);
        
        roundVert=round(vertices);
        for blueIndex=1:size(roundVert,1)
            checkOutImage(roundVert(blueIndex,2),roundVert(blueIndex,1),:)=[255 0 0];   
        end
        maskStructure(1,Nindex).ringPixListSub=roundVert;
        try
            maskStructure(1,Nindex).ringPixList= sub2ind([RImagePix, CImagePix], roundVert(:,2), roundVert(:,1));
        catch
            maskStructure(1,Nindex).ringPixList=[];
        end
        BW = createMask(h);
        outerSpace=outerSpace+double(BW);
        maskStructure(1,Nindex).WCPixList=find(BW);
        RP=regionprops(BW);
        if isempty(RP)
            maskStructure(1,Nindex).CenterCoor=nan;
        else
            maskStructure(1,Nindex).CenterCoor=RP.Centroid;
        end
        
        delete(h);
        delete(hRef);
        delete(hRefC);
                    
        if mod(Nindex,13)==0      
            close
            figHandle = figure;
            axNew = subplot(2,3,[1 2 4 5], 'Parent', figHandle);
            imshow(imageCN, 'Parent', axNew)
            hold(axNew, 'on')
            title('New FOV', 'Parent', axNew)
        
            axRefC = subplot(2,3,3, 'Parent', figHandle);
            imshow(imageCNRefC, 'Parent', axRefC)
            hold(axRefC, 'on')
            title('Reference FOV', 'Parent', axRefC)
        
            axRef = subplot(2,3,6, 'Parent', figHandle);
            imshow(imageCNRef, 'Parent', axRef)
            hold(axRef, 'on')
        % 	title('Reference FOV', 'Parent', axRef)
            set (figHandle, 'Units', 'normalized', 'Position', [0,0,1,1]);
        end
        Nindex = Nindex + 1;
    end
    imwrite(checkOutImage, 'checkOutImage.tif', 'tiff');
end

close;
FOVandSessionName(end+1:end+4)='.mat';
save(FOVandSessionName);
figure
imshow(checkOutImage);
figure(gcf);
for indexMarker=1:size(maskStructure,2) %%%Here it produces a nice annotated reference image
    if reidentificationRecord(indexMarker)==108
        colorVector=[0 0 1];
    else
        colorVector=[0 1 0];
    end
    try
    hText = text(round(maskStructure(1,indexMarker).CenterCoor(1)),round(maskStructure(1,indexMarker).CenterCoor(2)),num2str(indexMarker),'Color',colorVector,'FontSize',8);
    end
end
fname=FOVandSessionName;
fname(end-3:end)='.fig';
savefig(fname);
fname(end-3:end)='.png';
print(gcf,fname,'-dpng', '-r300');
end
