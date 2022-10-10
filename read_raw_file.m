function gnss_raw = read_raw_file(gnss_raw_file)

    if ~isfile(gnss_raw_file)
        error(sprintf('Cannot find the GNSS raw file: %s', gnss_raw_file));
    end

    gnss_raw = get_empty_gnss_raw();
    fid = fopen(gnss_raw_file, 'r');
    while ~feof(fid)
        this_line = fgetl(fid);
        if strlength(this_line) > 0
            if this_line(1) == '#'
                gnss_raw = parse_raw_header(gnss_raw, this_line);
            else
                break;
            end
        end
    end
    frewind(fid);
    raw_data = textscan(fid, '%[^,]%*[,]%[^\n]', 'CommentStyle', '#');
    fclose(fid);

    all_headers = {'Raw', 'Status', 'Fix'};
    for i = 1:length(all_headers)
        this_label = all_headers{i};
        this_raw_index = strcmp(raw_data{1}, this_label);

        if any(this_raw_index)
            this_raw = raw_data{2}(this_raw_index);
            this_formatspec = '';
            for j = 1:length(gnss_raw.header.(this_label))
                this_formatspec = [this_formatspec, FormatSpec.(gnss_raw.header.(this_label){j}).value];
            end
            this_raw_cell = cell(size(this_raw, 1), length(gnss_raw.header.(this_label)));
            for j = 1:size(this_raw, 1)
                this_raw_cell(j,:) = textscan(this_raw{j}, this_formatspec, 'Delimiter', ',');
            end
            gnss_raw.header.Raw{end} = '(tt)';
            gnss_raw.(this_label) = cell2table(this_raw_cell, 'VariableNames', gnss_raw.header.(this_label));
        else
            gnss_raw.(this_label) = table.empty;
        end
    end

%     all_headers = fieldnames(gnss_raw.header);
%     for i = 1:size(all_headers, 1)
%         this_label = all_headers{i};
%         this_raw_index = strcmp(raw_data{1}, this_label);
%         if any(this_raw_index)
%             this_raw = split(raw_data{2}(this_raw_index), ',');
%             gnss_raw.(this_label) = cell2struct(this_raw, gnss_raw.header.(this_label), 2);
%         else
%             gnss_raw.(this_label) = struct.empty(0, 1);
%         end
%     end
end

function gnss_raw = parse_raw_header(gnss_raw, raw_line)
    if strlength(raw_line) > 3
        if contains(raw_line, ':') && ~contains(raw_line, 'Header Description','IgnoreCase',true)
            this_header = regexp(raw_line, '([A-Z][A-Za-z]+):[ ]*([\w\S]*)', 'tokens');
            for i = 1:length(this_header)
                gnss_raw.(lower(this_header{i}{1})) = this_header{i}{2};
            end
        elseif contains(raw_line, ',')
            raw_cell = textscan(raw_line, '%s', 'Delimiter', {',', '#'}, 'MultipleDelimsAsOne', true);
            raw_cell = raw_cell{1};
            gnss_raw.header.(raw_cell{1}) = raw_cell(2:end);
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
