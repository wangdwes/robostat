#!/usr/bin/python

# all the players march into the arena
from expert import *
from nature import *
from learner import *
# we also need to plot and etc. 
import numpy as np
import matplotlib.pyplot as plt 

def do_online_learning(learner, nature, number_rounds): 
  """learn online with the specified learner, nature for the specified number of rounds."""

  # salute to the old good linux function naming convention.
  regrets, losses = [], [] 
  # yep, just iterate that many times. 
  for index in range(0, number_rounds - 1):
    # 1. the nature produces an observation
    # 2. the learner receives the observation that makes a prediction.  
    # 3. the nature determines the label, possibly peeking at the learner.
    # 4. the learner updates the weights of its experts and returns the loss.
    observation = nature.observe() 
    prediction = learner.predict(**observation) 
    true_label = nature.label(learner = learner, **observation)
    losses.append(learner.update(true_label))   
    # 5. also save the regrets this round for all the experts. 
    # again, this is essentially a difference of losses, not regrets, for being not cumulative. 
    regrets.append(learner.regrets())  

  return losses, regrets

def plot(losses, regrets): 
  """plot the losses and regrets, supposedly cumulative."""
  figure, axe1 = plt.subplots()
  axe1.plot(regrets, 'r-')
  axe1.set_ylabel('Regret')
  axe2 = axe1.twinx()
  axe2.plot(losses, 'b--')
  axe2.set_ylabel('Loss') 
  return figure 

def learn_online(nature, learner, experts, number_rounds = 100): 
  """the learner will first hire the experts, and run online learning 
     for the specified number of rounds, and return the plots."""   
  # hire the experts. 
  learner.hire(*experts)
  # run the online learning algorithm
  losses, regrets = do_online_learning(learner, nature, number_rounds)
  # compute the cumulative regrets and losses
  losses_cum = np.cumsum(losses)
  regrets_cum = np.amax(np.cumsum(regrets, axis = 0), axis = 1)
  # plot the performance and return the figure   

  return plot(losses_cum, regrets_cum)



# instantiate the elements. 
nature = LawfulNature()
learner = WeightedMajorityLearner(0.5)
experts = [TimeExpert(), WeatherExpert(), HomeAdvantageExpert()]

# run the simulations.  
figure = learn_online(nature, learner, experts, 1000) 
figure.set_size_inches(10, 4, forward = True)

# visualize
plt.grid()
figure.savefig('lawful-wm-3.eps')


