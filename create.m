
function [ newImg ] = create( imgs, f)

nImgs = size(imgs, 4);
cylindricalimages = zeros(size(imgs), 'like', imgs);

for i = 1 : nImgs
    cylindricalimages(:, :, :, i) = warp(imgs(:, :, :, i), f);
end

cimgs=cylindricalimages;
Thresh = 10;
confidence = 0.99;
inlierRatio = 0.3;
epsilon = 1.5;

nImgs = size(cimgs, 4);

T = zeros(3, 3, nImgs);
T(:, :, 1) = eye(3);
[f2, d2] = getSIFTFeatures(cimgs(:, :, :, 1), Thresh);
for i = 2 : nImgs
    f1 = f2;
    d1 = d2;
    [f2, d2] = getSIFTFeatures(cimgs(:, :, :, i), Thresh);
    [matches, ~] = getMatches(f1, d1, f2, d2);
    [T(:, :, i),~] = RANSAC(confidence, inlierRatio, 1, matches, epsilon);
end

translations=T;

absoluteTrans = zeros(size(translations));
absoluteTrans(:, :, 1) = translations(:, :, 1);
for i = 2 : nImgs
    absoluteTrans(:, :, i) = absoluteTrans(:, :, i - 1) * translations(:, :, i);
end

width = size(cylindricalimages, 2);
height = size(cylindricalimages, 1);

    maxY = height;
    minY = 1;
    minX = 1;
    maxX=width;
    for i = 2 : nImgs 
        maxY = max(maxY, absoluteTrans(1,3,i)+height);
        maxX = max(maxX, absoluteTrans(2,3,i)+width);
        minY = min(minY, absoluteTrans(1,3,i));
        minX=min(minX,absoluteTrans(2,3,i));
    end
    panorama_h = ceil(maxY) - floor(minY) + 1;
    panorama_w = ceil(maxX)-floor(minX) +1;
    
    absoluteTrans(2, 3, :) = absoluteTrans(2, 3, :) - floor(minX);
    absoluteTrans(1, 3, :) = absoluteTrans(1, 3, :) - floor(minY);


newImg = merge(cylindricalimages, absoluteTrans , panorama_h, panorama_w, f);

end

function [potential_matches, scores] = getMatches(f1, d1, f2, d2)

[matches, scores] = vl_ubcmatch(d1, d2);

numMatches = size(matches,2);
pairs = nan(numMatches, 3, 2);
pairs(:,:,1)=[f1(2,matches(1,:));f1(1,matches(1,:));ones(1,numMatches)]';
pairs(:,:,2)=[f2(2,matches(2,:));f2(1,matches(2,:));ones(1,numMatches)]';

potential_matches = pairs;

end
 