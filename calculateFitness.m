% --- calculateFitness.m --- %
function fitness = calculateFitness(chromosome, environmentalData)
% Calculates the fitness of a 72-element chromosome representing a 24-hour schedule.

% --- Constants and Weights ---
w_comfort = 0.65;
w_energy = 0.35;

% Comfort parameters
idealHumidity = 50; % percent
tempComfortWeight = 0.5;
lightComfortWeight = 0.3;
humidComfortWeight = 0.2;
tempDeviationScale = 3; % More sensitive temperature comfort scale
lightDeviationScale = 100; % From appendix example for light comfort
humidDeviationScale = 50; % From appendix example for humid comfort
passiveComfortTemp = 24; % Assumed comfortable temp if thermostat is off

% Energy parameters (Base costs if device is ON and active)
baseCoolCost = 2; % Reduced energy units for cooling mode
baseHeatCost = 2; % Reduced energy units for heating mode
maxLightCost = 2; % Reduced max cost units for 100% lighting (Lh=5)

% HVAC effectiveness (Simple model parameter)
hvacEffectiveness = 0.98; % High effectiveness

% --- Initialize Totals ---
totalComfortScore = 0;
totalEnergyCost = 0;

% --- Loop Through Each Hour ---
for h = 1:24
    % Extract hourly schedule from chromosome
    idx_base = (h-1)*3;
    THh = chromosome(idx_base + 1); % Thermostat setting (1-4)
    Lh = chromosome(idx_base + 2);  % Lighting setting (1-5)
    Bh = chromosome(idx_base + 3);  % Blinds setting (1-3)

    % Extract hourly environmental & preference data
    T_out_h = environmentalData.T_out(h);
    Hum_h = environmentalData.Humidity(h);
    L_nat_h = environmentalData.L_nat(h);
    T_pref_mode_h = environmentalData.T_pref_mode{h};
    L_pref_h = environmentalData.L_pref(h);

    % --- 1. Estimate Indoor Temperature (T_in_h) based on action ---
    T_in_h = T_out_h; % Start by assuming indoor = outdoor
    targetTemp = NaN; % Will be set if HVAC is active

    if THh == 2 % Cool 25C
        targetTemp = 25;
        % Simple model: Indoor temp moves towards target from T_out
        T_in_h = targetTemp + (T_out_h - targetTemp) * (1 - hvacEffectiveness);
        % Ensure it doesn't overshoot (can't cool below target instantly)
        T_in_h = max(T_in_h, targetTemp);
    elseif THh == 3 % Cool 23C (High Comfort)
        targetTemp = 23;
        T_in_h = targetTemp + (T_out_h - targetTemp) * (1 - hvacEffectiveness);
        T_in_h = max(T_in_h, targetTemp);
    elseif THh == 4 % Heat 21C
        targetTemp = 21;
        T_in_h = targetTemp - (targetTemp - T_out_h) * (1 - hvacEffectiveness);
        % Ensure it doesn't overshoot (can't heat above target instantly)
         T_in_h = min(T_in_h, targetTemp);
    end
    % If THh == 1 (Off), T_in_h remains T_out_h, targetTemp remains NaN

    % --- 2. Calculate Hourly Comfort Score ---

    % a) Temperature Comfort (Using estimated T_in_h)
    tempComfort_h = 0; % Default low comfort
    current_target = targetTemp; % Use the active target if ON

    if isnan(current_target) % Thermostat is Off
        current_target = passiveComfortTemp; % Compare T_in_h to the passive comfort temp
        tempDeviation = abs(T_in_h - current_target);
        tempComfort_h = max(0, 1 - tempDeviation / tempDeviationScale);
        % Optional: Penalize if Off but user preferred action
        if ~strcmp(T_pref_mode_h, 'Off')
            tempComfort_h = tempComfort_h * 0.7; % Reduce comfort score slightly
        end
    else % Thermostat is On
        tempDeviation = abs(T_in_h - current_target);
        tempComfort_h = max(0, 1 - tempDeviation / tempDeviationScale);
         % Optional: Penalize if mode mismatches preference (e.g., Heat ON when Cool preferred)
         isCooling = (THh == 2 || THh == 3);
         isHeating = (THh == 4);
         prefCool = strcmp(T_pref_mode_h, 'Cool');
         prefHeat = strcmp(T_pref_mode_h, 'Heat');
         modeMismatch = (isCooling && prefHeat) || (isHeating && prefCool);
         if modeMismatch
             tempComfort_h = tempComfort_h * 0.7; % Reduce comfort score slightly
         end
    end

    % b) Lighting Comfort (Compare actual artificial light % vs preferred %)
    L_actual_percent = (Lh - 1) * 25;
    lightDeviation = abs(L_actual_percent - L_pref_h);
    lightComfort_h = max(0, 1 - lightDeviation / lightDeviationScale);

    % c) Humidity Comfort (Compare actual outdoor humidity vs ideal 50%)
    humidDeviation = abs(Hum_h - idealHumidity);
    humidComfort_h = max(0, 1 - humidDeviation / humidDeviationScale);

    % d) Combine Hourly Comfort Score
    comfort_h = (tempComfort_h * tempComfortWeight) + ...
                  (lightComfort_h * lightComfortWeight) + ...
                  (humidComfort_h * humidComfortWeight);
    totalComfortScore = totalComfortScore + comfort_h;

    % --- 3. Calculate Hourly Energy Cost ---

    % a) Base Thermostat Cost (if active)
    base_HVAC_cost_h = 0;
    if THh == 2 || THh == 3 % Cooling active
        base_HVAC_cost_h = baseCoolCost;
        % Optional refinement: Cost depends on T_out vs T_in?
        % base_HVAC_cost_h = baseCoolCost * (1 + abs(T_out_h - T_in_h)/20); % Example scaling
    elseif THh == 4 % Heating active
        base_HVAC_cost_h = baseHeatCost;
        % Optional refinement: Cost depends on T_out vs T_in?
        % base_HVAC_cost_h = baseHeatCost * (1 + abs(T_out_h - T_in_h)/20); % Example scaling
    end

    % b) Base Lighting Cost
    % Scale 0 to maxLightCost units (where Lh=5 corresponds to maxLightCost)
    base_Light_cost_h = max(0, Lh - 1) * (maxLightCost / 4);

    % c) Blinds Impact Factors (from Page 14)
    blindsFactorHVAC = 1.0; % Default for Half-Open
    lightingFactor = 1.0;   % Default for Half-Open

    if Bh == 1 % Closed
        blindsFactorHVAC = 0.8;
        lightingFactor = 1.2;
    elseif Bh == 3 % Open
        blindsFactorHVAC = 1.2;
        lightingFactor = 0.8;
    end
    % Refinement: Blind factor effect on HVAC depends on mode
    % If Cooling: Closed (0.8) is good, Open (1.2) is bad.
    % If Heating: Closed (0.8) is bad (blocks sun), Open (1.2) is good (allows sun).
    % Let's adjust the HVAC factor based on mode for more realism:
    actual_blindsFactorHVAC = blindsFactorHVAC; % Start with the base factor
    isCooling = (THh == 2 || THh == 3);
    isHeating = (THh == 4);
    if isHeating % Reverse the effect for heating
        if Bh == 1 % Closed (bad for heating)
             actual_blindsFactorHVAC = 1.2; % Increase effective cost
        elseif Bh == 3 % Open (good for heating)
             actual_blindsFactorHVAC = 0.8; % Decrease effective cost
        end
        % Half-open remains 1.0
    end


    % d) Calculate Actual Energy Costs for the hour including blind impact
    actual_HVAC_cost_h = actual_blindsFactorHVAC * base_HVAC_cost_h;

    % Refined Lighting Cost: Factor adjusts need based on natural light
    % If blinds are closed (factor 1.2), need is higher.
    % If blinds are open (factor 0.8), need is lower IF natural light exists.
    effective_Light_Need_Factor = 1.0; % Default
    if Bh == 1 % Closed blinds always increase need
         effective_Light_Need_Factor = lightingFactor; % Use 1.2
    elseif Bh == 3 && L_nat_h > 0 % Open blinds only help if there's natural light
         effective_Light_Need_Factor = lightingFactor; % Use 0.8
    end
    % Note: If Bh=2 (Half-Open) or Bh=3 and L_nat=0, factor remains 1.0

    actual_Light_cost_h = effective_Light_Need_Factor * base_Light_cost_h;


    energyCost_h = actual_HVAC_cost_h + actual_Light_cost_h;
    totalEnergyCost = totalEnergyCost + energyCost_h;

