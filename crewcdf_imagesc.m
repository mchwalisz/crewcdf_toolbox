function varargout = crewcdf_imagesc(p, varargin)
% CREWCDF_IMAGESC Display spectrogram of common data format object
%   CREWCDF_IMAGESC(P) Creates spectrogram of P.Power
%
%   CREWCDF_IMAGESC(P, ..., 'Title', TITLE) Adds own title to the figure;
%   it overwrites the usual P.Name option.
%
%   CREWCDF_IMAGESC(P, ..., 'tlims', TLIMS) Limits spectrogram to the TLIMS
%   range in time.
%
%   CREWCDF_IMAGESC(P, ..., 'clims', CLIMS) Limits spectrogram to the CLIMS
%   range in frequency.
%
%   CREWCDF_IMAGESC(P, ..., 'FontSize', FS) Sets own font size FS for
%   labels and titles.
%
%   See also IMAGE, IMAGESC.
%
% Mikolaj Chwalisz <chwaliszATtkn.tu-berlin.de>

iP = inputParser;   % Create an instance of the class.
iP.addRequired('p', @(x)(sum(isfield(x, fieldnames(crewcdf_struct()))) ...
    ==length(fieldnames(crewcdf_struct()))));
iP.addOptional('clims',[]);
iP.addOptional('tlims',[]);
iP.addOptional('FontSize', 0);
iP.addOptional('Title', 0);
iP.parse(p, varargin{:});
options = iP.Results;
freqcenter = p.CenterFreq(round(length(p.CenterFreq)/2));
if freqcenter < 1e3
    ylabeltxt = 'Frequency (Hz)';
    ydenom = 1;
elseif freqcenter < 1e6
    ylabeltxt = 'Frequency (kHz)';
    ydenom = 1e3;
elseif freqcenter < 1e9
    ylabeltxt = 'Frequency (MHz)';
    ydenom = 1e6;
elseif freqcenter < 1e12
    ylabeltxt = 'Frequency (GHz)';
    ydenom = 1e9;
end
if isempty(options.clims)
    h = imagesc(p.SampleTime, p.CenterFreq/ydenom, p.Power');
else
    h = imagesc(p.SampleTime, p.CenterFreq/ydenom, p.Power', options.clims);
end
if ~isempty(options.tlims)
    xlim(options.tlims);
end
xlabel(['      Time (s)' '  T_{start}=' p.Tstart]);
ylabel(ylabeltxt);
cbar = colorbar;
xlabel(cbar,'Power [dBm]','HorizontalAlignment','Left');
if options.Title == 0
    title(p.Name,'Interpreter','none', 'fontWeight','bold');
else
    if options.Title ~= ''
        title(options.Title,'Interpreter','none', 'fontWeight','bold');
    end
end
% cmap = jet();
cmap = viridis_cm();
colormap(cmap)

if options.FontSize ~= 0
    set(gca,'FontSize', options.FontSize);
    set(findall(gcf,'type','text'),'FontSize', options.FontSize);
end

switch nargout
    case 1
        varargout{1} = h;
    otherwise
end
end
