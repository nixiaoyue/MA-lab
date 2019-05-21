function xs = GetData (x, is, N) 
%(x,is,N) = (azbp, center window sample index, n of samples/window)
% is is the index of the center
% is = round(t * Fs - (LWin-1) / 2) + 1;
% N is the length of the window
N = N+1;                %
Nx = length(x);         %length of the total data
iss = max(is, 1);       %sanity check?
ie = min(is+N-1, Nx);

xs = zeros(N,1);
Nv = ie - iss + 1;
if (Nv > 0)
    offs = iss - is;
    xs(offs+1:offs+Nv) = x(iss:ie);
end

return
