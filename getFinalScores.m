% --- getFinalScores.m --- %
function [totalComfortScore, totalEnergyCost, avgHourlyComfort, avgHourlyEnergy] = getFinalScores(chromosome, environmentalData)
% Calculates the raw Total Comfort Score and Total Energy Cost for a final chromosome.
% Re-uses most logic from calculateFitness but returns raw scores.

% --- Constants ---
% Comfort parameters
idealHumidity = 50; % percent
tempComfortWeight = 0.5;
lightComfortWeight = 0.3;
humidComfortWeight = 0.2;
tempDeviationScale = 3;
lightDeviationScale = 100;
humidDeviationScale = 50;
passiveComfortTemp = 24;

% Energy parameters
baseCoolCost = 2;
baseHeatCost = 2;
maxLightCost = 2;

% HVAC effectiveness
hvacEffectiveness = 0.98;

% --- Initialize Totals ---
totalComfortScore = 0;
totalEnergyCost = 0;

% --- Loop Through Each Hour ---
for h = 1:24
    % Extract hourly schedule
    idx_base = (h-1)*3;
    THh = chromosome(idx_base + 1);
    Lh = chromosome(idx_base + 2);
    Bh = chromosome(idx_base + 3);

    % Extract hourly environmental & preference data
    T_out_h = environmentalData.T_out(h);
    Hum_h = environmentalData.Humidity(h);
    L_nat_h = environmentalData.L_nat(h);
    T_pref_mode_h = environmentalData.T_pref_mode{h};
    L_pref_h = environmentalData.L_pref(h);

    % --- 1. Estimate Indoor Temperature (T_in_h) ---
    T_in_h = T_out_h;
    targetTemp = NaN;
    if THh == 2, targetTemp = 25; T_in_h = max(targetTemp, targetTemp + (T_out_h - targetTemp) * (1 - hvacEffectiveness));
    elseif THh == 3, targetTemp = 23; T_in_h = max(targetTemp, targetTemp + (T_out_h - targetTemp) * (1 - hvacEffectiveness));
    elseif THh == 4, targetTemp = 21; T_in_h = min(targetTemp, targetTemp - (targetTemp - T_out_h) * (1 - hvacEffectiveness));
    end

    % --- 2. Calculate Hourly Comfort Score ---
    % a) Temperature Comfort
    tempComfort_h = 0;
    current_target = targetTemp;
    if isnan(current_target)
        current_target = passiveComfortTemp;
        tempDeviation = abs(T_in_h - current_target);
        tempComfort_h = max(0, 1 - tempDeviation / tempDeviationScale);
        if ~strcmp(T_pref_mode_h, 'Off'), tempComfort_h = tempComfort_h * 0.7; end
    else
        tempDeviation = abs(T_in_h - current_target);
        tempComfort_h = max(0, 1 - tempDeviation / tempDeviationScale);
         isCooling = (THh == 2 || THh == 3); isHeating = (THh == 4);
         prefCool = strcmp(T_pref_mode_h, 'Cool'); prefHeat = strcmp(T_pref_mode_h, 'Heat');
         modeMismatch = (isCooling && prefHeat) || (isHeating && prefCool);
         if modeMismatch, tempComfort_h = tempComfort_h * 0.7; end
    end
    % b) Lighting Comfort
    L_actual_percent = (Lh - 1) * 25;
    lightDeviation = abs(L_actual_percent - L_pref_h);
    lightComfort_h = max(0, 1 - lightDeviation / lightDeviationScale);
    % c) Humidity Comfort
    humidDeviation = abs(Hum_h - idealHumidity);
    humidComfort_h = max(0, 1 - humidDeviation / humidDeviationScale);
    % d) Combine Hourly Comfort Score
    comfort_h = (tempComfort_h * tempComfortWeight) + ...
                  (lightComfort_h * lightComfortWeight) + ...
                  (humidComfort_h * humidComfortWeight);
    totalComfortScore = totalComfortScore + comfort_h;

    % --- 3. Calculate Hourly Energy Cost ---
    % a) Base Thermostat Cost
    base_HVAC_cost_h = 0;
    if THh == 2 || THh == 3, base_HVAC_cost_h = baseCoolCost;
    elseif THh == 4, base_HVAC_cost_h = baseHeatCost;
    end
    % b) Base Lighting Cost
    base_Light_cost_h = max(0, Lh - 1) * (maxLightCost / 4);
    % c) Blinds Impact Factors
    blindsFactorHVAC = 1.0; lightingFactor = 1.0;
    if Bh == 1, blindsFactorHVAC = 0.8; lightingFactor = 1.2;
    elseif Bh == 3, blindsFactorHVAC = 1.2; lightingFactor = 0.8;
    end
    % d) Refine factors based on mode/natural light
    actual_blindsFactorHVAC = blindsFactorHVAC;
    isHeating = (THh == 4);
    if isHeating
        if Bh == 1, actual_blindsFactorHVAC = 1.2;
        elseif Bh == 3, actual_blindsFactorHVAC = 0.8;
        end
    end
    effective_Light_Need_Factor = 1.0;
    if Bh == 1, effective_Light_Need_Factor = lightingFactor;
    elseif Bh == 3 && L_nat_h > 0, effective_Light_Need_Factor = lightingFactor;
    end
    % e) Calculate Actual Energy Costs
    actual_HVAC_cost_h = actual_blindsFactorHVAC * base_HVAC_cost_h;
    actual_Light_cost_h = effective_Light_Need_Factor * base_Light_cost_h;
    energyCost_h = actual_HVAC_cost_h + actual_Light_cost_h;
    totalEnergyCost = totalEnergyCost + energyCost_h;

end % End of hourly loop

% Calculate averages
avgHourlyComfort = totalComfortScore / 24.0;
avgHourlyEnergy = totalEnergyCost / 24.0;

end