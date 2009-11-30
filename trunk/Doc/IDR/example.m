clear all;
close all;

disp('Solution of convection-diffusion problem with negative shift');
m = 20;
n = m*m;
shift = 1;
Pe = 0.1;
A = gallery('poisson',m) - shift * speye(n,n) + gallery('tridiag',n,-Pe,0,Pe);
x = ones(n,1);
b = A*x;
x0 = zeros(n,1);

tol = 1e-8;

s = 1;
[x, resvec_idr1,iter] = idrs(A,b,s,tol, 4*n);
disp(['idrs(',num2str(s),'), iteration: ',num2str(iter)])
disp(['Final accuracy: ', num2str(norm(b-A*x)/norm(b))])

s = 2;
[x, resvec_idr2,iter] = idrs(A,b,s,tol, 4*n);
disp(['idrs(',num2str(s),'), iteration: ',num2str(iter)])
disp(['Final accuracy: ', num2str(norm(b-A*x)/norm(b))])

s = 4;
[x, resvec_idr4,iter] = idrs(A,b,s,tol, 4*n);
disp(['idrs(',num2str(s),'), iteration: ',num2str(iter)])
disp(['Final accuracy: ', num2str(norm(b-A*x)/norm(b))])

s = 8;
[x, resvec_idr8,iter] = idrs(A,b,s,tol, 4*n);
disp(['idrs(',num2str(s),'), iteration: ',num2str(iter)])
disp(['Final accuracy: ', num2str(norm(b-A*x)/norm(b))])

[x, flag, relres, iter, resvec_gmres] = gmres(A, b, [], tol, 400 );
disp(['GMRES iteration: ',num2str(iter)])
disp(['Final accuracy: ', num2str(norm(b-A*x)/norm(b))])

[x, flag, relres, iter, resvec_bicgstab] = bicgstab(A, b, tol, 4*n );
disp(['Bi-CGSTAB iteration: ',num2str(iter)])
disp(['Final accuracy: ', num2str(norm(b-A*x)/norm(b))])

figure;
it = [0:1:length(resvec_bicgstab)-1];
semilogy(it,resvec_bicgstab/norm(b));
hold on
it = [0:1:length(resvec_idr1)-1];
semilogy(it,resvec_idr1/norm(b),'r');
it = [0:1:length(resvec_idr2)-1];
semilogy(it,resvec_idr2/norm(b),'r--');
it = [0:1:length(resvec_idr4)-1];
semilogy(it,resvec_idr4/norm(b),'r-+');
it = [0:1:length(resvec_idr8)-1];
semilogy(it,resvec_idr8/norm(b),'r-o');
it = [0:1:length(resvec_gmres)-1];
semilogy(it,resvec_gmres/norm(b),'k');
legend('BI-CGSTAB', 'IDR(1)', 'IDR(2)', 'IDR(4)', 'IDR(8)', 'GMRES' )
hold off;
xlabel('matrix-vector multiplications')
ylabel('residual norm')

