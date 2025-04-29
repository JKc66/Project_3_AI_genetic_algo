# Smart Home GA Optimization Results

Date Run: 29-Apr-2025 20:26:12
GA Parameters:
- Population Size: 100
- Max Generations: 300
- Random Seed: 421011

## Peak Summer (July) Results

**GA Performance:**
- Final Best Fitness (Minimized Value): -0.3386
- Exit Flag: 1
- Generations Run: 296

**Optimal Schedule Performance Metrics:**
- Total Comfort Score (Higher is better, Max ~24): 19.6300
- Average Hourly Comfort Score (Higher is better, Max ~1): 0.8179
- Total Energy Cost (Lower is better, arbitrary units): 66.2000
- Average Hourly Energy Cost (Lower is better): 2.7583

**Optimal Schedule (Summer):**

| Hour | Thermostat | Lighting | Blinds | Notes |
|------|------------|----------|--------|-------|
| 1 | Cool 25C | 0% | Half-Open | Warm Night |
| 2 | Cool 23C | 0% | Half-Open | Warm Night |
| 3 | Cool 25C | 0% | Half-Open | Warm Night |
| 4 | Cool 25C | 0% | Half-Open | Warm Night |
| 5 | Cool 23C | 25% | Half-Open | Before Sunrise |
| 6 | Cool 23C | 25% | Closed | Sunrise ~5:40 AM |
| 7 | Cool 25C | 75% | Half-Open | Morning, getting bright |
| 8 | Cool 25C | 25% | Half-Open | Morning, getting bright |
| 9 | Cool 25C | 75% | Closed | Morning, getting bright |
| 10 | Cool 25C | 75% | Half-Open | Peak Sun Period |
| 11 | Cool 25C | 50% | Half-Open | Peak Sun Period |
| 12 | Cool 23C | 25% | Half-Open | Peak Sun Period |
| 13 | Cool 23C | 75% | Half-Open | Peak Sun Period |
| 14 | Heat 21C | 75% | Open | Peak Sun Period, Hottest Time |
| 15 | Cool 23C | 75% | Half-Open | Peak Sun Period |
| 16 | Cool 25C | 75% | Half-Open | Peak Sun Period |
| 17 | Cool 23C | 75% | Half-Open | Peak Sun Period |
| 18 | Cool 23C | 75% | Half-Open | Afternoon Peak Sun Ends |
| 19 | Cool 25C | 50% | Closed | Sunset ~7:10 PM |
| 20 | Cool 23C | 25% | Half-Open | Evening |
| 21 | Cool 25C | 50% | Half-Open | Evening |
| 22 | Cool 25C | 25% | Open | Late Evening |
| 23 | Cool 23C | 0% | Half-Open | Night |
| 24 | Cool 25C | 0% | Closed | Night |

## Peak Winter (January) Results

**GA Performance:**
- Final Best Fitness (Minimized Value): -0.4471
- Exit Flag: 0
- Generations Run: 300

**Optimal Schedule Performance Metrics:**
- Total Comfort Score (Higher is better, Max ~24): 22.2817
- Average Hourly Comfort Score (Higher is better, Max ~1): 0.9284
- Total Energy Cost (Lower is better, arbitrary units): 53.6000
- Average Hourly Energy Cost (Lower is better): 2.2333

**Optimal Schedule (Winter):**

| Hour | Thermostat | Lighting | Blinds | Notes |
|------|------------|----------|--------|-------|
| 1 | Heat 21C | 0% | Open | Cool Night |
| 2 | Cool 23C | 0% | Closed | Cool Night |
| 3 | Heat 21C | 0% | Open | Cool Night |
| 4 | Heat 21C | 0% | Open | Cool Night, Coolest |
| 5 | Heat 21C | 0% | Open | Before Sunrise |
| 6 | Heat 21C | 25% | Open | Before Sunrise |
| 7 | Heat 21C | 75% | Open | Sunrise ~7:10 AM |
| 8 | Heat 21C | 75% | Open | Morning, warming up |
| 9 | Heat 21C | 75% | Open | Morning, warming up |
| 10 | Heat 21C | 50% | Open | Mild |
| 11 | Heat 21C | 50% | Open | Comfortable Day Temp Start |
| 12 | Cool 23C | 75% | Closed | Peak Day Temp |
| 13 | Off | 75% | Open | Peak Day Temp |
| 14 | Heat 21C | 75% | Open | Comfortable Day Temp |
| 15 | Heat 21C | 75% | Open | Comfortable Day Temp, Temp starts falling |
| 16 | Heat 21C | 75% | Open | Getting Cooler |
| 17 | Heat 21C | 75% | Open | Getting Cooler |
| 18 | Heat 21C | 50% | Open | Sunset ~5:45 PM |
| 19 | Heat 21C | 50% | Open | Evening |
| 20 | Heat 21C | 50% | Open | Evening |
| 21 | Heat 21C | 25% | Open | Late Evening |
| 22 | Heat 21C | 0% | Open | Night |
| 23 | Heat 21C | 0% | Open | Night |
| 24 | Heat 21C | 0% | Open | Night |

