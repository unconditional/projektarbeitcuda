clear all
% Compileraufruf
%nvmex -f nvmexopts_bb_double.bat mexUnitTestMain.cu -IC:\CUDA\include -LC:\CUDA\lib -lcudart
%nvmex -f nvmexopts_bb_double.bat mexUnitTestMain_cpu.cu -IC:\CUDA\include -LC:\CUDA\lib -lcudart
%nvmex -f nvmexopts_bb_double.bat mexInterface_sparseMv_gpu.cu -IC:\CUDA\include -LC:\CUDA\lib -lcudart
nvmex -f nvmexopts_bb_double.bat mexInterface_sparseMv_gpu02.cu -IC:\CUDA\include -LC:\CUDA\lib -lcudart

%mex mexInterface_sparseMv.c
% mex mexUnitTestMain_cpu.c
%scalarMul
% a1 = 1*[1:10]';%ones(10000,1);
% a2 = 3;
%tic
 % b3=mexUnitTestMain_cpu(a1,a2,3)
%toc
%tic  
%b33 = mexUnitTestMain(a1,a2,3);
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
% %%%%N < sqrt(mem/12)
%  mA = 1000000
%  nB = 50
% % 
%  A=ones(mA,nB);
%  B = 1*ones(nB,1);
% %tic
%b3 = mexUnitTestMain_cpu(A,B,2);
%toc
% tic
% %b32 = mexUnitTestMain(A,B,2);
% toc
%==================================
%
   N=500000;
   e=ones(N,1);
A=spdiags([e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e],[-16:15],N,N);
  %A = sparse(1:N,1:N,1,N,N);
  b=ones(1,N);
% %  %b = [1:N];
% % 
%tic
 c2 = mexInterface_sparseMv_gpu02(A',b);
% toc
% tic
% %c1 = mexInterface_sparseMv(A',b);
% c1 = mexInterface_sparseMv_gpu(A',b);
% toc
 %tic
 %c3=A'*b';
 %toc
%==================================
