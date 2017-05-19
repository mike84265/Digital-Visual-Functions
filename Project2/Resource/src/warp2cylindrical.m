function cylImg = warp2cylindrical(recImg, f)
forward = @(U) [ f*atan2(U(:,1),f), f*(U(:,2)./sqrt(U(:,1).^2+f^2)) ];
inverse = @(X) [ f*tan(X(:,1)/f), X(:,2)./(cos(X(:,1)/f)) ];
% MATLAB use i-j coordinate to record an image, 
% which is not instinctive. 
% Here I exchange the indices to j-i to represent x-y coordinate.
m = size(recImg,2);
n = size(recImg,1);
inRange = @(xy) (xy(1)>=1 && xy(1)<=m && xy(2)>=1 && xy(2)<=n);
rxc = m/2;
ryc = n/2;
rxmin = 1-rxc; rxmax = m-rxc;
rymin = 1-ryc; rymax = n-ryc;

%% Using forward mapping to find the boundary of the cylindrical image
rbound = [rxmin, rymin; rxmin, rymax; 0, rymax; ...
   rxmax, rymax; rxmax, rymin; 0, rymin];
cbound = round(forward(rbound));
cxmin = cbound(1,1); cxmax = cbound(4,1);
cymin = min(cbound(5,2),cbound(6,2));
cymax = max(cbound(3,2),cbound(4,2));
cxc = 1-cxmin; cyc = 1-cymin;
cylImg = uint8(zeros(cymax+cyc, cxmax+cxc,3));

%% inverse mapping to find the corresponding pixel to the image.
for i=cxmin:cxmax
   cxy = i * ones(cymax+cyc,2);
   cxy(:,2) = cymin:cymax;
   rxy = round(inverse(cxy));
   inRange = rxy(:,1) >= rxmin & rxy(:,1) <=rxmax & ...
      rxy(:,2)>=rymin & rxy(:,2)<=rymax;
   for j=1:cymax+cyc
      if (inRange(j))
         cylImg(cxy(j,2)+cyc,cxy(j,1)+cxc,:) = ...
            recImg(rxy(j,2)+ryc, rxy(j,1)+rxc,:);
      end
   end
end
   

