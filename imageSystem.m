classdef imageSystem
    %IMAGESYSTEM Summary of this class goes here
    %   Detailed explanation goes here
    methods(Static)
        function img = readGrayImage(path)
            image = imread(path);
            img = rgb2gray(image);
        end
        function ret = detectFeature(image,windowSize)
            %1.color to grayscal
            I = image;
            imshow(I);
            %2.Spatial derivative calculation
            [Ix, Iy] = gradient(double(I)); % first order partials
            [Ixx, Ixy] = gradient(Ix);      % second order partials
            [Iyx, Iyy] = gradient(Iy);      % second order partials
            M = 
            figure();
            imshow(Ix);
            figure();
            imshow(Iy);
            figure();
            imshow(Ixx);
            figure();
            imshow(Ixy);
            figure();
            imshow(Iyx);
            figure();
            imshow(Iyy);
            %3.Structure tensor setup
            %4.Harris response calculation
            %5.Non-maximum suppression
            
        end
    end
end

