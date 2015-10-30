
load(fullfile('data', 'data.mat')); 

% just invoke our subroutines are get the results. 
% we can optionally take the labels and compute the little same variance bars. 

nr_iters = 8; 

[rtrain1, rtest1] = naive(feat_train, result_train, feat_test, result_test, numTrajPerEnv); 
[rtrain2, rtest2] = listpred(feat_train, result_train, feat_test, result_test, numTrajPerEnv, nr_iters); 
[rtrain3, rtest3] = lpwftupdate(feat_train, result_train, feat_test, result_test, numTrajPerEnv, nr_iters); 

figure; 
plot([rtrain1(1: nr_iters) rtrain2 rtrain3], '-s'); 
grid on; 
xlabel('k');
ylabel('Success Ratio');
title('Training Performance of List Prediction Algorithms'); 
legend('Naive', 'List Prediction', 'List Prediction with Feature Update', 'Location', 'Best'); 

figure; 
plot([rtest1(1: nr_iters) rtest2 rtest3], '-s'); 
grid on; 
xlabel('k');
ylabel('Success Ratio');
title('Testing Performance of List Prediction Algorithms'); 
legend('Naive', 'List Prediction', 'List Prediction with Feature Update', 'Location', 'Best'); 
