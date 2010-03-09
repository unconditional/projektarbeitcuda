
close all
runnr=20000;
fid=fopen([num2str(runnr) '1e-8'],'r');
for ii=1:33
    tline = fgetl(fid);
end
x=zeros(runnr,1);
for ii=1:runnr
    tline = fgetl(fid);
    arr=regexp(tline, '\t', 'split');
    x(ii)=str2double(arr{2});
end
for ii=1:5
    tline = fgetl(fid);
end
arr=regexp(tline, '\t', 'split');
ii=1;
while length(arr)>1
    resi(ii)=str2num(arr{2});
    tline = fgetl(fid);
    arr=regexp(tline, '\t', 'split');
    ii=ii+1;
end

fclose(fid)

figure(1)
plot(x,'o-')

figure(2)
semilogy(resi,'o')
