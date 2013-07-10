function [ p ] = crewcdf_struct()
%CREWCDF_STRUCT Returns the dummy common data format structure
%
% p = common data format structure
% p.Name        = Unique identifier of the sensing device
% p.Location    = Location of the sensing device (m) e.g [x,y,z]
% p.CenterFreq  = Array defining center frequencies 
%                   of the columns of power the matrix (Hz)
% p.BW          = Bandwidth around each center frequency (Hz)
% p.Tstart      = Start time of the measurement in datestr format
%                   e.g. '24-Jan-2003 11:58:15'
% p.SampleTime  = Timestamp relative to Tstart (s)
% p.Power       = Matrix containing power measurements (dBm)
%                   row contains all frequencies for one timestamp
%
%   See also CREWCDF_WISPY, CREWCDF_TELOS, CREWCDF_IMEC

%   CREW 2011

p = struct( ...                         
    'Name'       , '', ...  
    'Location'   , [0, 0, 0], ...   
    'CenterFreq' , [] , ...
    'BW'         , 0 ,  ...  
    'Tstart'     , '01-Jan-0000 00:00:01', ...
    'SampleTime' , [], ...   
    'Power'      , [] );
end