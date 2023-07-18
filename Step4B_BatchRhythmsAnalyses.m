%
% Script for sampling either 100, 200, 400, or 800 data points per condition
% from the data pool of 200 hypothetical participants, and then analyzing the
% data with PATS and with spectral analysis (Example 2, second part). The data
% sampled or generated with this script will be saved under the data-fitted/
% directory.
%
% This script relies on Optimization Toolbox.
%

clear;
addpath('lib');

% Set random seed. The seed 'rhyt' will generate the data shown in Figure 5
% reported in the paper. You can use "rng('shuffle');" instead.
rngchar('rhyt');

% Load the data pool.
load(fullfile('data-fitted', 'Step4_DataPool.mat'));

% Number of samples for each batch.
nSamples = [100, 200, 400, 800];



% For each batch:
for s = 1:length(nSamples)
	% Sample data from the data pool of 200 hypothetical participants.
	xSample = sampleData(xData, nSamples(s));

	% Analyze rhythms with PATS and with spectral analysis, and save results
	% under the data-fitted/ directory.
	fitMatFile = sprintf('Step4_FitRhythms_%ddp-sample.mat', nSamples(s));
	fftMatFile = sprintf('Step4_FFTRhythms_%ddp-sample.mat', nSamples(s));
	batchFitRhythms(xSample, fullfile('data-fitted', fitMatFile));
	batchFFTRhythms(xSample, fullfile('data-fitted', fftMatFile));
end



% Sample data from the data pool of 200 hypothetical participants.
function xSample = sampleData(xData, nDataPoints)
	xSample = cell(size(xData));
	% For each condition of each hypothetical participant:
	for s = 1:numel(xData)
		% Sample with replacement.
		sampleIdx = ceil(rand(1, nDataPoints) * length(xData{s}));
		xSample{s} = xData{s}(sampleIdx);
	end
end
