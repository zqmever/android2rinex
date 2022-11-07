function gnss_dataset = parse_raw_data(fileID, gnss_dataset)
    % read body data
    raw_data = textscan(fileID, '%[^,]%*[,]%[^\n]', 'CommentStyle', '#');

    % parse the body data
    for i = 1:length(gnss_dataset.data)
        gnss_dataset.data(i) = android.fill_data_frame(gnss_dataset.data(i), raw_data);
    end
end