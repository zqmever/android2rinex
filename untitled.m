% 
% raw_file = fullfile(pwd, 'tests', 'gnss_log_2022_10_03_11_27_19.txt');
% 
% gnss_raw = read_raw_file(raw_file);


% raw_max = size(gnss_raw.Raw, 1);
% i = 17;
% while i < raw_max
%     this_index = gnss_raw.Raw.utcTimeMillis(i) == gnss_raw.Raw.utcTimeMillis;
% 
% %     for j = 1:length(this_index)
%         tTxNanos = gnss_raw.Raw.ReceivedSvTimeNanos(i);
% 
%         FullBiasNanos1 = gnss_raw.Raw.FullBiasNanos(i);
%         BiasNanos1 = gnss_raw.Raw.BiasNanos(i);
% 
%         tRxNanosGnss = gnss_raw.Raw.TimeNanos(i) + int64(floor(gnss_raw.Raw.TimeOffsetNanos(i))) - (FullBiasNanos1 + int64(floor(BiasNanos1)));
%         tRxNanosGnssFrac = mod(gnss_raw.Raw.TimeOffsetNanos(i), 1) - mod(BiasNanos1, 1);
% 
%     for j = 1:length(this_index)
%         switch gnss_raw.Raw.ConstellationType(i)
%             case GnssConstants.GPS
%                 tRxNanos = mod(tRxNanosGnss, GnssConstants.WEEKSECNANOS);
%             case GnssConstants.GLO
%                 tRxNanos = mod(tRxNanosGnss, GnssConstants.DAYSECNANOS) + GnssConstants.GLOTIMEOFFSETSECNANOS - GnssConstants.LEAPSECNANOS;
%             case GnssConstants.GAL
%                 if false
%                     tRxNanos = mod(tRxNanosGnss, GnssConstants.MILLISECNANOS100);
%                 else
%                     tRxNanos = mod(tRxNanosGnss, GnssConstants.WEEKSECNANOS);
%                 end
%             case GnssConstants.BDS
%                 tRxNanos = mod(tRxNanosGnss, GnssConstants.WEEKSECNANOS) - GnssConstants.BDSTIMEOFFSETSECNANOS;
%             otherwise
%         
%         end
%     end
% 
%         [prNanos, tRxNanos] = CheckWeekRollover(tRxNanos, tTxNanos);
%         PrM = (double(prNanos) + tRxNanosGnssFrac) / 1e9 * GnssConstants.LIGHTSPEED;
% 
%         sprintf('%.6f', PrM)
% %     end
% i=inf;
% end






tTxNanos = gnss_raw.Raw.ReceivedSvTimeNanos;

FullBiasNanos1 = gnss_raw.Raw.FullBiasNanos(1);
BiasNanos1 = gnss_raw.Raw.BiasNanos(1);

tRxNanosGnss = gnss_raw.Raw.TimeNanos + int64(floor(gnss_raw.Raw.TimeOffsetNanos)) - (FullBiasNanos1 + int64(floor(BiasNanos1)));
tRxNanosGnssFrac = mod(gnss_raw.Raw.TimeOffsetNanos, 1) - mod(BiasNanos1, 1);

% GPS
tRxNanos = mod(tRxNanosGnss, GnssConstants.WEEKSECNANOS);

% GLO
glo_filter = gnss_raw.Raw.ConstellationType == GnssConstants.GLO;
if any(glo_filter)
    tRxNanos(glo_filter) = mod(tRxNanosGnss(glo_filter), GnssConstants.DAYSECNANOS) + GnssConstants.GLOTIMEOFFSETSECNANOS - int64(gnss_raw.Raw.LeapSecond(glo_filter));
end

% GAL
gal_filter = (gnss_raw.Raw.ConstellationType == GnssConstants.GAL) & false;
if any(gal_filter)
    tRxNanos(gal_filter) = mod(tRxNanosGnss(gal_filter), GnssConstants.MILLISECNANOS100);
end

% BDS
bds_filter = gnss_raw.Raw.ConstellationType == GnssConstants.BDS;
if any(bds_filter)
    tRxNanos(bds_filter) = tRxNanos(bds_filter) - GnssConstants.BDSTIMEOFFSETSECNANOS;
end

[prNanos, tRxNanos] = CheckWeekRollover(tRxNanos, tTxNanos);
PrM = (double(prNanos) + tRxNanosGnssFrac) / 1e9 * GnssConstants.LIGHTSPEED;


% signal band
band = round(gnss_raw.Raw.CarrierFrequencyHz / 10.23e6, 1);
band_str = zeros(size(band));
band_str(band == 154) = 1;
band_str(band == 120) = 2;
band_str(band == 115) = 5;
band_str(band == 118) = 7;
band_str(band == 125) = 6;
band_str(band == 116.5) = 8;
band_str(band == 152.6) = 2;
band_str(band == 124) = 6;
band_str(band == 243.6) = 9;

band_str(gnss_raw.Raw.ConstellationType == GnssConstants.GLO) = 1;
band_str((gnss_raw.Raw.CarrierFrequencyHz < 1500e6) & (gnss_raw.Raw.ConstellationType == GnssConstants.GLO)) = 2;
band_str(band == 156.5) = 4;
band_str(band == 122) = 6;
band_str(band == 117.5) = 3;

