function [pointList, logicMtx] = decreaseFeature(points, featureloc, r)
m = size(points,1);
n = size(points,2);
loc = false(m+r*2, n+r*2);
loc(r+1:r+m, r+1:r+n) = featureloc;
numPoints = sum(sum(loc));
tmp = zeros(numPoints,3);
pointList = zeros(numPoints,3);

[Y, X] = meshgrid(1:n,1:m);
tmp(:,1) = X(loc(r+1:r+m, r+1:r+n));
tmp(:,2) = Y(loc(r+1:r+m, r+1:r+n));
tmp(:,3) = points(loc(r+1:r+m, r+1:r+n));
[~, I] = sort(tmp,1, 'descend');
list = tmp(I(:,3)',:);


window = false(2*r+1, 2*r+1);
window(r+1,r+1) = 1;
k = 1;

for i=1:numPoints
   if (loc(list(i,1)+r, list(i,2)+r) == 0)
      continue;
   else
      x = list(i,1); y = list(i,2);
      loc(x:x+r*2, y:y+r*2) = loc(x:x+r*2, y:y+r*2) & window;
      pointList(k,1) = x;
      pointList(k,2) = y;
      pointList(k,3) = list(i,3);
      k = k+1;
   end
end

pointList = pointList(1:k-1,:);
logicMtx = logical(loc(1+r:m+r, 1+r:n+r));