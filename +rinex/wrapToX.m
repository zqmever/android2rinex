function value = wrapToX(value, x)
    % wrap value to [-x x]
    q = (value < -x) | (x < value);
    value(q) = rinex.wrapTo2x(value(q) + x, x) - x;
end