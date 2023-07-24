%% INPUTS

%% OUTPUT

function []=displayCorrFilm(maps_1D,Var_s,dimensions,Fs,xlab,ylab,ylimits,nx,ny,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMap,mapsT,Tthreshold,contourColor,dashedColor,transparency,lineWidth,linestyle,savedir,effectNames,range,rangeVarCorr,FrameRate,units,imageResolution,colorLine)


minVal=Var_s(1);
maxVal=Var_s(end);

if ~isempty(range)
    if isempty(rangeVarCorr)

        ranged=minVal:range:maxVal;
        if max(ranged)<maxVal
            ranged(end+1)=ranged(end)+range;
        end

    else

        ranged=rangeVarCorr(1):range:rangeVarCorr(end);

    end

    ranged=unique([ceil(ranged/range)*range floor(ranged/range)*range]);

    if max(ranged(end-1))>maxVal
        ranged(end)=[];
    end

    for k=1:(numel(ranged)-1)
        regroup=find([Var_s>=ranged(k) & Var_s<ranged(k+1)]);
        plot1D{k}=maps_1D(regroup,:);
        if numel(regroup)==1
            mapR(k,:)=maps_1D(regroup,:);
        else
            mapR(k,:)=mean(maps_1D(regroup,:));
        end
    end

    ok=find(~isnan(mapR(:,1)));
    mapR=mapR(ok,:);
    ranged=ranged([ok ok+1]);


end

if isempty(ylimits)
    ylimits=[0 dimensions(1)];
end


if min(dimensions)==1 & ~isempty(range)%1D

    plotmeanCont(plot1D,[],xlab,ylab,Fs,xlimits,nx,colorLine,imageFontSize,imageSize,effectNames,units,ranged)
    title(['Means in function of ' effectNames])
    print('-dtiff',imageResolution,[savedir '\Means in function of ' effectNames '.tiff'])
    close

elseif min(dimensions)>1


    vidfile = VideoWriter([savedir '\Video ' effectNames '.mp4'],'MPEG-4');
    vidfile.FrameRate = FrameRate;
    open(vidfile);

    if isempty(imageSize)
        figure('Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1],'visible','off');
    elseif max(size(imageSize))==1
        figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize, imageSize],'visible','off');
    else
        figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize(1), imageSize(2)],'visible','off');
    end

    if ~isempty(range)
        mkdir([savedir '\Images'])
        for k=1:size(mapR,1)

            imagesc(flipud(reshape(mapR(k,:),dimensions(1),dimensions(2))))

            ylabel(ylab)
            xlabel(xlab)
            colormap(colorMap)
            Co=colorbar('EastOutside');
            Co.Label.String=colorbarLabel;
            Co.FontSize=imageFontSize;

            if ~isempty(limitMeanMaps)
                if numel(limitMeanMaps)==1
                    caxis([0 limitMeanMaps]);
                else
                    caxis([limitMeanMaps]);
                end
            else
                caxis([min(min(mapR)) max(mean(mapR))]);
            end
            ylabels=linspace(ylimits(end),ylimits(1),ny);
            yticks(linspace(1,dimensions(1),ny))

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
                xlabels=linspace(0,dimensions(2)/Fs,nx);
            end
            xticks(linspace(1,dimensions(2),nx))
            for i=1:nx
                if abs(xlabels(i))==0 | abs(xlabels(i))>=1 & abs(xlabels(i))<100
                    xlabs{i}=sprintf('%0.2g',xlabels(i));
                elseif abs(xlabels(i))>=100
                    xlabs{i}=sprintf('%d',round(xlabels(i)));
                else
                    xlabs{i}=sprintf('%0.2f',xlabels(i));
                end
            end
            xticklabels(xlabs)
            box off
            set(gca,'FontSize',imageFontSize)

            dispContour(abs(mapsT),Tthreshold,contourColor,dashedColor,transparency,lineWidth,linestyle)

            title([effectNames ' = [' num2str(ranged(k,1)) ' - ' num2str(ranged(k,2)) '[ ' units])
            print('-dtiff',imageResolution,[savedir '\Images\[' num2str(ranged(k,1)) ' - ' num2str(ranged(k,2)) '[ ' units '.tiff'])

            F{k}=getframe(gcf);
        end

    else

        for k=1:size(maps_1D,1)

            imagesc(flipud(reshape(maps_1D(k,:),dimensions(1),dimensions(2))))

            ylabel(ylab)
            xlabel(xlab)
            colormap(colorMap)
            Co=colorbar('EastOutside');
            Co.Label.String=colorbarLabel;
            Co.FontSize=imageFontSize;

            if ~isempty(limitMeanMaps)
                if numel(limitMeanMaps)==1
                    caxis([0 limitMeanMaps]);
                else
                    caxis([limitMeanMaps]);
                end
            else
                caxis([min(min(maps_1D)) max(mean(maps_1D))]);
            end
            ylabels=linspace(ylimits(end),ylimits(1),ny);
            yticks(linspace(1,dimensions(1),ny))
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
                xlabels=linspace(0,dimensions(2)/Fs,nx);
            end
            xticks(linspace(1,dimensions(2),nx))
            for i=1:nx
                if abs(xlabels(i))==0 | abs(xlabels(i))>=1 & abs(xlabels(i))<100
                    xlabs{i}=sprintf('%0.2g',xlabels(i));
                elseif abs(xlabels(i))>=100
                    xlabs{i}=sprintf('%d',round(xlabels(i)));
                else
                    xlabs{i}=sprintf('%0.2f',xlabels(i));
                end
            end
            xticklabels(xlabs)
            box off
            set(gca,'FontSize',imageFontSize)

            dispContour(abs(mapsT),Tthreshold,contourColor,dashedColor,transparency,lineWidth,linestyle)

            title([effectNames ' = ' num2str(Var_s(k)) ' ' units])
            F{k}=getframe(gcf);

        end
    end
    close

    for k=1:numel(F)
        writeVideo(vidfile,F{k});
    end
    close(vidfile)


end
