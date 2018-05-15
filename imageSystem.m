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
            %2.Spatial derivative calculation
            dx = [-1 0 1;-1 0 1;-1 0 1];
            dy = dx';
            Ix = conv2(I,dx,'same');
            Iy = conv2(I,dy,'same');
            g = fspecial('gaussian',12,2);
            Ixx = conv2(Ix.^2,g,'same');
            Iyy = conv2(Iy.^2,g,'same');
            Ixy = conv2(Ix.*Iy,g,'same');
            
            %3.Structure tensor setup
            
            %We skip the M matrix since we use "R(Ixx.*Iyy-Ixy.^2)-k*(Ixx+Iyy).^2;"
            
            %4.Harris response calculation
            k = 0.04;
            R = (Ixx.*Iyy-Ixy.^2)-k*(Ixx+Iyy).^2;

            %5.Non-maximum suppression
            R=(1000/max(max(R)))*R;%map response to 1000~0
            Rt = R;%Rt is the response that make to the threshold
            
            r = 6;  % tuening constent
            
            minN = 200;
            maxN = 250;
            thrshold = 20;
            Mx = ordfilt2(R,r^2,ones(r));%file the maxman within the r
            Rt = (R==Mx)&(R>thrshold);
            count = sum(sum(Rt));%exclusive the edge pixles
            loop = 0;
            while(((count <minN)|(count > maxN)) &loop<100)
                if(count > maxN)
                    thrshold = thrshold * 1.5;
                elseif(count < minN)
                    thrshold = thrshold * 0.5;
                end
                Rt = (R==Mx)&(R>thrshold);
                count = sum(sum(Rt));%exclusive the edge pixles
                loop = loop+1;
            end
            %6 output conor
            result = zeros(count,3);
            index = 1;
            for i=1:size(R,1)
                for j=1:size(R,2)
                    if(Rt(i,j) == 1)
                        result(index,1) = R(i,j);
                        result(index,2) = j;
                        result(index,3) = i;
                        index = index+1;
                    end
                end
            end
            result = sortrows(result,'descend');
            ret =  result(1:200,2:end);
        end
    end
end

