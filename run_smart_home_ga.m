% --- run_smart_home_ga.m ---
clear; clc; close all;

fprintf('Setting up GA for Smart Home Optimization...\n');

% --- 0. Setup ---
rng(421011, 'twister'); % Set the random seed for reproducibility

% Define the results directory name
resultsDir = 'results';

% Define full paths for output files within the results directory
outputFileName = fullfile(resultsDir, 'results_summary.md');
summerPlotFileName = fullfile(resultsDir, 'GA_Convergence_Summer.png');
winterPlotFileName = fullfile(resultsDir, 'GA_Convergence_Winter.png');

% Create the results directory if it doesn't exist
if ~exist(resultsDir, 'dir')
    fprintf('Creating results directory: %s\n', resultsDir);
    mkdir(resultsDir);
end

% --- 1. Load Environmental Data ---
fprintf('Loading data from .mat files...\n');
try
    load('summer_data.mat'); % Loads 'summerData'
    load('winter_data.mat'); % Loads 'winterData'
    fprintf('Data loaded successfully.\n');
catch ME
    error('Could not load data files. Ensure summer_data.mat and winter_data.mat are present. Error: %s', ME.message);
end

% --- 2. Define GA Parameters ---
nVars = 72;
lb_single_hour = [1, 1, 1];
ub_single_hour = [4, 5, 3];
lb = repmat(lb_single_hour, 1, 24);
ub = repmat(ub_single_hour, 1, 24);
IntCon = 1:nVars;

populationSize = 100;
maxGenerations = 300;
% Base options - create copies later if needed to ensure separate plots
options_base = optimoptions('ga', ...
    'PopulationSize', populationSize, ...
    'MaxGenerations', maxGenerations, ...
    'PlotFcn', @gaplotbestf, ...
    'Display', 'final', ...
    'FunctionTolerance', 1e-6, ...
    'UseParallel', false);

% --- 3. Run GA for Peak Summer ---
fprintf('\n--- Running GA for Peak Summer ---\n');
fitnessFunctionSummer = @(x) calculateFitness(x, summerData);
options_summer = optimoptions(options_base); % Use a copy for summer run
[x_summer, fval_summer, exitflag_summer, output_summer, population_summer, scores_summer] = ga(fitnessFunctionSummer, nVars, [], [], [], [], lb, ub, [], IntCon, options_summer);

fprintf('\n--- GA Run for Summer Complete ---\n');
fprintf('Best Fitness Found (Summer): %f\n', fval_summer);

% --- Find, Rename, and Save Summer Plot ---
fig_summer = findobj(0, 'Type', 'Figure', 'Name', 'Genetic Algorithm'); % Find the default GA plot figure
if ~isempty(fig_summer)
    % Rename the figure window
    set(fig_summer, 'Name', 'GA Convergence - Summer', 'NumberTitle', 'off');
    fprintf('Renamed Summer plot window.\n');
    % Save plot to the results directory using the defined path
    exportgraphics(fig_summer, summerPlotFileName, 'Resolution', 300);
    fprintf('Saved Summer convergence plot to %s\n', summerPlotFileName);
else
    fprintf('Warning: Could not find GA plot figure for Summer.\n');
    fig_summer = []; % Ensure handle is empty if not found
end


% --- 4. Run GA for Peak Winter ---
fprintf('\n--- Running GA for Peak Winter ---\n');
fitnessFunctionWinter = @(x) calculateFitness(x, winterData);
% Use a fresh copy of options to potentially create a new plot window
options_winter = optimoptions(options_base);
[x_winter, fval_winter, exitflag_winter, output_winter, population_winter, scores_winter] = ga(fitnessFunctionWinter, nVars, [], [], [], [], lb, ub, [], IntCon, options_winter);

fprintf('\n--- GA Run for Winter Complete ---\n');
fprintf('Best Fitness Found (Winter): %f\n', fval_winter);

% --- Find, Rename, and Save Winter Plot ---
% Search for the figure named 'Genetic Algorithm' AGAIN.
% It might be a new figure, or it might have reused the old one if it wasn't closed.
fig_winter_current = findobj(0, 'Type', 'Figure', 'Name', 'Genetic Algorithm');

if ~isempty(fig_winter_current)
    % Check if it reused the summer figure window (optional warning)
    if ~isempty(fig_summer) && ishandle(fig_summer) && fig_winter_current == fig_summer
         fprintf('Warning: Winter GA plot might have reused the Summer plot window. Renaming and saving as Winter.\n');
    end
    % Always rename the *current* figure found after the winter run
    set(fig_winter_current, 'Name', 'GA Convergence - Winter', 'NumberTitle', 'off');
    fprintf('Renamed Winter plot window.\n');
    % Save the *current* figure as the Winter plot
    exportgraphics(fig_winter_current, winterPlotFileName, 'Resolution', 300);
    fprintf('Saved Winter convergence plot to %s\n', winterPlotFileName);
else
     fprintf('Warning: Could not find GA plot figure for Winter.\n');
end


% --- 5. Process and Save Results to File ---
% ... (rest of your results processing and saving code remains the same) ...
fprintf('\n--- Processing and Saving Results to %s ---\n', outputFileName);

% Decode the optimal chromosomes
schedule_summer = decodeSchedule(x_summer, summerData, 'Summer');
schedule_winter = decodeSchedule(x_winter, winterData, 'Winter');

