
FOV = 6;
load(sprintf('\\\\195.113.42.48\\Large data\\Monika 2p\\VIP_tdT\\534 M\\2p 20210731 534M F2\\file_%05d_aligned_CH2outOf200001.mat', FOV));
%%
FOV = 44;
load(sprintf('\\\\195.113.42.48\\Large data\\Monika 2p\\VIP_tdT\\430F\\2p 20210630 430F F3\\file_%05d_aligned_CH2outOf200001.mat', FOV));
imageReference = imadjust(uint16(mean(dataset.aligned, 3)));
figure
imshow(imageReference)
%%
FOV = 51;
load(sprintf('\\\\195.113.42.48\\Large data\\Monika 2p\\VIP_tdT\\430F\\2p 20210707 430F F4\\file_%05d_aligned_CH2outOf200001.mat', FOV));
imageReferenceNEW = imadjust(uint16(mean(dataset.aligned, 3)));
figure
imshow(imageReferenceNEW)
%%
FOV = 44;
load(sprintf('\\\\195.113.42.48\\Large data\\Monika 2p\\VIP_tdT\\430F\\2p 20210630 430F F3\\krouzky_%05d.mat', FOV));
%%
manualPick(imageReference, maskStructInt, imageReferenceNEW, 'JanaTest')
%%
figure
imshow(imageReference)
[optimizer, metric] = imregconfig('multimodal');
tform = imregtform(imageReferenceNEW, imageReference, 'rigid', optimizer, metric);
B = imwarp(imageReferenceNEW,tform, 'OutputView', imref2d(size(imageReference)));
tform_inv = imregtform(imageReference, imageReferenceNEW, 'rigid', optimizer, metric);
Binv = imwarp(imageReference,tform_inv,'OutputView', imref2d(size(imageReference)));
xPoints=maskStructIntOld(1).ringPixListSub(:,1);
yPoints=maskStructIntOld(1).ringPixListSub(:,2);
[u, v] = transformPointsInverse(tform, xPoints, yPoints);
pointsN=numel(u);


neuronTMPPoints=maskStructure(1,1).ringPixListSub;
% neuronTMP_Y=round(maskStructure(1,Nindex).CenterCoor(2));
% neuronTMP_X=round(maskStructure(1,Nindex).CenterCoor(1));
% if (neuronTMP_X-2*neuronR)<1
% XlimLeft=1;
% else
% XlimLeft=neuronTMP_X-2*neuronR;   
% end
% 
% if (neuronTMP_X+2*neuronR)>CImagePix
% XlimRight=CImagePix;
% else
% XlimRight=neuronTMP_X+2*neuronR;   
% end
% 
% if (neuronTMP_Y-2*neuronR)<1
% YlimTop=1;
% else
% YlimTop=neuronTMP_Y-2*neuronR;   
% end
% 
% if (neuronTMP_Y+2*neuronR)>RImagePix
% YlimDown=RImagePix;
% else
% YlimDown=neuronTMP_Y+2*neuronR;   
% end
h= impoly(gca, neuronTMPPoints);

%%
imshow(imageReferenceNEW)
h= impoly(gca, neuronTMPPoints);
%%
fig = figure;
pomocna=[];
reidentC=[];
while isempty(pomocna) || isempty(reidentC) || pomocna~=13 
    waitforbuttonpress;
    reidentC = pomocna
    pomocna = double(get(fig,'CurrentCharacter'))
end

