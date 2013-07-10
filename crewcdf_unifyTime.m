function [ p ] = crewcdf_unifyTime(p, varargin)
%CREWCDF_UNIFYTIME Sets the same Tstart for all p{:} measurements
%
%   TODO: Add more help
%

%   Mikolaj Chwalisz for CREW

iP = inputParser;
iP.addRequired('p');
iP.addOptional('Tstart','',@(x)isdate(x,'dd-mmm-yyyy HH:MM:SS'));
iP.parse(p, varargin{:});
options = iP.Results;
if isempty(options.Tstart)
    apstru = [p{:}]';
    options.Tstart = datestr(min(datenum({apstru.Tstart})));
end

for ii=1:length(p)
    [p{ii}.Tstart, p{ii}.SampleTime ] = TimeConvRel( ...
        options.Tstart, p{ii}.Tstart, p{ii}.SampleTime );
end
end

function result = isdate(dateString,dateformat)
try
    datenum(dateString,dateformat);
    result = true;
catch
    result = false;
end
end

function [ tStart, tVector ] = TimeConvRel( tStartNew, tStartOrg, tVectorOrg )
%TIMECONVREL Convert relative time format to new starting time
%   [ tStart, tVector ] = TimeConvRel( tStartNew, tStartOrg, tVectorOrg )
%
%   Mikolaj Chwalisz for CREW in Sept 2011
tStart = tStartNew;
tDiff = datenum(tStartNew) - datenum(tStartOrg);
tDiffSec = 24*60*60*tDiff;
tVector = tVectorOrg - tDiffSec;
end

