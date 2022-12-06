classdef (Abstract) RinexDataSet < handle
    
    % header
    properties
        header;
    end

    % body
    properties
        epoch_time;
        satellite;
        pseudorange;
        carrier_phase;
        doppler;
        signal_strength;
        frequency_band;
        glo_freq_num;
    end

    properties
        data;
    end

    properties (Access = protected)
        variable_names_types = [["epoch_time",     "datetime"];...
                                ["satellite",      "double"];...
                                ["pseudorange",    "double"];...
                                ["carrier_phase",  "double"];...
                                ["doppler",        "double"];...
                                ["signal_strengt", "double"];...
                                ["frequency_band", "double"];...
                                ["glo_freq_num",   "double"]];
    end

    methods (Access = public)
        function self = RinexDataSet()
            % init the header
            self.header = struct;

            % [MANDATORY] RINEX VERSION / TYPE
            self.header.version = 0;
            self.header.file_type = 'OBSERVATION DATA';
            self.header.satellite_system = 'M (MIXED)';

            % [MANDATORY] PGM / RUN BY / DATE
            self.header.program_generator = 'android2rinex';
            self.header.run_by = 'Android phone';
            self.header.creation_date = datetime('now', 'Format', 'uuuuMMdd HHmmss ''UTC', 'TimeZone', 'local');
            self.header.creation_date.TimeZone = 'UTC';
            
            % [MANDATORY] MARKER NAME
            self.header.marker_name = 'Google GnssLogger';
            
            % [MANDATORY] OBSERVER / AGENCY
            self.header.observer = 'UCL';
            self.header.agency = 'UCL: University College London';
            
            % [MANDATORY] REC # / TYPE / VERS
            self.header.receiver_number = 'Unknown';
            self.header.receiver_type = 'GnssLogger';
            self.header.receiver_version = 'Unknown';
            
            % [MANDATORY] ANT # / TYPE
            self.header.antenna_number = 'Unknown';
            self.header.antenna_type = 'Android Built-in Antenna';
            
            % [MANDATORY] APPROX POSITION XYZ
            self.header.approx_position_xyz = zeros(1, 3);
            
            % [MANDATORY] ANTENNA: DELTA H/E/N
            self.header.antenna_height = 0;
            self.header.antenna_eccentricities = zeros(1, 2);
            
            % [MANDATORY] TIME OF FIRST OBS
            self.header.time_first_epoch = NaT;
            self.header.time_system_first_epoch = 'GPS';

            self.header.observation_type = ["C", "L", "D", "S"];

            % DATA
            self.epoch_time      = NaT(0,1);
            self.satellite       = nan(0,2);
            self.pseudorange     = nan(0,3);
            self.carrier_phase   = nan(0,3);
            self.doppler         = nan(0,3);
            self.signal_strength = nan(0,3);
            self.frequency_band  = nan(0,1);
            self.glo_freq_num    = nan(0,1);

            variable_names_types = [["epoch_time",     "datetime"];...
                                    ["satellite",      "double"];...
                                    ["pseudorange",    "double"];...
                                    ["carrier_phase",  "double"];...
                                    ["doppler",        "double"];...
                                    ["signal_strengt", "double"];...
                                    ["frequency_band", "double"];...
                                    ["glo_freq_num",   "double"]];
            self.data = table('Size',[0, size(variable_names_types,1)],... 
	                          'VariableNames', variable_names_types(:,1),...
	                          'VariableTypes', variable_names_types(:,2));
        end

        function writeToFile(self, file_name)
            % open the file
            file_id = fopen(file_name, 'w+');

            % write the header
            self.writeHeader(file_id);
            
            % write the body
            self.writeBody(file_id);

            % close the file
            fclose(file_id);
        end
    end

    methods (Access = protected)
        function writeLine(~, file_id, line)
            fprintf(file_id, '%s\n', line);
        end

        function data_string = getDataString(~, data_slice)
            this_data = cell(1,3);
            for i = 1:min(3, length(data_slice))
                if ~isnan(data_slice(i))
                    this_data{i} = data_slice(i);
                end
            end
            data_string = sprintf('%14.3f%1d%1d', this_data{:});
        end
    end

    % interfaces
    methods (Access = public)
        updateHeader(self, rinex_config)
    end

    % protected interfaces
    methods (Access = protected)
        writeHeader(self, file_id);
        writeBody(self, file_id);
    end
end
