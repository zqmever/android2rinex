classdef GnssConstants
    
    properties (Constant)
        LIGHTSPEED = 299792458;
    end

    properties (Constant)
        DAYSEC = 24 * 3600;
        DAYSECNANOS = int64(rinex.GnssConstants.DAYSEC * 1e9);

        WEEKSEC = rinex.GnssConstants.DAYSEC * 7;
        WEEKSECNANOS = int64(rinex.GnssConstants.WEEKSEC * 1e9);

        MILLISECNANOS100 = int64(100 * 1e-3 * 1e9);

        GLOTIMEOFFSETSEC = 3 * 3600;
        GLOTIMEOFFSETSECNANOS = int64(rinex.GnssConstants.GLOTIMEOFFSETSEC * 1e9);

        BDSTOGPSTIMESEC = 14;
        BDSTOGPSTIMESECNANOS = int64(rinex.GnssConstants.BDSTOGPSTIMESEC * 1e9);
    end
end
