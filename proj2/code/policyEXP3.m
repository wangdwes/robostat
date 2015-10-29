classdef policyEXP3 < Policy
    %POLICYEXP3 This is a concrete class implementing EXP3.
    
    properties
        nbActions     %% number of bandit actions
        weights       %% the weights associated with each action.
        lastAction    %% this is the last action this policy has produced.
        nr_iteration  %% number of iterations for computing the penalty factor.  
                      %% copied from policyGWM - nothing has changed. 
    end
    
    methods

        function init(self, nbActions)
            % Initialize member variables
            self.nbActions = nbActions;

            % the weights are initialized as ones. no iteration yet.  
            self.weights = ones(nbActions, 1); 
            self.nr_iteration = 0; 

        end
        
        function action = decision(self)
            % Choose an action
            %% again everything is copied directly from policyGWM.m

            %% mnrnd only accepts probabilities that sum up to one, so we do that first.
            %% then we use find to find out the index of the element that has exactly one count. 
            action = find(mnrnd(1, self.weights / sum(self.weights)));

            %% also keep a record on this for later this in getReward.
            self.lastAction = action; 
            self.nr_iteration = self.nr_iteration + 1; 

        end
        
        function getReward(self, reward)
            % reward is the reward of the chosen action
            % update internal model

            %% it is not necessary to create a vector that only has one element.  
            %% we just update the weight in question and leave everything else untouched.
            scaled_loss = (1 - reward) / (self.weights(self.lastAction) / sum(self.weights)); 
            penalty = sqrt(log(self.nbActions) / (self.nr_iteration * self.nbActions));  
            self.weights(self.lastAction) = self.weights(self.lastAction) * exp(-penalty * scaled_loss); 

        end        
    end
end
