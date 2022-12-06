classdef Status
    properties (Constant)
        UnixTimeMillis     = '%d64';
        SignalCount        = '%d';
        SignalIndex        = '%d';
        ConstellationType  = '%d';
        Svid               = '%d';
        CarrierFrequencyHz = '%f';
        Cn0DbHz            = '%f';
        AzimuthDegrees     = '%f';
        ElevationDegrees   = '%f';
        UsedInFix          = '%d';
        HasAlmanacData     = '%d';
        HasEphemerisData   = '%d';
        BasebandCn0DbHz    = '%f';
    end
end
