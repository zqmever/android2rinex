classdef FormatSpec

    properties
        value;
    end

    enumeration
        % Raw
        utcTimeMillis                             ('%d64')
        TimeNanos                                 ('%d64')
        LeapSecond                                ('%d')
        TimeUncertaintyNanos                      ('%f')
        FullBiasNanos                             ('%d64')
        BiasNanos                                 ('%f')
        BiasUncertaintyNanos                      ('%f')
        DriftNanosPerSecond                       ('%f')
        DriftUncertaintyNanosPerSecond            ('%f')
        HardwareClockDiscontinuityCount           ('%d')
        Svid                                      ('%d')
        TimeOffsetNanos                           ('%f')
        State                                     ('%d')
        ReceivedSvTimeNanos                       ('%d64')
        ReceivedSvTimeUncertaintyNanos            ('%d')
        Cn0DbHz                                   ('%f')
        PseudorangeRateMetersPerSecond            ('%f')
        PseudorangeRateUncertaintyMetersPerSecond ('%f')
        AccumulatedDeltaRangeState                ('%d')
        AccumulatedDeltaRangeMeters               ('%f')
        AccumulatedDeltaRangeUncertaintyMeters    ('%f')
        CarrierFrequencyHz                        ('%f')
        CarrierCycles                             ('%d64')
        CarrierPhase                              ('%f')
        CarrierPhaseUncertainty                   ('%f')
        MultipathIndicator                        ('%d')
        SnrInDb                                   ('%f')
        ConstellationType                         ('%d')
        AgcDb                                     ('%f')
        BasebandCn0DbHz                           ('%f')
        FullInterSignalBiasNanos                  ('%f')
        FullInterSignalBiasUncertaintyNanos       ('%f')
        SatelliteInterSignalBiasNanos             ('%f')
        SatelliteInterSignalBiasUncertaintyNanos  ('%f')
        CodeType                                  ('%s')
        ChipsetElapsedRealtimeNanos               ('%d64')

        % Status
        UnixTimeMillis                            ('%d64')                   
        SignalCount                               ('%d')                
        SignalIndex                               ('%d')                
        % ConstellationType                         ('%d')                        
        % Svid                                      ('%d')           
        % CarrierFrequencyHz                        ('%f')                         
        % Cn0DbHz                                   ('%f')              
        AzimuthDegrees                            ('%f')                   
        ElevationDegrees                          ('%f')                     
        UsedInFix                                 ('%d')              
        HasAlmanacData                            ('%d')                   
        HasEphemerisData                          ('%d')                     
        % BasebandCn0DbHz                           ('%f')                      

        % OrientationDeg
        % utcTimeMillis                             ('%d64')                      
        elapsedRealtimeNanos                      ('%d64')                           
        yawDeg                                    ('%f')             
        rollDeg                                   ('%f')              
        pitchDeg                                  ('%f')               

        % Fix
        Provider                                  ('%s')                
        LatitudeDegrees                           ('%f')                       
        LongitudeDegrees                          ('%f')                        
        AltitudeMeters                            ('%f')                      
        SpeedMps                                  ('%f')                
        AccuracyMeters                            ('%f')                      
        BearingDegrees                            ('%f')                      
        % UnixTimeMillis                            ('%d64')                        
        SpeedAccuracyMps                          ('%f')                        
        BearingAccuracyDegrees                    ('%f')                              
        % elapsedRealtimeNanos                      ('%d64')                              
        VerticalAccuracyMeters                    ('%f')                              
    end

    methods
        function self = FormatSpec(value)
            self.value = value;
        end
    end
end
