% --- create_data_files.m --- %
clear; clc;

fprintf('Creating data files...\n');

% --- Peak Summer Data (Madinah, July - based on Table 1/5) ---
summerData.Hour = (1:24)';
summerData.T_out = [35; 34; 33; 32; 32; 33; 35; 38; 42; 45; 47; 48; 49; 50; 49; 47; 45; 42; 38; 36; 35; 34; 33; 32]; % degrees C
summerData.Humidity = [30; 30; 30; 30; 30; 30; 25; 20; 15; 10; 10; 10; 10; 10; 10; 15; 20; 25; 30; 30; 30; 30; 30; 30]; % percent
summerData.L_nat = [0; 0; 0; 0; 0; 10; 30; 50; 70; 85; 95; 100; 100; 95; 85; 70; 50; 30; 10; 0; 0; 0; 0; 0]; % percent
summerData.T_pref_mode = repmat({'Cool'}, 24, 1); % Always 'Cool' preference in summer example
summerData.L_pref = [0; 0; 0; 0; 25; 25; 75; 75; 75; 75; 75; 75; 75; 75; 75; 75; 75; 75; 50; 50; 50; 25; 0; 0]; % percent

% Save the summer data structure to a .mat file
save('summer_data.mat', 'summerData');
fprintf('Saved summer_data.mat\n');

% --- Peak Winter Data (Madinah, January - based on Table 2/6) ---
winterData.Hour = (1:24)';
winterData.T_out = [10; 9; 8; 8; 7; 8; 10; 12; 15; 18; 20; 22; 23; 22; 20; 18; 15; 12; 10; 9; 8; 8; 9; 10]; % degrees C
winterData.Humidity = [50; 50; 50; 50; 50; 50; 50; 45; 40; 35; 30; 30; 30; 30; 35; 40; 45; 50; 50; 50; 50; 50; 50; 50]; % percent
winterData.L_nat = [0; 0; 0; 0; 0; 0; 10; 30; 50; 70; 85; 90; 90; 85; 70; 50; 30; 10; 0; 0; 0; 0; 0; 0]; % percent
% Define T_pref_mode based on interpretation
winterData.T_pref_mode = [{'Heat'}; {'Heat'}; {'Heat'}; {'Heat'}; {'Heat'}; {'Heat'}; {'Heat'}; {'Heat'}; {'Heat'}; ... % 1-9
                           {'Off'}; {'Off'}; {'Off'}; {'Off'}; {'Off'}; {'Off'}; {'Off'}; ... % 10-16
                           {'Heat'}; {'Heat'}; {'Heat'}; {'Heat'}; {'Heat'}; {'Heat'}; {'Heat'}; {'Heat'}]; % 17-24
winterData.L_pref = [0; 0; 0; 0; 25; 25; 75; 75; 75; 75; 75; 75; 75; 75; 75; 75; 75; 50; 50; 50; 25; 0; 0; 0]; % percent

% Save the winter data structure to a .mat file
save('winter_data.mat', 'winterData');
fprintf('Saved winter_data.mat\n');

fprintf('Data file creation complete.\n');