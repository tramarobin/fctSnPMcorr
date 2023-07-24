function [maps_1D,dimensions]=vectorMap(mapsAll)
maps_1D=[];
for x=1:size(mapsAll,1)
    for y=1:size(mapsAll,2)
        maps_1D(end+1,:)= mapsAll{x,y}(:);
    end
end

dimensions=size(mapsAll{1,1});

end