clear;
clc;
%todo
%load image
%feature detection
%feature matching(Harris or MSOP)
%image matching
%bundle adjustment and blending

%test1
if(0)
    BasePath = 'data/scene1/';
    PicNameS = 'scene1 (';
    picNameE = ')';
    PicType = '.jpg';
    PicSNumber = 1;
    Number = 28;
    focal = 2355;
end
%test2
if(1)
    BasePath = 'data/scene3/';
    PicNameS = 'scene2_';
    picNameE = '';
    PicType = '.jpg';
    PicSNumber = 2;
    Number = 6;
    focal = 2781;
end
scale = 1;
p = cell(Number,1);
%read image
for i=1:Number
    n = i+PicSNumber-1;
    if(0)
        ns = strcat('0',num2str(n));
    else
        ns = num2str(n);
    end
    S = strcat(BasePath,PicNameS,ns,picNameE,PicType);
    tempP.Oimg = imageSystem.readColorImage(S);
    p{i} = tempP;
end
%some time we want to tune the parameter.
featureSample =[1000];
windowSize = [6];
for i=1:size(windowSize,2)
    for j=1:size(featureSample,2)
        %for each pic we find the feature and do cylinderProjection
        for k=1:Number
            p{k}.colorImg = p{k}.Oimg;
            p{k}.img = rgb2gray(p{k}.colorImg);
            p{k}.feature = imageSystem.detectFeature(p{k}.img,featureSample(j),windowSize(i));
            p{k} = imageSystem.cylinderProjection(p{k},focal);
            p{k} = imageSystem.cylinderProjectionColor(p{k},focal);
        end
        %feature match,ransac and blending
        result = imageSystem.blendingColor(p,scale);
        %outFile
        imwrite(result,strcat(PicNameS,'F',num2str(featureSample(j)),'W',num2str(windowSize(i)),'.jpg'));
    end
end

