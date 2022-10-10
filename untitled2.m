

% write_rinex_header(1, 2.11)
get_version_line(3.04)
get_pgm_line('huawei', datetime)

get_header_line('', 'END OF HEADER')


function get_header()
end

function line = get_pgm_line(run_by, date)
    label = 'PGM / RUN BY / DATE';
    pgm = 'Test';
    date.Format = 'uuuuMMdd HHmmss';
%     date.timezone = 'UTC';
    text = sprintf('%-20s%-20s%-15s UTC', pgm, run_by, date);
    line = get_header_line(text, label);
end

function line = get_version_line(version)
    label = 'RINEX VERSION / TYPE';
    text = sprintf('%-20s%-20s%-20s', sprintf('% 9.2f', version), 'OBSERVATION DATA', 'M (MIXED)');
    line = get_header_line(text, label);
end

function line = get_comment_line(data)
    label = 'COMMENT';
    line = get_header_line(data, label);
end

