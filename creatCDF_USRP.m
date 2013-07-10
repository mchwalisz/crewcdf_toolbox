% script to convert USRP sensing output to CREW common data format 
% Liu Wei Sep 2011

function creatStructUSRP(number, par_tstart, par_loc,Filename,device);


%%% create the parameter struct
NFFT = 520;
% default parameters
par_fc =  [2400000000+(0.5*100000000/NFFT) : 100000000/NFFT :  2500000000]; % frequency bin array
par_bw = 100000000/NFFT; %BW in Hz
par_cal = 0; % callibration offset in dB
%% read data 
M = csvread(Filename);
par_power = M(:,2:(NFFT+1))-par_cal;
time = M(:,1);

% struct with default info, depends on the hardware/location
p = struct(  ...                        
    'Name'          , device, ...      % unique identifier of the sensing device 
    'Location'      , par_loc, ...          % [x,y,z] in (m) 
    'CenterFreq'    , par_fc , ...          % array defining center frequencies of the rows of power the matrix (Hz)
    'BW'            , par_bw,  ...          % bandwidth arond each center frequency (Hz)
    'Tstart'        , par_tstart, ...       % start time of the measurement in datestr format e.g. '24-Jan-2003 11:58:15'
    'SampleTime'    , time, ...             % timestamp relattive to Tstart (s)
    'Power'         , par_power  ...        % Matrix containing power measurements (dBm) row contains for one timestamp for all frequencies
);

FileName=['measurements/' device '_' number  '.mat'];
FigureName = ['figures/' device '_' number ];
save(FileName,'p');
h = imagesc(time,par_fc,par_power');
colorbar('EastOutside');
saveas (h,FigureName,'png');






