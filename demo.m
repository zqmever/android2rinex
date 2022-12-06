% demo

%% get the test data
% specify the folder
test_data_folder = fullfile(pwd, 'tests');
% specify the input and output file names
test_data_file_input  = 'gnss_log_2022_10_03_11_27_19.txt';
test_data_file_output = 'aa.obs';

% get the full path to the input file
test_data_file_full = fullfile(test_data_folder, test_data_file_input);

%% read the Android GNSS raw dataset
gnss_raw_dataset = android.readRawFile(test_data_file_full);

%% convert the Android raw data to a RINEX dataset
% first create a RINEX dataset with the specified version
rinex_version = 3.04;
rinex_dataset = rinex.newRinexDataSet(rinex_version);
% then fill the data 
rinex_dataset = rinex.convertAndroidToRinex(gnss_raw_dataset, rinex_dataset);

% OR let the program create a RINEX dataset itself (using the default RINEX version) 
% rinex_dataset = rinex.convertAndroidToRinex(gnss_raw_dataset);

%% make some changes to the header
% blah blah blah ...

% update the header
% [IMPORTANT] If some changes have been made to the header, it is necessary to re-update the header
rinex_dataset.updateHeader();

%% write to a RINEX file
% get the full path to the input file
rinex_file = fullfile(test_data_folder, test_data_file_output);
% write the output file
rinex_dataset.writeToFile(rinex_file)
