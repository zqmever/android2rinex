function all_properties = search_format_spec(data_header)
    this_class_name = strcat('android.formatSpec.', data_header);
    if exist(this_class_name, 'class') == 8
        all_properties = properties(this_class_name);
    else
        all_properties = {};
    end
end
