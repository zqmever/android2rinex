classdef DataSet < handle
    properties
        info;
        data (:,1) android.DataFrame;
    end

    methods
        function self = DataSet()
            self.info.version      = 'Unknown';
            self.info.platform     = 'Unknown';
            self.info.manufacturer = 'Unknown';
            self.info.model        = 'Unknown';
        end
    end
end