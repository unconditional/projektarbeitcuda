function hh = bb_bar3(varargin)
% BB_BAR3   3-D bar graph.
% Modified BAR3:
% coloring is accordingly to the absolute value of Z
% the rest ist equal to bar3.m
% example:
% bb_bar3([0:20]'*[0:20])
%varargin{1,1}=rot90(varargin{1,1});
error(nargchk(1,inf,nargin,'struct'));
[cax,args] = axescheck(varargin{:});

[msg,x,y,xx,yy,linetype,plottype,barwidth,zz] = makebars(args{:},'3');
if ~isempty(msg), error(msg); end %#ok

m = size(y,2);
% Create plot
cax = newplot(cax);
fig = ancestor(cax,'figure');

next = lower(get(cax,'NextPlot'));
hold_state = ishold(cax);
edgec = get(fig,'defaultaxesxcolor');
facec = 'flat';
h = []; 
cc = zz/(max(max(zz)'))+1;

for ii=1:size(cc,1)/6
    for jj=1:size(cc,2)/4
        cc((ii-1)*6+(1:6),(jj-1)*4+(1:4)) = ones(6,4)*cc(2+(ii-1)*6,2+(jj-1)*4);
    end
end
    

if ~isempty(linetype)
    facec = linetype;
end

for i=1:size(yy,2)/4
    h = [h,surface('xdata',xx+x(i),...
            'ydata',yy(:,(i-1)*4+(1:4)), ...
            'zdata',zz(:,(i-1)*4+(1:4)),...
            'cdata',cc(:,(i-1)*4+(1:4)), ...
            'FaceColor','flat',...
            'EdgeColor',edgec,...
            'tag','bar3',...
            'parent',cax)];
end

if length(h)==1
    set(cax,'clim',[1 2]);
end

if ~hold_state, 
  % Set ticks if less than 16 integers
  if all(all(floor(y)==y)) && (size(y,1)<16) 
      set(cax,'ytick',y(:,1));
  end
  
 xTickAmount = sort(unique(x(1,:))); 
 if length(xTickAmount)<2
     set(cax,'xtick',[]);
 elseif length(xTickAmount)<=16
      set(cax,'xtick',xTickAmount);
 end  %otherwise, will use xtickmode auto, which is fine
  
  hold(cax,'off'), view(cax,3), grid(cax,'on')
  set(cax,...
      'NextPlot',next,...
      'ydir','reverse');
  if plottype==0,
    set(cax,'xlim',[1-barwidth/m/2 max(x)+barwidth/m/2])
  else
    set(cax,'xlim',[1-barwidth/2 max(x)+barwidth/2])
  end

  dx = diff(get(cax,'xlim'));
  dy = size(y,1)+1;
  if plottype==2,
    set(cax,'PlotBoxAspectRatio',[dx dy (sqrt(5)-1)/2*dy])
  else
    set(cax,'PlotBoxAspectRatio',[dx dy (sqrt(5)-1)/2*dy])
  end
end

if nargout>0, 
    hh = h; 
end
xlabel('row')
ylabel('column')

