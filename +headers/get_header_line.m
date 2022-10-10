function header_line = get_header_line(data, label)
    text_length_max = 60;
    data = extractBefore(data, min(strlength(data), text_length_max) + 1);
    label = extractBefore(label, min(strlength(label), text_length_max) + 1);
    header_line = sprintf('%-60s%-20s', data, label);
end
