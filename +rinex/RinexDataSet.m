classdef RinexDataset < handle

    properties (SetAccess = protected)
        source_file string;
    end

    properties
        header (1,1) struct;
    end

    properties
        epoch_time (:,1) datetime;

        % satellite column defination: 
        %   [constellation, PRN]
        satellite (:,2) uint16;

        % measurement column defination: 
        %   [meas, loss_of_lock_indicator, signal_strength_indicator]
        pseudorange (:,3) double;
        doppler     (:,3) double;
        phase       (:,3) double;
        strength    (:,3) double;

        % frequency band
        freq_band (:,1) uint8;
        % code (aka: channel)
        code_type (:,1) char;

        glo_freq_k (:,1) int8;
    end

    methods
        function self = set.epoch_time(self, epoch_time)
            epoch_time.Format = 'uuuu MM dd HH mm ss.SSSSSSS';
            self.epoch_time = epoch_time;
        end
    end

    methods
        function self = RinexDataset(source_file)
            self.source_file = source_file;
        end
    end
end