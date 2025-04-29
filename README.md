# Smart Home Energy and Comfort Optimization

This MATLAB project implements a genetic algorithm (GA) to optimize smart home controls for both energy efficiency and occupant comfort across summer and winter seasons. The system optimizes three main control parameters: thermostat settings, lighting levels, and blind positions.

## Genetic Algorithm Parameters

- Population Size: 100 individuals
- Maximum Generations: 300
- Random Seed: 421011 (for reproducibility)
- Chromosome Structure: 72 elements (24 hours × 3 control parameters)
- Function Tolerance: 1e-6

## Project Structure

- `run_smart_home_ga.m` - Main script that executes the genetic algorithm optimization
- `calculateFitness.m` - Core fitness function for the genetic algorithm
- `decodeSchedule.m` - Converts GA chromosomes into human-readable schedules
- `enhanceGAPlot.m` - Improves visualization of GA convergence plots
- `getFinalScores.m` - Calculates final comfort and energy scores
- `create_data_files.m` - Generates environmental data files for summer and winter
- `summer_data.mat` - Environmental data for peak summer conditions
- `winter_data.mat` - Environmental data for peak winter conditions

### Data Files

- `summer_data.mat` and `winter_data.mat` contain hourly environmental data including:
  - Outside temperature (Summer: 32-50°C, Winter: 7-23°C)
  - Humidity levels (Summer: 10-30%, Winter: 30-50%)
  - Natural light availability (0-100%)
  - Temperature preferences (Cool/Heat/Off modes)
  - Lighting preferences (0-100%)
  - Location-specific context: Madinah climate data
  - 24-hour time series for peak summer (July) and winter (January)

## Control Parameters

The system optimizes three main control parameters for each hour:

1. **Thermostat (TH)**
   - Off
   - Cool 25°C
   - Cool 23°C
   - Heat 21°C

2. **Lighting (L)**
   - 0% to 100% in 25% increments

3. **Blinds (B)**
   - Closed
   - Half-Open
   - Open

## Comfort Score Calculation

The comfort score is calculated hourly using weighted components:

1. **Temperature Comfort (50% weight)**
   - Based on deviation from target temperature
   - Scaled using 3°C deviation factor
   - Penalties applied for mode mismatches

2. **Lighting Comfort (30% weight)**
   - Based on deviation from preferred lighting level
   - Scaled using 100% deviation factor
   - Considers natural light availability

3. **Humidity Comfort (20% weight)**
   - Target: 50% ideal humidity
   - Scaled using 50% deviation factor

## Energy Cost Model

The energy consumption is calculated using:

1. **HVAC Energy**
   - Base cooling cost: 2 units
   - Base heating cost: 2 units
   - HVAC effectiveness: 98%
   - Temperature differential impact

2. **Lighting Energy**
   - Maximum cost: 2 units at 100% brightness
   - Linear scaling with brightness level

3. **Blind Position Impact**
   - Closed: 0.8× HVAC cost, 1.2× lighting need
   - Half-Open: 1.0× for both
   - Open: 1.2× HVAC cost, 0.8× lighting need
   - Season-specific adjustments for heating/cooling

## Optimization Goals

The genetic algorithm balances two main objectives:

1. **Comfort Score (65% weight)**
   - Temperature comfort
   - Lighting comfort
   - Humidity comfort

2. **Energy Efficiency (35% weight)**
   - HVAC energy consumption
   - Lighting energy consumption
   - Impact of blind positions

## Results

The optimization results are saved in:

- `results/GA_Convergence_Summer.png` - Convergence plot for summer optimization
- `results/GA_Convergence_Winter.png` - Convergence plot for winter optimization
- `results/results_summary.md` - Detailed results including:
  - Optimal schedules for both seasons
  - Comfort and energy metrics
  - GA performance statistics

## Usage

1. Run `create_data_files.m` to generate the environmental data files
2. Execute `run_smart_home_ga.m` to perform the optimization
3. View results in the `results` directory

## Dependencies

- MATLAB R2024a (Version 24.1.0.2537033)
- Global Optimization Toolbox (Version 24.1)
  - Required for genetic algorithm implementation  

Note: The project has been tested with these versions. Earlier versions may work but are not guaranteed.
