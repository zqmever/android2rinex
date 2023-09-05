function [formatspec_obj, all_formatspecs] = search(data_header)
    % generate the class name
    this_class_name = strcat('android.formatSpec.', data_header);
    % check if the class exists
    if exist(this_class_name, 'class') == 8
        % if it exists, return the class and its properties
        formatspec_obj  = feval(this_class_name);
        all_formatspecs = properties(this_class_name);
    else
        % if it not exists, return an empty cell
        formatspec_obj  = [];
        all_formatspecs = {};
    end
end
