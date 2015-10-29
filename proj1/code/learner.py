
from numpy import average
from numpy.random import choice

class Assistant(object):
  """An administrative assistant that maintains the weight and the prediction 
     associated with a particular expert. These pieces of information should
     not be kept by the experts because they do not care about these.""" 

  weight = 1.0
  regret = 0.0 
  prediction = False
  expert = None

  # each assistant is responsible for assisting one expert.
  def __init__(self, expert): 
    self.expert = expert

class NaiveLearner(object): 
  """A naive learner that makes all decisions stochastically."""
  
  penalty = 0.5       # the penalty factor.
  loss = 0            # the loss incurred in the most recent round of prediction. 
  prediction = False  # the prediction most recently made by the learner. 
  assistants = []     # the list of assistants, therefore the experts, that we need to consult. 

  def __init__(self, penalty = 0.5): 
    self.penalty = penalty 

  def hire(self, *experts):
    """hire an expert and assign an administrative assistant to him or her.
       yep, experts all hold tenure and you cannot fire them at will."""
    for expert in experts: self.assistants.append(Assistant(expert)) 
    return len(self.assistants) 

  def number_experts(self):
    """retrieve the number of experts.""" 
    return len(self.assistants)

  def regrets(self):  
    """retrieve the regrets incurred in the mots recent round of prediction.
       note this is technically not regret for being not cumulative.""" 
    return [assistant.regret for assistant in self.assistants]

  def predictions(self):
    """retrieve the predictions made in the most recent round of prediction.""" 
    return [assistant.prediction for assistant in self.assistants] 

  def true_weights(self):
    """retrieve the current and un-normalized weights from all experts.""" 
    return [assistant.weight for assistant in self.assistants]

  def normalized_weights(self):
    """retrieve the current and normalized weights from all experts."""
    true_weights = self.true_weights()
    return [true_weight / sum(true_weights) for true_weight in true_weights]

  def predict(self, **observation):
    """make a prediction by consulting all the experts, given an observation.
       this method only changes all the predictions maintained by the assistants."""
    # first let each assistant talk to the expert that get some prediction
    for assistant in self.assistants:
      assistant.prediction = assistant.expert.predict(**observation) 
    # produce a final prediction based on the predictions provided by the experts. 
    # in this naive learner we just make a prediction stochastically.
    self.prediction = choice([False, True]) 
    return self.prediction 

  def update(self, true_label): 
    """update the weights of the experts based on the true label.
       this method only changes all the weights maintained by the assistants.""" 
    # first of all compute the loss incurred in this round of prediction.
    self.loss = int(self.prediction != true_label)
    # iterate through all the assistants and update their weights and regrets 
    for assistant in self.assistants:
      assistant.regret = self.loss - int(assistant.prediction != true_label)
      if self.loss == 1 and assistant.prediction != true_label:
        assistant.weight *= 1 - self.penalty 
    # return the loss. perhaps returning the regrets together in a tuple would be better?
    return self.loss

class WeightedMajorityLearner(NaiveLearner):
  """A learner that uses the weighted majority algorithm to make predictions."""
  def predict(self, **observation):
    NaiveLearner.predict(self, **observation)
    self.prediction = average(self.predictions(), weights = self.normalized_weights()) >= 0.5 
    return self.prediction

class RandomizedWeightedMajorityLearner(NaiveLearner): 
  """A learner that uses the randomized weighted majority algorithm to make predictions."""
  def predict(self, **observation): 
    NaiveLearner.predict(self, **observation)
    self.prediction = choice(self.predictions(), p = self.normalized_weights())
    return self.prediction 

