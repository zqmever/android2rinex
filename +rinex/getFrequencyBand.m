function [freq_band, glo_freq_k] = getFrequencyBand(frequency, constellation)

    base_freq = 10.23e6;
    i_freq = round(frequency / base_freq, 1);

    freq_band = zeros(size(frequency));
    glo_freq_k = freq_band;
    
    glo_filter = constellation == rinex.Constellation.GLONASS;

    if any(~glo_filter)
        freq_band(i_freq == 154)   = 1;
        freq_band(i_freq == 120)   = 2;
        freq_band(i_freq == 115)   = 5;
        freq_band(i_freq == 118)   = 7;
        freq_band(i_freq == 125)   = 6;
        freq_band(i_freq == 116.5) = 8;
        freq_band(i_freq == 152.6) = 2;
        freq_band(i_freq == 124)   = 6;
        freq_band(i_freq == 243.6) = 9;
    end
    
    if any(glo_filter)
        freq_band(glo_filter & i_freq == 156.5) = 4;
        freq_band(glo_filter & i_freq == 122)   = 6;
        freq_band(glo_filter & i_freq == 117.5) = 3;

        glo_g1_k = round((frequency - 1602e6) ./ (9 / 16 * 1e6), 1);
        glo_g1 = glo_filter & glo_g1_k >= -7 & glo_g1_k <= 12 & mod(glo_g1_k, 1) == 0;
        glo_freq_k(glo_g1) = glo_g1_k(glo_g1);
        freq_band(glo_g1) = 1;

        glo_g2_k = round((frequency - 1246e6) ./ (7 / 16 * 1e6), 1);
        glo_g2 = glo_filter & glo_g2_k >= -7 & glo_g2_k <= 12 & mod(glo_g2_k, 1) == 0;
        glo_freq_k(glo_g2) = glo_g2_k(glo_g2);
        freq_band(glo_g2) = 2;
    end
end
