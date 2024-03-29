function fHM = HarrisDetector(img)
%% Define variables
N = 4;
sd = 1.0;  si = 1.5;
dx = [0.5 0 -0.5];   dy = [-0.5;0;0.5];

Gd = fspecial('gaussian',[2*N+1, 2*N+1], sd);
Gi = fspecial('gaussian',[2*N+1, 2*N+1], si);
px = conv2(img,dx,'same'); 
py = conv2(img,dy,'same'); 
px = conv2(px,Gd,'same');   
py = conv2(py,Gd,'same');

Ixx = px.^2;
Iyy = px.^2;
Ixy = px.*py;
Ixx = conv2(Ixx,Gi,'same'); 
Iyy = conv2(Iyy,Gi,'same');
Ixy = conv2(Ixy,Gi,'same');
fHM = ( (Ixx.*Ixy) - Ixy.^2 ) ./ (Ixx+Iyy);

