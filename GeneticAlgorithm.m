function [bestPosition, bestFitness, convergenceCurve] = GeneticAlgorithm( ...
    objectiveFunction, bounds, maxGenerations, populationSize, ...
    crossoverProbability, mutationProbability, elitismRate, ...
    selectionMethod, absConvCounterLimit, relConvCounterLimit)

% =========================================================================
% Genetic Algorithm for Continuous Optimization
%
% Finds a high-value solution for a user-defined objective function.
% The objective function must be written to accept a vector of decision
% variables and return a single scalar value. This implementation performs
% maximization; to minimize a function, pass its negative as the objective.
%
% Decision variables are represented internally as normalized values in
% [0, 1] and mapped to the user-defined bounds before objective evaluation.
%
% Inputs:
%   objectiveFunction    - Function handle that returns the fitness value
%   bounds               - Lower and upper bounds in alternating order:
%                          [lb1 ub1 lb2 ub2 ...]
%   maxGenerations       - Maximum number of generations (default: 100)
%   populationSize       - Number of individuals (default: 50)
%   crossoverProbability - Probability of applying crossover (default: 0.75)
%   mutationProbability  - Mutation rate used to determine the number of
%                          mutation operations (default: 0.02)
%   elitismRate          - Fraction used to determine the number of elite
%                          individuals (default: 0.1)
%   selectionMethod      - Selection strategy: 0 for rank-based selection,
%                          1 for roulette-wheel selection (default: 0)
%   absConvCounterLimit  - Number of consecutive generations required by
%                          the absolute convergence test (default: 10000)
%   relConvCounterLimit  - Number of consecutive generations required by
%                          the relative convergence test (default: 10000)
%
% Outputs:
%   bestPosition     - Decision-variable vector with the highest fitness
%   bestFitness      - Objective-function value at bestPosition
%   convergenceCurve - Best fitness value recorded at each generation
%
% Stopping criteria:
%   The algorithm stops when the maximum generation count is reached or
%   when both convergence tests meet their respective consecutive-generation
%   limits. The convergence tolerances are defined in the implementation.
% =========================================================================

if nargin < 3

       maxGenerations = 100; % Maximum number of generations

end

if nargin < 4

       populationSize = 50; % Population size

end

if nargin < 5

       crossoverProbability = 0.75; % Crossover probability

end

if nargin < 6

       mutationProbability = 0.02; % Mutation probability

end

if nargin < 7

       elitismRate = 0.1; % Fraction used to determine the elite count

end

if nargin < 8

       selectionMethod = 0; % selectionMethod = 0 (rank-based selection); 1 (roulette-wheel selection)

end

if nargin < 9

       absConvCounterLimit = 10000;

end

if nargin < 10

       relConvCounterLimit = 10000;

end

numVariables = length(bounds)/2;

numElite = round(elitismRate*populationSize);

numMutations = round(mutationProbability*(populationSize-numElite)*numVariables);

chromosomes=zeros(populationSize,numVariables); % Normalized candidate solutions

fitnessValues = zeros(populationSize,1); % Fitness value of each individual

decisionVariables = zeros(numVariables,1);

% Extract the lower and upper bounds for each decision variable

lowerBounds=bounds(1:2:end-1);

upperBounds=bounds(2:2:end);

%% Initialize the population

for i=1:populationSize

       for j=1:numVariables

           chromosomes(i,j)=rand;

       end

end

%% Evaluate the initial population

for i=1:populationSize

       for j=1:numVariables

           decisionVariables(j)=lowerBounds(j)+(upperBounds(j)-lowerBounds(j))*chromosomes(i,j);

       end

       fitnessValues(i)=objectiveFunction(decisionVariables);

end

if selectionMethod==0

       selectionProbabilities=zeros(populationSize,1);    

       cumulativeProbabilities=zeros(populationSize,1);    

       for i=1:populationSize

           selectionProbabilities(i)=i;

       end

       selectionProbabilities=selectionProbabilities/sum(selectionProbabilities);

       for i=1:populationSize

           if i==1

               cumulativeProbabilities(i)=selectionProbabilities(i);

           else

               cumulativeProbabilities(i)=cumulativeProbabilities(i-1)+selectionProbabilities(i);

           end

       end

end

generation=0;

running=1;

absConvFlag=0;

relConvFlag=0;

absConvCounter=0;

relConvCounter=0;

previousBestFitness=inf;

convergenceCurve=zeros(maxGenerations,1);

%% Main genetic algorithm loop

