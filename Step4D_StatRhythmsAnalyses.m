%
% Script for statistical tests reported in Table 3.
%
% This script relies on bayesFactor Toolbox, which requires Statistics and
% Machine Learning Toolbox. The bayesFactor toolbox files, including a LICENSE
% file, are located under the lib/bayesFactor-2.2.0/ directory.
%
% bayesFactor Toolbox github repository: https://klabhub.github.io/bayesFactor/
%

clear;
addpath('lib', fullfile('lib', 'bayesFactor-2.2.0'));

% Number of samples in each batch.
nSamples = [100, 200, 400, 800];


fprintf('================================\n');
% For each batch:
for s = 1:length(nSamples)
	% Load data and analysis results.
	fitMatFile = sprintf('Step4_FitRhythms_%ddp-sample.mat', nSamples(s));
	fftMatFile = sprintf('Step4_FFTRhythms_%ddp-sample.mat', nSamples(s));
	fitData = load(fullfile('data-fitted', fitMatFile));
	fftData = load(fullfile('data-fitted', fftMatFile));

	% Data density estimate.
	dataDensity = zeros(size(fitData.xData));
	for i = 1:numel(fitData.xData)
		q05 = quantile(fitData.xData{i}, .05);
		q95 = quantile(fitData.xData{i}, .95);
		dataDensity(i) = sum(fitData.xData{i} > q05 & fitData.xData{i} < q95 ) / (q95 - q05);
	end

	fprintf('Bayesian t-tests (%d dp/sample)\n', nSamples(s));
	fprintf('--------------------------------\n');

	% Print data density estimate.
	fprintf('DataDensity: %.2f dp/sec\n', mean(mean(dataDensity)));

	% Print t-test results for estimated amplitude.
	[BF10, pValue] = bf.ttest(fitData.avgAmpEstd7_9Hz(1, :)', fitData.avgAmpEstd7_9Hz(2, :)');
	if (BF10 < 10000) && (BF10 > 0.01)
		fprintf('EstdAmp: BF\x2081\x2080=%.2f, p=%.2f\n', BF10, pValue);
	else
		fprintf('EstdAmp: BF\x2081\x2080=%.2e, p=%.2f\n', BF10, pValue);
	end

	% Print t-test results for rCDF amplitude parameter.
	[BF10, pValue] = bf.ttest(fitData.avgAmpRCDF7_9Hz(1, :)', fitData.avgAmpRCDF7_9Hz(2, :)');
	if (BF10 < 10000) && (BF10 > 0.01)
		fprintf('rCDFAmp: BF\x2081\x2080=%.2f, p=%.2f\n', BF10, pValue);
	else
		fprintf('rCDFAmp: BF\x2081\x2080=%.2e, p=%.2f\n', BF10, pValue);
	end

	% Print t-test results for spectral amplitude.
	[BF10, pValue] = bf.ttest(fftData.avgSpecAmp7_9Hz(1, :)', fftData.avgSpecAmp7_9Hz(2, :)');
	if (BF10 < 10000) && (BF10 > 0.01)
		fprintf('SpecAmp: BF\x2081\x2080=%.2f, p=%.2f\n', BF10, pValue);
	else
		fprintf('SpecAmp: BF\x2081\x2080=%.2e, p=%.2f\n', BF10, pValue);
	end

	fprintf('================================\n');
end

