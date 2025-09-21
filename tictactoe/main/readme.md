# Tic-Tac-Toe AI Agents

This project implements three AI agents for playing Tic-Tac-Toe using different algorithms: Value Iteration, Policy Iteration, and Q-Learning. The agents can play against each other or against rule-based opponents.

## Agents Overview

- **Value Iteration Agent**: Implements the value iteration algorithm for Markov Decision Processes
- **Policy Iteration Agent**: Implements the policy iteration algorithm for Markov Decision Processes  
- **Q-Learning Agent**: Implements a reinforcement learning agent using Q-learning with ε-greedy exploration

## Getting Started

### Prerequisites

- Java JDK 8 or higher
- Git

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
```

2. Navigate to the project directory:
```bash
cd tic-tac-toe-ai
```

### Running the Game

To run the game with default settings (human vs random agent):
```bash
java -cp target/classes/ ticTacToe.Game
```

To see all available options:
```bash
java -cp target/classes/ ticTacToe.Game -h
```

## Usage Examples

Play against a random agent:
```bash
java -cp target/classes/ ticTacToe.Game -x human -o random
```

Watch two random agents play:
```bash
java -cp target/classes/ ticTacToe.Game -x random -o random
```

Test the Value Iteration agent against a random agent:
```bash
java -cp target/classes/ ticTacToe.Game -x vi -o random -s x
```

Test the Policy Iteration agent against a defensive agent:
```bash
java -cp target/classes/ ticTacToe.Game -x pi -o defensive -s x
```

Test the Q-Learning agent against an aggressive agent:
```bash
java -cp target/classes/ ticTacToe.Game -x ql -o aggressive -s x
```

## Agent Types

- `human`: Human player (you)
- `random`: Random move selection
- `aggressive`: Rule-based agent that prioritizes winning
- `defensive`: Rule-based agent that prioritizes blocking
- `vi`: Value Iteration agent
- `pi`: Policy Iteration agent  
- `ql`: Q-Learning agent

## Project Structure

- `ValueIterationAgent.java`: Value Iteration implementation
- `PolicyIterationAgent.java`: Policy Iteration implementation
- `QLearningAgent.java`: Q-learning implementation
- `Game.java`: Main game class
- `TTTMDP.java`: Tic-Tac-Toe MDP model definition
- `TTTEnvironment.java`: Reinforcement Learning environment
- `Agent.java`: Abstract agent class
- Various policy and agent implementations

## Explanation Video

For a detailed explanation of the algorithms and implementation, please watch the accompanying video tutorial.


