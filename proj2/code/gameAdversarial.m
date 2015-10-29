classdef gameAdversarial<Game
    %GAMEADVERSARIAL This is a concrete class defining a game where rewards
    %   are adversarially chosen.

    methods
        
        function self = gameAdversarial(nbActions, totalRounds)

            self.nbActions = nbActions;
            self.totalRounds = totalRounds; 

            %% populate a deterministic reward sequence. the idea is that we know the policy
            %% would certainly pick up the first action in the first iteration, so we set the
            %% reward to be one for the second action, and zero otherwise. seeing this, the policy
            %% goes to the second action for exploration, but this time we set its reward to zero,
            %% and the reward for the first action to one. the policy will go on and exhaust
            %% all the actions, and until it rewinds back to the first action (it will, since there
            %% is no payoff from any of the action, the policy has no preference at all and therefore
            %% will go back). before this happens we repeat the same reward pattern as the second
            %% iteration, and when this happens the reward pattern starts a new cycle. in this scenario, 
            %% the policy gets nothing, but choosing a fixed action 1 gives substantial reward. 

            self.tabR = vertcat(ones(1, totalRounds), zeros(nbActions - 1, totalRounds));
            self.tabR(1, 1: nbActions: totalRounds) = 0; 
            self.tabR(2, 1: nbActions: totalRounds) = 1; 

            self.N = 0;

        end
        
    end    
end

