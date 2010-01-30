clear all
close all
%513
%ngrid=1000; %choose odd numbers!
%[A,q]=Kondensator_Edge(ngrid);

% calculate potential: PCG (for comparison)
% [p,flag,relres,iter,resvec] = pcg(A,q,1e-11,600);


% calculate potential: IDRS
%x0=rand(size(q));

%x0=x0/norm(x0); %normalized starting vector x0
N = 100;
%N=1000000;%0.55(s)
%N = 100000;%18.8(s)
%N = 1000000;
e=ones(N,1);
A=spdiags([-1*e,2*e,-1*e],[-1,0,1],N,N);
%A = sparse(1:N,1:N,1,N,N);
%q = rand(N,1);
q=[0:N-1]';
%x0 = rand(N,1);
x0=2*q;
tol=0.1;%1e-11
matit =30;% 1000;
tic
[p,resvec,iter]=idrs(A,q,6,tol,matit,x0);
toc

% figure
% spy(A)
% title('sparsity of matrix A')
% 
% figure
% surf(reshape(p,ngrid,ngrid))
% title('potential near metallic edge')

% figure
% semilogy(resvec,'o')
% title('convergence history of idr(s)')