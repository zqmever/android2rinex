function data_frame = fillDataFrame(data_frame, raw_data)
    % init the output
    data_frame.data = table.empty;

    % check if the header is empty
    if isempty(data_frame.header)
        warning('The header of the data frame for %s is empty. ', data_frame.id);
        return;
    end

    % check for pre-defined format specs
    [formatspec_obj, formatspec_list] = android.formatSpec.search(data_frame.id);
    if isempty(formatspec_obj)
        warning('Cannot find format specifiers for %s. ', data_frame.id);
    end

    % generate the format spec string
    undefined_formatspec = '%s';
    formatspec_string = '';
    in_list = ismember(data_frame.header, formatspec_list);
    for i = 1:length(data_frame.header)
        if in_list(i)
            formatspec_string = append(formatspec_string, formatspec_obj.(data_frame.header{i}));
        else
            formatspec_string = strcat(formatspec_string, undefined_formatspec);
        end
    end

    % check for matched data
    matched_data_index = strcmp(raw_data{1}, data_frame.id);
    if ~any(matched_data_index)
        warning('Cannot find any data for %s. ', data_frame.id);
        return;
    end

    % parse the data
    matched_data = raw_data{2}(matched_data_index);
    matched_data_cell = cell(size(matched_data, 1), length(data_frame.header));
    for i = 1:size(matched_data, 1)
        matched_data_cell(i,:) = textscan(matched_data{i}, formatspec_string, 'Delimiter', ',');
    end
    data_frame.data = cell2table(matched_data_cell, 'VariableNames', data_frame.header);
end
