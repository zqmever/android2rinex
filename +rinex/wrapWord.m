function line_out = wrapWord(line_in, data_unit_length, line_length_max)
    % convert to string
    if ~isstring(line_in)
        line_in = string(line_in);
    end

    % check if we need word wrap
    line_length = strlength(line_in);
    if line_length > line_length_max
        n_data_units_per_line = floor(line_length_max / data_unit_length);
        n_chars_per_line = n_data_units_per_line * data_unit_length;
        n_lines = ceil(line_length / data_unit_length / n_data_units_per_line);

        line_out = strings(n_lines, 1);
        for i = 1:n_lines
            start_point = (i - 1) * n_chars_per_line + 1;
            end_point   = min(i * n_chars_per_line, line_length);
            line_out(i) = extractBetween(line_in, start_point, end_point);
        end
    else
        line_out = line_in;
    end
end
