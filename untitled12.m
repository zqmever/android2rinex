
raw_meas = 'Raw,1664792839411,354925370000000,18,0.0,-1348473132041959639,0.02816462516784668,102.61097486363724,2.848226519251992,9.69316470149952,554,26,0.0,16399,124043325153659,35,27.2,59.74348831176758,1.3639999628067017,16,0.0,0.0,1561097980,,,,0,0.0,5,-62.84,22.9,-1538.9464111328125,11.741512298583984,,,I,374333049278073';

% raw_meas = 'Raw,1664792839411,354925370000000,18,0.0,-1348473132041959639,0.02816462516784668,102.61097486363724,2.848226519251992,9.69316470149952,554,6,0.0,16399,124057338588997,46,23.8,-513.1839599609375,0.9164999723434448,16,0.0,0.0,1575420030,,,,0,0.0,1,-53.76,20.2,0.0,0.0,,,C,374333049278073';

raw_meas = 'Raw,1595024717000,4056555000000,,,-1279055878445490398,0.0,7.742283831823661,,,0,29,0.0,16431,512734927316340,45,23.719484329223633,522.9606334842417,0.8833286054304477,4,1520573.5914765082,3.4028234663852886E38,1.57542003E9,,,,0,,1,,,,,,';

raw_meas = 'Raw,1664792839411,354925370000000,18,0.0,-1348473132041959639,0.02816462516784668,102.61097486363724,2.848226519251992,9.69316470149952,554,17,0.0,16399,124057337073182,7,41.4,479.0208740234375,0.022205490618944168,16,0.0,0.0,1575420030,,,,0,0.0,1,-53.76,37.8,0.0,0.0,,,C,374333049278073';

raw_meas_field = 'Raw,utcTimeMillis,TimeNanos,LeapSecond,TimeUncertaintyNanos,FullBiasNanos,BiasNanos,BiasUncertaintyNanos,DriftNanosPerSecond,DriftUncertaintyNanosPerSecond,HardwareClockDiscontinuityCount,Svid,TimeOffsetNanos,State,ReceivedSvTimeNanos,ReceivedSvTimeUncertaintyNanos,Cn0DbHz,PseudorangeRateMetersPerSecond,PseudorangeRateUncertaintyMetersPerSecond,AccumulatedDeltaRangeState,AccumulatedDeltaRangeMeters,AccumulatedDeltaRangeUncertaintyMeters,CarrierFrequencyHz,CarrierCycles,CarrierPhase,CarrierPhaseUncertainty,MultipathIndicator,SnrInDb,ConstellationType,AgcDb,BasebandCn0DbHz,FullInterSignalBiasNanos,FullInterSignalBiasUncertaintyNanos,SatelliteInterSignalBiasNanos,SatelliteInterSignalBiasUncertaintyNanos';

raw_meas_field = 'Raw,utcTimeMillis,TimeNanos,LeapSecond,TimeUncertaintyNanos,FullBiasNanos,BiasNanos,BiasUncertaintyNanos,DriftNanosPerSecond,DriftUncertaintyNanosPerSecond,HardwareClockDiscontinuityCount,Svid,TimeOffsetNanos,State,ReceivedSvTimeNanos,ReceivedSvTimeUncertaintyNanos,Cn0DbHz,PseudorangeRateMetersPerSecond,PseudorangeRateUncertaintyMetersPerSecond,AccumulatedDeltaRangeState,AccumulatedDeltaRangeMeters,AccumulatedDeltaRangeUncertaintyMeters,CarrierFrequencyHz,CarrierCycles,CarrierPhase,CarrierPhaseUncertainty,MultipathIndicator,SnrInDb,ConstellationType,AgcDb,BasebandCn0DbHz,FullInterSignalBiasNanos,FullInterSignalBiasUncertaintyNanos,SatelliteInterSignalBiasNanos,SatelliteInterSignalBiasUncertaintyNanos,CodeType,ChipsetElapsedRealtimeNanos';
raw_meas_field_cell = split(raw_meas_field, ',');
raw_meas_field_cell{1} = 'Header';

gnssRaw = cell2struct(split(raw_meas, ','), raw_meas_field_cell);

