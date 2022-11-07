function all_properties = search(data_header)
    % generate the class name
    this_class_name = strcat('android.formatSpec.', data_header);
    % check if the class exists
    if exist(this_class_name, 'class') == 8
        % if it exists, return its properties
        all_properties = properties(this_class_name);
    else
        % if it not exists, return an empty cell
        all_properties = {};
    end
end
