classdef imageSystem
    %IMAGESYSTEM Summary of this class goes here
    %   Detailed explanation goes here
    methods(Static)
        function img = readGrayImage(path)
            image = imread(path);
            img = rgb2gray(image);
        end
    end
end

