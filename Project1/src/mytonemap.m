function rgb = mytonemap(hdr)
delta = 0.18;
a = 0.36;   % key value
N = size(hdr,1) * size(hdr,2);
Lwbar = exp(sum(sum(log(delta + hdr),1),2));
L = hdr * a / Lwbar;
Ld = L / (1+L);