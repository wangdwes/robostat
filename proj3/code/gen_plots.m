
load('data.mat'); 

% just invoke our subroutines are get the results. 
% we can optionally take the labels and compute the little same variance bars. 

nr_iters = 8; 
ratio_naive = naive(feat_train, result_train, feat_test, result_test, numTrajPerEnv); 
ratio_listpred = listpred(feat_train, result_train, feat_test, result_test, numTrajPerEnv, nr_iters); 
ratio_lpwftupdate = lpwftupdate(feat_train, result_train, feat_test, result_test, numTrajPerEnv, nr_iters); 

% and - we just plot everything! 

plot([ratio_naive(1: nr_iters) ratio_listpred ratio_lpwftupdate], '-s'); 
grid on; 
xlabel('k');
ylabel('Success Ratio');
title('Performance Comparison of List Prediction Algorithms'); 
legend('Naive', 'List Prediction', 'List Prediction with Feature Update', 'Location', 'Best'); 

