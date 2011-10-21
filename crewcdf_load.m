function [ p ] = crewcdf_load(fileName, varargin)
%CREWCDF_LOAD Loads the device source file to the common data format.
%   CREWCDF_LOAD(fileName)  Tries to guess the device type from filename.
%
%   CREWCDF_LOAD(fileName, DevType) Converts data according to DevType
%   device
%
%   CREWCDF_LOAD(fileName, DevType, varargin) or
%   CREWCDF_LOAD(fileName, varargin) passes the varargin argument to the
%   device specyfic loading fuction
%
%   TODO: add documentation
%
%   See also CREWCDF_STRUCT, CREWCDF_WISPY, CREWCDF_TELOS, CREWCDF_IMEC

% Mikolaj Chwalisz for CREW

DevList = {'wispy','telos','imec'};

iP = inputParser;   % Create an instance of the class.
iP.addRequired('fileName', @ischar);
iP.addOptional('DevType','', ...
    @(x)any(strcmpi(x,DevList)));
iP.parse(fileName, varargin{:});
options = iP.Results;

if isempty(options.DevType)
    for ii=1:length(DevList)
        if ~isempty(strfind(lower(fileName),DevList{ii}))
            options.DevType = DevList{ii};
            break;
        end
    end
else
    varargin(1) = [];
end

switch options.DevType
    case 'wispy'
        p = crewcdf_wispy(fileName, varargin{:});
    case 'telos'
        p = crewcdf_telos(fileName, varargin{:});
    otherwise
        error('CrewCdf:UnknownDevice','Unknown device type');
end

end