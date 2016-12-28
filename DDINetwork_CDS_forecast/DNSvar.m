function [yhat, beta] = DNSvar(xval, k, h)
    % forecast with others
    [n, m] = size(xval);
    y      = xval(1 + h : n, k);
    x      = [ones(n - h, 1) xval(1 : n - h, 1 : end)];  % different 
    fai    = (inv(x'*x))*(x'*y);
    eps2   = ((y - x*fai)'*(y - x*fai)/(n - m - h));
    delta  = sqrt(eps2);
    yhat   = [1 xval(n - h + 1, 1 : end)]*fai;    
    beta   = [fai; delta]; 
end

