function output = ACC(vector, lags)
[N, M] = size(vector); 
for i = 1 : M
    mu_vec       = mean(vector(:, i))*ones(N - lags, 1); 
    output(1, i) = (1/(N - 1))*(vector(1 : N - lags, i) - mu_vec)'*...
                   (vector(1 + lags : N, i) - mu_vec)/var(vector(:, i)); 
end