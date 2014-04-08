function time = crewcdf_plotall( dirname, sizelim, suffix )
%CREWCDF_PLOTALL Make plot for all loadable files in dirname
%
% Example:
%  crewcdf_plotall(['ss_dex_overhead' filesep 'data'], 50e6)
%
% Parameters:
%  |dirname| - Folder name to crawl [default: '.']
%  |sizelim| - Ignore files larger than this (in bytes) [default: 90e6]
%  |suffix|  - filename suffix [default: 'summary']
%
% Mikolaj Chwalisz <chwaliszATtkn.tu-berlin.de>

tic
if ~exist('dirname','var')
    dirname = '.';
end
if ~exist('sizelim','var')
    sizelim = 90e6;
end
if ~exist('suffix','var')
    suffix = 'summary';
end
list = dir(dirname);
for jj=1:length(list)
    list(jj).dirname = dirname;
end
ii = 0;
while ii<length(list)
    ii=ii+1;
    if strcmpi(list(ii).name,'.') || strcmpi(list(ii).name,'..')
        continue
    end
    if list(ii).isdir
        % disp(['Folder: ' list(ii).name])
        list2 = dir([list(ii).dirname filesep list(ii).name]);
        if isempty(list2)
            continue
        end
        for jj=1:length(list2)
            list2(jj).dirname = [list(ii).dirname filesep list(ii).name];
        end
        list = [list; list2]; %#ok<AGROW>
        continue
    end
    if sizelim > 0 && list(ii).bytes >= sizelim
        continue
    end
    [path, name, ext] = fileparts([list(ii).dirname filesep list(ii).name]);
    % Try to load files with following extensions:
    test = strcmp(ext,{'.txt', '.mat','.sft','.fsv','.bin'});
    if any(test)
        if exist([path filesep name '_' suffix '.png'],'file')
            continue
        end
        try
            close all
            % Load file
            disp(['Reading file: ' path filesep name ext])
            p =  crewcdf_load([path filesep name ext]);
            f = figure;
            subplot(2,1,1);
            crewcdf_plotpers(p);
            freezeColors;
            subplot(2,1,2);
            crewcdf_imagesc(p, 'Title', '');
            crewcdf_savefig(f,[path filesep name '_' suffix],{'png'});
        catch err
            close all
            disp(err.identifier)
        end
    end
end
time = toc;

