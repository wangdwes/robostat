
% this function implements online support vector machine. its input are the features
% in arbitrary order (ideally scrambled), and the corresponding labels. the code will
% be using the algorithms introduced in the handout and provide cumulative accuracy, 
% and labels for each iteration. it is additionally assumed that, the labels are either -1 or +1. 

function [accuracies, labels] = onlinesvm(features, true_labels) 

  weights = zeros(size(features, 2), 1); 
  labels = zeros(size(true_labels)); eta = 0.1; lambda = 0.1; 

  for index = 1: size(features, 1)

    % doing some initialization up there - values that are debatable are eta, lambda. 
    % and down here we are just iterating through all the features and see what would happen.
    % this is essentially just translating human languages to matlab languages. 
    labels(index) = sign(features(index, :) * weights); 

    cond = true_labels(index) * features(index, :) * weights < 1; 
    subgradient = weights * lambda / index - cond * true_labels(index) * features(index, :)'; 
    weights = weights - subgradient * eta / sqrt(index);

  end 

  % cumulative accuracies - we are expecting to see some improvements over each iteration. 
  % to get the accuracy over the entire online experience, just access the last element. 
  accuracies = cumsum(labels == true_labels) ./ cumsum(ones(size(labels))); 

end

