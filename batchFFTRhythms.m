function batchFFTRhythms(xData, matFile)
% batchFFTRhythms run a batch of spectral analysis, and save the results
%
% batchFFTRhythms(xData, matFile)
%
% Input Variables:
%   xData   - cell containing sets of duration data (in seconds)
%   matFile - cumulative probability values for each data point in [xData]
%
% This function relies on Optimization Toolbox, [fftRhythms] function, and the
% functions in the lib/ directory. You may execute "addpath('lib');" to add the
% lib/ directory to MATLAB path.
%
% See also FFTRHYTHMS

	% Load variables defined in CommonVars_CDF.m.
	CommonVars_CDF;

	% Fitting options for fftRhythms() function (used in step 1).
	fitOptions = optimoptions('lsqcurvefit', ...
		'MaxIterations',       10000, ...
		'OptimalityTolerance', 1e-6, ...
		'Display',             'off');

	% Input variables for fftRhythms() function.
	pdfBinSize = .025;  % bin width of the probability density histogram in s
	fftWindow  = 1;     % FFT window width in s
	pdfFun  = @(B, x) lognpdf(x - B(3), B(1), B(2));  % lognormal PDF
	icdfFun = @(B, p) logninv(p, B(1), B(2)) + B(3);  % inverse lognormal CDF

	simCount = numel(xData);
	dataDims = num2cell(size(xData));
	cpData = cell(dataDims{:});
	fftAmp = cell(dataDims{:});
	pdfInfo(dataDims{:}) = struct( ...
		'tData',  [], ...
		'tEdges', [], ...
		'pRaw',   [], ...
		'pResid', [], ...
		'fftIdx', []);
	cdfB = cell(dataDims{:});

	fprintf('FFT-ing batch |');
	progText = { '\b:', '1', '\b2', '\b3', '\b4', '\b5', '\b6', '\b7', '\b8', '\b9' };
	% For each hypothetical participant:
	for s = 1:simCount
		fprintf(progText{mod(s, 10) + 1});
		% Conduct spectral analysis employed in Cha & Blake (2019).
		[xData{s}, cpData{s}] = cdfdata(xData{s});
		[fftAmp{s}, pdfInfo(s), cdfB{s}] = fftRhythms( ...
			pdfBinSize, pdfFun, fftWindow, icdfFun, cdfFun, cdfB0, ...
			xData{s}, cpData{s}, cdfBlb, cdfBub, fitOptions);
	end
	% Calculate average spectral power within 7-9 Hz frequency range.
	avgSpecAmp7_9Hz = cellfun(@(a) mean(a(7:9)), fftAmp); %#ok<NASGU>
	fprintf('|\n');

	% Save spectral analysis results to a given path.
	clear progText s;
	save(matFile);
end