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
tform(numImg) = projective2d(eye(3));

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

%% Using exhausive search and RANSAC to match features
for i=2:numImg
   fprintf('Finding features between img %d and img %d\n', i, i-1);
   tic;
   [indexPair{i-1}, projMatrix] = FeatureMatch(fdscpt{i},fdscpt{i-1});
   tform(i) = projective2d([ projMatrix, [0; 0; 1] ]);
   tform(i).T = tform(i-1).T * tform(i).T;
   toc;
end

%% Initialize the panaroma canvas
for i=1:numImg
   [xlim(i,:) ylim(i,:)] = outputLimits(tform(i), ...
      [1 size(img{i},2)], [1 size(img{i},1)]);
   img{i} = imwarp(img{i},tform(i));
   ref(i) = imref2d(size(img{i}), xlim(i,:), ylim(i,:));
end

xmin = min(xlim(:,1));
ymin = min(ylim(:,1));
xmax = max(xlim(:,2));
ymax = max(ylim(:,2));
width = round(xmax - xmin);
height = round(ymax - ymin);

panaroma = zeros(height, width, 3, 'like', img{1});
panaromaRef = imref2d(size(panaroma), [xmin xmax], [ymin ymax]);

%% Stick the pixels to the panaroma canvas
[imin, jmin] = worldToSubscript(panaromaRef,xlim(1,1), ylim(1,1));
% [imax, jmax] = worldToSubscript(panaromaRef,xlim(1,2), ylim(1,2));
imax = imin + size(img{1},1) - 1;
jmax = jmin + size(img{1},2) - 1;
panaroma(imin:imax, jmin:jmax, :) = img{1};

for i=2:numImg
   % overlapXmin = xlim(i,1);
   % overlapXmax = xlim(i-1,2);
   % Handle overlap area
   [imin, jmin] = worldToSubscript(panaromaRef,ceil(xlim(i,1)), ceil(ylim(i,1)));
   [imax, jmax] = worldToSubscript(panaromaRef,floor(xlim(i,2)), floor(ylim(i,2)));
   % imax = imin + size(img{i},1) - 1;
   % jmax = jmin + size(img{i},2) - 1;
   
   [ovimin, ovjmin] = worldToSubscript(panaromaRef,ceil(xlim(i,1)),ceil(ylim(i,1)))
   [ovimax, ovjmax] = worldToSubscript(panaromaRef,floor(xlim(i-1,2)),floor(ylim(i-1,2)))
   overlapLength = ovjmax - ovjmin + 1;
   weight = meshgrid(0:overlapLength-1, ovimin:ovimax) / overlapLength;
   weight = cat(3, weight, weight, weight);
   size(weight)
   panaroma(ovimin:ovimax, ovjmin:ovjmax, :) = ...
      uint8(double(panaroma(ovimin:ovimax, ovjmin:ovjmax, :)) .* (1-weight));  
   
   
   [bndi1, bndj1] = worldToSubscript(ref(i),floor(xlim(i-1,2)), ceil(ylim(i,1)));
   [bndi2, bndj2] = worldToSubscript(ref(i),floor(xlim(i-1,2)), floor(ylim(i,2)));
   bndj = min(bndj1, bndj2);
   % overlapLength = bndj - jmin + 1;
   % weight = meshgrid(0:overlapLength-1, bndi1:bndi2) / overlapLength;
   weight = meshgrid(0:bndj-1, bndi1:bndi2) / bndj;
   weight = cat(3,weight,weight,weight);
   img{i}(bndi1:bndi2, 1:bndj, :) = ...
      uint8(double(img{i}(bndi1:bndi2, 1:bndj,:)) .* weight);
   panaroma(imin:imax, jmin:jmax, :) = ...
      panaroma(imin:imax, jmin:jmax, :) + img{i}(1:(imax-imin+1), 1:(jmax-jmin+1), :);
end

