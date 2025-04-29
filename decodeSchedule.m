% --- decodeSchedule.m --- %
function scheduleTable = decodeSchedule(chromosome, ~, seasonName)
% Decodes the 72-element chromosome into a human-readable table.

    hours = (1:24)';
    thermostatSettings = cell(24, 1);
    lightingSettings = cell(24, 1);
    blindsSettings = cell(24, 1);
    notes = cell(24, 1); % Add notes based on time/events

    for h = 1:24
        % Extract hourly schedule
        idx_base = (h-1)*3;
        THh = chromosome(idx_base + 1);
        Lh = chromosome(idx_base + 2);
        Bh = chromosome(idx_base + 3);

        % Decode Thermostat
        switch THh
            case 1
                thermostatSettings{h} = 'Off';
            case 2
                thermostatSettings{h} = 'Cool 25C';
            case 3
                thermostatSettings{h} = 'Cool 23C';
            case 4
                thermostatSettings{h} = 'Heat 21C';
            otherwise
                thermostatSettings{h} = 'Invalid';
        end

        % Decode Lighting
        switch Lh
            case 1
                lightingSettings{h} = '0%';
            case 2
                lightingSettings{h} = '25%';
            case 3
                lightingSettings{h} = '50%';
            case 4
                lightingSettings{h} = '75%';
            case 5
                lightingSettings{h} = '100%';
            otherwise
                lightingSettings{h} = 'Invalid';
        end

        % Decode Blinds
        switch Bh
            case 1
                blindsSettings{h} = 'Closed';
            case 2
                blindsSettings{h} = 'Half-Open';
            case 3
                blindsSettings{h} = 'Open';
            otherwise
                blindsSettings{h} = 'Invalid';
        end

        % Add Notes (customize based on season/hour)
        % These are examples based on the input tables' notes
        if strcmp(seasonName, 'Summer')
            if h >= 1 && h <= 4
                notes{h} = 'Warm Night';
            elseif h == 5
                notes{h} = 'Before Sunrise';
            elseif h == 6
                notes{h} = 'Sunrise ~5:40 AM';
            elseif h >= 7 && h <= 9 % Changed upper limit to 9
                 notes{h} = 'Morning, getting bright'; % Assign note for 7, 8, 9
            elseif h >= 10 && h <= 17
                 notes{h} = 'Peak Sun Period';
                 if h == 14
                     notes{h} = [notes{h} ', Hottest Time'];
                 end
            elseif h == 18 % Added specific case for 18
                 notes{h} = 'Afternoon Peak Sun Ends'; % Assign note for 18
            elseif h == 19
                notes{h} = 'Sunset ~7:10 PM';
            elseif h >= 20 && h <= 21
                notes{h} = 'Evening';
            elseif h == 22
                notes{h} = 'Late Evening';
            elseif h >= 23
                notes{h} = 'Night';
            else % Catch any missed hours
                notes{h} = '';
            end
        else % Winter
            % ... (Winter notes logic remains the same) ...
             if h >= 1 && h <= 4
                notes{h} = 'Cool Night';
                 if h == 4
                     notes{h} = [notes{h} ', Coolest'];
                 end
            elseif h >= 5 && h <= 6
                notes{h} = 'Before Sunrise';
            elseif h == 7
                notes{h} = 'Sunrise ~7:10 AM';
            elseif h == 8 || h == 9
                notes{h} = 'Morning, warming up';
            elseif h == 10
                notes{h} = 'Mild';
            elseif h >= 11 && h <= 15
                 notes{h} = 'Comfortable Day Temp';
                 if h == 11, notes{h} = [notes{h} ' Start']; end
                 if h == 12 || h == 13, notes{h} = 'Peak Day Temp'; end
                 if h == 15, notes{h} = [notes{h} ', Temp starts falling']; end
            elseif h == 16 || h == 17
                notes{h} = 'Getting Cooler';
            elseif h == 18
                notes{h} = 'Sunset ~5:45 PM';
            elseif h >= 19 && h <= 20
                notes{h} = 'Evening';
            elseif h == 21
                notes{h} = 'Late Evening';
            elseif h >= 22
                notes{h} = 'Night';
            else % Catch any missed hours
                notes{h} = '';
            end
        end

    end

    % Create MATLAB table for better display
    scheduleTable = table(hours, thermostatSettings, lightingSettings, blindsSettings, notes, ...
        'VariableNames', {'Hour', 'Thermostat', 'Lighting', 'Blinds', 'Notes'});

end