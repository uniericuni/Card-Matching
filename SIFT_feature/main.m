close all;
clear;
clc;

% feature: 128-dim SIFT feature
% loc: coordinate corresponding to same indexed feature

img1=imread('../cp_data/cards/001.png');
img2=imread('../cp_data/cards/002.png');
[feature1,loc1]=SIFT(img1);
[feature2,loc2]=SIFT(img2);
