function rtMsec = sampleFromCDF(numTrials, cdfFun, B)
% sampleFromCDF samples response times from a given CDF and given parameters
%   using the inverse transform sampling method
%
% rtMsec = sampleFromCDF(numTrials, cdfFun, B)
%
% Input Variables:
%   numTrials - number of trials to simulate
%   cdfFun    - CDF function; please refer to CommonVars_CDF.m
%   B         - parameters for the CDF function; this variable will be passed
%               on as the first input variable for [cdfFun]
%
% Output Variable:
%   rtMsec - sampled response times (in msec)

	% Ticks in msec, corresponding cumulative probability values.
	tickSec = 0:.001:100;
	cp = cdfFun(B, tickSec);
	% Trim cumulative probability values for the fixed point precision.
	cpMinIdx = find(cp < .000001, 1, 'last');
	cpMaxIdx = find(cp > .999999, 1);
	tickSec = tickSec(cpMinIdx:cpMaxIdx);
	cp = cp(cpMinIdx:cpMaxIdx);
	% Sample random cumulative probability values and convert to RT values.
	cpRand = rand(1, numTrials) * .999998 + .000001;
	rtMsec = spline(cp, tickSec, cpRand);
end