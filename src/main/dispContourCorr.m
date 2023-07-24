function []=dispContourCorr(ax1,maps,threshold,contourColor,dashedColor,transparency,lineWidth,linestyle)
if ~isempty(threshold)
if max(max(maps))>=threshold
    hold on
    ax2=axes;
    [~, hContour] = contourf(flipud(maps),[0 threshold],contourColor,'linewidth',lineWidth,'linestyle',linestyle,'Parent',ax1);
    drawnow;  % this is important, to ensure that FacePrims is ready in the next line!
    hFills = hContour.FacePrims;  % array of TriangleStrip objects
    [hFills.ColorType] = deal('truecoloralpha');  % default = 'truecolor'
    for i=1:3
        hFills(1).ColorData(i) = dashedColor(i);
    end
    hFills(1).ColorData(4) = transparency;
    if ~isempty(find(maps>=threshold))
        hFills(2).ColorData(4) = 0;
    end
end
end
end