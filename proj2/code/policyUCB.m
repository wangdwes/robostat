classdef policyUCB < Policy
    %POLICYUCB This is a concrete class implementing UCB.

    properties
        nbActions     %% number of bandit actions.
        nr_selected   %% the number of times that a particular action is selected. 
        nr_payoffs    %% the number of times that a particular action pays off.  
        nr_iteration  %% the number of iterations, necessary for deriving the action.  
        lastAction    %% this is the last action this policy has produced.
    end
    
    methods
        function init(self, nbActions)
            % Initialize
            
            %% yep, just initialize.   
            self.nbActions = nbActions; 
            self.nr_selected = zeros(nbActions, 1) + eps; %% so we don't get nans and infs. 
            self.nr_payoffs = zeros(nbActions, 1);
            self.nr_iteration = 0; 

        end
        
        function action = decision(self)
            % Choose action

            %% determine the action consistent with our confidence over all the actions.
            %% note that initially this will result in a bunch of division by zeros but that is fine. 
            [~, action] = max((self.nr_payoffs ./ self.nr_selected) + ...
              sqrt(log(self.nr_iteration) ./ (2 * self.nr_selected)));

            %% also keep a record on this for later this in getReward.
            self.lastAction = action; 
            self.nr_iteration = self.nr_iteration + 1; 

        end
        
        function getReward(self, reward)
            % Update ucb
    
            %% update the counters for selected and payoffs.
            self.nr_selected(self.lastAction) = self.nr_selected(self.lastAction) + 1;
            self.nr_payoffs(self.lastAction) = self.nr_payoffs(self.lastAction) + reward; 

        end        
    end

end
