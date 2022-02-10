function [maskStructInt_warped]=maskStructIntTRANSFORMER(maskStructIntOld, imageReference, imageReferenceNEW, FOVandSessionName, transformationType)
maskStructInt_warped=maskStructIntOld;
imageReference=imadjust(imageReference);
imageReferenceNEW=imadjust(imageReferenceNEW);

if nargin<5 || isempty(transformationType)
    %%%default
    transformationType = 'rigid';
end

satisfaction=0;
while satisfaction~=1
switch transformationType
    case 'rigid'
        [optimizer, metric] = imregconfig('multimodal');
        tform = imregtform(imageReferenceNEW, imageReference, 'rigid', optimizer, metric);
        B = imwarp(imageReferenceNEW,tform, 'OutputView', imref2d(size(imageReference)));
        tform_inv = imregtform(imageReference, imageReferenceNEW, 'rigid', optimizer, metric);
        Binv = imwarp(imageReference,tform_inv,'OutputView', imref2d(size(imageReference)));
    case 'similarity'
        [optimizer, metric] = imregconfig('multimodal');
        tform = imregtform(imageReferenceNEW, imageReference, 'similarity', optimizer, metric);
        B = imwarp(imageReferenceNEW,tform, 'OutputView', imref2d(size(imageReference)));
        tform_inv = imregtform(imageReference, imageReferenceNEW, 'similarity', optimizer, metric);
        Binv = imwarp(imageReference,tform_inv,'OutputView', imref2d(size(imageReference)));
    case 'affine'
        [optimizer, metric] = imregconfig('multimodal');
        tform = imregtform(imageReferenceNEW, imageReference, 'affine', optimizer, metric);
        B = imwarp(imageReferenceNEW,tform, 'OutputView', imref2d(size(imageReference)));
        tform_inv = imregtform(imageReference, imageReferenceNEW, 'affine', optimizer, metric);
        Binv = imwarp(imageReference,tform_inv,'OutputView', imref2d(size(imageReference)));
    otherwise
        [selectedFixedPoints,selectedMovingPoints] = cpselect(imageReference, imageReferenceNEW,'Wait',true);
        tform = fitgeotrans(selectedMovingPoints,selectedFixedPoints,'polynomial',3);
        B = imwarp(imageReferenceNEW,tform, 'OutputView', imref2d(size(imageReference)));
        tform_inv = fitgeotrans(selectedFixedPoints, selectedMovingPoints,'polynomial',3);
        Binv = imwarp(imageReference,tform_inv, 'OutputView', imref2d(size(imageReference)));      
end
figure
imshowpair(imageReference, imageReferenceNEW)
pause;
imshowpair(imageReference,B)
pause;
close;
figure
imshowpair(imageReference, imageReferenceNEW)
pause;
figure
imshowpair(Binv,imageReferenceNEW)
pause;

commandwindow
satisfaction = input('Fit the warped images to the originals? 1 for YES, anything for NO');
if satisfaction ~=1
transformationType = 'polynomial';    
end
end



neuronN=size(maskStructIntOld,2);
imageSize=size(imageReference,1);

for index=1:neuronN
xPoints=maskStructIntOld(index).ringPixListSub(:,1);
yPoints=maskStructIntOld(index).ringPixListSub(:,2);
[u, v] = transformPointsInverse(tform, xPoints, yPoints);
pointsN=numel(u);

%%%% Protection against warp out of the image
for indexProtection=1:pointsN
    if u(indexProtection)<1
       u(indexProtection)=1; 
    end
    if u(indexProtection)>imageSize
       u(indexProtection)=imageSize; 
    end
     if v(indexProtection)<1
       v(indexProtection)=1; 
    end
    if v(indexProtection)>imageSize
       v(indexProtection)=imageSize; 
    end       
end
maskStructInt_warped(index).ringPixListSub(:,1)=u;
maskStructInt_warped(index).ringPixListSub(:,2)=v;
maskStructInt_warped(1,index).CenterCoor=[mean(u), mean(v)];

end
FOVandSessionName(end+1:end+13)='warpParam.mat';
save(FOVandSessionName)
end