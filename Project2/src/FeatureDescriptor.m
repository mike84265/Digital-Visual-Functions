function fdscpt = FeatureDescriptor(img,fpnt)
%% variables:
m = size(img,1);
n = size(img,2);
tmp = padarray(img,[40 40],'replicate');
fdscpt = cell(size(fpnt,1),2);
k = size(fpnt,1);
sigma = 4.5;
img = imgaussfilt(img,sigma);
[~, gdir] = imgradient(img);

%% Extract features
for i=1:k
   x = fpnt(i,1);
   y = fpnt(i,2);
   window = tmp(x:x+80, y:y+80);
   window = imrotate(window,-gdir(x,y),'crop');
   window = window(23:5:60, 23:5:60);
   fdscpt{i,1} = [x; y];
   fdscpt{i,2} = (window - mean2(window)) / std2(window);
end