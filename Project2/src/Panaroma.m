numImg = 3;
img = cell(numImg,1);
GrayImg = cell(numImg,1);
fdscpt = cell(numImg,1);
indexPair = cell(numImg-1, 1);

img{1} = imread('../input/IMG_8917.JPG');
img{2} = imread('../input/IMG_8918.JPG');
img{3} = imread('../input/IMG_8919.JPG');

m = size(img{1},1);
n = size(img{1},2);

for i=1:numImg
   tic;
   GrayImg{i} = rgb2gray(img{i});
   GrayImg{i} = double(GrayImg{i});
   fHM = HarrisDetector(GrayImg{i});
   fHM(isnan(fHM)) = 0;
   loc1 = imregionalmax(fHM);
   thr = 10;
   loc2 = fHM > thr;
   loc = loc1 & loc2;

   [featureList, loc3] = decreaseFeature(fHM, loc, 20);

   fdscpt{i} = FeatureDescriptor(GrayImg{i},featureList);
   toc;
end

