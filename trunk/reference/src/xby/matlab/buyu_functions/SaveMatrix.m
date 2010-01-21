%create C matrix mit unterschiedlich Gro?e
%function Mc = SaveMatrix()

N = 10;

N=3
nx=N;
ny=N;
nz=N;
Mc = create_C(nx,ny,nz);
%save('mein_dateiname.txt','Acc','-ASCII','-double','-tabs')
Mc=full(Mc);
save('Mc.txt','Mc','-ASCII','-double','-tabs');