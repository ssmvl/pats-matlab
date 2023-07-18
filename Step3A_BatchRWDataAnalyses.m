%
% Script for running 4 batches that generate either 100, 200, 400, or 800 data
% points from 1000 hypothetical participants, and then analyzing the data with
% PATS and with spectral analysis (Example 2, first part). The data generated
% with this script will be saved under the data-fitted/ directory.
%
% This script relies on Optimization Toolbox.
%

clear;
addpath('lib');

% Set random seed. The seed 'rwda' will generate the data shown in Figure 4
% reported in the paper. You can use "rng('shuffle');" instead.
rngchar('rwda');

% Number of hypothetical participants and number of data points.
simCount = 1000;
nDataPoints = [100, 200, 400, 800];

% Rhythmic transformation parameters for the modified random walk model.
rhythmF = 8;
rhythmP = 0;
rhythmFs = rhythmF + .250 * randn_t95iw(simCount, 1);
%rhythmPs = rhythmP + .785 * randn_t95iw(simCount, 1);
rhythmPs = rhythmP + 2*pi * rand(simCount, 1) - pi;
rhythmKs = rand(simCount, 1);

% Random walk model parameters for each hypothetical participant.
randWalkArgs = [
	.750 + .250 * randn_t95iw(simCount, 1), ...
	.667 + .333 * randn_t95iw(simCount, 1), ...
	.667 + .333 * randn_t95iw(simCount, 1) ...
	];

% Save rhythmic transformation and random walk model parameters for 4 batches
% under the data-fitted/ directory.
batchArgs = num2cell([randWalkArgs, rhythmFs, rhythmPs, rhythmKs], 2);
save(fullfile('data-fitted', 'Step3_BatchArgs.mat'));



% For each batch:
for dp = 1:length(nDataPoints)
	% Generate data for 1000 hypothetical participants.
	xData = batchRandomWalk(nDataPoints(dp), batchArgs);

	% Analyze rhythms with PATS and with spectral analysis, and save results
	% under the data-fitted/ directory.
	fitMatFile = sprintf('Step3_FitRhythms_%ddp-sim.mat', nDataPoints(dp));
	fftMatFile = sprintf('Step3_FFTRhythms_%ddp-sim.mat', nDataPoints(dp));
	batchFitRhythms(xData, fullfile('data-fitted', fitMatFile));
	batchFFTRhythms(xData, fullfile('data-fitted', fftMatFile));
end



% Generate data for 1000 hypothetical participants.
function xData = batchRandomWalk(nDataPoints, batchArgs)
	timeoutMsec = 10 * 1000;  % 10 s

	simCount = numel(batchArgs);
	xData = cell(size(batchArgs));

	fprintf('sampling %d dp/sim |', nDataPoints);
	progText = { '\b:', '1', '\b2', '\b3', '\b4', '\b5', '\b6', '\b7', '\b8', '\b9' };
	% For each hypothetical participant:
	for s = 1:simCount
		fprintf(progText{mod(s, 10) + 1});
		% Run a modified random walk model simulation. See the help document for
		% each function for more details.
		simArgs = num2cell(batchArgs{s});
		simData = simRandomWalk(nDataPoints, timeoutMsec, simArgs{:});
		xData{s} = simData / 1000;  % msec => s
	end
	fprintf('|\n');
end
