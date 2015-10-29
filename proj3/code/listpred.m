
load('data.mat'); nr_iter = 8;

% there would be one group of coefficients for each learner, i.e., for each iteration; 
% here we pre-allocate some space for those coefficents, including the additional intercept term. 

coeff_iter = zeros(nr_iter, size(feat_train, 2) + 1); 
for index = 1: nr_iter

% linear regression will still be used to make sure that our comparison is fair. 
% 1) append a column for the intercept to the features, 2) train the regressor, 
% 3) compute the score using l1-distance on the training data, and
% 4) extract the trajectory with the best score for each environment. 

  [feats_intcp] = horzcat(feat_train, ones(size(feat_train, 1), 1)); 
  [coeff_iter(index, :)] = mldivide(feats_intcp, result_train); 
  [scores] = reshape(abs(feats_intcp * coeff_iter(index, :)' - 1), [], numEnvironmentsTrain); 
  [~, indices] = min(scores, [], 1); 

% at this point 'indices' would be the indices of those trajectories that we would
% like to choose in this iteration. the next steps are: 5) look at the labels: 
% if true, we just set all the labels for that particular environment to zero, 
% since from that point on all the margin benefits would be zero; otherwise,
% we do not touch the labels.

  [labels] = result_train(sub2ind(size(scores), indices, 1: size(scores, 2)));
  [envs, trajs] = meshgrid(find(labels), 1: size(scores, 1)); 
  [result_train(sub2ind(size(scores), trajs, envs))] = deal(0); 

end

% the handout instructs us to have multiple functions for training, predicting, 
% updating that kind of stuff; however for this small procedure-oriented routine, 
% just putting everything together would actually make things easier. 

feats_intcp = horzcat(feat_test, ones(size(feat_test, 1), 1));
labels = zeros(nr_iter, numEnvironmentsTest); 
for index = 1: nr_iter

% making prediction is rather straightforward, we simply evaluate the test features on
% the coefficients we have obtained earlier, and compute the l1-distances as scores. 
% the indices that yield the minimum scores will be extracted, and their labels will be saved.  

  [scores] = reshape(abs(feats_intcp * coeff_iter(index, :)' - 1), [], numEnvironmentsTest); 
  [~, indices] = min(scores, [], 1); 
  [labels(index, :)] = result_test(sub2ind(size(scores), indices, 1: size(scores, 2)));

end 

% the last step is just to compute the values of the multiple guess function
% at each iterations by accumulating all the labels and cutting off at one. 
success_ratio = mean(cumsum(labels, 1) > 0, 2); 

figure; 
plot(success_ratio(1: nr_iter), '-s');
grid on; 
xlabel('k'); 
ylabel('Success Ratio (%)')
legend('List Prediction')

