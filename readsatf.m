function [struct, freq, level] = readsatf(filename, varargin)
% READSATF - reads spectrum analyzer trace file.
%            Rohde&Schwarz and Agilent (partially) supported.
%
%    [struct] = readsatf(filename)
%    [struct] = readsatf(filename, PropertyName, PropertyValue,...)
%    [struct, freq, level] = readsatf(filename,...)
%
%       The filename is name of file to read.
%       The PropertyName and PropertyValue sets properties
%           to the specified property values.
%           Property list:
%           'FileType'  defines type of file.
%                       'rs'    Rohde&Schwarz .DAT file (default)
%                       'ag'    Agilent SA .TRC file
%                       'raw'   raw two column ASCII file with
%                               freq & level pair on each line
%           'Delimiter' defines a delimiter string. A semicolon (;) is
%                       the default delimiter. Use '\t' to specify
%                       a tab delimiter.
%
%       The struct is structure with spectrum capture informations.
%       The freq is frequency vector.
%       The level is power level vector.
%
%     Examples:
%       [s, f, l] = readsatf('spectrum00.dat')
%       [s, f, l] = readsatf('spectrum01.dat', 'FileType', 'rs', 'Delimiter', ';')
%       [s, f, l] = readsatf('ag00.trc', 'FileType', 'ag');
%       [s, f, l] = readsatf('spectrum02.csv', 'FileType', 'raw', 'Delimiter', ',')
%       (See result by plot(f,l))
%       

% Copyright (c) 2008-2011 Stepan Matejka
% $Revision: 1.10 $  $Date: 2011/10/11 $
% $Revision: 1.02 $  $Date: 2009/02/06 $
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% check input/output arguments

if nargin == 0, help readsatf; return; end
error(nargoutchk(0,3,nargout))
if mod(length(varargin),2)
    error('Bad property specification.');
end
struct = [];
filetype = 'rs';
delimiter = ';';
for idx = 1:length(varargin)/2
    switch lower(char(varargin(2*idx - 1)))
        case 'filetype'
            filetype = char(varargin(2*idx));
        case 'delimiter'
            delimiter = char(varargin(2*idx));
        otherwise
            error('Unsupported property.');
    end
end

% -------------------------------------------------------------------------
% read data from file

file = textread(filename,'%s','delimiter','\n','whitespace','');
struct.exFileName = filename;
struct.exFileCont = file;

% 'raw' -------------------------------------------------------------------
% raw two column ASCII file with freq & level pair on each line

if strcmpi(filetype,'raw')
    data = dlmread(filename,delimiter);
    struct.Type = 'RAW';
    freq = data(:,1);
    level = data(:,2);
    struct.exFreq = freq;
    struct.exLevel = level;
    return
end

% 'ag' --------------------------------------------------------------------
% Agilent SA .TRC file

if strcmpi(filetype,'ag')
    index = 0;
    % preallocating
    freq = zeros(1, 1000);
    level = zeros(1, 1000);
    for line = 1:length(file)
        % parse line
        item = char(file(line));
        if (item(1) == '#')
            % parameter
            item(1) = ' ';
            item = strread(item, '%s', 'delimiter', '=');
            switch lower(char(item(1)))
                case 'xnum'
                    struct.XNum = str2double(item(2));
                case 'xrightlabel'
                    struct.XRightLabel = char(item(2));
                case 'xstart'
                    struct.XStart = strs2double(item(2));
                case 'xscale'
                    struct.XScale = strs2double(item(2));
                case 'xunit'
                    struct.XUnit = char(item(2));
                case 'znum'
                    struct.ZNum = str2double(item(2));
                case 'ystart'
                    struct.YStart = str2double(item(2));
                case 'xleftlabel'
                    struct.XLeftLabel = char(item(2));
                case 'updateareas'
                    struct.UpdateAreas = str2double(item(2));
                case 'yunit'
                    struct.YUnit = char(item(2));
                case 'zunit'
                    struct.ZUnit = char(item(2));
                case 'nbw'
                    struct.NBW = strs2double(item(2));
                case 'ymiddleunit'
                    struct.XMiddleUnit = char(item(2));
                case 'yscale'
                    struct.YScale = str2double(item(2));
                case 'updateposition'
                    struct.UpdatePosition = str2double(item(2));
                otherwise
                    error('Unknown parameter.\nLine %d: %s', line, char(file(line)));
            end
        else
            % power level
            % dataline: "double,0"
            % is item(1) a number?
            value = str2double(item);
            if isempty(value)
                error('Not a number.\nLine %d: %s', line, char(file(line)));
            end
            index = index + 1;
            freq(index) = struct.XStart + (index-1)*struct.XScale/struct.XNum;
            level(index) = value;
        end
    end
    % cut freq and level
    if (index > 0)
        freq = freq(1:index);
        level = level(1:index);
        struct.exFreq = freq;
        struct.exLevel = level;
    end
    return
