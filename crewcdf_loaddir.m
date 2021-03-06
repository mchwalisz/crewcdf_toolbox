function [ p , pFileName ] = crewcdf_loaddir(dirNames)
%CREWCDF_LOADDIR Loads all files from dirNames directories.
%   CREWCDF_LOAD(dirNames)  Tries to load all files in diven directories.
%
%   TODO: add documentation
%
%   See also CREWCDF_LOAD, CREWCDF_STRUCT

% Mikolaj Chwalisz for CREW

pAll{1} = 0;
pFileName{1} = '';
for ii=1:length(dirNames)
    files = dir([dirNames{ii} filesep '*']);
    pdir = cell(size(files,1),1);
    pFileNamedir = cell(size(files,1),1);
    errno = 0;
    for i2=1:size(files,1)
        fileName = files(i2).name;
        disp(fileName)
        try
            p = crewcdf_load([dirNames{ii} filesep fileName]);
            pdir{i2-errno} = p;
            pFileNamedir{i2 - errno} = fileName;
        catch ME
            pdir(i2-errno) = [];
            pFileNamedir(i2 - errno) = [];
            errno = errno + 1;
            clear ME;
        end
    end
    pAll = {pAll{:}, pdir{:}};
    pFileName = {pFileName{:}, pFileNamedir{:}};
end
pAll(1) = [];
pFileName(1) = [];
pFileName = pFileName';
p = pAll';