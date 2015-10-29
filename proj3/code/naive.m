
% we could use functions we have written for the list prediction stuff. 
% but again i am way to lazy to do this.  

function [ratio, labels] = naive(ftstrain, lbltrain, ftstest, lbltest, nr_trajs)

  %% it seems that there should only be one learner for all the environments. a linear
  %% regression would be nice since it is simple and it demonstrates the superiority 
  %% of list prediction with greedy strategy fairly easily. l1-distance to '1' is the score. 

  [coefficients] = mldivide(horzcat(ftstrain, ones(size(ftstrain, 1), 1)), lbltrain);
  [scores] = abs(horzcat(ftstest, ones(size(ftstest, 1), 1)) * coefficients - 1); 
  [scores, indices] = sort(reshape(scores, [], size(ftstest, 1) / nr_trajs)); 

  %% at this point the first k rows of 'indices' would be the indices that will be
  %% selected by the naive learner for each of the environment. we just need to 
  %% extract them, and compute the resultant accuracies using the test labels. 

  [selections] = sub2ind(size(indices), indices, repmat(1: size(indices, 2), size(indices, 1), 1)); 
  [labels, ratio] = deal(lbltest(selections), mean(cumsum(lbltest(selections), 1) > 0, 2)); 

end
