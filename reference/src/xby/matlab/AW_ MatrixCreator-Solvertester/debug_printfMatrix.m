function varargout = debug_printfMatrix(fid,matrix)

if(fid~=0)
    matrix_size = size(matrix);
    for i=1:matrix_size(1)
        fprintf(fid,'%10.6f',matrix(i,:)); 
        fprintf(fid,'\n'); 
    end
    
    
end
end