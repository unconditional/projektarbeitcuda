clear all
close all


% A=sparse([1  0  0  0;...
%           -1 2 -1  0;...
%           0 -1  2 -1;...
%           0  0  0  1]);
%       
%       q=[10 0 0 -10]';
      
N=500;      
A=speye(N)*2 + sparse([2:N],[1:N-1],-ones(N-1,1),N,N) + sparse([1:N-1],[2:N],-ones(N-1,1),N,N);
A(1,2)=0;
A(1,1)=1;
A(N,N)=1;
A(N,N-1)=0;      

% q=ones(N,1)*10;
q=zeros(N,1);
q(1,1)=1;
q(N,1)=-1;

q=sparse(q);
      
x0=rand(size(q));
x0=x0/norm(x0); %normalized starting vector x0
% [p,resvec,iter]=idrs_single(A,q,4,1e-16,2700,x0);
[p,resvec,iter]=idrs(A,q,4,1e-16,600,x0);


figure
spy(A)
title('sparsity of matrix A')

figure
semilogy(resvec,'o')
title('convergence history of idr(s)')

figure
plot(p,'o')
title('potential')
