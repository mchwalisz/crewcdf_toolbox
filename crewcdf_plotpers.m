function varargout = crewcdf_plotpers(p, varargin)
%CREWCDF_PLOTPERS Display presistence plot of common data format object
%   CREWCDF_PLOTPERS(P) Creates persistence plot of P.Power
%
%   CREWCDF_PLOTPERS(P, ..., 'Title', TITLE) Adds own title to the figure;
%   it overwrites the usual P.Name option.
%
%   CREWCDF_PLOTPERS(P, ..., 'tlims', TLIMS) Limits spectrogram to the
%   TLIMS range in time.
%
%   CREWCDF_PLOTPERS(P, ..., 'FontSize', FS) Sets own font size FS for
%   labels and titles.
%
%   See also CREWCDF_IMAGESC, HIST, IMAGESC.
%
% Mikolaj Chwalisz <chwaliszATtkn.tu-berlin.de>

iP = inputParser;   % Create an instance of the class.
iP.addRequired('p', @(x)(sum(isfield(x, fieldnames(crewcdf_struct()))) ...
    ==length(fieldnames(crewcdf_struct()))));
iP.addOptional('FontSize', 0);
iP.addOptional('Title', 0);
iP.addOptional('tlims', []);
iP.parse(p, varargin{:});
options = iP.Results;
freqcenter = p.CenterFreq(round(length(p.CenterFreq)/2));
if freqcenter < 1e3
    xlabeltxt = 'Frequency (Hz)';
    xdenom = 1;
elseif freqcenter < 1e6
    xlabeltxt = 'Frequency (kHz)';
    xdenom = 1e3;
elseif freqcenter < 1e9
    xlabeltxt = 'Frequency (MHz)';
    xdenom = 1e6;
elseif freqcenter < 1e12
    xlabeltxt = 'Frequency (GHz)';
    xdenom = 1e9;
end
if ~isempty(options.tlims)
    Power =  p.Power(p.SampleTime >= options.tlims(1) & ...
        p.SampleTime <= options.tlims(2), : );
else
    Power = p.Power;
end
%% Actual work

nbins = (abs(floor(min(Power(:)))-ceil(max(Power(:)))))*4+1;
[histogram, bins] = hist(Power,nbins);
zeroindex = all(histogram==0,2);
histogram(zeroindex,:) =[];
bins(zeroindex) = [];
histlog = log10(histogram+1);

h = imagesc(p.CenterFreq/xdenom, bins, histlog); %, ...
%      [0 max(quantile(histlog(histlog~=-Inf),0.999))]);
set(gca,'YDir','normal')
cmap = jet(nbins);
cmap(1,:) = 1;
% cmap(2,:) = 0;
colormap(cmap)


%% Some labeling

xlabel(xlabeltxt);
xlim([p.CenterFreq(1)/xdenom, p.CenterFreq(end)/xdenom]);
ylabel('Signal Power (dBm)');
cbar = colorbar;
ticks = round(linspace(0, ...
    max(max(histogram))*(p.SampleTime(end)-p.SampleTime(1)) ...
    /length(p.SampleTime), 8)*100)/100;

set(cbar,'YTickLabel', ticks);
xlabel(cbar,'\Sigma Time [s]','HorizontalAlignment','Left');

if options.Title == 0
    title(p.Name,'Interpreter','none', 'fontWeight','bold');
else
    if options.Title ~= ''
        title(options.Title,'Interpreter','none', 'fontWeight','bold');
    end
end

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
