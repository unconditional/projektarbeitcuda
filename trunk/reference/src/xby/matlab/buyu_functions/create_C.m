function C = create_C(Nx, Ny, Nz)
% this function generates the Curl Matrix for karthesian Coordinates with
% Nx, Ny and Nz Gridpoints.
% 
% This function is called as: 
%       C = create_C(Nx, Ny, Nz)
    Np = Nx*Ny*Nz;
    [Px,Py,Pz] = create_P(Nx,Ny,Nz);    
    C1 = [zeros(Np,Np),-1*Pz,Py];
    C2 = [Pz,zeros(Np,Np),-1*Px];
    C3 = [-1*Py,Px,zeros(Np,Np)];
    C=[C1;C2;C3];
    spy(C);
end