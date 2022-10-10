
raw_file = fullfile(pwd, 'tests', 'gnss_log_2022_10_03_11_27_19.txt');

gnss_raw = read_raw_file(raw_file);

% a = '1664792839411,354.9253700,,C,374333049278073';
% a(2,:) = {'1664792839411,354.9253700,,C,374333049278073'};


% fid = fopen(raw_file, 'r');
% raw_data = textscan(fid, '%[^,]%*[,]%[^\n]', 'CommentStyle', '#');
% fclose(fid);
% 
% this_label = 'Raw';
% this_raw_sort = strcmp(raw_data{1}, this_label);
% a = raw_data{2}(this_raw_sort);
% 
% h = gnss_raw.header.Raw;
% fs = '';
% 
% for i = 1:length(h)
%     fs = [fs, FormatSpec.(h{i}).value];
% end
% 
% aa = cell(size(a, 1), length(h));
% 
% for i = 1:size(a, 1)
%     aa(i,:) = textscan(a{i}, fs, 'Delimiter', ',');
% end
% 

