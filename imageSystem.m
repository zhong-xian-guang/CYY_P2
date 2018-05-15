classdef imageSystem
    %IMAGESYSTEM Summary of this class goes here
    %   Detailed explanation goes here
    
    methods(Static)
        function img = readGrayImage(path)
            image = imread(path);
            img = rgb2gray(image);
        end
        function match = featureMatch(p0, p1)
            match = [];
            for i = 1 : size(p0.feature,1)
                if p0.feature(i,1) <= 1 || p0.feature(i,1) >= size(p0.img,2)
                    continue 
                end
                if p0.feature(i,2) <= 1 || p0.feature(i,2) >= size(p0.img,1)
                    continue 
                end
                X0 = p0.feature(i,1);
                Y0 = p0.feature(i,2);
                minIndex = -1;
                minValue = 99999999;
                minSecondIndex = -1;
                minSecondValue = 99999999;
                for j = 1 : size(p1.feature,1)
                    if p1.feature(j,1) <= 1 || p1.feature(j,1) >= size(p1.img,2)
                        continue 
                    end
                    if p1.feature(j,2) <= 1 || p1.feature(j,2) >= size(p1.img,1)
                        continue 
                    end
                    X1 = p1.feature(j,1);
                    Y1 = p1.feature(j,2);
                    m0 = p0.img(Y0 - 1 : Y0 + 1, X0 - 1 : X0 + 1);
                    m1 = p1.img(Y1 - 1 : Y1 + 1, X1 - 1 : X1 + 1);
                    m2 = (int64(m0) - int64(m1)).^2;
                    d = sum(sum(m2));
                    if d <= minValue
                        minSecondValue = minValue;
                        minSecondIndex = minIndex;
                        minValue = d;
                        minIndex = j;
                    elseif  d < minSecondValue
                        minSecondValue = d;
                        minSecondIndex = j;
                    end
                end
                if minValue / minSecondValue < 0.6
                    match = [match; [i, minIndex]];
                end
            end
        end
    end
end

