function [ p ] = crewcdf_imec(number, par_loc, par_power,time)
%CREWCDF_IMEC Loads imec measurement source file into common data format
%
%   TODO: fill the correct content
%   TODO: Add more help;

% default parameters

% center frequency of each bin 
par_fc = [2.39e9:20e6/128:2.51e9]; 

% start time in human readable format
par_tstart = time(1);

par_bw = 20e6/128; %BW in Hz
par_cal = 0; % callibration offset in dB

% struct with default info, depends on the hardware/location
p = struct( ...                         
    'Name'  , 'imec_sensing_engine',...     % unique identifier of the sensing device 
    'Location'      , par_loc, ...          % [x,y,z] in (m) 
    'CenterFreq'    , par_fc , ...          % array defining center frequencies of the rows of power the matrix (Hz)
    'BW'            , 20e6/128,  ...        % bandwidth arond each center frequency (Hz)
    'Tstart'        , par_tstart, ...       % start time of the measurement in datestr format e.g. '24-Jan-2003 11:58:15'
    'SampleTime'    , time-time(1), ...     % timestamp relattive to Tstart (s)
    'Power'         , par_power ...        % Matrix containing power measurements (dBm) row contains for one timestamp for all frequencies
);

%FileName=['measurements/imec_' int2str(number) '.mat'];
%save(FileName, 'p');
