function [Px,Py,Pz] = create_P(Nx,Ny,Nz)
    Mx = 1;
    My = Nx;
    Mz = Nx*Ny;
    Np = Nx*Ny*Nz
    e = ones(Np,1);
    Px = spdiags([-1*e,e],[0,Mx],Np,Np);
    Py = spdiags([-1*e,e],[0,My],Np,Np);
    Pz = spdiags([-1*e,e],[0,Mz],Np,Np);
end