while (running)

       generation=generation+1;

       fprintf('Generation: %d\n', generation);

       %% Preserve the elite individuals

       [fitnessValues, sortedIndices]=sort(fitnessValues); % Sort fitness values in ascending order

       sortedFitnessValues=fitnessValues;

       chromosomes=chromosomes(sortedIndices,:);

       sortedChromosomes=chromosomes;

       for i=1:numElite

           fitnessValues(i)=sortedFitnessValues(populationSize+1-i);

           chromosomes(i,:)=sortedChromosomes(populationSize+1-i,:);

       end

       if selectionMethod==1

           % Roulette wheel: calculate each individual's selection probability

           totalFitness=sum(sortedFitnessValues);

           selectionProbabilities=zeros(populationSize,1); % Used for roulette-wheel selection

           cumulativeProbabilities=zeros(populationSize,1); % Used for roulette-wheel selection

           for i=1:populationSize

               selectionProbabilities(i)=sortedFitnessValues(i)/totalFitness;

               if i==1

                   cumulativeProbabilities(i)=selectionProbabilities(i);

               else

                   cumulativeProbabilities(i)=cumulativeProbabilities(i-1)+selectionProbabilities(i);

               end

           end

       end

       %% Select individuals for reproduction

       for i=1:populationSize-numElite

           randomValue=rand;

           for j=1:populationSize

               if j==1

                   if randomValue>0 && randomValue<=cumulativeProbabilities(j)

                      fitnessValues(i+numElite)=sortedFitnessValues(j);

                      chromosomes(i+numElite,:)=sortedChromosomes(j,:);

                   end

               else

                   if randomValue>cumulativeProbabilities(j-1) && randomValue<=cumulativeProbabilities(j)

                      fitnessValues(i+numElite)=sortedFitnessValues(j);

                      chromosomes(i+numElite,:)=sortedChromosomes(j,:);

                   end    

               end

           end    

       end

     %% Generate and evaluate crossover candidates

     parentOrder=randperm(populationSize);

     parentOrder=parentOrder(parentOrder>numElite);

     for i=2:2:populationSize-numElite

         randomValue=rand;

         if randomValue<crossoverProbability % Apply crossover to the selected parent pair    

             offspring=zeros(3,numVariables);

             for j=1:numVariables

                 offspring(1,j)=0.5*chromosomes(parentOrder(i-1),j)+0.5*chromosomes(parentOrder(i),j);

                 if offspring(1,j)<0

                     offspring(1,j)=0;

                 end

                 if offspring(1,j)>1

                     offspring(1,j)=1;

                 end

                 offspring(2,j)=1.5*chromosomes(parentOrder(i-1),j)-0.5*chromosomes(parentOrder(i),j);

                 if offspring(2,j)<0

                     offspring(2,j)=0;

                 end

                 if offspring(2,j)>1

                     offspring(2,j)=1;

                 end

                 offspring(3,j)=-0.5*chromosomes(parentOrder(i-1),j)+1.5*chromosomes(parentOrder(i),j);

                 if offspring(3,j)<0

                     offspring(3,j)=0;

                 end

                 if offspring(3,j)>1

                     offspring(3,j)=1;

                 end

             end

             offspringFitness=zeros(1,3);

             for j=1:3

                 for k=1:numVariables

                     decisionVariables(k)=(upperBounds(k)-lowerBounds(k))*offspring(j,k)+lowerBounds(k);

                 end

                 offspringFitness(j)=objectiveFunction(decisionVariables);

             end

             [sortedOffspringFitness,sortedIndices]=sort(offspringFitness);

             chromosomes(parentOrder(i-1),:)=offspring(sortedIndices(2),:);

             fitnessValues(parentOrder(i-1))=sortedOffspringFitness(2);

             chromosomes(parentOrder(i),:)=offspring(sortedIndices(3),:);

             fitnessValues(parentOrder(i))=sortedOffspringFitness(3);

         end

     end

     %% Mutate selected individuals

     needsEvaluation=zeros(1,populationSize);% A value of 1 indicates that the objective function must be evaluated later

     for i=1:numMutations

         mutationIndex=floor(rand*(populationSize-numElite)+numElite)+1;

         if mutationIndex>populationSize

             mutationIndex=populationSize;

         end

         randomVariableOrder=randperm(numVariables);

         mutationVariable=randomVariableOrder(1);

         chromosomes(mutationIndex,mutationVariable)=rand;

         needsEvaluation(mutationIndex)=1;

     end

     %% Re-evaluate individuals changed by mutation

     for i=1:populationSize

         if needsEvaluation(i)==1

             for j=1:numVariables

                 decisionVariables(j)=(upperBounds(j)-lowerBounds(j))*chromosomes(i,j)+lowerBounds(j);

             end

             fitnessValues(i)=objectiveFunction(decisionVariables);

         end

     end

     %% Check stopping criteria

     if (generation>=maxGenerations)

         running=0;

     end

     if (abs(max(fitnessValues)-previousBestFitness)<0.00001)

         absConvCounter=absConvCounter+1;

         if (absConvCounter>=absConvCounterLimit)

             absConvFlag=1;

         end

     else

         absConvCounter=0;

         absConvFlag=0;

     end

     if (abs(max(fitnessValues)-previousBestFitness)/max(abs(max(fitnessValues)),10^(-10))<0.01)

         relConvCounter=relConvCounter+1;

         if (relConvCounter>=relConvCounterLimit)

             relConvFlag=1;

         end

     else

         relConvCounter=0;

         relConvFlag=0;

     end

     if absConvFlag==1 && relConvFlag==1

         running=0;

     end

     previousBestFitness=max(fitnessValues);

     convergenceCurve(generation)=previousBestFitness;

end

[bestFitness,bestIndex]=max(fitnessValues);

for j=1:numVariables

       decisionVariables(j)=(upperBounds(j)-lowerBounds(j))*chromosomes(bestIndex,j)+lowerBounds(j);    

end

bestPosition=decisionVariables;

convergenceCurve = convergenceCurve(1:generation);

end