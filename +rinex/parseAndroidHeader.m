function rinex_dataset = parseAndroidHeader(rinex_dataset, android_dataset)

    rinex_dataset.header.run_by = strcat(android_dataset.info.manufacturer, " ", android_dataset.info.model);
    rinex_dataset.header.receiver_version = android_dataset.info.version;
end