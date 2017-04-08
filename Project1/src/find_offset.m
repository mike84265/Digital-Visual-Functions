% find_offset - Find offset of the image cell(array).
% Arguments:
% img_cell  cell array that contains images to be calculates.
% offset    an array storing offset of each images
function offset = find_offset(img_cell)

%% Defining variables and constants
offset = zeros(size(img_cell,1), 2);
directions = zeros(9,2);
directions(1,:) = [-1, -1];
directions(2,:) = [-1,  0];
directions(3,:) = [-1,  1];
directions(4,:) = [ 0, -1];
directions(5,:) = [ 0,  0];
directions(6,:) = [ 0,  1];
directions(7,:) = [ 1, -1];
directions(8,:) = [ 1,  0];
directions(9,:) = [ 1,  1];
% Assume all images has the same size.
m = size(img_cell{1}, 1);
n = size(img_cell{1}, 2);

%% Building MTB of the main image
med_main = median(img_cell{1}(:));
MTB_main = cell(9,1);
MTB_main{1} = uint8(zeros(m,n));
for x=1:m
   for y=1:n
      if (img_cell{1}(x,y) > med_main)
         MTB_main{1}(x,y) = 1;
      else
         MTB_main{1}(x,y) = 0;
      end
   end
end

%% Scaling down
for i=2:9
   MTB_main{i} = MTB_main{1}(1:2^(i-1):m, 1:2^(i-1):n);
end

%% Building MTB of subfigs
for i=2:size(img_cell)
   med_sub = median(img_cell{i}(:));
   MTB_sub = cell(9,1);
   MTB_sub{1} = uint8(zeros(m,n));
   for x=1:m
      for y=1:n
         if (img_cell{i}(x,y) > med_sub)
            MTB_sub{1}(x,y) = 1;
         else
            MTB_sub{1}(x,y) = 0;
         end
      end
   end
   for j=2:9
      MTB_sub{j} = MTB_sub{1}(1:2^(j-1):m, 1:2^(j-1):n);
   end
 %% Comparing MTBs:
   for j=9:-1:1
      diffsum = zeros(8,1);
      for k=1:9
         offset(i,:) = offset(i,:) * 2;
         tmp_offset = offset(i,:) + directions(k,:);
         minx = max(1-tmp_offset(1),1);
         miny = max(1-tmp_offset(2),1);
         maxx = min(size(MTB_sub{j},1)-tmp_offset(1),size(MTB_sub{j},1));
         maxy = min(size(MTB_sub{j},2)-tmp_offset(2),size(MTB_sub{j},2));
         diffsum(k) = sum(sum(bitxor(MTB_main{j}(minx:maxx,miny:maxy), ...
            MTB_sub{j}((minx:maxx) + tmp_offset(1), (miny:maxy) + tmp_offset(2)))));
      end
      [~, index] = min(diffsum);
      offset(i,:) = offset(i,:) + directions(index,:);
   end
end