function rinex_dataset = convertRawToMeas(gnss_raw_data_frame)

    %% get the raw data
    tTxNanos        = gnss_raw_data_frame.getData('ReceivedSvTimeNanos');
    TimeOffsetNanos = gnss_raw_data_frame.getData('TimeOffsetNanos');
    TimeNanos       = gnss_raw_data_frame.getData('TimeNanos');
    
    FullBiasNanos1 = gnss_raw_data_frame.getData('FullBiasNanos', 1);
    BiasNanos1     = gnss_raw_data_frame.getData('BiasNanos', 1);
    
    ConstellationType = gnss_raw_data_frame.getData('ConstellationType');
    Svid              = gnss_raw_data_frame.getData('Svid');
    
    FullInterSignalBiasNanos = gnss_raw_data_frame.getData('FullInterSignalBiasNanos');
    
    LeapSecond = gnss_raw_data_frame.getData('LeapSecond');
    
    CarrierFrequencyHz             = gnss_raw_data_frame.getData('CarrierFrequencyHz');
    AccumulatedDeltaRangeMeters    = gnss_raw_data_frame.getData('AccumulatedDeltaRangeMeters');
    PseudorangeRateMetersPerSecond = gnss_raw_data_frame.getData('PseudorangeRateMetersPerSecond');

    Cn0DbHz = gnss_raw_data_frame.getData('Cn0DbHz');
    
    CodeType = string(gnss_raw_data_frame.getData('CodeType'));
    
    %% calculate pseudoranges
    tRxNanosGnss = TimeNanos - int64(floor(TimeOffsetNanos)) - (FullBiasNanos1 + int64(floor(BiasNanos1)));
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
    
    %% calculate carrier phases
    wavelength = rinex.GnssConstants.LIGHTSPEED ./ CarrierFrequencyHz;
    carrier_phase = AccumulatedDeltaRangeMeters ./ wavelength;
    
    %% calculate doppler
    doppler = - PseudorangeRateMetersPerSecond ./ wavelength;
    
    %% calculate signal strength
    signal_strength = Cn0DbHz;
    
    %% fill the rinex dataset
    T = datetime(1980,1,6,0,0,0,0,'Format','uuuu MM dd HH mm ss.SSSSSSS');
    this_frac = mod(tRxNanosGnss, 1e9);
    this_duration = seconds(double((tRxNanosGnss - this_frac) ./ 1e9));
    rinex_dataset.epoch_time = T + this_duration + seconds(double(this_frac) ./ 1e9);
    rinex_dataset.constellation = ConstellationType;
    rinex_dataset.prn = Svid;
    rinex_dataset.pseudorange = pseudorange;
    rinex_dataset.carrier_phase = carrier_phase;
    rinex_dataset.doppler = doppler;
    rinex_dataset.signal_strength = signal_strength;
    [rinex_dataset.frequency_band, rinex_dataset.glo_freq_num] = rinex.getFrequencyBand(CarrierFrequencyHz, ConstellationType);
    rinex_dataset.code_type = CodeType;
end
