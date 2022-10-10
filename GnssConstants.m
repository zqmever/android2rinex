classdef GnssConstants
    
    properties (Constant)
        LIGHTSPEED = 299792458;

        DAYSEC = 24 * 3600;
        DAYSECNANOS = int64(GnssConstants.DAYSEC * 1e9);

        WEEKSEC = GnssConstants.DAYSEC * 7;
        WEEKSECNANOS = int64(GnssConstants.WEEKSEC * 1e9);

        MILLISECNANOS100 = int64(100 * 1e-3 * 1e9);

        GLOTIMEOFFSETSEC = 3 * 3600;
        GLOTIMEOFFSETSECNANOS = int64(GnssConstants.GLOTIMEOFFSETSEC * 1e9);

        GPS = 1;
        GLO = 3;
        GAL = 6;
        BDS = 5;
        UNK = 9;
    end
end
