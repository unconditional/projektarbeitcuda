clear all
close all

% Compileraufruf
nvmex -f nvmexopts_bb_double.bat mex_sum.cu -IC:\CUDA\include -LC:\CUDA\lib -lcudart

% Größe der Vektoren
n=48000;
test_vec1=rand(n,1);
test_vec2=rand(n,1);

fprintf('CPU... ')
tic %Stoppuhr start
    result_matlab = test_vec1 + test_vec2;
toc % Stoppuhr stopp

fprintf('GPU... ')

tic
    [result_cuda]=mex_sum(test_vec1, test_vec2);
toc
% tic
%     [result_cuda]=mex_sum(test_vec1, test_vec2);
% toc
% tic
%     [result_cuda]=mex_sum(test_vec1, test_vec2);
% toc
% tic
%     [result_cuda]=mex_sum(test_vec1, test_vec2);
% toc
% tic
%     [result_cuda]=mex_sum(test_vec1, test_vec2);
% toc

fprintf('  done\n')

difference = norm(result_matlab-result_cuda)

