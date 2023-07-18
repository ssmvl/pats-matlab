%
% Script for statistical tests reported in Table 2.
%
% This script relies on bayesFactor Toolbox, which requires Statistics and
% Machine Learning Toolbox. The bayesFactor toolbox files, including a LICENSE
% file, are located under the lib/bayesFactor-2.2.0/ directory.
%
% bayesFactor Toolbox github repository: https://klabhub.github.io/bayesFactor/
%

clear;
addpath('lib', fullfile('lib', 'bayesFactor-2.2.0'));

% Load rhythmic transformation and random walk model parameters.
load(fullfile('data-fitted', 'Step3_BatchArgs.mat'));

% True amplitude values.
rmatTrueAmp = rhythmKs;
rmatTrueAmp(:, 2) = 1;


warning('off', 'MATLAB:integral:NonFiniteValue');
fprintf('=========================\n');
% For each batch:
for dp = 1:length(nDataPoints)
	% Load data and analysis results.
	fitMatFile = sprintf('Step3_FitRhythms_%ddp-sim.mat', nDataPoints(dp));
	fftMatFile = sprintf('Step3_FFTRhythms_%ddp-sim.mat', nDataPoints(dp));
	fitResult = load(fullfile('data-fitted', fitMatFile));
	fftResult = load(fullfile('data-fitted', fftMatFile));

	% Frequency component strength estimates from PATS and spectral analysis.
	avgAmpRCDF = fitResult.avgAmpRCDF7_9Hz;
	avgAmpEstd = fitResult.avgAmpEstd7_9Hz;
	avgSpecAmp = fftResult.avgSpecAmp7_9Hz;

	% Estimate the slope of the regression line.
	slopeAmpEstd = regress(avgAmpEstd, rmatTrueAmp);
	slopeAmpRCDF = regress(avgAmpRCDF, rmatTrueAmp);
	slopeSpecAmp = regress(avgSpecAmp, rmatTrueAmp);

	% Calculate resiudals and prepare for partial correlations.
	rmatSpecAmp = avgSpecAmp;
	rmatSpecAmp(:, 2) = 1;
	[~, ~, residData] = regress(rhythmKs, rmatSpecAmp);
	[~, ~, residEstd] = regress(avgAmpEstd, rmatSpecAmp);
	[~, ~, residRCDF] = regress(avgAmpRCDF, rmatSpecAmp);


	fprintf('Correlations (%d dp/sim)\n', nDataPoints(dp));
	fprintf('-------------------------\n');

	% Print correlation b/w true amplitude and estimated amplitude.
	[BF10, r, pValue] = bf.corr(rhythmKs, avgAmpEstd);
	fprintf('TrueAmp<->EstdAmp: r=%.2f, BF\x2081\x2080=%.2e, p=%.3f; slope=%.2f\n', r, BF10, pValue, slopeAmpEstd(1));

	% Print correlation b/w true amplitude and rCDF amplitude parameter.
	[BF10, r, pValue] = bf.corr(rhythmKs, avgAmpRCDF);
	fprintf('TrueAmp<->rCDFAmp: r=%.2f, BF\x2081\x2080=%.2e, p=%.3f; slope=%.2f\n', r, BF10, pValue, slopeAmpRCDF(1));

	% Print correlation b/w true amplitude and spectral power.
	[BF10, r, pValue] = bf.corr(rhythmKs, avgSpecAmp);
	fprintf('TrueAmp<->SpecAmp: r=%.2f, BF\x2081\x2080=%.2e, p=%.3f; slope=%.2f\n', r, BF10, pValue, slopeSpecAmp(1));

	% Print partial correlation b/w true amplitude and estimated amplitude,
	% controlling for spectral power.
	[BF10, r, pValue] = bf.corr(residData, residEstd);
	if (BF10 < 10000) && (BF10 > 0.01)
		fprintf('Partial TrueAmp<->EstdAmp: r=%.2f, BF\x2081\x2080=%.2f, p=%.2f\n', r, BF10, pValue);
	else
		fprintf('Partial TrueAmp<->EstdAmp: r=%.2f, BF\x2081\x2080=%.2e, p=%.2f\n', r, BF10, pValue);
	end

	% Print partial correlation b/w true amplitude and rCDF amplitude parameter,
	% controlling for spectral power.
	[BF10, r, pValue] = bf.corr(residData, residRCDF);
	if (BF10 < 10000) && (BF10 > 0.01)
		fprintf('Partial TrueAmp<->rCDFAmp: r=%.2f, BF\x2081\x2080=%.2f, p=%.2f\n', r, BF10, pValue);
	else
		fprintf('Partial TrueAmp<->rCDFAmp: r=%.2f, BF\x2081\x2080=%.2e, p=%.2f\n', r, BF10, pValue);
	end

	fprintf('=========================\n');
end
warning('on', 'MATLAB:integral:NonFiniteValue');
