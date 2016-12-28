function [yhat, beta] = DNSar(xval, k, h)
    % forecast without others
    [n, m] = size(xval);  
    y      = xval(1 + h : n, k);
    x      = [ones(n - h, 1) xval(1 : n - h, k)];
    fai    = (inv(x'*x))*(x'*y);
    eps2   = ((y - x*fai)'*(y - x*fai)/(n - 1 - h));
    delta  = sqrt(eps2);
    yhat   = [1 xval(n - h + 1, k)]*fai;    
    beta   = [fai; delta]; 
end

