function gnss_dataset = parse_raw_header(gnss_dataset, raw_line)
    if strlength(raw_line) > 3
        if contains(raw_line, ':') && ~contains(raw_line, 'Header Description', 'IgnoreCase', true)
            this_header = regexp(raw_line, '([A-Z][A-Za-z]+):[ ]*([\w\S]*)', 'tokens');
            for i = 1:length(this_header)
                gnss_dataset.info.(lower(this_header{i}{1})) = this_header{i}{2};
            end
        elseif contains(raw_line, ',')
            gnss_dataset.data(end+1) = android.create_data_frame(raw_line);
        end
    end
end

