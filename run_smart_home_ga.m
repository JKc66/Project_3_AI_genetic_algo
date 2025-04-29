% --- run_smart_home_ga.m ---
clear; clc; close all;

fprintf('Setting up GA for Smart Home Optimization...\n');

% --- 0. Setup ---
rng(421011, 'twister'); % Set the random seed for reproducibility
resultsDir = 'results';
outputFileName = fullfile(resultsDir, 'results_summary.md');
summerPlotFileName = fullfile(resultsDir, 'GA_Convergence_Summer.png');
winterPlotFileName = fullfile(resultsDir, 'GA_Convergence_Winter.png');
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
lb_single_hour = [1, 1, 1]; ub_single_hour = [4, 5, 3];
lb = repmat(lb_single_hour, 1, 24); ub = repmat(ub_single_hour, 1, 24);
IntCon = 1:nVars;
populationSize = 100;
maxGenerations = 300;
options_base = optimoptions('ga', ...
    'PopulationSize', populationSize, ...
    'MaxGenerations', maxGenerations, ...
    'PlotFcn', @gaplotbestf, ... % Keep the basic plot function
    'Display', 'final', ...
    'FunctionTolerance', 1e-6, ...
    'UseParallel', false);

% --- 3. Run GA for Peak Summer ---
fprintf('\n--- Running GA for Peak Summer ---\n');
fitnessFunctionSummer = @(x) calculateFitness(x, summerData);
options_summer = optimoptions(options_base);
[x_summer, fval_summer, exitflag_summer, output_summer, ~, ~] = ga(fitnessFunctionSummer, nVars, [], [], [], [], lb, ub, [], IntCon, options_summer);
fprintf('\n--- GA Run for Summer Complete ---\n');
fprintf('Best Fitness Found (Summer): %f\n', fval_summer);

% --- Find, Enhance, and Save Summer Plot ---
fig_summer = findobj(0, 'Type', 'Figure', 'Name', 'Genetic Algorithm');
if ~isempty(fig_summer)
    % Rename the figure window (optional)
    set(fig_summer, 'Name', 'GA Convergence - Summer', 'NumberTitle', 'off');
    % Enhance the plot using the helper function
    enhanceGAPlot(fig_summer, 'GA Convergence - Summer', fval_summer); % <<< CALL HELPER
    % Save plot
    exportgraphics(fig_summer, summerPlotFileName, 'Resolution', 300);
    fprintf('Saved enhanced Summer convergence plot to %s\n', summerPlotFileName);
else
    fprintf('Warning: Could not find GA plot figure for Summer.\n');
    fig_summer = [];
end

% --- 4. Run GA for Peak Winter ---
fprintf('\n--- Running GA for Peak Winter ---\n');
fitnessFunctionWinter = @(x) calculateFitness(x, winterData);
options_winter = optimoptions(options_base);
[x_winter, fval_winter, exitflag_winter, output_winter, ~, ~] = ga(fitnessFunctionWinter, nVars, [], [], [], [], lb, ub, [], IntCon, options_winter);
fprintf('\n--- GA Run for Winter Complete ---\n');
fprintf('Best Fitness Found (Winter): %f\n', fval_winter);

% --- Find, Enhance, and Save Winter Plot ---
fig_winter_current = findobj(0, 'Type', 'Figure', 'Name', 'Genetic Algorithm');
if ~isempty(fig_winter_current)
    if ~isempty(fig_summer) && ishandle(fig_summer) && fig_winter_current == fig_summer
         fprintf('Warning: Winter GA plot reused the Summer plot window. Enhancing for Winter.\n');
    end
    % Rename the figure window (optional)
    set(fig_winter_current, 'Name', 'GA Convergence - Winter', 'NumberTitle', 'off');
    % Enhance the plot using the helper function
    enhanceGAPlot(fig_winter_current, 'GA Convergence - Winter', fval_winter); % <<< CALL HELPER
    % Save plot
    exportgraphics(fig_winter_current, winterPlotFileName, 'Resolution', 300);
    fprintf('Saved enhanced Winter convergence plot to %s\n', winterPlotFileName);
else
     fprintf('Warning: Could not find GA plot figure for Winter.\n');
end


% --- 5. Process and Save Results to File ---
% ... (rest of your results processing and saving code remains the same) ...
fprintf('\n--- Processing and Saving Results to %s ---\n', outputFileName);
schedule_summer = decodeSchedule(x_summer, summerData, 'Summer');
schedule_winter = decodeSchedule(x_winter, winterData, 'Winter');
[comfort_S, energy_S, avgComfort_S, avgEnergy_S] = getFinalScores(x_summer, summerData);
[comfort_W, energy_W, avgComfort_W, avgEnergy_W] = getFinalScores(x_winter, winterData);
fid = fopen(outputFileName, 'w');
if fid == -1; error('Cannot open file %s for writing.', outputFileName); end
fprintf(fid, '# Smart Home GA Optimization Results\n\n');
fprintf(fid, 'Date Run: %s\n', datestr(now));
fprintf(fid, 'GA Parameters:\n');
fprintf(fid, '- Population Size: %d\n', populationSize);
fprintf(fid, '- Max Generations: %d\n', maxGenerations);
fprintf(fid, '- Random Seed: %d\n\n', 421011);
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
header = sprintf('| %s | %s | %s | %s | %s |', schedule_summer.Properties.VariableNames{:});
separator = regexprep(header, '[^|]', '-');
fprintf(fid, '%s\n%s\n', header, separator);
for i = 1:height(schedule_summer); fprintf(fid, '| %d | %s | %s | %s | %s |\n', schedule_summer.Hour(i), schedule_summer.Thermostat{i}, schedule_summer.Lighting{i}, schedule_summer.Blinds{i}, schedule_summer.Notes{i}); end; fprintf(fid, '\n');
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
header = sprintf('| %s | %s | %s | %s | %s |', schedule_winter.Properties.VariableNames{:});
separator = regexprep(header, '[^|]', '-');
fprintf(fid, '%s\n%s\n', header, separator);
for i = 1:height(schedule_winter); fprintf(fid, '| %d | %s | %s | %s | %s |\n', schedule_winter.Hour(i), schedule_winter.Thermostat{i}, schedule_winter.Lighting{i}, schedule_winter.Blinds{i}, schedule_winter.Notes{i}); end; fprintf(fid, '\n');
fclose(fid);
fprintf('Results successfully saved to %s\n', outputFileName);

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

% --- Helper Function Definition (if not in separate file) ---
% Paste the enhanceGAPlot function code here if you didn't save it separately
% function enhanceGAPlot(figHandle, plotTitle, bestFitnessValue)
%    ... (function code from Step 1) ...
% end