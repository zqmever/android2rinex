classdef RinexConfig

    properties (Constant)
        data_length_max = 60;
        label_length_max = 20;
        header_length_max = rinex.RinexConfig.data_length_max + rinex.RinexConfig.label_length_max;
        header_format_spec = sprintf("%%-%ds%%-%ds", rinex.RinexConfig.data_length_max, rinex.RinexConfig.label_length_max);
    end
end