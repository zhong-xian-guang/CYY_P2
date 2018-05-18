clear;
clc;
%todo
%load image
%feature detection
%feature matching(Harris or MSOP)
%image matching
%bundle adjustment and blending
BasePath = 'data/grail/';
PicName = 'grail';
PicType = '.jpg';
PicSNumber = 0;
Number = 4;
p = cell(Number,1);
focal = 628;
for i=1:Number
    n = i+PicSNumber-1;
    if(n<10)
        ns = strcat('0',num2str(n));
    else
        ns = num2str(n);
    end
    S = strcat(BasePath,PicName,ns,PicType);
    tempP.colorImg = imageSystem.readColorImage(S);
    tempP.img = rgb2gray(tempP.colorImg);
    tempP.feature = imageSystem.detectFeature(tempP.img,8);
    tempP = imageSystem.cylinderProjection(tempP,focal);
    p{i} = tempP;

end
result = imageSystem.blendingColor(p);

%offset = [-197, -4]
%ttt = zeros(size(p0.img,1) + abs(offset(1,2)), size(p0.img,2) + abs(offset(1,1)),'uint8');
%ttt(5:516 , 198:581) = p0.img;
%ttt(1:512 , 1:384) = p1.img;

imshow(result);

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

