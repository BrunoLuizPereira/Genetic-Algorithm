clc
clear
close all

%% Search-space bounds
% Bounds are provided as [lower1 upper1 lower2 upper2 ...].
searchBounds = [-5 +2 -5 +3];

%% Genetic Algorithm parameters
maxGenerations = 100;
populationSize = 50;
crossoverProbability = 0.75;
mutationProbability = 0.02;
elitismRate = 0.1;
selectionMethod = 0;

%% Run the Genetic Algorithm
[bestPosition, bestFitness, convergenceCurve] = ...
    GeneticAlgorithm(@ObjectiveFunction, searchBounds, ...
    maxGenerations, populationSize, crossoverProbability, ...
    mutationProbability, elitismRate, selectionMethod);

%% Display results
fprintf('Best decision variables: \n');
disp(bestPosition)

fprintf('Best objective-function value: %.6f \n', bestFitness);

%% Plot the convergence curve
figure
plot(convergenceCurve, 'LineWidth', 1.5)
xlabel('Generation')
ylabel('Best Objective-Function Value')
title('Genetic Algorithm Convergence')
grid on
box on