for i = 2:length(raw_meas_field_cell)
    this_value = 0;
    this_value_str = gnssRaw.(raw_meas_field_cell{i});
    if ~isempty(this_value_str)
        this_value = str2double(this_value_str);
        if ~isnan(this_value)
            gnssRaw.(raw_meas_field_cell{i}) = this_value;
        end
    else
        gnssRaw.(raw_meas_field_cell{i}) = this_value;
    end
end

GpsConstants.WEEKSEC = 604800;
GpsConstants.WEEKSECNANOS = int64(GpsConstants.WEEKSEC * 1e9);
GpsConstants.DAYSEC = 86400;
GpsConstants.DAYSECNANOS = int64(GpsConstants.DAYSEC * 1e9);
GpsConstants.LIGHTSPEED = 299792458;
GpsConstants.GPS = 1;
GpsConstants.GLO = 3;
GpsConstants.GAL = 6;
GpsConstants.BDS = 5;
GpsConstants.UNK = 9;


tTxNanos = int64(gnssRaw.ReceivedSvTimeNanos);
FullBiasNanos1 = int64(gnssRaw.FullBiasNanos);
BiasNanos1 = int64(gnssRaw.BiasNanos);
BiasNanos1 = BiasNanos1; % + int64(time_offset * 1e9);
tRxNanosGnss = int64(gnssRaw.TimeNanos) + int64(gnssRaw.TimeOffsetNanos) - (FullBiasNanos1 + BiasNanos1);
% sprintf('%d', tRxNanosGnss)

NumberNanoSecondsWeek = int64(GpsConstants.WEEKSEC * 1e9);
NumberNanoSecondsDay = int64(GpsConstants.WEEKSEC / 7 * 1e9);
NumberNanoSeconds100Milli = int64(100 * 1e-3 * 1e9);
leapSecondsNanos = int64(18 * 1e9);
switch gnssRaw.ConstellationType
    case GpsConstants.GPS
        tRxNanos = mod(tRxNanosGnss, NumberNanoSecondsWeek);
    case GpsConstants.GLO
        tRxNanos = mod(tRxNanosGnss, NumberNanoSecondsDay) + 3 * 3600 * 1e9 - leapSecondsNanos;
    case GpsConstants.GAL
        if false
            tRxNanos = mod(tRxNanosGnss, NumberNanoSeconds100Milli);
        else
            tRxNanos = mod(tRxNanosGnss, NumberNanoSecondsWeek);
        end
    case GpsConstants.BDS
        tRxNanos = mod(tRxNanosGnss, NumberNanoSecondsWeek) - 14e9;
    otherwise

end

[prNanos, tRxNanos] = CheckGpsWeekRollover(tRxNanos, tTxNanos, GpsConstants);
PrM = double(prNanos) / 1e9 * GpsConstants.LIGHTSPEED;
sprintf('%.6f', PrM)

T = datetime(1970,1,1,0,0,0,0,'TimeZone','UTC','F','uuuu-MM-dd''T''HH:mm:ss.SSSSSSSS Z');
addMS = milliseconds(cumsum([0;gnssRaw.utcTimeMillis]));
out = T + addMS + seconds(18)


function [prNanos, tRxNanos]  = CheckGpsWeekRollover(tRxNanos, tTxNanos, GpsConstants)
    %utility function for ProcessGnssMeas
    
    prNanos  = tRxNanos - tTxNanos;
    
    iRollover = prNanos > GpsConstants.DAYSECNANOS / 2;
    if any(iRollover)
        fprintf('\nWARNING: week rollover detected in time tags. Adjusting ...\n')
        prS = prNanos(iRollover);
        prS = wrap_to_x(prS, GpsConstants.DAYSECNANOS / 2);
%         delS = round(prS / (GpsConstants.WEEKSEC * 1e9)) * GpsConstants.WEEKSEC * 1e9;
        prS = mod(prS, GpsConstants.DAYSECNANOS);
        %prS are in the range [-WEEKSEC/2 : WEEKSEC/2];
        %check that common bias is not huge (like, bigger than 10s)
        maxBiasSeconds = 10 * 1e9;
        if any(prS>maxBiasSeconds)
            error('Failed to correct week rollover\n')
        else
            prNanos(iRollover) = prS; %put back into prSeconds vector
            %Now adjust tRxSeconds by the same amount:
            tRxNanos(iRollover) = mod(tRxNanos(iRollover), GpsConstants.DAYSECNANOS);
            fprintf('Corrected week rollover\n')
        end
    end
end

