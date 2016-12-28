function [] = CDSPlot(Res, bname)
    mesh(Res);
    set(gca, 'XTick', [266, 788, 1309, 1831])
    set(gca, 'XTicklabel', ['2009'; '2011'; '2013'; '2015'])
    x1 = xlabel('Year');
    hold on;
    set(gca, 'YTick', [1, 6, 10])
    set(gca, 'YTicklabel', [' 6M'; ' 5Y'; '30Y'])
    x2 = ylabel('Maturity');
    zlabel('Value')
    hold on;
    set(x1, 'Rotation', 20);    
    set(x2, 'Rotation', -20);    
    ylim([0, size(Res, 1)]);
    xlim([1, size(Res, 2)])
    title(char(bname))
    set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
end

