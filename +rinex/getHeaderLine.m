function header_line = getHeaderLine(label, data)
    data = extractBefore(data, min(strlength(data), rinex.RinexConfig.data_length_max) + 1);
    label = extractBefore(label, min(strlength(label), rinex.RinexConfig.label_length_max) + 1);
    header_line = sprintf(rinex.RinexConfig.header_format_spec, data, label);
end
