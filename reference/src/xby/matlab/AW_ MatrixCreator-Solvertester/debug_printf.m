function [varargout] = debug_printf(varargin)

filename = varargin{length(varargin)};
fid = fopen(filename,'a');

%fprint(fid,format,A);
%c = M\m;
    c=varargin{1};
    M=varargin{2};
    m=varargin{3};
    iter=varargin{4};
    oldest=varargin{5};
    norm=varargin{6};
    
    fprintf(fid,'iter:%d ,oldest:%f ,norm:%f ',iter,oldest,norm);
    fprintf(fid,'\n');
    
    fprintf(fid,'c= ');
    fprintf(fid,'\n');
    fprintf(fid,'%10.6f ',c);
    fprintf(fid,'\n');
    
    fprintf(fid,'M= ');
    fprintf(fid,'\n');
    debug_printfMatrix(fid,M);
    %fprintf(fid,'%f ',M);
    %fprintf(fid,'\n');
    
    fprintf(fid,'m= ');
    fprintf(fid,'\n');
    fprintf(fid,'%10.6f ',m);
    fprintf(fid,'\n');
    fprintf(fid,'\n');
    for i = 1:length(varargin)
        print=varargin{i};
        data{i}= print;
    end
   fclose(fid);
end