
% List Prediction with 'Multiple Guess' and 'Linear Regression', 

function [ratio, labels] = listpred(ftstrain, lbltrain, ftstest, lbltest, nr_trajs, nr_iters)

  nrenv_train = size(ftstrain, 1) / nr_trajs;
  nrenv_test = size(ftstest, 1) / nr_trajs;  
  ftstrain = horzcat(ftstrain, ones(size(ftstrain, 1), 1)); 
  ftstest = horzcat(ftstest, ones(size(ftstest, 1), 1)); 

  %% above we are just appending some intercept terms for the features.
  %% down here we are using a cell array to save all the coefficients because
  %% i copied everything from lpwftupdate and i am too lazy to change it. 

  coefficients = cell(nr_iters, 1); 
  for index = 1: nr_iters

    %% linear regression will still be used to make sure that our comparison is fair. 
    %% here we have a bunch of nice functions that sequentially: 
    %%   1) train the model on the training features and labels; 
    %%   2) predict (pick) the features that are considered the best for each environment; 
    %%   3) update the labels as the marginal benedits based on the selected features; 

    coefficients{index} = train(ftstrain, lbltrain); 
    indices = predict(ftstrain, nrenv_train, coefficients{index}); 
    lbltrain = lblupdate(lbltrain, lbltrain(indices, :));  

  end

  labels = zeros(nr_iters, nrenv_test); 
  for index = 1: nr_iters
  
    %% making prediction is rather straightforward. we simply 
    %% predict (pick) the features that are considered the best for each environment; 

    indices = predict(ftstest, nrenv_test, coefficients{index}); 
    labels(index, :) = lbltest(indices);

  end

  %% the last step is just to compute the values of the multiple guess function
  %% at each iterations by accumulating all the labels and cutting off at one. 
  ratio = mean(cumsum(labels, 1) > 0, 2);
  
end
