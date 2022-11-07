function gnss_dataset = read_raw_file(gnss_raw_file, gnss_dataset)
    % check if the file exists
    if ~isfile(gnss_raw_file)
        error('Cannot find the GNSS raw file: %s', gnss_raw_file);
    end

    if nargin < 2
        % generate a new dataset
        gnss_dataset = android.DataSet();
    end

    % read the file
    fid = fopen(gnss_raw_file, 'r');
    %   [1/2] read and parse the header
    gnss_dataset = android.parse_raw_header(fid, gnss_dataset);
    %   [2/2] read and parse the body
    frewind(fid);
    gnss_dataset = android.parse_raw_data(fid, gnss_dataset);
    fclose(fid);
end
