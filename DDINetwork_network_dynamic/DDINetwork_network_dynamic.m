%% DNS factor estimation
clear all;  clc;
[data, d] = xlsread('Bank.xlsx', 'Bank_1', 'A4:K2091'); 
N         = size(data, 1);
yname     = ['  m06'; '  y01'; '  y02'; '  y03'; '  y04'; '  y05'; '  y07'; '  y10'; '  y20'; '  y30']; 
maturity  = [ 6    12    24    36    48    60    84   120   240   360];
yn        = size(yname, 1);  % Number of yields
rolling   = 260;
firmnum   = 10;
Level     = zeros(rolling, firmnum, N - rolling + 1);
Slope     = zeros(rolling, firmnum, N - rolling + 1);
Curva     = zeros(rolling, firmnum, N - rolling + 1);
for k = 1 : firmnum
    % read the data
    [data, dt] = xlsread('Bank.xlsx', ['Bank_' num2str(k)], 'A4:K2091'); 
    CDS        = log(data);
    for t = 1 : N - rolling + 1     
        yield  = CDS(t : t + rolling - 1, :);
        length = size(yield, 1);
        lamda  = 0.0609;       
        c1     = ones(yn, 1);
        c2     = zeros(yn, 1);
        c3     = zeros(yn, 1);
        for i = 1:yn
            c2(i) = (1 - exp(-lamda*maturity(i)))/(lamda*maturity(i));
            c3(i) = c2(i) - exp(-lamda*maturity(i));
        end;
        CC  = [c1 c2 c3];
        NS  = ((CC'*CC)\eye(size(CC,2)))*CC'*yield';
        dns = NS';        
        Level(:, k, t) = dns(:, 1);
        Slope(:, k, t) = dns(:, 2);
        Curva(:, k, t) = dns(:, 3);         
    end
end

%% VAR variance decomposition
rolling   = 260;
firmnum   = 10;
N         = 2088;
horizon   = 12;  
plott     = 0;
net_Level = zeros(firmnum + 2, firmnum + 1, N - rolling + 1 );
net_Slope = zeros(firmnum + 2, firmnum + 1, N - rolling + 1 );
net_Curva = zeros(firmnum + 2, firmnum + 1, N - rolling + 1 );
for t = 1 : N - rolling + 1 
    tic;
    [ net1 ] = VARdecompfactor(squeeze(Level(:, :, t)), plott, horizon); 
    net_Level(:, :, t) = net1;
    [ net2 ] = VARdecompfactor(squeeze(Slope(:, :, t)), plott, horizon);
    net_Slope(:, :, t) = net2;
    [ net3 ] = VARdecompfactor(squeeze(Curva(:, :, t)), plott, horizon);
    net_Curva(:, :, t) = net3;
    toc;
end
total_net_Level = squeeze(net_Level(firmnum + 1, firmnum + 1, :));
total_net_Slope = squeeze(net_Slope(firmnum + 1, firmnum + 1, :));
total_net_Curva = squeeze(net_Curva(firmnum + 1, firmnum + 1, :));
save('results_network_dynamic')

%% Plot
clear all; clc
load('results_network_dynamic.mat')
firmnum          = 10;
rolling          = 260;  
N                = 2088;
horizon          = 12;     
plott            = 1;
total_net        = [total_net_Level total_net_Slope  total_net_Curva];
total_net_smooth = Smooth(total_net, 7);   

tm = 1 : 1:  N; 
figure
subplot(3, 1, 1)
plot(tm(rolling:N), total_net_smooth(:, 1), 'b-', 'linewidth', 1.4);
Day = {'2008', '2009', '2010', '2011', '2012', '2013', '2014', '2015', '2016'};
set(gca, 'xtick', [1 263 524 785 1045 1306 1567 1828 2088]);
set(gca, 'xticklabel', Day);
xlim([1, N])
ylim([min(total_net(:, 1)) - 0.5, max(total_net(:, 1)) + 0.5])
h = title('Long-run factor: Level');
set(h, 'FontName', 'Times New Roman', 'FontSize', 14);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)

subplot(3, 1, 2)
plot(tm(rolling:N), total_net_smooth(:, 2), 'b-', 'linewidth', 1.4);
Day = {'2008', '2009', '2010', '2011', '2012', '2013', '2014', '2015', '2016'};
set(gca, 'xtick', [1 263 524 785 1045 1306 1567 1828 2088]);
set(gca, 'xticklabel', Day);
xlim([1, N])
ylim([min(total_net(:, 2)) - 0.5, max(total_net(:, 2)) + 0.5])
h1 = ylabel('Total Connectedness');
h = title('Short-run factor: Slope');
set([h, h1], 'FontName', 'Times New Roman', 'FontSize', 14)
set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)

