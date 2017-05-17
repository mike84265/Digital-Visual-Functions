%% Define constants
numImg = 3;
focalLength = 1666.67;
% FocalLength = 6000 pixels * 25 mm / 22.5 mm = 6667
% For downsampled image, focalLength = 1500 pixels * 25mm / 22.5mm = 1667

%% Read in images
img = cell(numImg,1);
GrayImg = cell(numImg,1);
fdscpt = cell(numImg,1);
indexPair = cell(numImg-1, 1);

img{1} = imread('../input/IMG_8917_S.JPG');
img{2} = imread('../input/IMG_8918_S.JPG');
img{3} = imread('../input/IMG_8919_S.JPG');

%% Warp images into cylindrical coordinate
for i=1:numImg
   img{i} = warp2cylindrical(img{i},focalLength);
end

m = size(img{1},1);
n = size(img{1},2);

%% Feature detection
for i=1:numImg
   tic;
   fprintf('Finding features of image %d...\n',i);
   GrayImg{i} = rgb2gray(img{i});
   GrayImg{i} = double(GrayImg{i});
   fHM = HarrisDetector(GrayImg{i});
   fHM(isnan(fHM)) = 0;
   thr = 10;
   loc = imregionalmax(fHM) & (fHM > thr);

   [featureList, loc3] = decreaseFeature(fHM, loc, 5);

   fdscpt{i} = FeatureDescriptor(GrayImg{i},featureList);
   toc;
end

%% Using exhausive search to match features
for i=1:numImg-1
   indexPair{i} = FeatureMatch(fdscpt{i},fdscpt{i+1},5);
end

% fitgeotrans(movingPoints, fixedPoints, transformationType);
