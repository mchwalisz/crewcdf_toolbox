function [ result, PdBm ] = crewcdf_integratePSD(p, varargin)
%CREWCDF_INTEGRATEPSD Calculates the power in certain frequency band
%   CREWCDF_INTEGRATEPSD(p) power over whole band
%
%   CREWCDF_INTEGRATEPSD(p,[fStart, fEnd]) power over frequency range
%   TODO: Add more help
%

%   Mikolaj Chwalisz for CREW

iP = inputParser;
iP.addRequired('p');
iP.addOptional('Freq',[0 0]);
iP.parse(p, varargin{:});
options = iP.Results;
if isempty(options.Freq)
    options.Freq = [p.CenterFreq(1), p.CenterFreq(end)];
end

%Strip p.Power:
% TODO: fix error of BW (take BW into consideration!)
PdBm = p.Power(:, ...
    options.Freq(1) <= p.CenterFreq & ...
    p.CenterFreq <= options.Freq(2));
% Freq = p.CenterFreq(:, ...
%     options.Freq(1) < p.CenterFreq-p.BW/2 & ...
%     p.CenterFreq+p.BW/2 < options.Freq(2))';    
%figure; imagesc(PdBm); title(p.Name,'Interpreter','none');
%Power in mW/bandwidth 
delogR = 10.^(PdBm/10);
%Power in mW for whole channel/bin := P*BW/1mW
PmW = delogR*p.BW/1000;
%Power over selected band (Integral)
pBandmW = sum(delogR,2);

avg = 10*log10(mean(pBandmW));
result = 10*log10(pBandmW);

end

