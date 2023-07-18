function batchFitRhythms(xData, matFile)
% batchFitRhythms run a batch of PATS, and save the results
%
% batchFitRhythms(xData, matFile)
%
% Input Variables:
%   xData   - cell containing sets of duration data (in seconds)
%   matFile - cumulative probability values for each data point in [xData]
%
% This function relies on Optimization Toolbox, [fftRhythms] function, and the
% functions in the lib/ directory. You may execute "addpath('lib');" to add the
% lib/ directory to MATLAB path.
%
% See also FITRHYTHMS

	% Load variables defined in CommonVars_CDF.m.
	CommonVars_CDF;

	% Model frequencies and lower/upper bound frequncies.
	modelFreqs = (7:9)';
	freqBounds = [modelFreqs - .5, modelFreqs + .5];

	% Fitting options for fitRhythms() function.
	fitOptions = optimoptions('lsqcurvefit', ...
		'MaxIterations',       10000, ...
		'OptimalityTolerance', 1e-6, ...
		'Display',             'off');

	simCount = numel(xData);
	dataDims = num2cell(size(xData));
	cpData  = cell(dataDims{:});
	rcdfB   = cell(dataDims{:});
	cdfB    = cell(dataDims{:});
	varExpl = cell(dataDims{:});
	ampRCDF = cell(dataDims{:});
	ampEstd = cell(dataDims{:});

	fprintf('fitting batch |');
	progText = { '\b:', '1', '\b2', '\b3', '\b4', '\b5', '\b6', '\b7', '\b8', '\b9' };
	% For each hypothetical participant:
	for s = 1:simCount
		fprintf(progText{mod(s, 10) + 1});
		% Analyze rhythms. See Tutorial_FitRhythms_LognormCDF.m and the help
		% document for each function for more details.
		[xData{s}, cpData{s}] = cdfdata(xData{s});
		[rcdfB{s}, rcdfAdjRsq, cdfB{s}, cdfAdjRsq] = fitRhythms( ...
			freqBounds, rhythmB0, cdfFun, cdfB0, xData{s}, cpData{s}, ...
			cdfBlb, cdfBub, fitOptions);
		varExpl{s} = (rcdfAdjRsq - cdfAdjRsq) / (1 - cdfAdjRsq);
		ampRCDF{s} = rcdfB{s}(:, end);
		ampEstd{s} = ampRCDF{s} .* varExpl{s};
	end
	% Calculate average PATS estimates within 7-9 Hz frequency range.
	avgAmpRCDF7_9Hz = cellfun(@mean, ampRCDF); %#ok<NASGU>
	avgAmpEstd7_9Hz = cellfun(@mean, ampEstd); %#ok<NASGU>
	fprintf('|\n');

	% Save PATS results to a given path.
	clear progText s;
	save(matFile);
end