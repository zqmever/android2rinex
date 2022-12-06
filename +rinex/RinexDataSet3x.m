classdef RinexDataSet3x < rinex.RinexDataSet
    
    properties
        code_type;
    end

    methods
        function self = RinexDataSet3x(version)
            % [MANDATORY] RINEX VERSION
            self.header.version = version;

            % [MANDATORY] MARKER TYPE
            self.header.marker_type = 'GEODETIC';

            % [MANDATORY] SYS / # / OBS TYPES
            self.header.sys_obs_types = struct('system', {}, 'obs_type', {});
            
            % [MANDATORY] SYS / PHASE SHIFTS
            self.header.sys_phase_shifts = struct('system', {}, 'obs_type', {}, 'phase_shift', {}, 'satellite', {});
            
            % [OPTIONAL] GLONASS SLOT / FRQ #
            self.header.glonass_slot_frq_num = struct('glonass_slot', {}, 'freq_num', {});

            self.code_type = repmat("N", size(self.epoch_time));
        end

        function self = updateHeader(self)
            [satellite_list_unique, ia, ~] = unique(self.satellite, "rows");
            system_list_unique = unique(self.satellite(:,1));

            % update the time of the first epoch
            self.header.time_first_epoch = self.epoch_time(1);

            % update SYS / # / OBS TYPES 
            self.header.sys_obs_types(:) = [];
            for i = 1:length(system_list_unique)
                self.header.sys_obs_types(i).system = system_list_unique(i);

                this_satellite_list = self.satellite(:,1) == system_list_unique(i);
                self.header.sys_obs_types(i).obs_type = unique(strcat(num2str(self.frequency_band(this_satellite_list)), self.code_type(this_satellite_list)));
            end

            % update SYS / PHASE SHIFTS
            self.header.sys_phase_shifts(:) = [];
            if any(self.header.observation_type == "L")
                for i = 1:length(system_list_unique)
                    for j = 1:length(self.header.sys_obs_types(i).obs_type)
                        self.header.sys_phase_shifts(end+1).system = system_list_unique(i);
                        self.header.sys_phase_shifts(end).obs_type = self.header.sys_obs_types(i).obs_type(j);
                        self.header.sys_phase_shifts(end).phase_shift = 0;
                        self.header.sys_phase_shifts(end).satellite = [];
                    end
                end
            end

            % update GLONASS SLOT / FRQ #
            self.header.glonass_slot_frq_num(:) = [];
            if any(rinex.Constellation.GLONASS == system_list_unique)
                this_glonass_index = satellite_list_unique(:,1) == rinex.Constellation.GLONASS;
                this_glonass_list = satellite_list_unique(this_glonass_index, :);
                this_glonass_freq_num = self.glo_freq_num(ia(this_glonass_index));

                for i = 1:length(this_glonass_list)
                    self.header.glonass_slot_frq_num(i).glonass_slot = this_glonass_list(i,:);
                    self.header.glonass_slot_frq_num(i).freq_num     = this_glonass_freq_num(i);
                end
            end
        end
    end

    methods (Access = protected)
        function writeHeader(self, file_id)
            self.writeLine(file_id, rinex.getHeaderLine('RINEX VERSION / TYPE', sprintf('%9.2f%11s%-20s%-20s', self.header.version, ' ', self.header.file_type, self.header.satellite_system)));
            self.writeLine(file_id, rinex.getHeaderLine('PGM / RUN BY / DATE',  sprintf('%-20s%-20s%-20s', self.header.program_generator, self.header.run_by, self.header.creation_date)));
            self.writeLine(file_id, rinex.getHeaderLine('MARKER NAME',          self.header.marker_name));
            self.writeLine(file_id, rinex.getHeaderLine('MARKER TYPE',          self.header.marker_type));
            self.writeLine(file_id, rinex.getHeaderLine('OBSERVER / AGENCY',    sprintf('%-20s%-40s', self.header.observer, self.header.agency)));
            self.writeLine(file_id, rinex.getHeaderLine('REC # / TYPE / VERS',  sprintf('%-20s%-20s%-20s', self.header.receiver_number, self.header.receiver_type, self.header.receiver_version)));
            self.writeLine(file_id, rinex.getHeaderLine('ANT # / TYPE',         sprintf('%-20s%-40s', self.header.antenna_number, self.header.antenna_type)));
            self.writeLine(file_id, rinex.getHeaderLine('APPROX POSITION XYZ',  sprintf('%14.4f%14.4f%14.4f', self.header.approx_position_xyz)));
            self.writeLine(file_id, rinex.getHeaderLine('ANTENNA: DELTA H/E/N', sprintf('%14.4f%14.4f%14.4f', self.header.antenna_height, self.header.antenna_eccentricities)));
            
            for i = 1:length(self.header.sys_obs_types)
                this_obs_type_list = append(reshape(self.header.observation_type, [], 1), reshape(self.header.sys_obs_types(i).obs_type, 1, []));
                this_obs_type_string = sprintf('%4s', this_obs_type_list(:));
                this_line = sprintf('%s%5d%s', rinex.Constellation(self.header.sys_obs_types(i).system).toString(), numel(this_obs_type_list), this_obs_type_string);
                self.writeLine(file_id, rinex.getLongHeaderLine('SYS / # / OBS TYPES', this_line, 6, 4));
            end

            for i = 1:length(self.header.sys_phase_shifts)
                if ~isempty(self.header.sys_phase_shifts(i).satellite)
                    this_satellite_string = sprintf('%4s', strcat(rinex.Constellation(self.header.sys_phase_shifts(i).satellite(:,1)).toString(), self.header.sys_phase_shifts(i).satellite(:,2)));
                else
                    this_satellite_string = '';
                end
                this_line = sprintf('%s%4s%9.5f%4d%s', rinex.Constellation(self.header.sys_phase_shifts(i).system).toString(), strcat("L", self.header.sys_phase_shifts(i).obs_type), self.header.sys_phase_shifts(i).phase_shift, this_satellite_string);
                self.writeLine(file_id, rinex.getLongHeaderLine('SYS / PHASE SHIFTS', this_line, 18, 4));
            end
            
            if ~isempty(self.header.glonass_slot_frq_num)
                this_glonass_freq_string = '';
                for i = 1:length(self.header.glonass_slot_frq_num)
                    this_glonass_freq_string = sprintf('%s%s%02d%3d', this_glonass_freq_string, rinex.Constellation(self.header.glonass_slot_frq_num(i).glonass_slot(1)).toString(), self.header.glonass_slot_frq_num(i).glonass_slot(2), self.header.glonass_slot_frq_num(i).freq_num);
                end
                this_line = sprintf('%3d %s', length(self.header.glonass_slot_frq_num), this_glonass_freq_string);
                self.writeLine(file_id, rinex.getLongHeaderLine('GLONASS SLOT / FRQ #', this_line, 4, 6));
            end
            
            self.header.time_first_epoch.Format = '  uuuu    MM    dd    HH    mm    ss.SSSSSSS';
            self.writeLine(file_id, rinex.getHeaderLine('TIME OF FIRST OBS',    sprintf('%s%8s', self.header.time_first_epoch, self.header.time_system_first_epoch)));
            
            self.writeLine(file_id, rinex.getHeaderLine('END OF HEADER', ''));
        end

        function writeBody(self, file_id)
            epoch_time_unique = unique(self.epoch_time);
            epoch_time_unique.Format = 'uuuu MM dd HH mm ss.SSSSSSS';

            obs_code = strcat(num2str(self.frequency_band), self.code_type);

            for i = 1:length(epoch_time_unique)
                this_epoch_index = self.epoch_time == epoch_time_unique(i);
                this_satellite_unique = unique(self.satellite(this_epoch_index, :), "rows");

                n_satellites = size(this_satellite_unique, 1);

                self.writeLine(file_id, sprintf('> %s%3d%3d%6s%15.12f', epoch_time_unique(i), 0, n_satellites, '', 0))

                for j = 1:n_satellites
                    this_line = sprintf('%s%02d', rinex.Constellation(this_satellite_unique(j, 1)).toString(), this_satellite_unique(j, 2));

                    this_obs_type_list = self.header.sys_obs_types(vertcat(self.header.sys_obs_types.system) == this_satellite_unique(j, 1)).obs_type;
                    for k = 1:length(this_obs_type_list)
                        this_obs_index = this_epoch_index & all(self.satellite == this_satellite_unique(j, :), 2) & obs_code == this_obs_type_list(k);

                        for m = 1:length(self.header.observation_type)
                            this_meas = nan(1,3);
                            if any(this_obs_index)
                                switch self.header.observation_type(m)
                                    case "C"
                                        this_meas = self.pseudorange(this_obs_index, :);
                                    case "L"
                                        this_meas = self.carrier_phase(this_obs_index, :);
                                    case "D"
                                        this_meas = self.doppler(this_obs_index, :);
                                    case "S"
                                        this_meas = self.signal_strength(this_obs_index, :);
                                end
                            end
                            this_line = sprintf('%s%s', this_line, self.getDataString(this_meas));
                        end
                    end
                    self.writeLine(file_id, this_line);
                end
            end
        end
    end
end
