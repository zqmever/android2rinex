
gnss_raw = get_empty_gnss_raw();

fid = fopen('C:\Users\QM\Documents\MATLAB\android2rinex\tests\gnss_log_2022_10_03_11_27_19.txt','r');
% while ~feof(fid)
for i = 1:10000
    raw_line = fgetl(fid);
    gnss_raw = parse_raw_line(gnss_raw, raw_line);
end
fclose(fid);
gnss_raw

function gnss_raw = read_raw_file1(gnss_raw_file)

    if ~isfile(gnss_raw_file)
        error(sprintf('Cannot find the GNSS raw file: %s', gnss_raw_file));
    end

    gnss_raw = get_empty_gnss_raw();
    fid = fopen(gnss_raw_file, 'r');
    while ~feof(fid) 
        this_line = fgetl(fid);
        gnss_raw = parse_raw_line(gnss_raw, this_line);
    end
    fclose(fid);
end

function gnss_raw = parse_raw_line(gnss_raw, raw_line)

    if strlength(raw_line) == 0
        return;
    end
    
    if raw_line(1) == '#'
        % header
        gnss_raw = parse_raw_header(gnss_raw, raw_line);
    else
        % body
        gnss_raw = parse_raw_body(gnss_raw, raw_line);
    end
end

function gnss_raw = parse_raw_header(gnss_raw, raw_line)
    if strlength(raw_line) > 3
        if contains(raw_line, ':') && ~startsWith(raw_line, '# Header Description:')
            this_header = regexp(raw_line, '([A-Z][A-Za-z]+):[ ]*([\w\S]*)', 'tokens');
            for i = 1:length(this_header)
                gnss_raw.(lower(this_header{i}{1})) = this_header{i}{2};
            end
        elseif contains(raw_line, ',')
            raw_cell = split(raw_line(3:end), ',');
            gnss_raw.header.(raw_cell{1}) = raw_cell(2:end);
        end
    end
end

function gnss_raw = parse_raw_body(gnss_raw, raw_line)
    if strcmp(raw_line(1:3), 'Raw')
        raw_cell = split(raw_line, ',');
        raw_struct = cell2struct(raw_cell(2:end), gnss_raw.header.(raw_cell{1}));
        if ~isfield(gnss_raw, raw_cell{1})
            gnss_raw.(raw_cell{1}) = raw_struct;
        else
            gnss_raw.(raw_cell{1})(end+1,:) = raw_struct;
        end
    end
end

function gnss_raw = get_empty_gnss_raw()
    gnss_raw.version      = 'Unknown';
    gnss_raw.platform     = 'Unknown';
    gnss_raw.manufacturer = 'Unknown';
    gnss_raw.model        = 'Unknown';
    gnss_raw.header       = struct;
end
