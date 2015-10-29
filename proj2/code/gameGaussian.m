classdef gameGaussian < Game
    %GAMEGAUSSIAN This is a concrete class defining a game where rewards a
    %   are drawn from a gaussian distribution.
    
    methods
        
        function self = gameGaussian(nbActions, totalRounds) 
            % Input
            %   nbActions - number of actions
            %   totalRounds - number of rounds of the game

            self.nbActions = nbActions; 
            self.totalRounds = totalRounds;
            self.N = 0; %% of course, the round counter is initialized to zero. 

            %% populate the table with some near-semi-quasi-guassian distribution. 
            %% use a pair of min and max to bound the samples within [0, 1]. 
            self.tabR = zeros(nbActions, totalRounds); 
            for index_action = [1: nbActions]
              self.tabR(index_action, :) = min(max(normrnd(rand, rand, 1, totalRounds), 0), 1); 
            end

        end 
    end    
end

