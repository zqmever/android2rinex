function gnss_dataset = readRawFile(gnss_raw_file)
    % check if the file exists
    if ~isfile(gnss_raw_file)
        error('Cannot find the GNSS raw file: %s', gnss_raw_file);
    end

    % generate a new dataset
    gnss_dataset = android.DataSet(gnss_raw_file);

    % read the file
    fid = fopen(gnss_raw_file, 'r');
    %   [1/2] read and parse the header
    gnss_dataset = android.parseRawHeader(fid, gnss_dataset);
    %   [2/2] read and parse the body
    frewind(fid);
    gnss_dataset = android.parseRawData(fid, gnss_dataset);
    fclose(fid);
end
