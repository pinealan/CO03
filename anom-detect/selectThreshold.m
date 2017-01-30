function [bestEpsilon, bestF1] = selectThreshold(yval, pval)
%SELECTTHRESHOLD Find the best threshold (epsilon) to use for selecting
%outliers
%   [bestEpsilon bestF1] = SELECTTHRESHOLD(yval, pval) finds the best
%   threshold to use for selecting outliers based on the results from a
%   validation set (pval) and the ground truth (yval).
%

bestEpsilon = 0;
bestF1 = 0;

stepsize = (max(pval) - min(pval)) / 1000;
for epsilon = min(pval):stepsize:max(pval)

    h = pval < epsilon;
    tp = sum(h(yval == 1, :));
    fn = sum(yval) - tp;
    fp = sum(h) - tp;
    prec = tp / (tp+fp);
    rec = tp / (tp+fn);
    F1 = 2*prec*rec / (prec+rec);

    if F1 > bestF1
       bestF1 = F1;
       bestEpsilon = epsilon;
    end
end

end
