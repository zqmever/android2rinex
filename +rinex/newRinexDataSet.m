function rinex_dataset = newRinexDataSet(rinex_version)

    switch floor(rinex_version)
        case 2
            rinex_dataset = rinex.RinexDataSet2x(rinex_version);
        case 3
            rinex_dataset = rinex.RinexDataSet3x(rinex_version);
        otherwise
            rinex_version_default = 3.04;
            rinex_dataset = rinex.RinexDataSet3x(rinex_version_default);
            
            warning('Unsupported RINEX version: %.2f, RINEX %.2f is used. ', rinex_version, rinex_version_default);
    end
end
