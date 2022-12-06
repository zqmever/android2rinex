function gnss_dataset = parseRawData(fileID, gnss_dataset)
    % read body data
    raw_data = textscan(fileID, '%[^,]%*[,]%[^\n]', 'CommentStyle', '#');

    % parse the body data
    for i = 1:length(gnss_dataset.data)
        gnss_dataset.data(i) = android.fillDataFrame(gnss_dataset.data(i), raw_data);
    end
end