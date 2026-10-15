# Genetic Algorithm for Continuous Optimization

A simple, practical, and easy-to-use implementation of a Genetic Algorithm (GA) for continuous optimization in **MATLAB and GNU Octave**.

The algorithm allows users to maximize their own objective functions within user-defined bounds, without requiring additional MATLAB toolboxes. It is suitable for students, researchers, engineers, and anyone interested in numerical optimization.

The implementation includes selection, crossover, mutation, elitism, and convergence monitoring.

**Important:** The algorithm performs **maximization**. To solve a minimization problem, define the objective function as the negative of the function to be minimized.

## Requirements

- MATLAB or GNU Octave.
- No additional MATLAB toolboxes are required.

## Files

- `GeneticAlgorithm.m` — main optimization function.
- `Main.m` — example script that configures and runs the algorithm.
- `ObjectiveFunction.m` — objective function used in the example.

Keep all three files in the same folder, or add their folder to the MATLAB or Octave path.

## Example

The provided `Main.m` script maximizes the objective function defined in `ObjectiveFunction.m`:

\[
f(x_1,x_2)=-x_1^2-x_2^2+10
\]

The search bounds are:

\[
-5\leq x_1\leq 2,\qquad -5\leq x_2\leq 3
\]

The theoretical maximum is \(f(0,0)=10\).

To run the example, set the project folder as the current folder and execute:

```matlab
Main
```

The script displays the best solution found, its objective-function value, and the convergence curve.

## Using the Algorithm

The main function has the following syntax:

```matlab
[bestPosition, bestFitness, convergenceCurve] = GeneticAlgorithm( ...
    objectiveFunction, bounds, maxGenerations, populationSize, ...
    crossoverProbability, mutationProbability, elitismRate, ...
    selectionMethod, absConvCounterLimit, relConvCounterLimit);
```

The first two arguments are required:

- `objectiveFunction` — function handle that receives a vector of decision variables and returns a scalar objective value.
- `bounds` — vector containing the lower and upper bounds of each decision variable in alternating order.

For example, for three decision variables:

```matlab
bounds = [lb1 ub1 lb2 ub2 lb3 ub3];
```

All subsequent arguments are optional.

### Input Parameters

| Parameter | Description | Default |
|---|---|---:|
| `maxGenerations` | Maximum number of generations. | `100` |
| `populationSize` | Number of individuals in the population. | `50` |
| `crossoverProbability` | Probability of applying crossover to a selected pair of parents. | `0.75` |
| `mutationProbability` | Parameter used to determine the number of mutation operations. | `0.02` |
| `elitismRate` | Fraction used to determine the number of elite individuals. | `0.1` |
| `selectionMethod` | `0` for rank-based selection probabilities; `1` for roulette-wheel selection. | `0` |
| `absConvCounterLimit` | Consecutive-generation limit for the absolute convergence test. | `10000` |
| `relConvCounterLimit` | Consecutive-generation limit for the relative convergence test. | `10000` |

### Selection, Mutation, and Elitism

- **Selection:** method `0` assigns probabilities according to individuals' positions after sorting fitness values. Method `1` calculates probabilities directly from fitness values using roulette-wheel selection. For method `1`, fitness values must produce valid probabilities; positive values with a positive sum are the safest choice.
- **Crossover:** combines selected parent chromosomes to generate candidate offspring.
- **Mutation:** modifies randomly selected normalized decision-variable values. The `mutationProbability` parameter determines the number of mutation operations; it is not an independent probability applied to each gene.
- **Elitism:** determines how many individuals are designated as elite and preserved according to fitness.

## Output Arguments

- `bestPosition` — decision-variable vector associated with the highest fitness found.
- `bestFitness` — objective-function value at `bestPosition`.
- `convergenceCurve` — best fitness value recorded at each generation.

## Stopping Criteria

The algorithm stops when the maximum number of generations is reached or when both convergence tests satisfy their respective consecutive-generation limits.

The convergence tests use an absolute tolerance of `1e-5` and a relative threshold of `0.01` (1%). The corresponding counter limits are configurable through `absConvCounterLimit` and `relConvCounterLimit`.

Because genetic algorithms are stochastic optimization methods, results may vary between runs, and finding the global optimum is not guaranteed.

## License

This project is distributed under the MIT License. See the `LICENSE` file for details.
