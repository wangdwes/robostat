
% List Prediction with 'Multiple Guess' and 'Linear Regression', 
% augmented with feature update.  

function [ratio_train, ratio_test] = lpwftupdate(ftstrain, lbltrain, ftstest, lbltest, nr_trajs, nr_iters)

  nrenv_train = size(ftstrain, 1) / nr_trajs;
  nrenv_test = size(ftstest, 1) / nr_trajs;  
  ftstrain = horzcat(ftstrain, ones(size(ftstrain, 1), 1)); 
  ftstest = horzcat(ftstest, ones(size(ftstest, 1), 1)); 

  %% above we are just appending some intercept terms for the features.
  %% down here we are using a cell array to save all the coefficients because
  %% they are potentially changing each iteration since the features are being updated.  

  coefficients = cell(nr_iters, 1); 
  labelspred_test = zeros(nr_iters, nrenv_test); 
  labelspred_train = zeros(nr_iters, nrenv_train); 

  for index = 1: nr_iters

    %% linear regression will still be used to make sure that our comparison is fair. 
    %% here we have a bunch of nice functions that sequentially: 
    %%   1) train the model on the training features and labels; 
    %%   2) predict (pick) the features that are considered the best for each environment; 
    %%   3) update the labels as the marginal benedits based on the selected features; 
    %%   4) update the features by appending to them some similarity metrics. 

    coefficients{index} = train(ftstrain, lbltrain); 
    indices = predict(ftstrain, nrenv_train, coefficients{index}); 
    labelspred_train(index, :) = lbltrain(indices); 
    lbltrain = lblupdate(lbltrain, lbltrain(indices, :));  
    ftstrain = ftupdate(ftstrain, ftstrain(indices, :)); 

  end

  for index = 1: nr_iters
  
    %% making prediction is rather straightforward. we simply 
    %%   1) predict (pick) the features that are considered the best for each environment; 
    %%   2) update the features by appending to them some similarity metrics. 

    indices = predict(ftstest, nrenv_test, coefficients{index}); 
    ftstest = ftupdate(ftstest, ftstest(indices, :));
    labelspred_test(index, :) = lbltest(indices);

  end

  %% the last step is just to compute the values of the multiple guess function
  %% at each iterations by accumulating all the labels and cutting off at one. 
  ratio_test = mean(cumsum(labelspred_test, 1) > 0, 2); 
  ratio_train = mean(cumsum(labelspred_train, 1) > 0, 2);
  
end
