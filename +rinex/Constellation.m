classdef Constellation < uint16
    % The enumeration class for constellation.
    %
    
    enumeration
        UNKNOWN (0);
        
        GPS     (1);
        GLONASS (3);
        GALILEO (6);
        BEIDOU  (5);
        
        QZSS    (4);
        SBSS    (2);
        IRNSS   (7);
    end
    
    methods
        function constellation_str = toString(self)
            switch self
                case rinex.Constellation.GPS
                    constellation_str = "G";
                case rinex.Constellation.GLONASS
                    constellation_str = "R";
                case rinex.Constellation.GALILEO
                    constellation_str = "E";
                case rinex.Constellation.BEIDOU
                    constellation_str = "C";
                case rinex.Constellation.QZSS
                    constellation_str = "J";
                case rinex.Constellation.SBSS
                    constellation_str = "S";
                case rinex.Constellation.IRNSS
                    constellation_str = "I";
                otherwise
                    constellation_str = "U";
            end
        end
    end
end
