
a1 = ones(10000,1);
a2 = a1;
tic
b1 = mexUnitTestMain_cpu(a1,1);
toc
tic
b12 = mexUnitTestMain(a1,1);
toc

tic
%b2 = mexUnitTestMain_cpu(a1,a2,0);
toc
tic
%b22 = mexUnitTestMain(a1,a2,0);
toc
%matrixMul
A=ones(1000,1000);
B = ones(1000,1);
tic
%b3 = mexUnitTestMain_cpu(A,B,2);
toc
tic
%b32 = mexUnitTestMain(A,B,2);
toc

