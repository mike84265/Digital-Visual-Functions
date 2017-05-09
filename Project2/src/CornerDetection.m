img = imread('../input/IMG_8905.JPG');
m = size(img,1);
n = size(img,2);
Yimg = rgb2ycbcr(img);
Yimg = Yimg(:,:,1);
Yimg = double(Yimg);
fHM = HarrisDetector(Yimg);

fHM(isnan(fHM)) = 0;
loc1 = imregionalmax(fHM);
thr = 10;
loc2 = fHM > thr;

loc = loc1 & loc2;

loc3 = decreaseFeature(fHM,20);

subplot(1,2,1); imshow(img);
subplot(1,2,2); imshow(loc);