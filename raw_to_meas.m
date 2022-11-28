function rinex_frame = raw_to_meas(gnss_raw_data_frame)

% get the raw data
tTxNanos = gnss_raw_data_frame.data.ReceivedSvTimeNanos;
TimeOffsetNanos = gnss_raw_data_frame.data.TimeOffsetNanos;
TimeNanos = gnss_raw_data_frame.data.TimeNanos;

FullBiasNanos1 = gnss_raw_data_frame.data.FullBiasNanos(1);
BiasNanos1 = gnss_raw_data_frame.data.BiasNanos(1);

ConstellationType = gnss_raw_data_frame.data.ConstellationType;

FullInterSignalBiasNanos = gnss_raw_data_frame.data.FullInterSignalBiasNanos;

LeapSecond = gnss_raw_data_frame.data.LeapSecond;

CarrierFrequencyHz = gnss_raw_data_frame.data.CarrierFrequencyHz;
AccumulatedDeltaRangeMeters = gnss_raw_data_frame.data.AccumulatedDeltaRangeMeters;
PseudorangeRateMetersPerSecond = gnss_raw_data_frame.data.PseudorangeRateMetersPerSecond;
Cn0DbHz = gnss_raw_data_frame.data.Cn0DbHz;

% calculate pseudoranges
tRxNanosGnss = TimeNanos - int64(floor(TimeOffsetNanos)) - (FullBiasNanos1 + int64(floor(BiasNanos1)));
tRxNanosGnssFrac = - mod(TimeOffsetNanos, 1) - mod(BiasNanos1, 1);

% GPS
tRxNanos = mod(tRxNanosGnss, GnssConstants.WEEKSECNANOS);

% GLO
glo_filter = ConstellationType == GnssConstants.GLO;
if any(glo_filter)
    tRxNanos(glo_filter) = mod(tRxNanosGnss(glo_filter), GnssConstants.DAYSECNANOS) + GnssConstants.GLOTIMEOFFSETSECNANOS - int64(LeapSecond(glo_filter)) * 1e9;
end

% GAL
gal_filter = (ConstellationType == GnssConstants.GAL) & false;
if any(gal_filter)
    tRxNanos(gal_filter) = mod(tRxNanosGnss(gal_filter), GnssConstants.MILLISECNANOS100);
end

% BDS
bds_filter = ConstellationType == GnssConstants.BDS;
if any(bds_filter)
    tRxNanos(bds_filter) = tRxNanos(bds_filter) - GnssConstants.BDSTOGPSTIMESECNANOS;
end

[prNanos, tRxNanos] = CheckWeekRollover(tRxNanos, tTxNanos);
pseudorange = (double(prNanos) + tRxNanosGnssFrac - FullInterSignalBiasNanos) / 1e9 * GnssConstants.LIGHTSPEED;

% calculate carrier phases
wavelength = GnssConstants.LIGHTSPEED ./ CarrierFrequencyHz;
carrier_phase = AccumulatedDeltaRangeMeters ./ wavelength;

% calculate doppler
doppler = - PseudorangeRateMetersPerSecond ./ wavelength;

% calculate signal strength
signal_strength = Cn0DbHz;

% make a summary


end

function [prNanos, tRxNanos]  = CheckWeekRollover(tRxNanos, tTxNanos)
    %utility function for ProcessGnssMeas
    
    prNanos  = tRxNanos - tTxNanos;
    
    iRollover = prNanos > GnssConstants.WEEKSECNANOS / 2;
    if any(iRollover)
        fprintf('\nWARNING: week rollover detected in time tags. Adjusting ...\n')
        prS = prNanos(iRollover);
        prS = wrap_to_x(prS, GnssConstants.WEEKSECNANOS / 2);
        %prS are in the range [-WEEKSEC/2 : WEEKSEC/2];
        %check that common bias is not huge (like, bigger than 10s)
        maxBiasSeconds = 10 * 1e9;
        if any(prS > maxBiasSeconds)
            error('Failed to correct week rollover\n')
        else
            prNanos(iRollover) = prS; %put back into prSeconds vector
            %Now adjust tRxSeconds by the same amount:
            tRxNanos(iRollover) = tTxNanos(iRollover) + prS;
            fprintf('Corrected week rollover\n')
        end
    end
end
