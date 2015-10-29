
load('data.mat'); 

% it seems that there should only be one learner for all the environments. a linear
% regression would be nice since it is simple and it demonstrates the superiority 
% of list prediction with greedy strategy fairly easily. l1-distance to '1' is the score. 

[coefficients] = mldivide(horzcat(feat_train, ones(size(feat_train, 1), 1)), result_train);
[scores] = abs(horzcat(feat_test, ones(size(feat_test, 1), 1)) * coefficients - 1); 
[scores, indices] = sort(reshape(scores, [], numEnvironmentsTest)); 

% at this point the first k rows of 'indices' would be the indices that will be
% selected by the naive learner for each of the environment. we just need to 
% extract them, and compute the resultant accuracies using the test labels. 

[selections] = sub2ind(size(indices), indices, repmat(1: size(indices, 2), size(indices, 1), 1)); 
[success_ratio] = mean(cumsum(result_test(selections), 1) > 0, 2); 

% success_ratio is a column vector that contains the success ratios for each k ranging from 1 to 30.
% we then just need to plot the ratios out and we are done here. note that we could also plot
% the variance bar but that would take two additional clauses up there.  

figure; 
plot(success_ratio(1: 8), '-s');
grid on; 
xlabel('k'); 
ylabel('Success Ratio (%)')
legend('Naive Strategy')
 
