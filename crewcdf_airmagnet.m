% script to create dummy measurements
% Sofie Pollin for CREW in Sept 2011
% NOT FULLY FUNCTIONAL

function createStructAirmagnet(number, par_tstart,par_loc,Filename);



% default parameters
par_fc =  [2402000000+(0.5*92032000/590) : 90032000/590 :  2494032000]; % frequency bin array
par_bw = 92032000/590; %BW per bin in Hz
par_cal = 0; % callibration offset in dBm



%%% create the result matrix in dB (log scale)
%for i = 1:length(par_fc);
%    r(i, :) = (par_power - (par_beta + 10*par_alpha * log(sqrt(sum(par_loc.^2 - par_loc_source.^2))))) .* ones(1,p.NbMeasurements) + par_noise .* randn(1,p.NbMeasurements);
%end;

%% plug in measurement result
M = csvread(Filename, 1, 4);
par_power = M(:,591:1180);
time = csvread(Filename, 1, 0);
time = time(:,1);
time = time - time(1);

% struct with default info, depends on the hardware/location
p = struct(  ...                        
    'Name'          , 'Airmagnet', ...       % unique identifier of the sensing device 
    'Location'      , par_loc, ...          % [x,y,z] in (m) 
    'CenterFreq'    , par_fc , ...          % array defining center frequencies of the rows of power the matrix (Hz)
    'BW'            , par_bw,  ...        % bandwidth arond each center frequency (Hz)
    'Tstart'        , par_tstart, ...       % start time of the measurement in datestr format e.g. '24-Jan-2003 11:58:15'
    'SampleTime'    , time-time(1), ...     % timestamp relattive to Tstart (s)
    'Power'         , par_power  ...        % Matrix containing power measurements (dBm) row contains for one timestamp for all frequencies
);

%FileName=[ Filename(1:13) '.mat'];
save('testmichael', 'p');
% FigureName = ['figures/' Filename(1:13) ];
% h = imagesc(par_fc,time,par_power);
% colorbar('EastOutside');
% xlabel('freq / Hz');
% ylabel('time / s');
% saveas (h,FigureName,'png');







