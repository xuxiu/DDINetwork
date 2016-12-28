function [ Sdata ] = Smooth(data, frequency)
%  Transform data into frequency (weekly) data
[N, M] = size(data);
Sdata  = zeros(size(data));
for i = 1 : floor(frequency/2)     
    Sdata(i, :) = data(i, :);
end
for i = floor(frequency/2) + 1 : N - floor(frequency/2)    
    Sdata(i, :) = mean(data(i - floor(frequency/2) : i  + floor(frequency/2), :)); 
end
for i = N - floor(frequency/2) + 1 : N   
    Sdata(i, :) = mean(data(i - frequency + 1: i, :));  % before and after hand to moving average
end
end