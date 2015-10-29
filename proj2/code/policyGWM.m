classdef policyGWM < Policy
    %POLICYGWM This policy implementes GWM for the bandit setting.
    
    properties
        nbActions     %  number of bandit actions
        weights       %% the weights associated with each action.
        lastAction    %% this is the last action this policy has produced.
        nr_iteration  %% number of iterations for computing the penalty factor.  
    end
    
    methods
        
        function init(self, nbActions)
            % Initialize any member variables
            self.nbActions = nbActions;

            %% the weights are initialized as ones. no iteration yet.  
            self.weights = ones(nbActions, 1); 
            self.nr_iteration = 0; 

        end
        
        function action = decision(self)
            % Choose an action according to multinomial distribution

            %% mnrnd only accepts probabilities that sum up to one, so we do that first.
            %% then we use find to find out the index of the element that has exactly one count. 
            action = find(mnrnd(1, self.weights / sum(self.weights)));

            %% also keep a record on this for later this in getReward.
            self.lastAction = action; 
            self.nr_iteration = self.nr_iteration + 1; 

        end
        
        function getReward(self, reward)
            % Update the weights
            
            % First we create the loss vector for GWM
            lossScalar = 1 - reward; % This is loss of the chosen action
            lossVector = zeros(1,self.nbActions);
            lossVector(self.lastAction) = lossScalar; 

            %% compute the penalty factor for this particular iteration as instructed, 
            %% and then update the weights by applying an exponential decaying factor.  
            penalty = sqrt(log(self.nbActions) / self.nr_iteration);  
            self.weights = self.weights .* exp(-penalty * lossVector)'; 
            
            % Do more stuff here using loss Vector
        end        
    end
end