end

% 'rs' --------------------------------------------------------------------
% Rohde&Schwarz .DAT file

index = 0;
% preallocating
freq = zeros(1, 1000);
level = zeros(1, 1000);
for line = 1:length(file)
    % parse line
    item = strread(char(file(line)), '%s', 'delimiter', delimiter);
    switch lower(char(item(1)))
        case 'type'
            struct.Type = char(item(2));
        case 'version'
            struct.Version = char(item(2));
        case 'date'
            struct.Date = char(item(2));
        case 'mode'
            struct.Mode = char(item(2));
        case 'center freq'
            [struct.CenterFreqVal struct.CenterFreqUnit] = getvalunit(item);
        case 'freq offset'
            [struct.FreqOffsetVal struct.FreqOffsetUnit] = getvalunit(item);
        case 'span'
            [struct.SpanVal struct.SpanUnit] = getvalunit(item);
        case 'x-axis'
            struct.xAxis = char(item(2));
        case 'start'
            [struct.StartVal struct.StartUnit] = getvalunit(item);
        case 'stop'
            [struct.StopVal struct.StopUnit] = getvalunit(item);
        case 'ref level'
            [struct.RefLevelVal struct.RefLevelUnit] = getvalunit(item);
        case 'level offset'
            [struct.RefLevelVal struct.RefLevelUnit] = getvalunit(item);
        case 'ref position'
            [struct.RefPositionVal struct.RefPositionUnit] = getvalunit(item);
        case 'y-axis'
            struct.yAxis = char(item(2));
        case 'level range'
            [struct.LevelRangeVal struct.LevelRangeUnit] = getvalunit(item);
        case 'rf att'
            [struct.RFAttVal struct.RFAttUnit] = getvalunit(item);
        case 'el att'
            [struct.ElAttVal struct.ElAttUnit] = getvalunit(item);
        case 'rbw'
            [struct.RBWVal struct.RBWUnit] = getvalunit(item);
        case 'vbw'
            [struct.VBWVal struct.VBWUnit] = getvalunit(item);
        case 'swt'
            [struct.SWTVal struct.SWTUnit] = getvalunit(item);
        case 'trace mode'
            struct.TraceMode = char(item(2));
        case 'detector'
            struct.Detector = char(item(2));
        case 'sweep count'
            struct.SweepCount = str2double(char(item(2)));
        case 'trace 1:'
            struct.Trace1 = char(item(2));
        case 'trace 2:'
            struct.Trace2 = char(item(2));
        case 'trace 3:'
            struct.Trace3 = char(item(2));
        case 'trace 4:'
            struct.Trace4 = char(item(2));
        case 'trace 5:'
            struct.Trace5 = char(item(2));
        case 'trace 6:'
            struct.Trace6 = char(item(2));
        case 'trace 7:'
            struct.Trace7 = char(item(2));
        case 'trace 8:'
            struct.Trace8 = char(item(2));
        case 'trace 9:'
            struct.Trace9 = char(item(2));
        case 'trace 10:'
            struct.Trace10 = char(item(2));
        case 'x-unit'
            struct.xUnit = char(item(2));
        case 'y-unit'
            struct.yUnit = char(item(2));
        case 'values'
            struct.Values = str2double(char(item(2)));
        otherwise
            % dataline: "double; double;"
            % is item(1) a number?
            value1 = str2double(char(item(1)));
            if isempty(value1)
                error('Unknown tag or not a number.\nLine %d: %s',...
                      line, char(file(line)));
            end
            value2 = str2double(char(item(2)));
            if isempty(value2)
                error('Not a number.\nLine %d: %s', line, char(file(line)));
            end
            index = index + 1;
            freq(index) = value1;
            level(index) = value2;
    end
end
% cut freq and level
if (index > 0)
    freq = freq(1:index);
    level = level(1:index);
    struct.exFreq = freq;
    struct.exLevel = level;
end
return

% -------------------------------------------------------------------------
% strip value and unit form item array

function [val, unit] = getvalunit(item)
val = str2double(char(item(2)));
unit = char(item(3));

% -------------------------------------------------------------------------
% convert char ary (number with suffix) to number
function retval = strs2double(item)
item = char(item);
mul = 1;
if item(end) == 'k'
    mul = 1e3;
    item(end) = ' ';
end
if item(end) == 'M'
    mul = 1e6;
    item(end) = ' ';
end
retval = mul*str2double(item);

% -------------------------------------------------------------------------
% end of file