if ismember('CodeType', gnss_raw.Raw.Properties.VariableNames)
    band_attr_str = cell2mat(gnss_raw.Raw.CodeType);
else
    band_attr_str = char(int32(zeros(size(band))) + int32('C'));
    band_attr_str(band_str == 5) = 'Q';
    band_attr_str(band_str == 2 & gnss_raw.Raw.ConstellationType == GnssConstants.BDS) = 'I';
end

% other meas
wavelength = GnssConstants.LIGHTSPEED ./ gnss_raw.Raw.CarrierFrequencyHz;
L = gnss_raw.Raw.AccumulatedDeltaRangeMeters ./ wavelength;
D = - gnss_raw.Raw.PseudorangeRateMetersPerSecond ./ wavelength;
S = gnss_raw.Raw.Cn0DbHz;


% tTxNanos = int64(gnssRaw.ReceivedSvTimeNanos);
% FullBiasNanos1 = int64(gnssRaw.FullBiasNanos);
% BiasNanos1 = int64(gnssRaw.BiasNanos);
% BiasNanos1 = BiasNanos1; % + int64(time_offset * 1e9);
% tRxNanosGnss = int64(gnssRaw.TimeNanos) + int64(gnssRaw.TimeOffsetNanos) - (FullBiasNanos1 + BiasNanos1);
% % sprintf('%d', tRxNanosGnss)
% 
% switch gnssRaw.ConstellationType
%     case GpsConstants.GPS
%         tRxNanos = mod(tRxNanosGnss, GnssConstants.WEEKSECNANOS);
%     case GpsConstants.GLO
%         tRxNanos = mod(tRxNanosGnss, GnssConstants.DAYSECNANOS) + GnssConstants.GLOTIMEOFFSETSECNANOS - GnssConstants.LEAPSECNANOS;
%     case GpsConstants.GAL
%         if false
%             tRxNanos = mod(tRxNanosGnss, GnssConstants.MILLISECNANOS100);
%         else
%             tRxNanos = mod(tRxNanosGnss, GnssConstants.WEEKSECNANOS);
%         end
%     case GpsConstants.BDS
%         tRxNanos = mod(tRxNanosGnss, GnssConstants.WEEKSECNANOS) - GnssConstants.BDSTIMEBIASNANOS;
%     otherwise
% 
% end
% 
% [prNanos, tRxNanos] = CheckGpsWeekRollover(tRxNanos, tTxNanos, GpsConstants);
% PrM = double(prNanos) / 1e9 * GpsConstants.LIGHTSPEED;
% sprintf('%.6f', PrM)
% 
% T = datetime(1970,1,1,0,0,0,0,'TimeZone','UTC','F','uuuu-MM-dd''T''HH:mm:ss.SSSSSSSS Z');
% addMS = milliseconds(cumsum([0;gnssRaw.utcTimeMillis]));
% out = T + addMS + seconds(18)











% a = '1664792839411,354.9253700,,C,374333049278073';
% a(2,:) = {'1664792839411,354.9253700,,C,374333049278073'};


% fid = fopen(raw_file, 'r');
% raw_data = textscan(fid, '%[^,]%*[,]%[^\n]', 'CommentStyle', '#');
% fclose(fid);
% 
% this_label = 'Raw';
% this_raw_sort = strcmp(raw_data{1}, this_label);
% a = raw_data{2}(this_raw_sort);
% 
% h = gnss_raw.header.Raw;
% fs = '';
% 
% for i = 1:length(h)
%     fs = [fs, FormatSpec.(h{i}).value];
% end
% 
% aa = cell(size(a, 1), length(h));
% 
% for i = 1:size(a, 1)
%     aa(i,:) = textscan(a{i}, fs, 'Delimiter', ',');
% end
% 



function [prNanos, tRxNanos]  = CheckWeekRollover(tRxNanos, tTxNanos)
    %utility function for ProcessGnssMeas
    
    prNanos  = tRxNanos - tTxNanos;
    
    iRollover = prNanos > GnssConstants.DAYSECNANOS / 2;
    if any(iRollover)
        fprintf('\nWARNING: week rollover detected in time tags. Adjusting ...\n')
        prS = prNanos(iRollover);
        prS = wrap_to_x(prS, GnssConstants.DAYSECNANOS / 2);
%         delS = round(prS / (GpsConstants.WEEKSEC * 1e9)) * GpsConstants.WEEKSEC * 1e9;
        prS = mod(prS, GnssConstants.DAYSECNANOS);
        %prS are in the range [-WEEKSEC/2 : WEEKSEC/2];
        %check that common bias is not huge (like, bigger than 10s)
        maxBiasSeconds = 10 * 1e9;
        if any(prS > maxBiasSeconds)
            error('Failed to correct week rollover\n')
        else
            prNanos(iRollover) = prS; %put back into prSeconds vector
            %Now adjust tRxSeconds by the same amount:
            tRxNanos(iRollover) = mod(tRxNanos(iRollover), GnssConstants.DAYSECNANOS);
            fprintf('Corrected week rollover\n')
        end
    end
end

