function [ p ] = crewcdf_rsfsv_bin( fileName, varargin )
%CREWCDF_RSFSV_BIN Loads Rohde & Schwarz trace into crew cdf (.fsv)
%
%   It is possible to load files generated by Rohde & Schwarz
%   .py script
%
%   See also CREWCDF_STRUCT, CREWCDF_WISPY, CREWCDF_IMEC, CREWCDF_TELOS

%   Mikolaj Chwalisz for CREW, COUWBAT

iP = inputParser;
iP.addRequired('fileName', @ischar);
iP.addParamValue('Name','');
iP.addParamValue('Location',[0, 0, 0]);
iP.parse(fileName, varargin{:});
options = iP.Results;
if isempty(options.Name)
    [ ~, options.Name] = fileparts(fileName);
    % options.Name = strrep(options.Name, '-', '');
end

p = struct( ...
    'Name'       , options.Name, ...
    'Location'   , options.Location, ...
    'CenterFreq' , [] , ...
    'BW'         , 0, ...
    'Tstart'     , '01-Jan-1970 00:00:00', ...
    'SampleTime' , [], ...
    'Power'      , [], ...
    'Meta'       , struct());

delimiter = ';';


fileId = fopen(fileName);
fline = fgets(fileId);

while ischar(fline)
    fline = deblank(fline);
    if isempty(fline)
        fline = fgets(fileId);
        continue
    end
    item = strsplit(fline, delimiter);
    name = genvarname(regexprep(char(item(1)),'[^\w]','_'));
    val = str2num(char(item(2))); %#ok<ST2NM>
    if isempty(val)
        p.Meta.(name) = char(item(2));
    else
        p.Meta.(name) = val;
        if length(item) == 3
            p.Meta.([name '_Unit']) = char(item(3));
        end
    end
    if strcmpi(name, 'values')
        % From the next line it is the sample data data
        format = '%s';
        c = textscan(fileId, format, p.Meta.Values, ...
            'delimiter', '\n');
        B = cellfun(@(x) regexp(x,delimiter,'split'),c{1},'uni',false);
        Bout=cell2mat(cellfun(@(x) cellfun(@(y) str2double(y),x), ...
            B,'uni',false));
        p.CenterFreq = Bout(:,1)';
        p.PowerSample = Bout(:,2)';
    end
    if strcmpi(name, 'binary_format')
        % There are binary data behind this poind we need to process them
        position = ftell(fileId);
        % Read data points
        c = fread(fileId, [p.Meta.Values + 2, Inf], 'float32');
        p.Power = c(3:end,:)';
        % Go back and reread time stamps
        fseek(fileId,position,'bof');
        SampleTime = fread(fileId,inf,'double',4*p.Meta.Values);
        % Put starting poind as text
        p.Tstart = datestr(SampleTime(1)/86400+datenum('1/1/1970'));
        tStart_epoch = (datenum(p.Tstart)-datenum(1970,1,1)) * 86400;
        % Store only relative time in the data
        p.SampleTime = SampleTime - tStart_epoch;
        % Calculate BW
        p.BW = (p.Meta.Stop - p.Meta.Start)/ p.Meta.Values;
        break
    end
    fline = fgets(fileId);
end
fclose(fileId);
end

