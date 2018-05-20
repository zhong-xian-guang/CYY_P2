%clear;
%clc;
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
    BasePath = 'data/scene2/';
    PicNameS = 'scene2_';
    picNameE = '';
    PicType = '.jpg';
    PicSNumber = 2;
    Number = 6;
    focal = 2781;
end

p = cell(Number,1);
scale = 1;
for i=1:Number
    n = i+PicSNumber-1;
    if(0)
        ns = strcat('0',num2str(n));
    else
        ns = num2str(n);
    end
    S = strcat(BasePath,PicNameS,ns,picNameE,PicType);
    tempP.Oimg = imageSystem.readColorImage(S);
    %tempP.Oimg = imresize(tempP.Oimg,0.2);
    %tempP.colorImg = tempP.Oimg;
    %tempP.img = rgb2gray(tempP.colorImg);
    %tempP.img = imresize(tempP.img,scale);
    %tempP.feature = imageSystem.detectFeature(tempP.img,2000,8);
    %tempP = imageSystem.cylinderProjection(tempP,focal);
    %tempP = imageSystem.cylinderProjectionColor(tempP,focal);
    p{i} = tempP;
end
result = imageSystem.blendingColor(p,scale);
imwrite(result,strcat('noMore','.jpg'));
featureSample =[1000 2000];
windowSize = [6 8];
for i=1:size(windowSize,2)
    for j=1:size(featureSample,2)
        for k=1:Number
            p{k}.colorImg = p{k}.Oimg;
            p{k}.img = rgb2gray(p{k}.colorImg);
            p{k}.feature = imageSystem.detectFeature(p{k}.img,featureSample(j),windowSize(i));
            p{k} = imageSystem.cylinderProjection(p{k},focal);
        end
        result = imageSystem.blendingColor(p,scale);
        imwrite(result,strcat(PicNameS,'F',num2str(featureSample(j)),'W',num2str(windowSize(i)),'.jpg'));
    end
end
%offset = [-197, -4]
%ttt = zeros(size(p0.img,1) + abs(offset(1,2)), size(p0.img,2) + abs(offset(1,1)),'uint8');
%ttt(5:516 , 198:581) = p0.img;
%ttt(1:512 , 1:384) = p1.img;

%imshow(result);

%{
tempImg = [p0.img,p1.img];
imshow(tempImg);
hold on
%plot(p0.feature(:,1),p0.feature(:,2),'r*');
%plot(p1.feature(:,1) + 384,p1.feature(:,2),'r*');
for i = 1 :size(match,1)
    index0 = match(i,1);
    index1 = match(i,2);
    line([p0.feature(index0,1), p1.feature(index1,1) + 384], [p0.feature(index0,2), p1.feature(index1,2)]);
end
plot(p0.feature(match(:,1),1), p0.feature(match(:,1),2),'r*');
plot(p1.feature(match(:,2),1) + 384, p1.feature(match(:,2),2),'r*');
%}

