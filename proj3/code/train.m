
% this function simply uses the legendary backslash operator
% to compute the optimal coefficients in the least-squares sense.  

function coefficients = train(feats, labels) 
  coefficients = mldivide(feats, labels); 
end