end % End of hourly loop


% --- 4. Calculate Final Fitness ---
maxPossibleComfort = 24.0; % Theoretical max over 24h (1.0 per hour)
% Estimate Max Energy: 24h * (Max HVAC Cost + Max Light Cost)
% Max HVAC = factor * base = 1.2 * 2 = 2.4
% Max Light = factor * base = 1.2 * (max(0, 5-1)*(2/4)) = 1.2 * (4*0.5) = 1.2 * 2 = 2.4
% Total Max Hourly = 2.4 + 2.4 = 4.8
maxPossibleEnergy = 24.0 * 4.8; % Estimated max over 24h (~115.2)
% Use a slightly higher round number for safety margin during normalization
maxPossibleEnergy = 120.0;

% Avoid division by zero if max values are somehow zero
if maxPossibleComfort <= 0 % Check <= 0 for safety
    maxPossibleComfort = 1; % Prevent NaN/Inf
end
if maxPossibleEnergy <= 0 % Check <= 0 for safety
    maxPossibleEnergy = 1; % Prevent NaN/Inf
end

% Normalize scores to be roughly [0, 1]
% Clamp scores just in case they exceed theoretical max due to model quirks
normalizedComfort = min(1.0, max(0.0, totalComfortScore / maxPossibleComfort));
normalizedEnergy = min(1.0, max(0.0, totalEnergyCost / maxPossibleEnergy));

% Apply weights to normalized scores
% We want to MAXIMIZE (w_comfort * normComfort - w_energy * normEnergy)
% So we MINIMIZE -(w_comfort * normComfort - w_energy * normEnergy)
fitness = -(w_comfort * normalizedComfort - w_energy * normalizedEnergy);

% Ensure fitness is never NaN or Inf
if isnan(fitness) || isinf(fitness)
    fitness = 1e6; % Assign a very large (bad) fitness if calculation failed
end

end