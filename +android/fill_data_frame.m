function data_frame = fill_data_frame(data_frame, raw_data)
    
    data_frame.data = table.empty;

    if isempty(data_frame.header)
        return;
    end

    formatspec_list = android.search_format_spec(data_frame.id);
    if ~isempty(formatspec_list)
        this_formatspec = '';
        for i = 1:length(data_frame.header)
            if any(strcmp(formatspec_list, data_frame.header{i}))
                this_formatspec = strcat(this_formatspec, android.formatSpec.(data_frame.id).(data_frame.header{i}));
            else
                this_formatspec = strcat(this_formatspec, '%s');
            end
        end
    else
        return;
    end

    raw_data_index = strcmp(raw_data{1}, data_frame.id);
    if any(raw_data_index)
        this_raw_data = raw_data{2}(raw_data_index);
        this_raw_cell = cell(size(this_raw_data, 1), length(data_frame.header));
        for i = 1:size(this_raw_data, 1)
            this_raw_cell(i,:) = textscan(this_raw_data{i}, this_formatspec, 'Delimiter', ',');
        end
        data_frame.data = cell2table(this_raw_cell, 'VariableNames', data_frame.header);
    else
        return;
    end
end
