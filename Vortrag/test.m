close all;
clear all;

% N=5000000;
% %N=10
% %A=ones(N,N);
% %A=sparse([1:N],[1:N],1,N,N);
% A=spdiags([ones(N,1),ones(N,1),ones(N,1)],[-1:1],N,N);

fullMatrix=[
0,      	0,	     7.64064	,5.37138	,3.81888,2.91632,3.088032	,6.01392	,6.01392  ;
10.4384,	7.3328	,	5.419744	,3.74288	,2.707	,2.007	,1.7896	,3.204864	,6.386464    ;
6.674496,	5.108224,	3.64,	2.568384	,1.87875	,1.4839	,1.243424	,2.17824,	0   ;
4.85414,	3.867008,	2.8256,	2.026368,	1.501664	,1.25072	,1.09832	0, 0    ;
5.891008,	4.839808,	3.566784,	2.5728	,1.9064	,1.476256,	0,	0,    0           ;
    
];

bb_bar3(fullMatrix);
set(gca,'YTickLabel',2.^[0:4]);
set(gca,'XTickLabel',2.^[0:8]);
title('Full Matrix Multiplikation ')
zlabel('Lauf Zeit(ms)');
xlabel('')
ylabel('')
figure

sparseMatrix = [
    0.219,      0.241,  0.878,  1.129,  2.898,  4;    
    0.0355,     0.059,  0.2789, 0.5348, 1.126,  2.399;
    0.09168,    0.091,  0.0932, 0.1191, 0.1739, 0.281
];

% bb_bar3(sparseMatrix)
% set(gca,'YTickLabel',{'Matlab';'CPU';'GPU'});
% set(gca,'XTickLabel',[1,3,16,32,64,128]);
% title('Sparse Matrix Multiplikation ')
% zlabel('Lauf Zeit(ms)');
% xlabel('')
% ylabel('')
x=[1,3,16,32,64,128];
n=3;


plot(x,sparseMatrix(1,:),x,sparseMatrix(2,:),x,sparseMatrix(3,:));
legend('Matlab','CPU','GPU');
ylabel('Lauf Zeit(ms)');

%%====Sparse 2D block 1 Diagonale==========================================
figure
sparseMatrix = [
    0,  2.41,   2.714,  3.77,   6.98,   14.56,  39.76;
    0.3,0.93,   2.45,   0,      0,      0,      0    ;
    0.3,1.33,   0,      0,      0,      0,      0    ;
    0.36,0,     0,      0,      0,      0,      0    ;
    0.65,0,     0,      0,      0,      0,      0    ;
    0.67,0,     0,      0,      0,      0,      0    ;
    0.71,0,     0,      0,      0,      0,      0    
];
bb_bar3(sparseMatrix)
set(gca,'YTickLabel', 2.^[0,4:9]);
set(gca,'XTickLabel',2.^[0,4:9]);
title('Sparse 2D 1 Diagonale ')
xlabel('blkX')
ylabel('blkY')
zlabel('Lauf Zeit(ms)');
%%====Sparse 2D 32 Diagonale==========================================
%figure
sparseMatrix = [
    0,      4.013,  2.7824, 3.8195, 6.96,   14.572, 39.82;
    7.0,    1.52,   2.56,   0,      0,      0,      0    ;
    7.19,   2.11,   0,      0,      0,      0,      0    ;
    8.3125, 0,     0,      0,      0,      0,      0    ;
    10.354, 0,     0,      0,      0,      0,      0    ;
    9.97,   0,     0,      0,      0,      0,      0    ;
    9.54,   0,     0,      0,      0,      0,      0    
];
% bb_bar3(sparseMatrix)
% set(gca,'YTickLabel', 2.^[0,4:9]);
% set(gca,'XTickLabel',2.^[0,4:9]);
% title('Sparse 2D 32 Diagonale ')
% xlabel('blkX')
% ylabel('blkY')
% zlabel('Lauf Zeit(ms)');

%%====Voll Matrix Optimierung==========================================
%figure
sparseMatrix = [

1.56	,15.94	,80			,3.44	,87.19	;
2.669	,26.059	,130.038	,0.564	,11.216 ;
0.207	,1.056	,4.963		,0.176	,2.998  
];

% bb_bar3(sparseMatrix)
% set(gca,'YTickLabel', 2.^[0,4:9]);
% set(gca,'XTickLabel',2.^[0,4:9]);
% title('Full-Matrix Optimierung  ')
% xlabel('')
% ylabel('')
% set(gca,'YTickLabel',{'CPU';'Old GPU';'GPU'});
% set(gca,'XTickLabel',{'1000x50','100000x50','500000x50','1000x1000','5000x5000'});
% zlabel('Lauf Zeit(ms)');
