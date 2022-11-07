function gnss_dataset = read_raw_file(gnss_raw_file)
    if ~isfile(gnss_raw_file)
        error('Cannot find the GNSS raw file: %s', gnss_raw_file);
    end

    gnss_dataset = android.DataSet();

    fid = fopen(gnss_raw_file, 'r');
    while ~feof(fid)
        this_line = fgetl(fid);
        if strlength(this_line) > 3
            if this_line(1) == '#'
                if contains(this_line, ':') && ~contains(this_line, 'Header Description', 'IgnoreCase', true)
                    this_header = regexp(this_line, '([A-Z][A-Za-z]+):[ ]*([\w\S]*)', 'tokens');
                    for i = 1:length(this_header)
                        gnss_dataset.info.(lower(this_header{i}{1})) = this_header{i}{2};
                    end
                elseif contains(this_line, ',')
                    gnss_dataset.data(end+1) = android.create_data_frame(this_line);
                end
            else
                break;
            end
        end
    end
    frewind(fid);
    raw_data = textscan(fid, '%[^,]%*[,]%[^\n]', 'CommentStyle', '#');
    fclose(fid);

    for i = 1:length(gnss_dataset.data)
        gnss_dataset.data(i) = android.fill_data_frame(gnss_dataset.data(i), raw_data);
    end
end