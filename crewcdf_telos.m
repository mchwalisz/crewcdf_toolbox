function [ p ] = crewcdf_telos(fileName, varargin)
%CREWCDF_TELOS Loads Telos measurement source file into common data format
%
%   TODO: Add more help
%
%   See also CREWCDF_STRUCT, CREWCDF_WISPY, CREWCDF_IMEC

%   Mikolaj Chwalisz for CREW

%
iP = inputParser;
iP.addRequired('fileName', @ischar);
iP.addParamValue('Name','');
iP.addParamValue('Location',[0, 0, 0]);
iP.parse(fileName, varargin{:});
options = iP.Results;
if isempty(options.Name)
    [ path, options.Name] = fileparts(fileName);
    options.Name = strrep(options.Name, '-', '');
end
% Import data from fileName (ignore 4 first lines)
raw_data = importdata(fileName, ' ')';

% Strip additional info
[ CenterFreq, BW ] = crewcdf_telos_getFrequency( raw_data.textdata(3));
[ Tstart, SampleTime ] = crewcdf_wispy_timeToRelative( raw_data.data(:,1)');
% Get power
Power = raw_data.data;
Power(:,1) = [];

p = struct( ...
    'Name'       , options.Name, ...
    'Location'   , options.Location, ...
    'CenterFreq' , CenterFreq , ...
    'BW'         , BW ,  ...
    'Tstart'     , Tstart, ...
    'SampleTime' , SampleTime, ...
    'Power'      , Power );
end

function [ CenterFreqVec, BW ] = crewcdf_telos_getFrequency( frequencyStr )
%CREWCDF_TELOS_GETFREQUENCY Convert frequency information from telos source
%file

freq = regexp(frequencyStr,'[,:]','split'); % Get freq from header
freq = str2double(freq{1,1}); % Convert to double
freq(1) = []; % Delete description text
% Get freq
CenterFreqVec = freq*1e6;
% Set BW (2MHz Zigbee channel, unchangeable)
BW = 2e6;
end

function [ Tstart, SampleTime ] = crewcdf_wispy_timeToRelative( rawTime )
%CREWCDF_WISPY_TIMETORELATIVE Convert telos time format to relative time
%   Based on the input from Telos source file format creates the relative
%   time vector. The starting point is marked 'tStart' and 'tVector'
%   represents time vector of sweeps (in seconds with us accuracy)

unixnum = datenum([1970 01 01 00 00 00]);
tStartnum = addtodate(unixnum, ...
    floor(rawTime(1,1)), 'second');
Tstart = datestr(tStartnum);
SampleTime = rawTime-floor(rawTime(1));
end