% 
% raw_file = fullfile(pwd, 'tests', 'gnss_log_2022_10_03_11_27_19.txt');
% 
% gnss_raw = read_raw_file(raw_file);


raw_max = size(gnss_raw.Raw, 1);
i = 5;
while i < raw_max
    this_index = gnss_raw.Raw.utcTimeMillis(i) == gnss_raw.Raw.utcTimeMillis;

%     for j = 1:length(this_index)
        tTxNanos = gnss_raw.Raw.ReceivedSvTimeNanos(i);

        FullBiasNanos1 = gnss_raw.Raw.FullBiasNanos(i);
        BiasNanos1 = gnss_raw.Raw.BiasNanos(i);

        tRxNanosGnss = gnss_raw.Raw.TimeNanos(i) + int64(floor(gnss_raw.Raw.TimeOffsetNanos(i))) - (FullBiasNanos1 + int64(floor(BiasNanos1)));
        tRxNanosGnssFrac = mod(gnss_raw.Raw.TimeOffsetNanos(i), 1) - mod(BiasNanos1, 1);

    for j = 1:length(this_index)
        switch gnss_raw.Raw.ConstellationType(i)
            case GnssConstants.GPS
                tRxNanos = mod(tRxNanosGnss, GnssConstants.WEEKSECNANOS);
            case GnssConstants.GLO
                tRxNanos = mod(tRxNanosGnss, GnssConstants.DAYSECNANOS) + GnssConstants.GLOTIMEOFFSETSECNANOS - GnssConstants.LEAPSECNANOS;
            case GnssConstants.GAL
                if false
                    tRxNanos = mod(tRxNanosGnss, GnssConstants.MILLISECNANOS100);
                else
                    tRxNanos = mod(tRxNanosGnss, GnssConstants.WEEKSECNANOS);
                end
            case GnssConstants.BDS
                tRxNanos = mod(tRxNanosGnss, GnssConstants.WEEKSECNANOS) - GnssConstants.BDSTIMEBIASNANOS;
            otherwise
        
        end
    end

        [prNanos, tRxNanos] = CheckWeekRollover(tRxNanos, tTxNanos);
        PrM = (double(prNanos) + tRxNanosGnssFrac) / 1e9 * GnssConstants.LIGHTSPEED;

        sprintf('%.6f', PrM)
%     end
i=inf;
end








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