% Calculate final raw scores for the best solutions
[comfort_S, energy_S, avgComfort_S, avgEnergy_S] = getFinalScores(x_summer, summerData);
[comfort_W, energy_W, avgComfort_W, avgEnergy_W] = getFinalScores(x_winter, winterData);

% Open the file for writing (uses the full path defined earlier)
fid = fopen(outputFileName, 'w');
if fid == -1
    error('Cannot open file %s for writing.', outputFileName);
end

% Write Header
fprintf(fid, '# Smart Home GA Optimization Results\n\n');
fprintf(fid, 'Date Run: %s\n', datestr(now));
fprintf(fid, 'GA Parameters:\n');
fprintf(fid, '- Population Size: %d\n', populationSize);
fprintf(fid, '- Max Generations: %d\n', maxGenerations);
fprintf(fid, '- Random Seed: %d\n\n', 421011); % Use the actual seed value used

% --- Summer Results ---
fprintf(fid, '## Peak Summer (July) Results\n\n');
fprintf(fid, '**GA Performance:**\n');
fprintf(fid, '- Final Best Fitness (Minimized Value): %.4f\n', fval_summer);
fprintf(fid, '- Exit Flag: %d\n', exitflag_summer);
fprintf(fid, '- Generations Run: %d\n\n', output_summer.generations);

fprintf(fid, '**Optimal Schedule Performance Metrics:**\n');
fprintf(fid, '- Total Comfort Score (Higher is better, Max ~24): %.4f\n', comfort_S);
fprintf(fid, '- Average Hourly Comfort Score (Higher is better, Max ~1): %.4f\n', avgComfort_S);
fprintf(fid, '- Total Energy Cost (Lower is better, arbitrary units): %.4f\n', energy_S);
fprintf(fid, '- Average Hourly Energy Cost (Lower is better): %.4f\n\n', avgEnergy_S);

fprintf(fid, '**Optimal Schedule (Summer):**\n\n');
% Convert table to Markdown format string (Corrected)
header = sprintf('| %s | %s | %s | %s | %s |', schedule_summer.Properties.VariableNames{:}); % No newline here
separator = regexprep(header, '[^|]', '-'); % Create separator based on header structure
fprintf(fid, '%s\n', header); % Print header with newline
fprintf(fid, '%s\n', separator); % Print separator with newline
for i = 1:height(schedule_summer)
    fprintf(fid, '| %d | %s | %s | %s | %s |\n', ... % Keep this loop the same
            schedule_summer.Hour(i), ...
            schedule_summer.Thermostat{i}, ...
            schedule_summer.Lighting{i}, ...
            schedule_summer.Blinds{i}, ...
            schedule_summer.Notes{i});
end
fprintf(fid, '\n');

% --- Winter Results ---
fprintf(fid, '## Peak Winter (January) Results\n\n');
fprintf(fid, '**GA Performance:**\n');
fprintf(fid, '- Final Best Fitness (Minimized Value): %.4f\n', fval_winter);
fprintf(fid, '- Exit Flag: %d\n', exitflag_winter);
fprintf(fid, '- Generations Run: %d\n\n', output_winter.generations);

fprintf(fid, '**Optimal Schedule Performance Metrics:**\n');
fprintf(fid, '- Total Comfort Score (Higher is better, Max ~24): %.4f\n', comfort_W);
fprintf(fid, '- Average Hourly Comfort Score (Higher is better, Max ~1): %.4f\n', avgComfort_W);
fprintf(fid, '- Total Energy Cost (Lower is better, arbitrary units): %.4f\n', energy_W);
fprintf(fid, '- Average Hourly Energy Cost (Lower is better): %.4f\n\n', avgEnergy_W);

fprintf(fid, '**Optimal Schedule (Winter):**\n\n');
% Convert table to Markdown format string (Corrected)
header = sprintf('| %s | %s | %s | %s | %s |', schedule_winter.Properties.VariableNames{:}); % No newline here
separator = regexprep(header, '[^|]', '-'); % Create separator
fprintf(fid, '%s\n', header); % Print header with newline
fprintf(fid, '%s\n', separator); % Print separator with newline
for i = 1:height(schedule_winter)
    fprintf(fid, '| %d | %s | %s | %s | %s |\n', ... % Keep this loop the same
            schedule_winter.Hour(i), ...
            schedule_winter.Thermostat{i}, ...
            schedule_winter.Lighting{i}, ...
            schedule_winter.Blinds{i}, ...
            schedule_winter.Notes{i});
end
fprintf(fid, '\n');

% Close the file
fclose(fid);
fprintf('Results successfully saved to %s\n', outputFileName); % Uses the path defined earlier

% --- 6. Display Summary to Console ---
% ... (console summary remains the same) ...
fprintf('\n--- Performance Summary ---\n');
fprintf('Metric                     | Peak Summer | Peak Winter\n');
fprintf('---------------------------|-------------|-------------\n');
fprintf('Best GA Fitness            | %11.4f | %11.4f\n', fval_summer, fval_winter);
fprintf('Total Comfort Score        | %11.4f | %11.4f\n', comfort_S, comfort_W);
fprintf('Avg Hourly Comfort         | %11.4f | %11.4f\n', avgComfort_S, avgComfort_W);
fprintf('Total Energy Cost          | %11.4f | %11.4f\n', energy_S, energy_W);
fprintf('Avg Hourly Energy          | %11.4f | %11.4f\n', avgEnergy_S, avgEnergy_W);

fprintf('\nScript finished.\n');