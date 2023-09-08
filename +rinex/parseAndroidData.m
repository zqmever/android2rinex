function rinex_dataset = parseAndroidData(rinex_dataset, android_dataset)

    raw_dataframe = android_dataset.getDataFrame('Raw');

    %% calculate epoch time
    datetime_gps_starts = datetime(1980,1,6,0,0,0,0);

    TimeOffsetNanos = raw_dataframe.getData('TimeOffsetNanos');
    TimeNanos = raw_dataframe.getData('TimeNanos');
    
    FullBiasNanos1 = raw_dataframe.getData('FullBiasNanos', 1);
    BiasNanos1 = raw_dataframe.getData('BiasNanos', 1);

    tRxNanosGnss = TimeNanos - int64(floor(TimeOffsetNanos)) - (FullBiasNanos1 + int64(floor(BiasNanos1)));

    tRxSecondFraction = mod(tRxNanosGnss, 1e9);
    tRxSeconds = seconds(double((tRxNanosGnss - tRxSecondFraction) ./ 1e9));
    
    epoch_time = datetime_gps_starts + tRxSeconds + seconds(double(tRxSecondFraction) ./ 1e9);

    %% define default values
    default_leap_seconds = rinex.getLeapSeconds(epoch_time);
    default_code_type = "C";

    %% get the raw data
    tTxNanos = raw_dataframe.getData('ReceivedSvTimeNanos');
    
    ConstellationType = raw_dataframe.getData('ConstellationType');
    Svid = raw_dataframe.getData('Svid');
    
    FullInterSignalBiasNanos = raw_dataframe.getData('FullInterSignalBiasNanos');
    
    LeapSecond = raw_dataframe.getData('LeapSecond');
    if any(LeapSecond == 0)
        LeapSecond(LeapSecond == 0) = default_leap_seconds(LeapSecond == 0);
    end

    CarrierFrequencyHz = raw_dataframe.getData('CarrierFrequencyHz');
    AccumulatedDeltaRangeMeters = raw_dataframe.getData('AccumulatedDeltaRangeMeters');
    PseudorangeRateMetersPerSecond = raw_dataframe.getData('PseudorangeRateMetersPerSecond');
    Cn0DbHz = raw_dataframe.getData('Cn0DbHz');
    
    CodeType = string(raw_dataframe.getData('CodeType'));
    CodeType(strlength(CodeType) < 1) = default_code_type;
    CodeType(strlength(CodeType) > 1) = extractBefore(CodeType(strlength(CodeType) > 1), 2);
    
    %% calculate pseudoranges
    tRxNanosGnssFrac = - mod(TimeOffsetNanos, 1) - mod(BiasNanos1, 1);
    
    % GPS
    tRxNanos = mod(tRxNanosGnss, rinex.GnssConstants.WEEKSECNANOS);
    
    % GLO
    glo_filter = ConstellationType == rinex.Constellation.GLONASS;
    if any(glo_filter)
        tRxNanos(glo_filter) = mod(tRxNanosGnss(glo_filter), rinex.GnssConstants.DAYSECNANOS) + rinex.GnssConstants.GLOTIMEOFFSETSECNANOS - int64(LeapSecond(glo_filter)) * 1e9;
    end
    
    % GAL
    gal_filter = (ConstellationType == rinex.Constellation.GALILEO) & false;
    if any(gal_filter)
        tRxNanos(gal_filter) = mod(tRxNanosGnss(gal_filter), rinex.GnssConstants.MILLISECNANOS100);
    end
    
    % BDS
    bds_filter = ConstellationType == rinex.Constellation.BEIDOU;
    if any(bds_filter)
        tRxNanos(bds_filter) = tRxNanos(bds_filter) - rinex.GnssConstants.BDSTOGPSTIMESECNANOS;
    end
    
    [prNanos, tRxNanos] = rinex.checkRollover(tRxNanos, tTxNanos, rinex.GnssConstants.WEEKSECNANOS);
    pseudorange = (double(prNanos) + tRxNanosGnssFrac - FullInterSignalBiasNanos) / 1e9 * rinex.GnssConstants.LIGHTSPEED;

    % loss of lock indicator
    pseudorange_LLI = nan(size(pseudorange));
    % signal strength indicator
    pseudorange_SSI = nan(size(pseudorange));
    
    %% calculate carrier phases
    wavelength = rinex.GnssConstants.LIGHTSPEED ./ CarrierFrequencyHz;
    phase = AccumulatedDeltaRangeMeters ./ wavelength;
    
    % loss of lock indicator
    phase_LLI = nan(size(phase));
    % signal strength indicator
    phase_SSI = nan(size(phase));
    
    %% calculate doppler
    doppler = - PseudorangeRateMetersPerSecond ./ wavelength;
    
    % loss of lock indicator
    doppler_LLI = nan(size(doppler));
    % signal strength indicator
    doppler_SSI = nan(size(doppler));
    
    %% calculate signal strength
    strength = Cn0DbHz;
    
    % loss of lock indicator
    strength_LLI = nan(size(Cn0DbHz));
    % signal strength indicator
    strength_SSI = nan(size(Cn0DbHz));
    
    %% fill the rinex dataset
    rinex_dataset.epoch_time = epoch_time;

    rinex_dataset.satellite = [ConstellationType, Svid];
    
    rinex_dataset.pseudorange = [pseudorange, pseudorange_LLI, pseudorange_SSI];
    rinex_dataset.phase       = [phase,       phase_LLI,       phase_SSI];
    rinex_dataset.doppler     = [doppler,     doppler_LLI,     doppler_SSI];
    rinex_dataset.strength    = [strength,    strength_LLI,    strength_SSI];

    [rinex_dataset.freq_band, rinex_dataset.glo_freq_k] = rinex.getFrequencyBand(CarrierFrequencyHz, ConstellationType);
    rinex_dataset.code_type = CodeType;
end