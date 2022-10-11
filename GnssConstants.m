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

        BDSTIMEOFFSETSEC = 14;
        BDSTIMEOFFSETSECNANOS = int64(GnssConstants.BDSTIMEOFFSETSEC * 1e9);
    end

    properties (Constant)
        % constellation code
        UNK = 0;
        GPS = 1;
        SBA = 2;
        GLO = 3;
        QZS = 4;
        BDS = 5;
        GAL = 6;
        IRN = 7;
    end
end
