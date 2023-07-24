function [maps_1D,var_1D,dimensions,sujets,nCat,indicesCat]=findModalitiesRFX(mapsAll,varCorr,Categories)

maps_1D=[];
var_1D=[];
sujets=[];
E_Cat=cell(1,size(Categories,2));
dimensions=size(mapsAll{1}{1});

for s=1:size(mapsAll,1)
    for cond=1:size(mapsAll,2)
        if ~isempty(mapsAll{s,cond})
            for trial=1:numel(mapsAll{s,cond})
                
                
                % Vectorisation of maps
                maps_1D(end+1,:)= mapsAll{s,cond}{trial}(:);
                var_1D(end+1,1)=varCorr{s,cond}{trial}(:);
                sujets(end+1,1)=s;
                
                % Modalities of each effect
                for nCat=1:size(Categories,2)
                    modalitiesCat{nCat}=unique(Categories{nCat},'stable');
                    E_Cat{nCat}{end+1,1}=Categories{nCat}{cond};
                end
                
                
            end
        end
    end
end


% numerisation of Cat for SPM
indicesCat=zeros(size(sujets,1),nCat);

for nCat=1:size(modalitiesCat,2)
    for modal=1:size(modalitiesCat{nCat},2)
        indice=strcmp(E_Cat{nCat},modalitiesCat{nCat}{modal});
        indicesCat(indice,nCat)=modal;
    end
end



end

