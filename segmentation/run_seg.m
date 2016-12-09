close all
imc = imread('../cp_data/cards/002.png');
imi = imread('../cp_data/images/002.png');
folders = {'../cp_data/cards/', '../cp_data/images/'};
name = {'001.png','002.png','003.png','004.png','005.png' };
namelist = {};
for i = 1:length(folders)
    for j = 1:length(name)
        namelist{(i-1)*length(name)+j} = [folders{i} name{j}];
    end
end

for i = 1:length(namelist)
    im = imread(namelist{i});
    imgray = rgb2gray(im);
    diff = 15;
    [x,y] = size(imgray);
    bg1 = zeros(size(imgray));
    bg2 = bg1;
    bg1 = process_background(imgray, imgray(1,1), bg1, diff, 1, 1);
    bg2 = process_background(imgray, imgray(x,y), bg2, diff, x, y);
    bg = bg1 | bg2;
    
    x1 =60;
    y1=275;
    bg1 = process_background(imgray, imgray(x1,y1), bg, diff, x1, y1);
    bg2 = process_background(imgray, imgray(200,50), bg, diff, 200, 50);
    bg = bg1 | bg2;
    bg = imgaussfilt(double(bg),1);
%     figure, imagesc(double(1-bg).*double(imgray));
    figure, imagesc(my_segment(uint8(double(1-bg).*double(imgray))==0));
end


% im = imc;
% imgray = rgb2gray(im);
% diff = 15;
% [x,y] = size(imgray);
% bg1 = zeros(size(imgray));
% bg2 = bg1;
% bg1 = process_background(imgray, imgray(1,1), bg1, diff, 1, 1);
% bg2 = process_background(imgray, imgray(x,y), bg2, diff, x, y);
% bg = bg1 | bg2;
% 
% x1 =60;
% y1=275;
% bg1 = process_background(imgray, imgray(x1,y1), bg, diff, x1, y1);
% bg2 = process_background(imgray, imgray(200,50), bg, diff, 200, 50);
% bg = bg1 | bg2;
% figure, imagesc(bg);


% im = imc;
% 
% diff = 20;
% [w,h,c] = size(im);
% green = repmat(imc(1,1,:), w, h);
% mask = sum((im - green).^2,3) < diff * diff;
% 
% imgray = rgb2gray(im);
% background = zeros(size(imgray));
% diff = 15;
% background = process_background(imgray, imgray(1,1), background, diff, 1, 1);
% figure, imagesc(background);
% background = process_background(imgray, imgray(200,50), background, diff, 200, 50);
% figure, imagesc(background);

% figure, imshow(imgray);
% figure, imshow(imcontour(imgray))

% BG = imfill(imgray < 240,'holes');
% figure, imshow(BG)
% figure, imshow(imgray < 230)
% figure, imshow(background);