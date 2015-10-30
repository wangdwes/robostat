
% we could use functions we have written for the list prediction stuff. 
% but again i am way too lazy to do this.  

function [ratio_train, ratio_test] = naive(ftstrain, lbltrain, ftstest, lbltest, nr_trajs)

  %% it seems that there should only be one learner for all the environments. a linear
  %% regression would be nice since it is simple and it demonstrates the superiority 
  %% of list prediction with greedy strategy fairly easily. l1-distance to '1' is the score. 

  coefficients = mldivide(horzcat(ftstrain, ones(size(ftstrain, 1), 1)), lbltrain);
  ratio_train = predict(ftstrain, lbltrain, coefficients); 
  ratio_test = predict(ftstest, lbltest, coefficients); 

  function [ratio, labels] = predict(features, true_labels, coefficients)

    [scores] = abs(horzcat(features, ones(size(features, 1), 1)) * coefficients - 1); 
    [scores, indices] = sort(reshape(scores, [], size(features, 1) / nr_trajs));

    %% at this point the first k rows of 'indices' would be the indices that will be
    %% selected by the naive learner for each of the environment. we just need to 
    %% extract them, and compute the resultant accuracies using the test labels. 

    [selections] = sub2ind(size(indices), indices, repmat(1: size(indices, 2), size(indices, 1), 1)); 
    [labels, ratio] = deal(true_labels(selections), mean(cumsum(true_labels(selections), 1) > 0, 2)); 

  end

end
