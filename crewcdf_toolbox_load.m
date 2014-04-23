%CREWCDF_TOOLBOX_LOAD CREW Common Data Format toolbox, set paths
%
%   To make change permanent use savepath function
%

%   Mikolaj Chwalisz for CREW

% Find toolbox directories
crewcdf_inst_filepath = [mfilename('fullpath') '.m'];
[crewcdf_inst_pathstr, crewcdf_inst_name, crewcdf_inst_ext] = ...
    fileparts(crewcdf_inst_filepath);

% Add directories to path
addpath(genpath(crewcdf_inst_pathstr));
addpath(genpath([crewcdf_inst_pathstr filesep 'tools']));
addpath(genpath([crewcdf_inst_pathstr filesep 'tools' filesep 'cmapbar']));

% Display and clean
disp(['Added crewcdf_toolbox from ' crewcdf_inst_pathstr]);
clear('-regexp','crewcdf_inst_*');
