%% readImg
m = 4000;
n = 6000;
p = dlmread('ChosenPoints4.txt');
numPic = 13;
numPixel = size(p,1);

img_cell = cell(numPic,1);
cd img;
for i=1:numPic
   s = "IMG_0" + string(i+110) + ".jpg";
   img_cell{i} = imread(char(s));
end
cd ..;

%% Setting variables
%  Z(i,j) : pixel value of the ith pixel in jth picture
%  B(j)   : exposure time
%  l      : lambda
%  w      : weighting function


Z = zeros(numPixel,numPic);
B = zeros(numPic,1);

B(1) = log(1/8);
B(2) = log(1/4);
B(3) = log(1/2);
B(4) = log(1);
B(5) = log(2);
B(6) = log(4);
B(7) = log(8);
B(8) = log(16);
B(9) = log(32);
B(10) = log(64);
B(11) = log(128);
B(12) = log(256);
B(13) = log(512);

l = 5; 

w = zeros(256,1);
for i=1:128
   w(i) = i-1;
end
for i=129:256
   w(i) = 256-i;
end
w = w/128;
g = zeros(256,3);
lE = zeros(numPixel,3);
radianceMap = zeros(m,n,3);
%% Three colors run seperately
for c=1:3
   for i=1:numPixel
      for j=1:numPic
         Z(i,j) = img_cell{j}(p(i,1),p(i,2),c);
      end
   end
   [g(:,c), lE(:,c)] = gsolve(Z,B,l,w);
   for x=1:m
      for y=1:n
         num = 0;
         den = 0;
         for s=1:numPic
            num = num + w(img_cell{s}(x,y,c)+1) * (g(img_cell{s}(x,y,c)+1,c)-B(s));
            den = den + w(img_cell{s}(x,y,c)+1);
         end
         radianceMap(x,y,c) = exp(num/den);
      end
   end
end

RGB = tonemap(radianceMap);

   