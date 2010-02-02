fs=20;  % FontSize
lw=2;   % LineWidth
ms=8;  % MarkerSize

set(gcf,'PaperPositionMode','auto')

% scrsz = get(0,'ScreenSize');
%set(gcf,'Position',[1 -0.07*scrsz(4) scrsz(3) scrsz(4)])
set(gcf,'Position',[100     100   800   600])

handle_list = findall(gcf);
object_handles = findall(handle_list,'FontSize',10);
set(object_handles,'FontSize',fs);

object_handles = findall(handle_list,'Type','Axes');

handle_list = findall(object_handles,'MarkerSize',6);
set(handle_list,'MarkerSize',ms);

handle_list = findall(object_handles,'LineWidth',0.5);
set(handle_list,'LineWidth',lw);

set(gcf,'Color',[1 1 1])

% object_handles = findall(handle_list,'LineWidth',0)
% set(object_handles,'LineWidth',2)

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% assume your style sheet's name is <foo.txt>
% create a fig
%      plot(1:10);
%      fnam='your_fig.eps'; % your file name
% the engine
% ...get style sheet info
%      snam='foo'; % note: NO extension...
%      s=hgexport('readstyle',snam);
% ...apply style sheet info
%      hgexport(gcf,fnam,s);
