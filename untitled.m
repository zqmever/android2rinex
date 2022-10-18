% 
% raw_file = fullfile(pwd, 'tests', 'gnss_log_2022_10_03_11_27_19.txt');

raw_file_list = dir(fullfile(pwd, 'test2', '*.txt'));

for ii = 1:length(raw_file_list)
    raw_file = fullfile(raw_file_list(ii).folder, raw_file_list(ii).name);
    gnss_raw = read_raw_file(raw_file);
    
    
    %% parse
    tTxNanos = gnss_raw.Raw.ReceivedSvTimeNanos;
    
    FullBiasNanos1 = gnss_raw.Raw.FullBiasNanos(1);
    BiasNanos1 = gnss_raw.Raw.BiasNanos(1);
    
    tRxNanosGnss = gnss_raw.Raw.TimeNanos - int64(floor(gnss_raw.Raw.TimeOffsetNanos)) - (FullBiasNanos1 + int64(floor(BiasNanos1)));
    tRxNanosGnssFrac = - mod(gnss_raw.Raw.TimeOffsetNanos, 1) - mod(BiasNanos1, 1);
    
    % GPS
    tRxNanos = mod(tRxNanosGnss, GnssConstants.WEEKSECNANOS);
    
    % GLO
    glo_filter = gnss_raw.Raw.ConstellationType == GnssConstants.GLO;
    if any(glo_filter)
        tRxNanos(glo_filter) = mod(tRxNanosGnss(glo_filter), GnssConstants.DAYSECNANOS) + GnssConstants.GLOTIMEOFFSETSECNANOS - int64(gnss_raw.Raw.LeapSecond(glo_filter)) * 1e9;
    end
    
    % GAL
    gal_filter = (gnss_raw.Raw.ConstellationType == GnssConstants.GAL) & false;
    if any(gal_filter)
        tRxNanos(gal_filter) = mod(tRxNanosGnss(gal_filter), GnssConstants.MILLISECNANOS100);
    end
    
    % BDS
    bds_filter = gnss_raw.Raw.ConstellationType == GnssConstants.BDS;
    if any(bds_filter)
        tRxNanos(bds_filter) = tRxNanos(bds_filter) - GnssConstants.BDSTOGPSTIMESECNANOS;
    end
    
    [prNanos, tRxNanos] = CheckWeekRollover(tRxNanos, tTxNanos);
    PrM = (double(prNanos) + tRxNanosGnssFrac) / 1e9 * GnssConstants.LIGHTSPEED;
    
    
    % signal band
    [band, k] = getBand(gnss_raw.Raw.CarrierFrequencyHz, gnss_raw.Raw.ConstellationType);
    
    if ismember('CodeType', gnss_raw.Raw.Properties.VariableNames)
        band_attr_str = cell2mat(gnss_raw.Raw.CodeType);
    else
        band_attr_str = char(int32(zeros(size(band))) + int32('C'));
        band_attr_str(band == 5) = 'Q';
        band_attr_str(band == 2 & gnss_raw.Raw.ConstellationType == GnssConstants.BDS) = 'I';
    end
    
    % other meas
    wavelength = GnssConstants.LIGHTSPEED ./ gnss_raw.Raw.CarrierFrequencyHz;
    L = gnss_raw.Raw.AccumulatedDeltaRangeMeters ./ wavelength;
    D = - gnss_raw.Raw.PseudorangeRateMetersPerSecond ./ wavelength;
    S = gnss_raw.Raw.Cn0DbHz;
    
    
    sys_code = getConstellationCode(gnss_raw.Raw.ConstellationType);
    obs_code = [num2str(band), band_attr_str];
    gps_filter = gnss_raw.Raw.ConstellationType == GnssConstants.GPS;
    obs_code_gps = unique(obs_code(gps_filter, :), 'row');
    glo_filter = gnss_raw.Raw.ConstellationType == GnssConstants.GLO;
    obs_code_glo = unique(obs_code(glo_filter, :), 'row');
    gal_filter = gnss_raw.Raw.ConstellationType == GnssConstants.GAL;
    obs_code_gal = unique(obs_code(gal_filter, :), 'row');
    bds_filter = gnss_raw.Raw.ConstellationType == GnssConstants.BDS;
    obs_code_bds = unique(obs_code(bds_filter, :), 'row');
    
    
    T = datetime(1980,1,6,0,0,0,0,'TimeZone','UTC','Format','uuuu MM dd HH mm ss.SSSSSSS');
    this_frac = mod(tRxNanosGnss, 1e9);
    this_duration = seconds(double((tRxNanosGnss - this_frac) ./ 1e9));
    epoch_pool = T + this_duration + seconds(double(this_frac) ./ 1e9);
    
    
    
    %% write to file
    fid = fopen([raw_file(1:end-4), '.obs'], 'w+');
    
    % add header
    fprintf(fid, '     3.04           OBSERVATION DATA    M                   RINEX VERSION / TYPE\n');
    fprintf(fid, 'GnssLogger          HONOR 12            %4d%02d%02d %02d%02d%02d UTC PGM / RUN BY / DATE \n', ...
        epoch_pool(1).Year, epoch_pool(1).Month, epoch_pool(1).Day, epoch_pool(1).Hour, epoch_pool(1).Minute, floor(epoch_pool(1).Second));
    fprintf(fid, 'Google GnssLogger                                           MARKER NAME         \n');
    fprintf(fid, 'Unknown                                                     MARKER NUMBER       \n');
    fprintf(fid, 'Unknown             Unknown                                 OBSERVER / AGENCY   \n');
    fprintf(fid, 'Unknown             GnssLogger          v3.0.5.6            REC # / TYPE / VERS \n');
    fprintf(fid, 'Unknown             Unknown                                 ANT # / TYPE        \n');
    fprintf(fid, '        0.0000        0.0000        0.0000                  APPROX POSITION XYZ \n');
    fprintf(fid, '        0.0000        0.0000        0.0000                  ANTENNA: DELTA H/E/N\n');
    this_line = sprintf('G%5d', 4*size(obs_code_gps, 1));
    for i = 1:size(obs_code_gps, 1)
        this_line = sprintf('%s C%s L%s D%s S%s', this_line, obs_code_gps(i,:), obs_code_gps(i,:), obs_code_gps(i,:), obs_code_gps(i,:));
    end
    fprintf(fid, '%-60sSYS / # / OBS TYPES \n', this_line);
    this_line = sprintf('R%5d', 4*size(obs_code_glo, 1));
    for i = 1:size(obs_code_glo, 1)
        this_line = sprintf('%s C%s L%s D%s S%s', this_line, obs_code_glo(i,:), obs_code_glo(i,:), obs_code_glo(i,:), obs_code_glo(i,:));
    end
    fprintf(fid, '%-60sSYS / # / OBS TYPES \n', this_line);
    this_line = sprintf('E%5d', 4*size(obs_code_gal, 1));
    for i = 1:size(obs_code_gal, 1)
        this_line = sprintf('%s C%s L%s D%s S%s', this_line, obs_code_gal(i,:), obs_code_gal(i,:), obs_code_gal(i,:), obs_code_gal(i,:));
    end
    fprintf(fid, '%-60sSYS / # / OBS TYPES \n', this_line);
    this_line = sprintf('C%5d', 4*size(obs_code_bds, 1));
    for i = 1:size(obs_code_bds, 1)
        this_line = sprintf('%s C%s L%s D%s S%s', this_line, obs_code_bds(i,:), obs_code_bds(i,:), obs_code_bds(i,:), obs_code_bds(i,:));
    end
    fprintf(fid, '%-60sSYS / # / OBS TYPES \n', this_line);
    fprintf(fid, '  %4d    %02d    %02d    %02d    %02d   %13.7f     GPS      TIME OF FIRST OBS   \n', ...
        epoch_pool(1).Year, epoch_pool(1).Month, epoch_pool(1).Day, epoch_pool(1).Hour, epoch_pool(1).Minute, epoch_pool(1).Second);
    fprintf(fid, ' 24 R01  1 R02 -4 R03  5 R04  6 R05  1 R06 -4 R07  5 R08  6 GLONASS SLOT / FRQ #\n');
    fprintf(fid, '    R09 -2 R10 -7 R11  0 R12 -1 R13 -2 R14 -7 R15  0 R16 -1 GLONASS SLOT / FRQ #\n');
    fprintf(fid, '    R17  4 R18 -3 R19  3 R20  2 R21  4 R22 -3 R23  3 R24  2 GLONASS SLOT / FRQ #\n');
    fprintf(fid, 'G L1C                                                       SYS / PHASE SHIFT   \n');
    fprintf(fid, 'G L5Q  0.00000                                              SYS / PHASE SHIFT   \n');
    fprintf(fid, 'R L1C                                                       SYS / PHASE SHIFT   \n');
    fprintf(fid, 'C L2I                                                       SYS / PHASE SHIFT   \n');
    fprintf(fid, 'C L7Q  0.00000                                              SYS / PHASE SHIFT   \n');
    fprintf(fid, 'E L1C  0.00000                                              SYS / PHASE SHIFT   \n');
    fprintf(fid, 'E L5Q  0.00000                                              SYS / PHASE SHIFT   \n');
    fprintf(fid, ' C1C    0.000 C1P    0.000 C2C    0.000 C2P    0.000        GLONASS COD/PHS/BIS \n');
    fprintf(fid, '                                                            END OF HEADER       \n');
    
    
    
    epoch_pool_unique = unique(epoch_pool);
    for i = 1:length(epoch_pool_unique)
        epoch_filter = epoch_pool == epoch_pool_unique(i);
    
        gps_filter = epoch_filter & gnss_raw.Raw.ConstellationType == GnssConstants.GPS;
        this_sat_gps = unique(gnss_raw.Raw.Svid(gps_filter));
        glo_filter = epoch_filter & gnss_raw.Raw.ConstellationType == GnssConstants.GLO;
        this_sat_glo = unique(gnss_raw.Raw.Svid(glo_filter));
        gal_filter = epoch_filter & gnss_raw.Raw.ConstellationType == GnssConstants.GAL;
        this_sat_gal = unique(gnss_raw.Raw.Svid(gal_filter));
        bds_filter = epoch_filter & gnss_raw.Raw.ConstellationType == GnssConstants.BDS;
        this_sat_bds = unique(gnss_raw.Raw.Svid(bds_filter));
    
        % header
        this_line = sprintf('> %s  0%3d', epoch_pool_unique(i), length(this_sat_gps)+length(this_sat_glo)+length(this_sat_gal)+length(this_sat_bds));
        fprintf(fid, this_line);
        fprintf(fid, '\n');
    
        % gps    
        for j = 1:size(this_sat_gps, 1)
            this_line = sprintf('G%02d', this_sat_gps(j));
            for k = 1:size(obs_code_gps, 1)
                this_index = gps_filter & (this_sat_gps(j) == gnss_raw.Raw.Svid) & all(obs_code_gps(k,:) == obs_code, 2);
                if any(this_index)
                    this_line = sprintf('%s%14.3f  %14.3f  %14.3f  %14.3f  ', this_line, PrM(this_index), L(this_index), D(this_index), S(this_index));
                else
                    this_line = sprintf('%s%64s', this_line, ' ');
                end
            end
            fprintf(fid, this_line);
            fprintf(fid, '\n');
        end
        % glonass
        for j = 1:size(this_sat_glo, 1)
            this_line = sprintf('R%02d', this_sat_glo(j));
            for k = 1:size(obs_code_glo, 1)
                this_index = glo_filter & (this_sat_glo(j) == gnss_raw.Raw.Svid) & all(obs_code_glo(k,:) == obs_code, 2);
                if any(this_index)
                    this_line = sprintf('%s%14.3f  %14.3f  %14.3f  %14.3f  ', this_line, PrM(this_index), L(this_index), D(this_index), S(this_index));
                else
                    this_line = sprintf('%s%64s', this_line, ' ');
                end
            end
            fprintf(fid, this_line);
            fprintf(fid, '\n');
        end
        % galileo
        for j = 1:size(this_sat_gal, 1)
            this_line = sprintf('E%02d', this_sat_gal(j));
            for k = 1:size(obs_code_gal, 1)
                this_index = gal_filter & (this_sat_gal(j) == gnss_raw.Raw.Svid) & all(obs_code_gal(k,:) == obs_code, 2);
                if any(this_index)
                    this_line = sprintf('%s%14.3f  %14.3f  %14.3f  %14.3f  ', this_line, PrM(this_index), L(this_index), D(this_index), S(this_index));
                else
                    this_line = sprintf('%s%64s', this_line, ' ');
                end
            end
            fprintf(fid, this_line);
            fprintf(fid, '\n');
        end
        % beidou
        for j = 1:size(this_sat_bds, 1)
            this_line = sprintf('C%02d', this_sat_bds(j));
            for k = 1:size(obs_code_bds, 1)
                this_index = bds_filter & (this_sat_bds(j) == gnss_raw.Raw.Svid) & all(obs_code_bds(k,:) == obs_code, 2);
                if any(this_index)
                    this_line = sprintf('%s%14.3f  %14.3f  %14.3f  %14.3f  ', this_line, PrM(this_index), L(this_index), D(this_index), S(this_index));
                else
                    this_line = sprintf('%s%64s', this_line, ' ');
                end
            end
            fprintf(fid, this_line);
            fprintf(fid, '\n');
        end
    end
    
    fclose(fid);
