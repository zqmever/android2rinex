
line = '# Version:  v3.0.5.6 Platform: 12 Manufacturer: HONOR Model: LGE-AN00';

split(line, {': ', ':', ' '})
gnss_raw =struct
this_header=regexp(line, '([A-Z][A-Za-z]+):[ ]*([\w\S]*)', 'tokens')
for i = 1:length(this_header)
    gnss_raw.(lower(this_header{i}{1})) = this_header{i}{2};
end
