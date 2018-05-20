classdef imageSystem
    %IMAGESYSTEM Summary of this class goes here
    %   Detailed explanation goes here
    
    methods(Static)
        %read gray image from(not used)
        function img = readGrayImage(path)
            image = imread(path);
            img = rgb2gray(image);
        end
        %read color image from path
        function img = readColorImage(path)
            img = imread(path);
        end
        %stitching and blending the image(for gray image)
        function img = blending(p)
            %treat p as cell of picture with size n
            [h w] = size(p{1}.img);
            n = size(p,1);
            %track all the images's offset relationship(noted that we assume that input pictures are sorted in order.)
            offsets = cell(n,1);
            offsets{1} = [0,0];
            %to calculate how big the output img will be
            boundary = [0 0 ; 0 0];
            track = offsets{1};
            %for each pics pair,calculate the offset relation and track the
            %offset boundary
            for i=1:n-1
                match = imageSystem.featureMatch(p{i},p{i+1});
                offsets{i+1} = -imageSystem.ransac(p{i},p{i+1},match);
                if(track(1)+offsets{i+1}(1)>boundary(2,1))%max x boundary update
                    boundary(2,1) = track(1)+offsets{i+1}(1);
                end
                if(track(1)+offsets{i+1}(1)<boundary(1,1))%min x boundary update
                    boundary(1,1) = track(1)+offsets{i+1}(1);
                end
                if(track(2)+offsets{i+1}(2)>boundary(2,2))%max y boundary update
                    boundary(2,2) = track(2)+offsets{i+1}(2);
                end
                if(track(2)+offsets{i+1}(2)<boundary(1,2))%min y boundary update
                    boundary(1,2) = track(2)+offsets{i+1}(2);
                end
                track = track + offsets{i+1};
            end
            %first pic will blend in start position, second pic will blend in
            %start + offset position ......
            start = [-boundary(1,1),-boundary(1,2)];
            %create img with enough size;
            img = uint8(zeros(h+boundary(2,2)-boundary(1,2),w+boundary(2,1)-boundary(1,1)));
            offset = start;
            for k=1:n
                offset = offsets{k} + offset;
                blendL = sqrt(offsets{k}(1)^2+offsets{k}(2)^2);
                offsetX = offsets{k}(1);
                [h w] = size(p{k}.img);
                for i=1:h
                    for j=1:w
                        blend = 1;
                        %we assume there is no black pixle in image,so we
                        %threat black one as missing data;
                        if(p{k}.img(i,j)==0)
                        elseif(img(i+offset(2),j+offset(1)) == 0)
                            img(i+offset(2),j+offset(1)) = p{k}.img(i,j);
                        else
                            %we only concern the x offset for blending
                            %blending factor
                            if(offsetX >0 & j)
                                blend = 1 - (j - offsetX < 0) * (j-offsetX)/(offsetX-w);
                            else
                                blend = 1 - (j+offsetX>0) * (j+offsetX)/(w+offsetX);
                            end
                            img(i+offset(2),j+offset(1)) = p{k}.img(i,j) * blend + (1-blend) * img(i+offset(2),j+offset(1));
                        end
                    end
                end
            end
        end
        %stitching and blending the image(for color image)
        function img = blendingColor(p,scale)
            %treat p as cell of picture with size n
            [h w c] = size(p{1}.colorImg);
            n = size(p,1);
            %track all the images's offset relationship(noted that we assume that input pictures are sorted in order.)
            offsets = cell(n,1);
            offsets{1} = [0,0];
            %to calculate how big the output img will be
            boundary = [0 0 ; 0 0];
            track = offsets{1};
            %for each pics pair,calculate the offset relation and track the
            %offset boundary
            for i=1:n-1
                match = imageSystem.featureMatch(p{i},p{i+1});
                offsets{i+1} = -imageSystem.ransac(p{i},p{i+1},match) /scale;
                if(track(1)+offsets{i+1}(1)>boundary(2,1))%max x boundary update
                    boundary(2,1) = track(1)+offsets{i+1}(1);
                end
                if(track(1)+offsets{i+1}(1)<boundary(1,1))%min x boundary update
                    boundary(1,1) = track(1)+offsets{i+1}(1);
                end
                if(track(2)+offsets{i+1}(2)>boundary(2,2))%max y boundary update
                    boundary(2,2) = track(2)+offsets{i+1}(2);
                end
                if(track(2)+offsets{i+1}(2)<boundary(1,2))%min y boundary update
                    boundary(1,2) = track(2)+offsets{i+1}(2);
                end
                track = track + offsets{i+1};
            end
            %first pic will blend in start position, second pic will blend in
            %start + offset position ......
            start = [-boundary(1,1),-boundary(1,2)];
            %create img with enough size;
            img = uint8(zeros(h+boundary(2,2)-boundary(1,2),w+boundary(2,1)-boundary(1,1),3));
            offset = start;
            for k=1:n
                offset = offsets{k} + offset;
                %img(offset(2):offset(2)+h , offset(1):offset(1)+w) = p{i}.img;
                blendL = sqrt(offsets{k}(1)^2+offsets{k}(2)^2);
                offsetX = offsets{k}(1);
                [h w c] = size(p{k}.colorImg);
                for i=1:h
                    for j=1:w
                        blend = 1;
                        %we assume there is no black pixle in image,so we
                        %threat black one as missing data;
                        if((p{k}.colorImg(i,j,1)+p{k}.colorImg(i,j,2)+p{k}.colorImg(i,j,3))==0)
                        elseif(img(i+offset(2),j+offset(1)) == 0)
                            img(i+offset(2),j+offset(1),:) = p{k}.colorImg(i,j,:);
                        else
                            %we only concern the x offset for blending
                            %blending factor
                            if(offsetX >0 & j)
                                blend = 1 - (j - offsetX < 0) * (j-offsetX)/(offsetX-w);
                            else
                                blend = 1 - (j+offsetX>0) * (j+offsetX)/(w+offsetX);
                            end
                            img(i+offset(2),j+offset(1),:) = p{k}.colorImg(i,j,:) * blend + (1-blend) * img(i+offset(2),j+offset(1),:);
                        end
                    end
                end
            end
        end
        %cylinderProjection(color image)
        function ret = cylinderProjectionColor(p,f)
            %use the equation from ppt
            %x' = f*tan^-1(x/f)
            %y' = f*(y/(sqrt(x^2+f^2)))
            ret = p;
            [h w c]= size(p.colorImg);
            ret.colorImg = uint8(zeros(h,w,3));
            cx = w/2;
            cy = h/2;
            for i=1:h
                for j=1:w
                    fx = j-cx;
                    fy = i-cy;
                    tx = f*atan(fx/f);
                    ty = f*(fy/(sqrt(fx^2+f^2)));
                    tx = tx+cx;
                    ty = ty+cy;
                    tx = floor(tx);
                    ty = floor(ty);
                    tx(tx<=0) = 1;
                    ty(ty<=0) = 1;
                    tx(tx>w) = w;
                    ty(ty> h) = h;
                    ret.colorImg(ty,tx,:) = p.colorImg(i,j,:);
                end
            end
        end
        %cylinderProjection(gray image & feature)
        function ret = cylinderProjection(p,f)
            ret = p;
            %use the equation from ppt
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
                    tx = tx+cx;
                    ty = ty+cy;
                    tx = floor(tx);
                    ty = floor(ty);
                    tx(tx<=0) = 1;
                    ty(ty<=0) = 1;
                    tx(tx>w) = w;
                    ty(ty> h) = h;
                    ret.img(ty,tx) = p.img(i,j);
                    %ret.colorImg(ty,tx,:) = p.colorImg(ty,tx,:);
                end
            end
            for i=1:size(p.feature,1)
                fx = p.feature(i,1)-cx;
                fy = p.feature(i,2)-cy;
                    tx = f*atan(fx/f);
                    ty = f*(fy/(sqrt(fx^2+f^2)));
                    tx = tx+cx;
                    ty = ty+cy;
                    tx = floor(tx);
                    ty = floor(ty);
                    
                    tx(tx<=0) = 1;
                    ty(ty<=0) = 1;
                    tx(tx>w) = w;
                    ty(ty> h) = h;
                    ret.feature(i,1) = tx;
                    ret.feature(i,2) = ty;
            end
        end
        %featureMatch
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
        %output matlab figure with feature infomation(not used)
        function showFeature(p)
            C = p.feature;
            figure;
            imshow(p.img);
            hold on
            plot(C(:,1),C(:,2),'r*');
        end
        %Harris Corner Detection
        function ret = detectFeature(image,N,r)
            %N: how many feature we want
            %r: windowSize ,6 will be good
            
            %if windowSize r is too large,it may not able to find enough feature N and have error
            
            %1.grayscal image
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
            
            minN = N;
            maxN = N*1.2;
            thrshold = 20;
            Mx = ordfilt2(R,r^2,ones(r));%file the maxman within the r
            Rt = (R==Mx)&(R>thrshold);
            count = sum(sum(Rt));
            loop = 0;
            while(((count <minN) || (count > maxN)) && loop<100)
                if(count > maxN)
                    thrshold = thrshold * 1.5;
                elseif(count < minN)
                    thrshold = thrshold * 0.5;
                end
                Rt = (R==Mx)&(R>thrshold);
                count = sum(sum(Rt));
                loop = loop+1;
            end
            %6 output result
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
        %ransac
        function offset = ransac(p0,p1,match)
            tempOffset = [];
            for i = 1 : size(match,1)
                index0 = match(i,1);
                index1 = match(i,2);
                tempOffset = [tempOffset;[p0.feature(index0,1) - p1.feature(index1,1) , p0.feature(index0,2) - p1.feature(index1,2)]];
            end
            threshold = 10;
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
            offset = -offset;
        end
    end
end

