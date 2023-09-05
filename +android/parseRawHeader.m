function gnss_dataset = parseRawHeader(fileID, gnss_dataset)
    % read and parse raw header
    while ~feof(fileID)
        % get the current line
        this_line = fgetl(fileID);

        % skip short lines
        if strlength(this_line) < 3
            continue;
        end

        % parse the header lines
        if this_line(1) == '#'
            if contains(this_line, ':') && ~contains(this_line, 'Header Description', 'IgnoreCase', true)
                this_header = regexp(this_line, '([A-Z][A-Za-z]+):[ ]*([\w\S]*)', 'tokens');
                for i = 1:length(this_header)
                    gnss_dataset.info.(lower(this_header{i}{1})) = this_header{i}{2};
                end
            elseif contains(this_line, ',')
                raw_cell = textscan(this_line, '%s', 'Delimiter', {',', '#'}, 'MultipleDelimsAsOne', true);
                this_data_frame = android.DataFrame(raw_cell{1}{1});
                this_data_frame.header = raw_cell{1}(2:end);
                gnss_dataset.data(end+1) = this_data_frame;
            end
        else
            break;
        end
    end
end