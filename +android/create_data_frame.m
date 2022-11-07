function data_frame = create_data_frame(raw_line)
    raw_cell = textscan(raw_line, '%s', 'Delimiter', {',', '#'}, 'MultipleDelimsAsOne', true);
    raw_cell = raw_cell{1};
    data_frame = android.DataFrame(raw_cell{1});
    data_frame.header = raw_cell(2:end);
end