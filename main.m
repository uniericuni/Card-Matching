% segmask: segmentation mask
% feature: 128-dim SIFT feature
% loc: coordinate corresponding to same indexed feature

close all;
clear;
clc;

%% Image Init
addpath('./siftDemoV4');
addpath('./segmentation');
directory = './cp_data/images/';
im1 = imread([directory,'001.png']);
im2 = imread([directory,'002.png']);
im1g=rgb2gray(im1);
im2g=rgb2gray(im2);
height=size(im1,1);
width=size(im1,2);

%% Image Segmentation
segmask1 = segmentation(im1);
segmask2 = segmentation(im2);

%% Feature Extraction adn Matching
max_num=-inf;
chosen1=0;
chosen2=0;
for i=1:max(max(segmask1))
    mask1=(segmask1==i);
    for j=1:max(max(segmask2))
        mask2=(segmask2==j);
        num = match(im1g+uint8(~mask1)*255, im2g+uint8(~mask2)*255, false);
        fprintf('i: %d, j: %d, matching pairs: %d \n', i, j, num);
        if num>max_num
            max_num=num;
            chosen1=i;
            chosen2=j;
        end
    end
end

%% Plotting
figure(1);
for i=1:3
    impair(:,:,i)=[im1(:,:,i) im2(:,:,i)];
end
[y1,x1]=ind2sub([height,width],find(segmask1==chosen1));
[y2,x2]=ind2sub([height,width],find(segmask2==chosen2));
imshow(impair);
hold on;
plot(mean(x1),mean(y1),'rx','MarkerSize', 20);
hold on;
plot(mean(x2)+width,mean(y2),'rx','MarkerSize', 20);