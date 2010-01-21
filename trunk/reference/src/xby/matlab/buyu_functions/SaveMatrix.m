%create C matrix mit unterschiedlich Gro?e
%function Mc = SaveMatrix()

N = 10;

N=3
nx=N;
ny=N;
nz=N;
Mc = create_C(nx,ny,nz);
save('Mc.txt',full(Mc));