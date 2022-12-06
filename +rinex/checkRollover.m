function [prNanos, tRxNanos]  = checkRollover(tRxNanos, tTxNanos, rollover_nanos)

    if nargin < 3
        rollover_nanos = rinex.GnssConstants.WEEKSECNANOS;
    end
    
    prNanos  = tRxNanos - tTxNanos;
    
    iRollover = prNanos > rollover_nanos / 2;

    if any(iRollover)
        warning('Rollover detected in time tags. Adjusting ... \n')
        prS = prNanos(iRollover);
        prS = rinex.wrapToX(prS, rollover_nanos / 2);
        % prS are in the range [-WEEKSEC/2 : WEEKSEC/2];
        % check that common bias is not huge (like, bigger than 10s)
        maxBiasSeconds = 10 * 1e9;
        if any(prS > maxBiasSeconds)
            error('Failed to correct rollover. ')
        else
            prNanos(iRollover) = prS; % put back into prSeconds vector
            % Now adjust tRxSeconds by the same amount:
            tRxNanos(iRollover) = tTxNanos(iRollover) + prS;
            fprintf('Corrected rollover. \n')
        end
    end
end