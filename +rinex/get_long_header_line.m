function lines = get_long_header_line(label, data, prefix_length, data_unit_length)
    
    if strlength(data) > rinex.RinexConfig.data_length_max
        n_data_units_per_line = floor((rinex.RinexConfig.data_length_max - prefix_length) / data_unit_length);
        n_lines = ceil((strlength(data) - prefix_length) / data_unit_length / n_data_units_per_line);

        this_prefix  = extractBefore(data, prefix_length + 1);
        this_prefix2 = repmat(' ', [1, prefix_length]);

        lines = strings(n_lines, 1);
        lines(1) = rinex.get_header_line(label, extractBefore(data, prefix_length + n_data_units_per_line * data_unit_length + 1));
        for i = 2:n_lines
            start_point = prefix_length + (i - 1) * n_data_units_per_line * data_unit_length;
            end_point   = min(prefix_length + i * n_data_units_per_line * data_unit_length, strlength(data)) + 1;
            lines(i) = rinex.get_header_line(label, sprintf('%s%s', this_prefix2, extractAfter(extractBefore(data, end_point), start_point)));
        end
    else
        lines = rinex.get_header_line(label, data);
    end
end
