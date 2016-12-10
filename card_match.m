function [segmask1,segmask2,chosen1,chosen2]=card_match(im1, im2)

%% Image Init
im1g=rgb2gray(im1);
im2g=rgb2gray(im2);

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