function [indexPair, tform] = FeatureMatch(ft1, ft2)
% ft1, ft2: N-by-2 cell matrix. First column is the coordinate, second
% column is the feature descriptor (8*8 matrix).
n1 = size(ft1,1);
n2 = size(ft2,1);
indexPair = zeros(min(n1,n2),4);
k = 1;
threshold = 5;

for i=1:n1
   dist = zeros(n2,1);
   for j=1:n2
      dist(j) = sum(sum( (ft1{i,2} - ft2{j,2}).^2 ));
   end
   [mindist, index] = min(dist);
   if mindist < threshold
      indexPair(k,1:2) = ft1{i,1};
      indexPair(k,3:4) = ft2{index,1};
      % indexPair(k,5) = mindist;
      k = k+1;
   end
end

indexPair = indexPair(1:k-1,:);

%% RANSAC

maxInlinerRate = 0;
bestTform = zeros(3,3);
while(maxInlinerRate < 0.85)
   k = size(indexPair,1);
   numSample = 6;
   if (k < numSample)
      fprintf('no enough pairs remain\n');
      return;
   end
   samplePoints = indexPair(randperm(k,numSample),:);
   A = [samplePoints(:,[2 1]), ones(numSample,1)];
   cx = A\samplePoints(:,4);
   cy = A\samplePoints(:,3);
   tform = [cx, cy];
   estimation = [indexPair(:,[2 1]) ones(k,1)] * tform;
   inliners = sum(((estimation - indexPair(:,[4 3])).^2), 2) < 100;
   inlinerRate = sum(inliners) / k;
   if (inlinerRate > 0.5)
      indexPair = indexPair(inliners,:);
   end
   if (inlinerRate > maxInlinerRate)
      maxInlinerRate = inlinerRate;
      bestTform = tform;
   end
end

tform = bestTform;
