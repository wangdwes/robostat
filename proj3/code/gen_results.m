
% read all the data entries with the space as the delimiter. 
% note that the first three rows of the data file are skipped 
% because they are just comments and contain no useful information. 
% also we want to compute the chance accuracy for baseline. 

[dataset] = dlmread(fullfile('data', 'oakland_part3_am_rf.node_features'), ' ', 3, 0); 
[labels, ~, indices] = unique(dataset(:, 5)); cols = [6: 15]; 
[counts] = accumarray(indices, 1);
[errmat, cherrmat] = deal(zeros(numel(labels))); 

% this script will be invoking our online support vector machine, with two nested loops. 
% i believe this is the first time ever that i am using two nested loops in matlab. 

for i = 1: numel(labels)
  for j = 1: numel(labels)
  
    %% do not bother to handle the case where the labels are the same. 
    if i == j, continue; end; 

    %% construct the features and the labels. 
    %% the math only seems to work if the labels are -1 and +1 so we ensure that. 
    binary_labels = (indices == i) - (indices == j);
    features = dataset(binary_labels ~= 0, cols);
    binary_labels = binary_labels(binary_labels ~= 0); 
    permidx = randperm(numel(binary_labels)); 

    %% and invoke the online support vector machine. 
    %% save the final accuracies and chance accuracies. 
    [accuracies, lblspred] = onlinesvm(features(permidx, :), binary_labels(permidx)); 
    [errmat(i, j), cherrmat(i, j)] = deal(1 - accuracies(end), ... 
      min(sum(indices == i), sum(indices == j)) / numel(binary_labels));

    %% figure; 
    %% coords = dataset(any([indices == i, indices == j], 2), 1: 3); 
    %% fscatter3(coords(permidx, 1), coords(permidx, 2), coords(permidx, 3), lblspred, jet);
    %% grid on;
    %% view([-70 26]); 

  end
end

disp(' '); % print an empty line.  
disp('Labels (rows and columns): Veg, Wire, Pole, Ground, Facade.'); 
disp('Binary mis-classification errors:'); disp(errmat);
disp('Chance errors (baseline):'); disp(cherrmat)

