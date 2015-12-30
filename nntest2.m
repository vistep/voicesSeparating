function [er, bad] = nntest2(nn, x, y)
    labels = nnpredict(nn, x);
    [dummy, expected] = max(y,[],2);
    bad = find(abs(labels - expected)>1);    
    er = numel(bad) / size(x, 1);
end

