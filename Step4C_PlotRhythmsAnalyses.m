%
% Script for plotting fig-images/Figure5.png.
%

clear;
addpath('lib');

% Number of samples in each batch.
nSamples = [100, 200, 400, 800];

% Load variables defined in CommonVars_Figure.m.
CommonVars_Figure;

% Panel titles.
panelTitles = {
	'Estimated amplitude (7-9 Hz)';
	'rCDF amplitude {\itk} (7-9 Hz)';
	'Spectral amplitude (7-9 Hz)';
	};
% Panel axis labels.
panelAxisLabels = {
	'Number of data points', 'Estimated amplitude';
	'Number of data points', 'rCDF amplitude {\itk}';
	'Number of data points', 'Spectral amplitude';
	};
% Y-axis limits and ticks.
panelAxisYLims = {
	[0, .06], 0:.02:.06;
	[0, .45], 0:.15:.45;
	[0, .30], 0:.10:.30;
	};

% Figure size in cm.
figureSize = [17.4, 5.8];
% Panel and label positions [left bottom width height] in cm.
panelPos = {
	[ 1.2 1.0 4.2 4.0];
	[ 7.0 1.0 4.2 4.0];
	[12.8 1.0 4.2 4.0];
	};
panelLabelPos = {
	[ 0   5.2 .7 .7];
	[ 5.8 5.2 .7 .7];
	[11.6 5.2 .7 .7];
	};
panelTitleBottom = 4.3;



%
% Prepare data for figure.
%
meanAmpEstd = zeros(2, length(nSamples));
meanAmpRCDF = zeros(2, length(nSamples));
meanSpecAmp = zeros(2, length(nSamples));

semAmpEstd = zeros(2, length(nSamples));
semAmpRCDF = zeros(2, length(nSamples));
semSpecAmp = zeros(2, length(nSamples));

% For each batch:
for s = 1:length(nSamples)
	% Load data and analysis results.
	fitMatFile = sprintf('Step4_FitRhythms_%ddp-sample.mat', nSamples(s));
	fftMatFile = sprintf('Step4_FFTRhythms_%ddp-sample.mat', nSamples(s));
	fitData = load(fullfile('data-fitted', fitMatFile));
	fftData = load(fullfile('data-fitted', fftMatFile));

	% Calculate means from PATS and spectral analysis results.
	meanAmpEstd(:, s) = mean(fitData.avgAmpEstd7_9Hz, 2);
	meanAmpRCDF(:, s) = mean(fitData.avgAmpRCDF7_9Hz, 2);
	meanSpecAmp(:, s) = mean(fftData.avgSpecAmp7_9Hz, 2);

	% Calculate standard errors from PATS and spectral analysis results.
	semAmpEstd(:, s) = std(fitData.avgAmpEstd7_9Hz, [], 2) / sqrt(size(fitData.avgAmpEstd7_9Hz, 2));
	semAmpRCDF(:, s) = std(fitData.avgAmpRCDF7_9Hz, [], 2) / sqrt(size(fitData.avgAmpRCDF7_9Hz, 2));
	semSpecAmp(:, s) = std(fftData.avgSpecAmp7_9Hz, [], 2) / sqrt(size(fftData.avgSpecAmp7_9Hz, 2));
end
dataY = { meanAmpEstd, meanAmpRCDF, meanSpecAmp };
dataE = { semAmpEstd,  semAmpRCDF,  semAmpRCDF  };



% Open new figure window.
figureHandle = openFigure(figureSize);

%
% For panel A/B/C:
%
for p = 1:3
	panelHandle = subplot(1, 3, p, subplotParams{:});
	set(panelHandle, 'Position', panelPos{p});

	% Plot PATS and spetral analysis results for strong/weak rhythms.
	hold on;
	for r = 1:2
		errorHandle = errorbar(nSamples', dataY{p}(r, :)', dataE{p}(r, :)', ...
			errorBarParams{:});
		skipLegend(errorHandle);
		plot(nSamples', dataY{p}(r, :)', 'Color', lineColors2(r, :), ...
			'LineWidth', plotLineWidth);
	end
	hold off;
	% Set axis limits, tick marks, and labels.
	xlim([0, 900]);
	ylim(panelAxisYLims{p, 1});
	setAxes(0:200:900, '%d\n', panelAxisYLims{p, 2}, '%.2f\n');
	xlabel(panelAxisLabels{p, 1}, labelParams{:});
	ylabel(panelAxisLabels{p, 2}, labelParams{:});
	
	% Set legend on panel A.
	if p == 1
		legendHandle = legend({
			'Strong rhythms', ...
			'Weak rhythms' ...
			}, legendParams{:}, 'Location', 'north');
		legendPos = get(legendHandle, 'Position');
		legendPos(1) = sum(panelPos{p}([1 3]) .* [1 .5]) - 1.7;
		legendPos(2) = sum(panelPos{p}([2 4])) - .85;
		set(legendHandle, 'Position', legendPos);
	end

	% Set panel title.
	titleHandle = title(panelTitles{p}, titleParams{:});
	titlePos = get(titleHandle, 'Position');
	titlePos(2) = panelTitleBottom;
	set(titleHandle, 'Position', titlePos);
	
	% Set panel label.
	annotation('textbox', 'String', char('A' - 1 + p), annotParams{:}, ...
		'Position', panelLabelPos{p});
end



% Save figure to an image file.
figureFile = fullfile('fig-images', 'Figure5.tif');
print(figureHandle, figureFile, '-dtiff', '-vector', '-r300');
