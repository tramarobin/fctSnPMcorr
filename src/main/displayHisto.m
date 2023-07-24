%% INPUTS

%% OUTPUT

function []=displayHisto(Var_s,imageFontSize,imageSize,savedir,effectNames,range,rangeVarCorr,units,imageResolution)

Var_s=sort(Var_s);
Var_s(isnan(Var_s))=[];
minVal=Var_s(1);
maxVal=Var_s(end);

if isempty(imageSize)
    figure('Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1],'visible','off');
elseif max(size(imageSize))==1
    figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize, imageSize],'visible','off');
else
    figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize(1), imageSize(2)],'visible','off');
end

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

    histogram(Var_s,[ranged],'FaceColor',[0.5 0.5 0.5])

else
    histogram(Var_s,'FaceColor',[0.5 0.5 0.5])
end
xlabel([effectNames ' (' units ')'])
ylabel('Number of participants')
title(['Distibution of ' effectNames])
box off
set(gca,'FontSize',imageFontSize)
print('-dtiff',imageResolution,[savedir '\Distibution of ' effectNames '.tiff'])
close

end