end



%% functions
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


function [prSeconds,tRxSeconds]  = CheckGpsWeekRollover_backup(tRxSeconds,tTxSeconds)
%utility function for ProcessGnssMeas

prSeconds  = tRxSeconds - tTxSeconds;

iRollover = prSeconds > GpsConstants.WEEKSEC/2;
if any(iRollover)
    fprintf('\nWARNING: week rollover detected in time tags. Adjusting ...\n')
    prS = prSeconds(iRollover);
    delS = round(prS/GpsConstants.WEEKSEC)*GpsConstants.WEEKSEC;
    prS = prS - delS;
    %prS are in the range [-WEEKSEC/2 : WEEKSEC/2];
    %check that common bias is not huge (like, bigger than 10s)
    maxBiasSeconds = 10; 
    if any(prS>maxBiasSeconds)
        error('Failed to correct week rollover\n')
    else
        prSeconds(iRollover) = prS; %put back into prSeconds vector
        %Now adjust tRxSeconds by the same amount:
        tRxSeconds(iRollover) = tRxSeconds(iRollover) - delS;
        fprintf('Corrected week rollover\n')
    end
end
%TBD Unit test this

end






function [band, glo_k] = getBand(frequency, constellation)

    base_freq = 10.23e6;
    i_freq = round(frequency / base_freq, 1);

    band = zeros(size(frequency));
    glo_k = band;
    
    glo_filter = constellation == GnssConstants.GLO;

    if any(~glo_filter)
        band(i_freq == 154)   = 1;
        band(i_freq == 120)   = 2;
        band(i_freq == 115)   = 5;
        band(i_freq == 118)   = 7;
        band(i_freq == 125)   = 6;
        band(i_freq == 116.5) = 8;
        band(i_freq == 152.6) = 2;
        band(i_freq == 124)   = 6;
        band(i_freq == 243.6) = 9;
    end
    
    if any(glo_filter)
        band(glo_filter & i_freq == 156.5) = 4;
        band(glo_filter & i_freq == 122)   = 6;
        band(glo_filter & i_freq == 117.5) = 3;

        glo_g1_k = round((frequency - 1602e6) ./ (9 / 16 * 1e6), 1);
        glo_g1 = glo_filter & glo_g1_k >= -7 & glo_g1_k <= 12 & mod(glo_g1_k, 1) == 0;
        glo_k(glo_g1) = glo_g1_k(glo_g1);
        band(glo_g1) = 1;

        glo_g2_k = round((frequency - 1246e6) ./ (7 / 16 * 1e6), 1);
        glo_g2 = glo_filter & glo_g2_k >= -7 & glo_g2_k <= 12 & mod(glo_g2_k, 1) == 0;
        glo_k(glo_g2) = glo_g2_k(glo_g2);
        band(glo_g2) = 2;
    end
end

function constellation_code = getConstellationCode(constellation)
constellation_code = char(int32(zeros(size(constellation))) + int32('U'));
constellation_code(constellation == GnssConstants.GPS) = 'G';
constellation_code(constellation == GnssConstants.GLO) = 'R';
constellation_code(constellation == GnssConstants.GAL) = 'E';
constellation_code(constellation == GnssConstants.BDS) = 'C';
constellation_code(constellation == GnssConstants.SBA) = 'S';
end
