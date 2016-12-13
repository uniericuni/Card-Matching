close all;
clear;
clc;

directory = './cp_data/cards/';
addpath('./segmentation');
addpath('./siftDemoV4');
for i=1:5
    for j=i+1:5
        
        % Matching
        im1 = imread([directory,'00',num2str(i),'.png']);
        im2 = imread([directory,'00',num2str(j),'.png']);
        [segmask1,segmask2,chosen1,chosen2]=card_match(im1,im2);
        height=size(im1,1);
        width=size(im1,2);
        
        %% Plotting
        figure;
        for k=1:3
            impair(:,:,k)=[im1(:,:,k) im2(:,:,k)];
        end
        [y1,x1]=ind2sub([height,width],find(segmask1==chosen1));
        [y2,x2]=ind2sub([height,width],find(segmask2==chosen2));
        imshow(impair);
        hold on;
        plot(mean(x1),mean(y1),'rx','MarkerSize', 40);
        hold on;
        plot(mean(x2)+width,mean(y2),'rx','MarkerSize', 40);
        saveas(gcf, ['00',num2str(i),'_00',num2str(j),'_demo.png']);
        
        % Write File
        out=zeros(height,width);
        out(floor(mean(y1)),floor(mean(x1)))=255;
        imwrite(out, ['00',num2str(i),'_00',num2str(j),'.png'])
        
    end
end