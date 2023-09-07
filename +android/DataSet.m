classdef DataSet < handle
    properties (SetAccess = protected)
        source_file string;
    end

    properties
        info (1,1) struct;
        data (:,1) android.DataFrame;
    end

    methods
        function self = DataSet(source_file_full_path)
            self.source_file = source_file_full_path;

            self.info.version      = 'Unknown';
            self.info.platform     = 'Unknown';
            self.info.manufacturer = 'Unknown';
            self.info.model        = 'Unknown';
        end
    end

    methods
        function this_data_frame = getDataFrame(self, data_frame_id)
            this_data_frame_index = strcmpi({self.data.id}, data_frame_id);
            this_data_frame = self.data(this_data_frame_index);
        end
    end
end