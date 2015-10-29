
% this function updates the features by appending to each of the original features  
% some similarity metrics. it is assumed that the input argument 'feats' consists
% of a constant number of trajectories for each environment vertically concatencated, 
% and that 'against' consists of one feature vector for each environment that is 
% selected. for each environment, the distances between some group of features in 
% 'feats' and the corresponding feature in 'against' will be computed and used as similarity. 

function feats = ftupdate(feats, against) 

  % since we only need to compute the distances within each individual environment, 
  % invoking pdist2 on everything seems unnecessary. therefore, we convert everything
  % into cell arrays and go from there. i also tried using loops, which turned out
  % to be marginally slower than the approach implemented below.  

  nr_trajs = size(feats, 1) / size(against, 1); 
  against = mat2cell(against, ones(size(against, 1), 1), size(feats, 2)); 
  featscell = mat2cell(feats, ones(size(against, 1), 1) * nr_trajs, size(feats, 2));  

  % at this point we are ready to use the fabolous cellfun to invoke pdist2, 
  % compute the distances, and update the correpsonding entries in 'feats'. 

  dists = cellfun(@pdist2, featscell, against, 'UniformOutput', false);
  feats = horzcat(feats, cell2mat(dists)); 

end
