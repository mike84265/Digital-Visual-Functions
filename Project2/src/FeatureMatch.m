function indexPair = FeatureMatch(ft1, ft2)
% ft1, ft2: N-by-2 cell matrix. First column is the coordinate, second
% column is the feature descriptor (8*8 matrix).
thr = 1;
n1 = size(ft1,1);
n2 = size(ft2,1);
indexPair = zeros(min(n1,n2),4);
k = 1;

for i=1:n1
   dist = zeros(n2,1);
   for j=1:n2
      dist(j) = sum(sum( (ft1{i,2} - ft2{j,2}).^2 ));
   end
   [mindist, index] = min(dist);
   if mindist < thr
      indexPair(k,1:2) = ft1{i,1};
      indexPair(k,3:4) = ft2{index,1};
      % indexPair(k,5) = mindist;
      k = k+1;
   end
end

indexPair = indexPair(1:k-1);
