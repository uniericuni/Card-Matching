% segmask: segmentation mask
% feature: 128-dim SIFT feature
% loc: coordinate corresponding to same indexed feature

close all;
clear;
clc;

%% Image Init
addpath('./SIFT_feature');
addpath('./segmentation');
directory = './cp_data/cards/';
im1 = imread([directory,'001.png']);
im2 = imread([directory,'002.png']);
width = size(im1,2);

%% Image Segmentation
segmask1 = segmentation(im1);
segmask2 = segmentation(im2);

%% Feature Extraction
mask=(segmask1==1);
[feature1,loc1]=SIFT(im1,20,mask);
[feature2,loc2]=SIFT(im2,500);
f1_num=size(feature1,2);
f2_num=size(feature2,2);
matching_idx=zeros(1,f1_num);

%% Matching
for i=1:f1_num
    mmin=inf;
    for j=1:f2_num
        if(norm(feature1(:,i)-feature2(:,j))<mmin)
            mmin=norm(feature1(:,i)-feature2(:,j));
            matching_idx(i)=j;
        end
    end
end

%% Figure
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


