classdef DataFrame < handle
    properties (SetAccess = protected)
        id;
    end

    properties
        header (:,1) cell;
        data table;
    end

    methods
        function self = set.id(self, id)
            if (ischar(id) || isstring(id)) && strlength(id) > 0
                self.id = char(id);
            else
                error('Invalid id. ');
            end
        end
    end

    methods
        function self = DataFrame(id)
            self.id = id;
        end
    end
end
