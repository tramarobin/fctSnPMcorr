%% INPUTS
% Obligatory
% Map of F-values
% Threshold of significativity

%% OUTPUT
% Figure of the anova results

function []=displayRtest(mapT,Tthreshold,anovaEffects,Fs,xlab,ylab,ylimits,dimensions,nx,ny,xlimits,imageFontSize,imageSize,colorMap)

if isempty(imageSize)
    figure('Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1],'visible','off');
elseif max(size(imageSize))==1
    figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize, imageSize],'visible','off');
else
    figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize(1), imageSize(2)],'visible','off');
end

if dimensions(1)==1 | dimensions(2)==1 %1D
    time=0:1/Fs:(max(size(mapT))-1)/Fs;
    plot(time,mapT,':k','linewidth',1); hold on
    clusters=find(abs(diff(anovaEffects'))==1);
    clusters=[0,clusters,max(size(mapT))];
    for t=1:size(clusters,2)-1
        timeCluster=time(clusters(t)+1:clusters(t+1));
        mapCluster=mapT(clusters(t)+1:clusters(t+1));
        goPlot=mean(anovaEffects(clusters(t)+1:clusters(t+1)));
        if goPlot==1
            plot(timeCluster,mapCluster,'b','linewidth',2)
            vline([timeCluster(1),timeCluster(end)])
        end
    end
    
    hline(0)
    xlabel(xlab)
    ylabel('r')
    if ~isempty(xlimits)
        xlabels=linspace(xlimits(1),xlimits(end),nx);
    else
        xlabels=linspace(0,(max(size(mapT)))/Fs,nx);
    end
    xticks(linspace(0,(max(size(mapT))-1)/Fs,nx))
    for i=1:nx
        if xlabels(i)<0 && xlabels(i)>-1e-16
            xlabs{i}='0';
        elseif abs(xlabels(i))==0 | abs(xlabels(i))>=1 & abs(xlabels(i))<100
            xlabs{i}=sprintf('%0.2g',xlabels(i));
        elseif abs(xlabels(i))>=100
            xlabs{i}=sprintf('%d',round(xlabels(i)));
        else
            xlabs{i}=sprintf('%0.2f',xlabels(i));
        end
    end
    xticklabels(xlabs)
    box off
    
    if max(anovaEffects)==0
        legend('t-value','Location','eastoutside','Box','off');
    else
        legend({'t-value','Real effect (blue)'},'Location','eastoutside','Box','off');
    end
    ylim([-1 1])
    
else % 2D
    
    if isempty(ylimits)
        ylimits=[0 size(mapT,1)];
    end
    
    imagesc(flipud(mapT))
    ylabel(ylab)
    xlabel(xlab);
    colormap(colorMap)
    Co=colorbar('EastOutside');
    Co.Label.String=('r');
    Co.FontSize=imageFontSize;
    
    
    if ~isempty(ylimits)
        ylabels=linspace(ylimits(end),ylimits(1),ny);
    else
        ylabels=linspace((size(mapT,1))/Fs,0,nx);
    end
    yticks(linspace(1,size(mapT,1),ny))
    for i=1:ny
        if abs(ylabels(i))==0 | abs(ylabels(i))>=1 & abs(ylabels(i))<100
            ylabs{i}=sprintf('%0.2g',ylabels(i));
        elseif abs(ylabels(i))>=100
            ylabs{i}=sprintf('%d',round(ylabels(i)));
        else
            ylabs{i}=sprintf('%0.2f',ylabels(i));
        end
    end
    yticklabels(ylabs)
    
    
    if ~isempty(xlimits)
        xlabels=linspace(xlimits(1),xlimits(end),nx);
    else
        xlabels=linspace(0,(size(mapT,2))/Fs,nx);
    end
    xticks(linspace(1,size(mapT,2),nx))
    for i=1:nx
        if xlabels(i)<0 && xlabels(i)>-1e-16
            xlabs{i}='0';
        elseif abs(xlabels(i))==0 | abs(xlabels(i))>=1 & abs(xlabels(i))<100
            xlabs{i}=sprintf('%0.2g',xlabels(i));
        elseif abs(xlabels(i))>=100
            xlabs{i}=sprintf('%d',round(xlabels(i)));
        else
            xlabs{i}=sprintf('%0.2f',xlabels(i));
        end
    end
    xticklabels(xlabs)
    box off
    
    caxis([-Tthreshold Tthreshold]);
    
end

set(gca,'FontSize',imageFontSize)

end

