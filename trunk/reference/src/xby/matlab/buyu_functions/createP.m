function [Px,Py,Pz] = create_P(Nx,Ny,Nz)
    Mx = 1;
    My = Nx;
    Mz = Nx*Ny;
    Np = Nx*Ny*Nz
    e = ones(3*NP,1);
    Px = spdiags([-1*e,e],0:Mx);
    Py = spdiags([-1*e,e],0:My);
    Py = spdiags([-1*e,e],0:Mz);
end;