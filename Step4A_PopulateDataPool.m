%
% Script for building a data pool comprising 10,000 data points × 2 conditions
% × 200 1000 hypothetical participants. The data generated with this script
% will be saved under the data-fitted/ directory.
%

clear;
addpath('lib');

% Set random seed. The seed 'data' will generate the data shown in Figure 5
% reported in the paper. You can use "rng('shuffle');" instead.
rngchar('data');


% Load variables defined in CommonVars_CDF.m.
CommonVars_CDF;

% Number of hypothetical participants and number of data points.
simCount    = 200;
nDataPoints = 10000;

% Rhythmic transformation parameters for lognormal rCDFs.
rhythmF = 8;
rhythmP = 0;
rhythmK = [.8, .4];
rhythmFs = rhythmF + .250 * randn_t95iw(simCount, 1);
rhythmPs = rhythmP + 2*pi * rand(simCount, 1) - pi;
rhythmKs = repmat(rhythmK, simCount, 1) + .002 * randn_t95iw(simCount, 2);

% Lognormal CDF parameters for each hypothetical participant.
cdfBsim = [
	-1.0 + .200 * randn_t95iw(simCount, 1), ...
	.800 + .160 * randn_t95iw(simCount, 1), ...
	.400 + .080 * randn_t95iw(simCount, 1) ...
	];

% Noise SD (in msec).
noiseSD = .040;



% Prepare empty data pool.
xData = cell(2, simCount);

fprintf('generating data |');
progText = { '.', '\b:' };
% For each hypothetical participant:
for s = 1:simCount
	% For each condition (strong/weak rhythms):
	for r = 1:2
		fprintf(progText{r});
		% Sample response times from rCDF, add noise to the sampled data.
		simData = sampleFromCDF(nDataPoints, ...
			@(B, x) rhythmfwrap(cdfFun, B, x), ...
			[cdfBsim(s, :), rhythmFs(s), rhythmPs(s), rhythmKs(s, r)]);
		xData{r, s} = simData + randn_t95iw(size(simData)) * noiseSD;
	end
end
fprintf('|\n');



% Save generated data under the data-fitted/ directory.
clear progText s r simData;
save(fullfile('data-fitted', 'Step4_DataPool.mat'));
