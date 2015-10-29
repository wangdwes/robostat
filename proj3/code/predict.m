
% this function picks the features that would yield the maximum mariginal benefits 
% from 'feats', given the current model estimate, 'coefficients'. the return-value
% 'indices' are linear indices into the 'feats' feature vector that dictate which
% of the features are selected for each environment. 'scores' are the scores for 
% each single feature vector as judged by the model.  

function [indices, scores] = predict(feats, nr_envs, coefficients) 

  [scores] = reshape(abs(feats * coefficients - 1), [], nr_envs);  
  [~, indices] = min(scores, [], 1); 
  [indices] = sub2ind(size(scores), indices, 1: size(scores, 2)); 

end

