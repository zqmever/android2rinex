classdef Raw
    properties (Constant)
        utcTimeMillis                             = '%d64';
        TimeNanos                                 = '%d64';
        LeapSecond                                = '%d';
        TimeUncertaintyNanos                      = '%f';
        FullBiasNanos                             = '%d64';
        BiasNanos                                 = '%f';
        BiasUncertaintyNanos                      = '%f';
        DriftNanosPerSecond                       = '%f';
        DriftUncertaintyNanosPerSecond            = '%f';
        HardwareClockDiscontinuityCount           = '%d';
        Svid                                      = '%d';
        TimeOffsetNanos                           = '%f';
        State                                     = '%d';
        ReceivedSvTimeNanos                       = '%d64';
        ReceivedSvTimeUncertaintyNanos            = '%d';
        Cn0DbHz                                   = '%f';
        PseudorangeRateMetersPerSecond            = '%f';
        PseudorangeRateUncertaintyMetersPerSecond = '%f';
        AccumulatedDeltaRangeState                = '%d';
        AccumulatedDeltaRangeMeters               = '%f';
        AccumulatedDeltaRangeUncertaintyMeters    = '%f';
        CarrierFrequencyHz                        = '%f';
        CarrierCycles                             = '%d64';
        CarrierPhase                              = '%f';
        CarrierPhaseUncertainty                   = '%f';
        MultipathIndicator                        = '%d';
        SnrInDb                                   = '%f';
        ConstellationType                         = '%d';
        AgcDb                                     = '%f';
        BasebandCn0DbHz                           = '%f';
        FullInterSignalBiasNanos                  = '%f';
        FullInterSignalBiasUncertaintyNanos       = '%f';
        SatelliteInterSignalBiasNanos             = '%f';
        SatelliteInterSignalBiasUncertaintyNanos  = '%f';
        CodeType                                  = '%s';
        ChipsetElapsedRealtimeNanos               = '%d64';
    end
end
