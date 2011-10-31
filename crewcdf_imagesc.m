function varargout = crewcdf_imagesc(p, varargin)
%CREWCDF_IMAGESC Display spectrogram of common data format object

iP = inputParser;   % Create an instance of the class.
iP.addRequired('p', @(x)(sum(isfield(x, fieldnames(crewcdf_struct()))) ...
    ==length(fieldnames(crewcdf_struct()))));
iP.addParamValue('clims',[]);
iP.addParamValue('tlims',[]);
iP.addParamValue('FontSize', 10);
iP.addParamValue('Title', '');
iP.parse(p, varargin{:});
options = iP.Results;
if isempty(options.clims)
    h = imagesc(p.SampleTime, p.CenterFreq, p.Power');
else
    h = imagesc(p.SampleTime, p.CenterFreq, p.Power', options.clims);
end
if ~isempty(options.tlims)
    xlim(tlims);
end
xlabel(['      Time (s)' '  T_{start}=' p.Tstart]);
ylabel('Frequency (Hz)');
colorbar;
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