clear all
% Compileraufruf
%nvmex -f nvmexopts_bb_double.bat mexUnitTestMain.cu -IC:\CUDA\include -LC:\CUDA\lib -lcudart
%nvmex -f nvmexopts_bb_double.bat mexUnitTestMain_cpu.cu -IC:\CUDA\include -LC:\CUDA\lib -lcudart
%nvmex -f nvmexopts_bb_double.bat mexInterface_sparseMv_gpu.cu -IC:\CUDA\include -LC:\CUDA\lib -lcudart
%nvmex -f nvmexopts_bb_double.bat mexInterface_sparseMv_gpu02.cu -IC:\CUDA\include -LC:\CUDA\lib -lcudart
%mex mexInterface_sparseMv.c
%mex mexUnitTestMain_cpu.c
%mex mexInterface_idrs.c


%scalarMul
% a1 = [1:10000]';%1*ones(10,1);
% a2 = 2;
%tic
%  b3=mexUnitTestMain_cpu(a1,a2,3)
%toc
%tic
%b33 = mexUnitTestMain(a1,a2,3)
%toc

% %norm
% a1 = 1*ones(9000,1);
% a2 = a1;
% tic
% b1 = mexUnitTestMain_cpu(a1,1)
% toc
% tic
% b12 = mexUnitTestMain(a1,1)
% toc

%dotmul
%tic
%  b2=mexUnitTestMain_cpu(a1,a2,0)
%toc
%tic
%b22 = mexUnitTestMain(a1,a2,0)
%toc
%%%matrixMul
%%%%N < sqrt(mem/12)
%N = 4000
%A=ones(N,N);
%B = 1*ones(N,1);
%tic
%b3 = mexUnitTestMain_cpu(A,B,2);
%toc
%tic
%b32 = mexUnitTestMain(A,B,2);
%toc
%==================================
%
N=5;
A = sparse(1:N,1:N,1,N,N);
b = [1:N];
c = mexInterface_sparseMv(A,b);
% %c = mexInterface_sparseMv_gpu(A,b);
% c = mexInterface_sparseMv_gpu02(A,b);
%==================================


%test idrs
% N = 10;
% A=sparse(1:N,1:N,1,N,N);
% b = [1:N];
% s = 1;
% tol = 1;
% maxit =1;
% x0 = [1:N];
% [x,resvec,iter] = mexInterface_idrs(A,b,s,tol,maxit,x0,N)
