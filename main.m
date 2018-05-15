clear;
clc;
%todo
%load image
%feature detection
%feature matching(Harris or MSOP)
%image matching
%bundle adjustment and blending
img = imageSystem.readGrayImage('data/grail/grail00.jpg');
%img = imageSystem.readGrayImage('gtest.png');
c = imageSystem.detectFeature(img,8);
C = corner(img);
figure;
imshow(img);
hold on
plot(C(:,1),C(:,2),'r*');

figure;
imshow(img);
hold on
plot(c(:,1),c(:,2),'r*');