close all;
clear;
clc;

% feature: 128-dim SIFT feature
% loc: coordinate corresponding to same indexed feature

img=imread('../cp_data/cards/001.png');
[feature,loc]=SIFT(img);
>>>>>>> b21f60c8cf73095a47ff11c8f8c9c21b42a45374
