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

    % convert the raw data to measurements
    raw_dataframe = android_raw_dataset.getDataFrame('Raw');
    rinex_data = rinex.convertRawToMeas(raw_dataframe);
    
    % fill the measurements
    rinex_dataset.epoch_time      = rinex_data.epoch_time;
    rinex_dataset.constellation   = rinex_data.constellation;
    rinex_dataset.prn             = rinex_data.prn;
    rinex_dataset.pseudorange     = rinex_data.pseudorange;
    rinex_dataset.carrier_phase   = rinex_data.carrier_phase;
    rinex_dataset.doppler         = rinex_data.doppler;
    rinex_dataset.signal_strength = rinex_data.signal_strength;
    rinex_dataset.frequency_band  = rinex_data.frequency_band;
    rinex_dataset.glo_freq_num    = rinex_data.glo_freq_num;
    rinex_dataset.code_type       = rinex_data.code_type;
end
