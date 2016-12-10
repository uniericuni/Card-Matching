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

%% Image Segmentation
segmask1 = segmentation(im1);
segmask2 = segmentation(im2);

%% Feature Extraction
[feature1,loc1]=SIFT(im1,100);
[feature2,loc2]=SIFT(im2,100);


