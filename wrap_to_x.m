function value = wrap_to_x(value, x)
    % wrap value to [-x x]
    q = (value < -x) | (x < value);
    value(q) = wrap_to_2x(value(q) + x, x) - x;
end