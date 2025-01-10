# Q-Learning Applied to Multi-Agent Systems

An example of Q-Learning application to a Multi-Agent System leveraging the GAMA platform.

## Introduction to the System

This project simulates a multi-agent system with 50 guests, 5 stages, and 2 bars. The guests are divided into five personality types:
- **10 Introvert**
- **10 Extrovert**
- **10 Party People**
- **10 Rock People**
- **10 Healthy People**

### Venues and Preferences
Each stage plays a music type, chosen from **Pop, Rock,** or **Techno**. The two bars are categorized as:
- **Non-Alcoholic Bar** (serves only non-alcoholic drinks)
- **Non-Alcaholic Bar** (serves both alcoholic and non-alcoholic drinks)

### Agent Attributes
Each agent has attributes influencing their happiness, including:
- Preferred music style
- Generosity in offering drinks
- Loudness tolerance
- Tolerance for noise
- Drink acceptance/refusal tendency

**FIPA communication protocol:** No specific protocol used.

### Simulation Flow
- **Initialization:** Agents start with `thirsty = false` and `dancing = false`. They begin at a stage playing their favorite music or, if unavailable, a random stage.
- **Thirst Mechanism:** Each agent has a random `thirsty_countdown`. Once it reaches zero, the agent becomes thirsty and heads to a random bar.
- **Socializing:** At the bar, a `socialize_countdown` starts. When it reaches zero, the agent's thirst is quenched, and they return to a stage playing their preferred music or a random stage.
- **Countdown Reset:** After each countdown completes, it resets to a random value.

## Rules for Happiness Value

### Extrovert
- **Happiness increases:** Social interactions, crowded areas, accepted drink offers, favorite music playing.
- **Happiness decreases:** Empty environments, rejected drink offers.

### Introvert
- **Happiness increases:** Favorite music playing, less crowded areas.
- **Happiness decreases:** Loud party people nearby, crowded bars.

### Rock People
- **Happiness increases:** Rock music, presence of other Rock people.
- **Happiness decreases:** Pop music parties, loud behavior during concerts.

### Party People
- **Happiness increases:** Receiving a drink, being anywhere except a non-alcoholic bar.
- **Happiness decreases:** Being at a non-alcoholic bar, presence of healthy agents.

### Healthy People
- **Happiness increases:** Being around other Healthy agents, non-alcoholic bar presence.
- **Happiness decreases:** Offered an alcoholic drink.

Moreover, each agent has a tolerance to loudness of the nearby agents which influences its happiness.

## Q-Learning Implementation

Reinforcement Learning (RL) is used to optimize overall happiness through **Q-Learning**. A **Q-Table** is initialized with zero values, where:
- **States:** 5 (each bar and stage)
- **Actions:** 9 (moving to any stage or bar, offering a drink, accepting a drink)

### Q-Learning Process:
1. **Explore or Exploit:** Agents either explore new options or exploit known high-reward actions.
2. **Action Selection:** If exploiting, agents choose the action with the highest Q-value.
3. **Reward:** Each action generates a reward (zero, positive, or negative).
4. **Q-Value Update:** The Q-Table is updated with the new reward feedback.

## Results

### Without Reinforcement Learning
<img src="https://github.com/user-attachments/assets/08808066-162f-43da-9975-79c3e2afb36a" width="700">

### With Reinforcement Learning
<img src="https://github.com/user-attachments/assets/e99ea7c2-c93a-46e1-95b7-9ce773b07cfe" width="700">

