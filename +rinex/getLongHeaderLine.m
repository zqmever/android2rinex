function lines = getLongHeaderLine(label, data, prefix_length, data_unit_length)
    % convert to string
    if ~isstring(data)
        data = string(data);
    end

    % check if we need wrap
    if strlength(data) > rinex.RinexConfig.data_length_max
        this_prefix(1) = extractBefore(data, prefix_length + 1);
        this_prefix(2) = string(repmat(' ', [1, prefix_length]));

        lines = rinex.wrapWord(extractAfter(data, prefix_length), data_unit_length, rinex.RinexConfig.data_length_max - prefix_length);
        for i = 1:length(lines)
            lines(i) = rinex.getHeaderLine(label, this_prefix(min(i, 2)) + lines(i));
        end
    else
        lines = rinex.getHeaderLine(label, data);
    end
end
