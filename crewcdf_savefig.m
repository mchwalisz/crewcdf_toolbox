function [] = savefig(f,name)
set(f,...
    'PaperType','A4',...
    'PaperOrientation','landscape', ...
    'PaperPositionMode', 'manual', ...
    'PaperUnits', 'centimeters', ...
    'PaperPosition', [-1 -1 30 21+1] ...
    );
set(f, 'renderer', 'painters');
fax = get(gcf,'CurrentAxes');
set(fax, 'LooseInset', get(fax,'TightInset'))
try
    print(f, [name '.pdf'], '-dpdf')
catch ME
    disp(ME)
end
try
    saveas(f, [name '.fig'],'fig')
catch ME
    disp(ME)
end
set(f, 'PaperOrientation','Portrait');
% set(f, 'PaperPositionMode', 'manual');
% set(f, 'PaperPosition', [0 0 30 21]);
%     'PaperPosition', [-2 -1 30 21+1] ...
%     );
% set(fax, 'Position', get(fax, 'OuterPosition') - ...
%     get(fax, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
print(f, [name '.png'], '-dpng')
end