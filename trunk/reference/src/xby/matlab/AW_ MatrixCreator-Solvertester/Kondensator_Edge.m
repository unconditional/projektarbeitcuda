function [Star,q]=Kondensator_Edge(ngrid)
xmin = -0.25; xmax = 0.25;
ymin = -0.25; ymax = 0.25;
zmin = 0; zmax = 0.01;
xbox = 0;
ybox = 0;
D.nx = ngrid;
D.ny = ngrid;
D.nz =1;
Mx = 1;
My = D.nx;
Np = D.nx*D.ny;
D.xmesh = linspace(xmin, xmax, D.nx);
D.ymesh = linspace(ymin, ymax, D.ny);
D.zmesh = linspace(zmin, zmax,D.nz);
helpgrid = ones(Np,1)*1;
for ii = 1:D.ny
    ip = (ii-1)*My + 1;
    helpgrid(ip) = 0.5;
end
for ii = 1:D.ny-1
    ip = (ii-1)*My + (D.nx-1)*Mx + 1;
    helpgrid(ip) = 0.5;
end
for ii = 1:D.nx
    ip = (D.ny-1)*My + (ii-1)*Mx + 1;
    helpgrid(ip) = 0.5;
end
for ii = 2:D.nx-1
    ip = (0)*My + (ii-1)*Mx + 1;
    helpgrid(ip) = 0.5;
end
for iy = 1:D.ny-1
    ymid = (D.ymesh(iy));
    if ymid > ybox, continue, end
    for ix = 1:D.nx
        xmid = (D.xmesh(ix));
        if xmid < xbox, continue, end
        ip = (iy-1)*My + (ix-1)*Mx + 1;
        helpgrid(ip) = 0.5;
    end
end
Star = sparse(Np,Np);
q = sparse(Np,1);
for ix = 1:D.nx
    for iy=1:D.ny
        ii= 1 + (ix-1) + (iy-1)*My;
        if helpgrid(ii) == 2
            Star(ii, ii)        = 4;
            Star(ii, ii-1)     = -1;
            Star(ii, ii+1)     = -1;
            Star(ii, ii-D.nx)   = -1;
            Star(ii, ii+D.nx)   = -1;
        elseif helpgrid(ii) == 1
            Star(ii, ii)        = 4;
            Star(ii, ii-1)     = -1;
            Star(ii, ii+1)     = -1;
            Star(ii, ii-D.nx)   = -1;
            Star(ii, ii+D.nx)   = -1;
        elseif helpgrid(ii) == 0.5
            Star(ii, ii)        = 1;
            q(ii)             = edge_funktion(D.xmesh(ix),D.ymesh(iy));
        end
    end
end
end

function Z = edge_funktion(X,Y)
m =75;
V_0 = 1;
beta = 3*pi/2;
Z = zeros(size(X))+V_0;
rho = sqrt(X.^2+Y.^2);
phi = atan2(Y,X);
helper = find(phi < 0);
phi(helper) = phi(helper)+2*pi;
a=0.5;
Zlast=Inf;
for n = 0:1:m
    En     = -4*V_0./(a^(pi*(2*n+1)./beta)*pi*(2*n+1));
    Z      = Z+(En*rho.^(pi.*(2*n+1)./beta).*sin(pi.*(2*n+1)./beta.*phi));
    Zlast=Z;
end
Z(rho>0.5)=0;
Z(phi>beta) = V_0;
end