subplot(3, 1, 3)
plot(tm(rolling:N), total_net_smooth(:, 3), 'b-', 'linewidth', 1.4);
Day = {'2008', '2009', '2010', '2011', '2012', '2013', '2014', '2015', '2016'};
set(gca, 'xtick', [1 263 524 785 1045 1306 1567 1828 2088]);
set(gca, 'xticklabel', Day);
xlim([1, N])
ylim([min(total_net(:, 3)) - 0.5, max(total_net(:, 3)) + 0.5])
h = title('Middle-run factor: Curvature');
h1 = xlabel('Time');
set([h1, h], 'FontName', 'Times New Roman', 'FontSize', 14)
set(gca, 'FontName', 'Times New Roman', 'FontSize', 14) 
saveas(gcf, 'total_net', 'png'); 

Bankname = [
'Bank of America';
'   Citygroup   ';
' Goldman Sachs ';
'  J.P.Morgan   ';
'  Wells Fargo  ';
' Deutsche Bank ';
'  Commerzbank  ';
' Barclays Bank ';
'   HSBC Bank   ';
'      UBS      '
];
LW1    = 0.8;
LW2    = 1.2;
tm     = 1 : 1: N; 
weight = 51;

% level
figure
for j = 1 : 3
    if j == 1
        for i = 1 : firmnum
            subplot(6, 5, (j - 1) * firmnum + i)
            net = squeeze(net_Level(firmnum + 1, i, :));
            net_smooth = Smooth(net, weight);   
            plot(tm(rolling:N), net_smooth, 'b-', 'linewidth', LW2);
            xlim([1, N])
            ylim([min(net) - 5, max(net) + 5])
            Day = {'08','10','12','14','16'};
            set(gca,'xtick',[1 524 1045 1567 2088]);
            set(gca,'xticklabel',Day);
            title(Bankname(i, :));
            if i == 1
                ylabel('To');
            end
        end
    end
    if j == 2
        for i = 1 : firmnum
            subplot(6, 5, (j - 1) * firmnum + i)
            net = squeeze(net_Level(i, firmnum + 1, :));
            net_smooth = Smooth(net, 13);   
            plot(tm(rolling:N), net_smooth, 'b-', 'linewidth', LW2);
            xlim([1, N])
            ylim([min(net) - 5, max(net) + 5])
            Day = {'08','10','12','14','16'};
            set(gca,'xtick',[1 524 1045 1567 2088]);
            set(gca,'xticklabel',Day); 
            title(Bankname(i, :));
            if i == 1
                ylabel('From');
            end 
        end
    end
    if j == 3
        for i = 1 : firmnum
            subplot(6, 5, (j - 1) * firmnum + i)
            net = squeeze(net_Level(firmnum + 2, i, :));
            net_smooth = Smooth(net, weight);  
            plot(tm(rolling:N), net_smooth, 'b-', 'linewidth', LW2);
            xlim([1, N])
            ylim([min(net) - 5, max(net) + 5])
            Day = {'08','10','12','14','16'};
            set(gca,'xtick',[1 524 1045 1567 2088]);
            set(gca,'xticklabel',Day);              
            title(Bankname(i, :));
            if i == 1
                ylabel('Net');
            end 
        end
    end
end   
saveas(gcf, 'net_dynamic_Level', 'png'); 

