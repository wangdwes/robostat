
from learner import *
from numpy import average
from numpy.random import choice

class NaiveNature(object):
  """A naive nature that generates an observation, including the match 
     number, the weather, the time and the location, which is shared
     among all natures, and produces an outcome uniformly at random.""" 

  def label(self, **information):
    return choice([False, True])

  match_number = 0 # the nature maintains an internal state.
  def observe(self):
    self.match_number += 1
    # we could use multi-value features, but they do not really help that much
    # in terms of demonstrating the effectiveness of online learning.  
    return {'match_number': self.match_number, \
            'weather'     : choice(['sunny', 'rainy']), \
            'time'        : choice(['afternoon', 'evening']), \
            'location'    : choice(['home', 'away'])}

class TrialNature(NaiveNature): 
  """A nature that determines that the outcome is true if the match number
     is a multiple of three, and false otherwise. Note that the name comes
     from the grammatical number 'trial', not from 'trial and error'."""
  def label(self, **information): 
    return information['match_number'] % 3 != 0 if 'match_number' in information \
      else NaiveNature.label(self, **information)

class ChaoticNature(NaiveNature): 
  """A nature that determines the outcome by first peeking at the most
     recently made predictions and the current weights of the learner,
     then making a deterministic prediction opposite to whatever the learner
     may think, using a model that may or may not be the same."""
  def label(self, **information): 
    return average(information['learner'].predictions(), weights = \
                   information['learner'].normalized_weights()) < 0.5 \
           if 'learner' in information else NaiveNature.label(self, **information)

# below is the nature newly introduced for section 3.5, the idea is that 
# although individual experts cannot perfectly predict the outcome of a match, 
# but since this nature is lawfully (as opposed to chaotically) generating the
# outcome as a linear combination of the features, the learner, essentially
# utilizing the same policy (weighted majority), should be able to learn the
# optimal weights, therefore achieving a decent accuracy and low regret. 

class LawfulNature(NaiveNature):
  """A nature that lawfully determines the outcome by considering the weather
     weather condition, the time, and the home advantage for a match. These
     factors are linearly combined using weights unbeknownst to the learner."""
  def label(self, **information): 
    return ((information['weather']  == 'sunny') * 0.20 + \
            (information['time']     == 'evening') * 0.35 + \
            (information['location'] == 'home') * 0.45) >= 0.50 \
           if all([feature in information for feature in ['weather', 'time', 'location']]) \
           else NaiveNature.label(self, **information)

