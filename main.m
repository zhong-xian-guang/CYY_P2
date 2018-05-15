clear;
clc;
%todo
%load image
%feature detection
%feature matching(Harris or MSOP)
%image matching
%bundle adjustment and blending
p0.img = imageSystem.readGrayImage('data/grail/grail00.jpg');
p1.img = imageSystem.readGrayImage('data/grail/grail01.jpg');
p0.feature = imageSystem.detectFeature(p0.img,8);
p1.feature = imageSystem.detectFeature(p1.img,8);

match = imageSystem.featureMatch(p0,p1);
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