% slope
figure
for j = 1 : 3
    if j == 1
        for i = 1 : firmnum
            subplot(6, 5, (j - 1) * firmnum + i)
            net = squeeze(net_Slope(firmnum + 1, i, :));
            net_smooth = Smooth(net, weight);   
            plot(tm(rolling:N), net_smooth, 'b-', 'linewidth', LW2);
            xlim([1, N]) 
            ylim([min(net) - 5, max(net) + 5])
            Day = {'08','10','12','14','16'};
            set(gca,'xtick',[1 524 1045 1567 2088]);
            set(gca,'xticklabel',Day);
            title(Bankname(i, :));
            if i == 1
                ylabel('To');
            end
        end
    end
    if j == 2
        for i = 1 : firmnum
            subplot(6, 5, (j - 1) * firmnum + i)
            net = squeeze(net_Slope(i, firmnum + 1, :));
            net_smooth = Smooth(net, 13);  
            plot(tm(rolling:N), net_smooth, 'b-', 'linewidth', LW2);
            xlim([1, N])
            ylim([min(net) - 5, max(net) + 5])
            Day = {'08','10','12','14','16'};
            set(gca,'xtick',[1 524 1045 1567 2088]);
            set(gca,'xticklabel',Day); 
            title(Bankname(i, :));
            if i == 1
                ylabel('From');
            end 
        end
    end
    if j == 3
        for i = 1 : firmnum
            subplot(6, 5, (j - 1) * firmnum + i)
            net = squeeze(net_Slope(firmnum + 2, i, :));
            net_smooth = Smooth(net, weight);  
            plot(tm(rolling:N), net_smooth, 'b-', 'linewidth', LW2);
            xlim([1, N])
            ylim([min(net) - 5, max(net) + 5])
            Day = {'08','10','12','14','16'};
            set(gca,'xtick',[1 524 1045 1567 2088]);
            set(gca,'xticklabel',Day);              
            title(Bankname(i, :));
            if i == 1
                ylabel('Net');
            end 
        end
    end
end   
saveas(gcf, 'net_dynamic_Slope', 'png');

% curvature
figure
for j = 1 : 3
    if j == 1
        for i = 1 : firmnum
            subplot(6, 5, (j - 1) * firmnum + i)
            net = squeeze(net_Curva(firmnum + 1, i, :));
            net_smooth = Smooth(net, weight);  
            plot(tm(rolling:N), net_smooth, 'b-', 'linewidth', LW2);
            xlim([1, N])
            ylim([min(net) - 5, max(net) + 5])
            Day = {'08','10','12','14','16'};
            set(gca,'xtick',[1 524 1045 1567 2088]);
            set(gca,'xticklabel',Day);
            title(Bankname(i, :));
            if i == 1
                ylabel('To');
            end
        end
    end
    if j == 2
        for i = 1 : firmnum
            subplot(6, 5, (j - 1) * firmnum + i)
            net = squeeze(net_Curva(i, firmnum + 1, :));
            net_smooth = Smooth(net, 13);   
            plot(tm(rolling:N), net_smooth, 'b-', 'linewidth', LW2);
            xlim([1, N])
            ylim([min(net) - 5, max(net) + 5])
            Day = {'08','10','12','14','16'};
            set(gca,'xtick',[1 524 1045 1567 2088]);
            set(gca,'xticklabel',Day); 
            title(Bankname(i, :));
            if i == 1
                ylabel('From');
            end 
        end
    end
    if j == 3
        for i = 1 : firmnum
            subplot(6, 5, (j - 1) * firmnum + i)
            net = squeeze(net_Curva(firmnum + 2, i, :));
            net_smooth = Smooth(net, weight);  
            plot(tm(rolling:N), net_smooth, 'b-', 'linewidth', LW2);
            xlim([1, N])
            ylim([-100, 370]) 
            Day = {'08','10','12','14','16'};
            set(gca,'xtick',[1 524 1045 1567 2088]);
            set(gca,'xticklabel',Day);              
            ylim([min(net) - 5, max(net) + 5])
            title(Bankname(i, :));
            if i == 1
                ylabel('Net');
            end 
        end
    end
end   
saveas(gcf, 'net_dynamic_Curva', 'png'); 

