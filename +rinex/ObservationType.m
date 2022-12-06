classdef ObservationType < uint8
    % The enumeration class for ObservationType.
    %
    
    enumeration
        pseudorange     ('C');
        carrier_phase   ('L');
        doppler         ('D');
        signal_strength ('S');
    end
end
