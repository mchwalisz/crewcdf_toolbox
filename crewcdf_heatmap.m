function varargout = crewcdf_heatmap(p, varargin)
%CREWCDF_HEATMAP Display heat map spectrogram of common data format object


iP = inputParser;   % Create an instance of the class.
iP.addRequired('p', @(x)(sum(isfield(x, fieldnames(crewcdf_struct()))) ...
    ==length(fieldnames(crewcdf_struct()))));
iP.addParamValue('FontSize', 10);
iP.addParamValue('Title', '');
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
nbins = ceil(abs(min(p.Power(:))-max(p.Power(:))))*3;
[histogram, dBmbins] = hist(p.Power,nbins);

h = imagesc(p.CenterFreq/xdenom, dBmbins, histogram, ...
    [0 max(quantile(histogram(histogram~=0),0.99))]);
set(gca,'YDir','normal')
cmap = jet(nbins);
cmap(1,:) = 1;
% cmap(2,:) = 0;
colormap(cmap)

xlabel(xlabeltxt);
ylabel('Signal Power (dBm)');
% colorbar;
set(findall(h, 'Type','text'), 'FontSize', options.FontSize);
if isempty(options.Title)
    title(p.Name,'FontSize',options.FontSize+1,'Interpreter','none');
else
    title(options.Title,'FontSize',options.FontSize+1,'Interpreter','none');
end


switch nargout
    case 1
        varargout{1} = h;
    otherwise
end
end
