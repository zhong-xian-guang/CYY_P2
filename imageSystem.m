classdef imageSystem
    %IMAGESYSTEM Summary of this class goes here
    %   Detailed explanation goes here
    
    methods(Static)
        function img = readGrayImage(path)
            image = imread(path);
            img = rgb2gray(image);
        end
        function ret = cylinderProjection(p,f)
            %x' = f*tan^-1(x/f)
            %y' = f*(y/(sqrt(x^2+f^2)))
            [h w]= size(p.img);
            cx = w/2;
            cy = h/2;
            ret.img = uint8(zeros(h,w));
            for i=1:h
                for j=1:w
                    fx = j-cx;
                    fy = i-cy;
                    tx = f*atan(fx/f);
                    ty = f*(fy/(sqrt(fx^2+f^2)));
                    tx = floor(tx);
                    ty = floor(ty);
                    tx = tx+cx;
                    ty = ty+cy;
                    tx(tx<=0) = 1;
                    ty(ty<=0) = 1;
                    tx(tx>w) = w;
                    ty(ty> h) = h;
                    ret.img(ty,tx) = p.img(i,j);
                end
            end
            for i=1:size(p.feature,1)
                fx = p.feature(i,1)-cx;
                fy = p.feature(i,2)-cy;
                    tx = f*atan(fx/f);
                    ty = f*(fy/(sqrt(fx^2+f^2)));
                    tx = floor(tx);
                    ty = floor(ty);
                    tx = tx+cx;
                    ty = ty+cy;
                    tx(tx<=0) = 1;
                    ty(ty<=0) = 1;
                    tx(tx>w) = w;
                    ty(ty> h) = h;
                    ret.feature(i,1) = tx;
                    ret.feature(i,2) = ty;
            end
            %figure;
            %imshow(p.img);
            %hold on
            %plot(p.feature(:,1),p.feature(:,2),'r*');
            %figure;
            %imshow(ret.img);
            %hold on
            %plot(ret.feature(:,1),ret.feature(:,2),'r*');
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
            
            minN = 500;
            maxN = 1000;
            thrshold = 20;
            Mx = ordfilt2(R,r^2,ones(r));%file the maxman within the r
            Rt = (R==Mx)&(R>thrshold);
            count = sum(sum(Rt));%exclusive the edge pixles
            loop = 0;
            while(((count <minN) || (count > maxN)) && loop<100)
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
            result = sortrows(result, 1);
            test = sortrows(result, 1);
            ret =  result(size(result,1)-(minN-1):end,2:end);
        end

        function offset = ransac(p0,p1,match)
            tempOffset = []
            for i = 1 : size(match,1)
                index0 = match(i,1);
                index1 = match(i,2)
                tempOffset = [tempOffset;[p0.feature(index0,1) - p1.feature(index1,1) , p0.feature(index0,2) - p1.feature(index1,2)]]
            end
            threshold = 10
            maxCount = 0;
            for i = 1 :size(tempOffset,1)
                count = 0;
                for j = 1 :size(tempOffset,1)
                    d = (tempOffset(i,1) - tempOffset(j,1)).^2 + (tempOffset(i,2) - tempOffset(j,2)).^2;
                    if d < threshold
                        count = count + 1;
                    end
                end
                if maxCount < count
                    maxCount = count;
                    offset = tempOffset(i,:);
                end
            end
        end
    end
end

