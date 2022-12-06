function rinex_dataset = convertAndroidToRinex(android_raw_dataset, rinex_dataset)

    if nargin < 2 || isempty(rinex_dataset)
        rinex_version = 3.04;
        fprintf('RINEX version is not specified. \n');
        fprintf('RINEX %.2f will be used. \n', rinex_version);
        rinex_dataset = rinex.newRinexDataSet(rinex_version);
    end

    % parse the header
    rinex_dataset.header.run_by = strcat(android_raw_dataset.info.manufacturer, " ", android_raw_dataset.info.model);
    rinex_dataset.header.receiver_version = android_raw_dataset.info.version;

    % fill the measurements
    raw_dataframe = android_raw_dataset.getDataFrame('Raw');
    rinex_dataset = rinex.convertRawToMeas(raw_dataframe, rinex_dataset);
end
