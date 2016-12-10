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

%% Image Segmentation
segmask1 = segmentation(im1);
segmask2 = segmentation(im2);

%% Feature Extraction adn Matching
max_err=inf;
chosen1=0;
chosen2=0;
for i=1:max(max(segmask1))
    mask1=(segmask1==i);
    for j=1:max(max(segmask2))
        mask2=(segmask1==i);
        num,err = match(im1g+uint8(~mask1)*255, im2g+uint8(~mask2)*255);
        fprintf('i: %d, j: %d, err: %d \n', i, j, err);
        if err<max_err
            max_err=err;
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
imshow(impair);
for i=1:f1_num
    hold on;
    plot([loc1(2,i),loc2(2,matching_idx(i))+width],[loc1(1,i),loc2(1,matching_idx(i))],'b*');
    plot([loc1(2,i),loc2(2,matching_idx(i))+width],[loc1(1,i),loc2(1,matching_idx(i))],'b--');
end
%}