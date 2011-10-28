function [ p ] = crewcdf_wispy(fileName, varargin)
%CREWCDF_WISPY Loads WiSpy measurement source file into common data format
%
%   TODO: Add more help
%
%   See also CREWCDF_STRUCT, CREWCDF_TELOS, CREWCDF_IMEC

%   Mikolaj Chwalisz for CREW in Sept 2011

iP = inputParser;
iP.addRequired('fileName', @ischar);
iP.addParamValue('Name','');
iP.addParamValue('Location',[0, 0, 0]);
iP.parse(fileName, varargin{:});
options = iP.Results;
if isempty(options.Name)
    [ path, options.Name] = fileparts(fileName);
end
% Import data from fileName (ignore 4 first lines)
raw_data = importdata(fileName, ' ',4);

% Strip additional info
[ CenterFreqVec, BW ]   = crewcdf_wispy_getFrequency( ...
    raw_data.textdata(4));
[ Tstart, SampleTime ] = crewcdf_wispy_timeToRelative( ...
    raw_data.data(:,1:4)');
% Get power
Power = raw_data.data;
Power(:,1:4) = [];
% Remove NaN
nans = isnan(Power);
nanrows = sum(nans,2);
Power = Power(nanrows==0,:);
SampleTime = SampleTime(nanrows==0);
p = struct( ...
    'Name'       , options.Name,...
    'Location'   , options.Location, ...
    'CenterFreq' , CenterFreqVec , ...
    'BW'         , BW ,  ...
    'Tstart'     , Tstart, ...
    'SampleTime' , SampleTime, ...
    'Power'      , Power );
end

function [ CenterFreqVec, BW ] = crewcdf_wispy_getFrequency( frequencyStr )
%CREWCDF_WISPY_GETFREQUENCY Convert frequency information from wispy source
%file

fc_txt = frequencyStr;
fc_txt = fc_txt{1};
if fc_txt(1) == '#' %Provide backwards compatibility
    fc_data = sscanf(fc_txt,'#    %dMHz-%dMHz @ %fKHz, %d samples');
else
    fc_data = sscanf(fc_txt,'%dMHz-%dMHz @ %fKHz, %d samples');
end
% Get freq
CenterFreqVec = linspace(fc_data(1)*1e6, fc_data(2)*1e6, fc_data(4));
% Get BW
BW = fc_data(3)*1e3; %BW in Hz
end

function [ Tstart, SampleTime ] = crewcdf_wispy_timeToRelative( rawTime )
%CREWCDF_WISPY_TIMETORELATIVE Convert wispy time format to relative time
%   Based on the input from Wispy source file format creates the relative
%   time vector. The starting point is marked 'tStart' and 'tVector' 
%   represents time vector of sweeps (in seconds with us accuracy)
%
%   Mikolaj Chwalisz for CREW in Sept 2011

unixnum = datenum([1970 01 01 00 00 00]);
Tstartnum = addtodate(unixnum, rawTime(1,1), 'second');
Tstart = datestr(Tstartnum);
SampleTime = rawTime(1,:)-rawTime(1,1)+rawTime(2,:)*1e-6;
end
