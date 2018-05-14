clear;
clc;
%todo
%load image
%feature detection
%feature matching(Harris or MSOP)
%image matching
%bundle adjustment and blending
img = imageSystem.readGrayImage('data/grail/grail00.jpg');
C = corner(img);

imshow(img);
hold on
plot(C(:,1),C(:,2),'r*');