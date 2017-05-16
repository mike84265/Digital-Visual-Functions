function [pointList, logicMtx] = decreaseFeature(points, r)
m = size(points,1);
n = size(points,2);
loc = zeros(m+r*2, n+r*2);
loc(r+1:r+m, r+1:r+n) = points > 10;
numPoints = sum(sum(loc));
X = zeros(numPoints,3);
pointList = zeros(numPoints,3);
k=1;
for i=1:m
   for j=1:n
      if (loc(r+i,r+j))
         X(k,1) = i;
         X(k,2) = j;
         X(k,3) = points(i,j);
         k = k+1;
      end
   end
end
[list I] = sort(X,1, 'descend');
list = X(I(:,3)',:);


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