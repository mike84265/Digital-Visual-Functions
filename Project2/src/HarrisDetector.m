function fHM = HarrisDetector(img)
%% Define variables
m = size(img,1);
n = size(img,2);
N = 4;
[X  Y]= meshgrid(-N:N,-N:N);
sd = 1.0;  si = 1.5;
dx = [0.5 0 -0.5];   dy = [-0.5;0;0.5];
Gd = exp(-(X.^2 + Y.^2) / (2*sd^2));
Gd = Gd / sum(sum(Gd));
Gi = exp(-(X.^2 + Y.^2) / (2*si^2));
Gi = Gi / sum(sum(Gi));
px = conv2(img,dx);  px = px(:,2:n+1);
py = conv2(img,dy);  py = py(2:m+1,:);
px = conv2(px,Gd);   px = px(N+1:N+m, N+1:N+n);
py = conv2(py,Gd);   py = py(N+1:N+m, N+1:N+n);

Ixx = px.^2;
Iyy = px.^2;
Ixy = px.*py;
Ixx = conv2(Ixx,Gi); Ixx = Ixx(N+1:N+m, N+1:N+n);
Iyy = conv2(Iyy,Gi); Iyy = Iyy(N+1:N+m, N+1:N+n);
Ixy = conv2(Ixy,Gi); Ixy = Ixy(N+1:N+m, N+1:N+n);

fHM = ( (Ixx.*Ixy) - Ixy.^2 ) ./ (Ixx+Iyy);

