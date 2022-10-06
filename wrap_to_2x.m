function value = wrap_to_2x(value, x)
    % wrap value to [0 2x]
    positiveInput = (value > 0);
    value = mod(value, 2*x);
    value((value == 0) & positiveInput) = 2*x;
end