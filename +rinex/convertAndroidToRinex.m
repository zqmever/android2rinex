function rinex_dataset = convertAndroidToRinex(android_dataset)
    % create a rinex dataset
    rinex_dataset = rinex.RinexDataset(android_dataset.source_file);

    % parse the header
    rinex_dataset = rinex.parseAndroidHeader(rinex_dataset, android_dataset);

    % parse the measurements
    rinex_dataset = rinex.parseAndroidData(rinex_dataset, android_dataset);
end
