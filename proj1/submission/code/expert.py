
from random import choice

class NaiveExpert(object): 
  """A naive expert that predicts the outcome uniformly at random."""
  def predict(self, **observation): 
    return choice([False, True])

class OptimisticExpert(NaiveExpert):  
  """An optimistic expert that always predicts that the outcome is true."""
  def predict(self, **observation): 
    return True

class PessimisticExpert(NaiveExpert):
  """A pessimistic expert that always predicts that the outcome is false.""" 
  def predict(self, **observation): 
    return False

class DualExpert(NaiveExpert): 
  """An expert that predicts that the outcome is true when the match number
     is even, and false otherwise. If the match number is not provided, 
     this expert consults the naive expert for a prediction.""" 
  def predict(self, **observation):
    return observation['match_number'] % 2 != 0 if 'match_number' in observation \
      else NaiveExpert.predict(self, **observation) # ternary operator, yeah!

# below are the experts newly introduced for section 3.5. 
# each expert is responsible for dealing with one feature. 

class WeatherExpert(NaiveExpert):
  """An expert that predicts the outcome by considering only the weather."""
  def predict(self, **observation): 
    return observation['weather'] == 'sunny' if 'weather' in observation \
      else NaiveExpert.predict(self, **observation) # 

class TimeExpert(NaiveExpert):  
  """An expert that predicts the outcome by considering only the time."""
  def predict(self, **observation):
    return observation['time'] == 'evening' if 'time' in observation \
      else NaiveExpert.predict(self, **observation) # 

class HomeAdvantageExpert(NaiveExpert):
  """An expert that predicts the outcome by considering only the home advantage."""
  def predict(self, **observation):
    return observation['location'] == 'home' if 'location' in observation \
      else NaiveExpert.predict(self, **observation) #

