%% Trama Robin (LIBM) 07/05/2019

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% INPUTS
% OBLIGATORY
% Maps : in cells, what we want to correlate
% Varcorr : variable to correlate with

% OPTIONAL (see at begining of the function)


%% OUTPUTS
% Figures and files.mat for correlations
% Contour plots correspond to statisticaly significant correlation

%% Informations
% See spm1d.org for the spm1d package informations used with this functions.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fctCORR(maps_1D,dimensions,varCorr,varargin)

%% Optional inputs
p = inputParser;

% Regression analysis
addParameter(p,'corrAll',1,@isnumeric); % 0 to perform only RFX

% RFX analysis
addParameter(p,'sub',[],@isnumeric); % subjects for random effect
addParameter(p,'plotSub',0,@isnumeric); % plot each subject of the RFX analysis
addParameter(p,'corrRFX',1,@isnumeric); % 0 to perform only linear regression

% utilities
addParameter(p,'savedir','RESULTS',@ischar); % save directory
addParameter(p,'effectsNames','x',@ischar); % name of the different effect tested (changes the name of folder and files)

% statistical parameters
addParameter(p,'alpha',0.05,@isnumeric); % alpha used for the ANOVA
addParameter(p,'Permutations',20,@isnumeric); % number of permutations is multiPermutations/alpha.
addParameter(p,'maximalIT',10000,@isnumeric); % limits the number of maximal permutations in case of two many multiple comparisons.
% specified either alphaT or nT, but not both
addParameter(p,'rangeVarCorr',[],@isnumeric); % limit the range of varCorr
addParameter(p,'range',[],@isnumeric) % range to regroup maps for video

% general plot parameters
addParameter(p,'ylabel','',@ischar); % name of the y label
addParameter(p,'xlabel','',@ischar); % name of the xlabel
addParameter(p,'samplefrequency',1,@isnumeric); % change xticks to correspond at the specified frequency
addParameter(p,'xlimits',[],@isnumeric); % change xticks to correspond to the specified range
% specified either samplefrequency or xlimits, but not both
addParameter(p,'nTicksX',5,@isnumeric); % number of xticks displayed
addParameter(p,'nTicksY',4,@isnumeric); % number of yticks displayed
addParameter(p,'imageresolution',100,@isnumeric); % resolution in ppp of the tiff images
addParameter(p,'imageSize',[],@isnumeric) % size of the image in cm. X --> X*X images, [X Y] X*Y imgages. By default the unit is normalized [0 0 1 1].
addParameter(p,'imageFontSize',12,@isnumeric) % font size of images
addParameter(p,'units',[],@ischar) % unit of the x parameter

% 2d plot parameters
addParameter(p,'colorMap',cbrewer('seq','Reds', 64)) % colormap used for means and ANOVA and ES plots (0 to positive)
addParameter(p,'colorMapDiff',flipud(cbrewer('div','RdBu', 64))) % colormap used for differences and SnPM plot (0 centered)
addParameter(p,'colorbarLabel','',@ischar); % name of the colorbar label
addParameter(p,'ylimits',[],@isnumeric); % change yticks to correspond to the specified range
addParameter(p,'limitMeanMaps',[],@isnumeric); % limit of the colorbar. the value of X will make the colorbar goind to -X to X for all plots. If not specified, the maps wont necessery be with the same colorbar
addParameter(p,'displaycontour',1,@isnumeric); % display contour map on differences and size effect maps (logical(0) to not display)
addParameter(p,'contourcolor','w'); % color of the contour for the differences maps
addParameter(p,'linestyle','-') % linewidth of the contour plot
addParameter(p,'dashedColor',[0 0 0],@isnumeric) % color of the dashed zone of the contour plot
addParameter(p,'transparency',50,@isnumeric) % transparancy of the dashed zone (0=transparant, 255=opaque)
addParameter(p,'lineWidth',2.5,@isnumeric) % linewidth of the contour plot
addParameter(p,'FrameRate',4,@isnumeric) % range to regroup maps for video

% 1d plot parameters
addParameter(p,'CI',[],@isnumeric); % confidence interval is used instead of standard deviation (0.7-->0.999)
addParameter(p,'colorLine',[]); % colorline for plots (default  is "lines")

parse(p,varargin{:});

sub=p.Results.sub;
plotSub=p.Results.plotSub;
corrRFX=p.Results.corrRFX;
corrAll=p.Results.corrAll;
alpha=p.Results.alpha;
contourColor=p.Results.contourcolor;
ylab=p.Results.ylabel;
xlab=p.Results.xlabel;
Fs=p.Results.samplefrequency;
savedir=p.Results.savedir;
effectNames=p.Results.effectsNames;
Permutations=p.Results.Permutations;
ylimits=p.Results.ylimits;
xlimits=p.Results.xlimits;
nTicksX=p.Results.nTicksX;
nTicksY=p.Results.nTicksY;
displayContour=p.Results.displaycontour;
imageResolution=['-r' num2str(p.Results.imageresolution)];
colorbarLabel=p.Results.colorbarLabel;
limitMeanMaps=p.Results.limitMeanMaps;
CI=p.Results.CI;
maximalIT=p.Results.maximalIT;
colorLine=p.Results.colorLine;
dashedColor=p.Results.dashedColor;
transparency=p.Results.transparency;
lineWidth=p.Results.lineWidth;
imageSize=p.Results.imageSize;
imageFontSize=p.Results.imageFontSize;
colorMap=p.Results.colorMap;
colorMapDiff=p.Results.colorMapDiff;
linestyle=p.Results.linestyle;
range=p.Results.range;
FrameRate=p.Results.FrameRate;
units=p.Results.units;
rangeVarCorr=p.Results.rangeVarCorr;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mkdir(savedir)
if isempty(dimensions)
    dimensions=[1,size(maps_1D,2)];
end

%% CONVERTING DATA FOR SPM ANALYSIS (Scale and Range)
[Var_s,Order]=sort(varCorr);
maps_1D=maps_1D(Order,:);

if ~isempty(rangeVarCorr)
    if numel(rangeVarCorr)==1
        outRange=find(Var_s>rangeVarCorr);
    else
        outRange=find(Var_s<rangeVarCorr(1) | Var_s>rangeVarCorr(2));
    end
    Var_s(outRange)=[];
    maps_1D(outRange,:)=[];
end

meanData=reshape(mean(maps_1D),dimensions(1),dimensions(2));

if corrRFX==1
    %% Random effect analysis
    if ~isempty(sub)
        
        sub=sub(Order);
        if ~isempty(rangeVarCorr)
            sub(outRange)=[];
        end
        
        %% Level 1
        Subjects=unique(sub);
        for Sub=1:numel(Subjects)
            if isnumeric(Subjects(Sub))
                saveSub=[savedir '\SUB\' num2str(Subjects(Sub))];
            else
                saveSub=[savedir '\SUB\' Subjects(Sub)];
            end
            if plotSub==1
            mkdir(saveSub)
            end
            indiceSub=find(Subjects(Sub)==sub);
            spm=spm1d.stats.regress(maps_1D(indiceSub,:),Var_s(indiceSub));
            Alpha(Sub,:)=spm.beta(1,:);
            Beta(Sub,:)=spm.beta(2,:);
            
            if plotSub==1 & min(dimensions)>1
                meanMapSub=reshape(mean(maps_1D(indiceSub,:)),dimensions(1),dimensions(2));
                mapAlphaSub=reshape(spm.beta(1,:),dimensions(1),dimensions(2));
                mapBetaSub=reshape(spm.beta(2,:),dimensions(1),dimensions(2));
                mapRSub=reshape(spm.r,dimensions(1),dimensions(2));
                mapTSub=reshape(spm.z,dimensions(1),dimensions(2));
                
                % Plot mean
                displayMeanMaps(meanMapSub,Fs,xlab,ylab,ylimits,nTicksX,nTicksY,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMap)
                title(['Mean for a mean ' effectNames ' of ' num2str(mean(Var_s(indiceSub))) ' ' units])
                print('-dtiff',imageResolution,[saveSub '\Mean.tiff'])
                close
                
                % Plot alpha (slope) parameter
                displayMeanMapsAlpha(mapAlphaSub,Fs,xlab,ylab,ylimits,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,colorbarLabel,colorMapDiff,units,effectNames)
                title(['Alpha  for ' effectNames])
                print('-dtiff',imageResolution,[saveSub '\Alpha for ' effectNames '.tiff'])
                close
                
                % Plot beta (origin) parameter
                displayMeanMaps(mapBetaSub,Fs,xlab,ylab,ylimits,nTicksX,nTicksY,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMap)
                title(['Beta for ' effectNames])
                print('-dtiff',imageResolution,[saveSub '\Beta for ' effectNames '.tiff'])
                close
                
                % Plot t
                displayTtest(mapTSub,max(max(abs(mapTSub))),abs(mapTSub')>=inf,Fs,xlab,ylab,ylimits,dimensions,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,colorMapDiff)
                title(['Alpha t for ' effectNames])
                print('-dtiff',imageResolution,[saveSub '\Alpha t for ' effectNames '.tiff'])
                close
                
                % Plot r
                displayRtest(mapRSub,1,mapRSub>=inf,Fs,xlab,ylab,ylimits,dimensions,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,colorMapDiff)
                title(['Correlation with ' effectNames])
                print('-dtiff',imageResolution,[saveSub '\r for ' effectNames '.tiff'])
                close
                
            end
            
        end
        
        %% Level 2
        spm=spm1d.stats.nonparam.ttest(Alpha);
        [nWarning,Permutations,alphaCorrected]=fctWarningPermutations(spm,alpha,1,maximalIT,Permutations);
        spmi=spm.inference(alpha,'Iterations',Permutations);
        mapTalpha=reshape(spmi.z,dimensions(1),dimensions(2));
        TthresholdAlpha=spmi.zstar;
        
        spm=spm1d.stats.nonparam.ttest(Beta);
        [nWarning,Permutations,alphaCorrected]=fctWarningPermutations(spm,alpha,1,maximalIT,Permutations);
        spmi=spm.inference(alpha,'Iterations',Permutations);
        mapTbeta=reshape(spmi.z,dimensions(1),dimensions(2));
        TthresholdBeta=spmi.zstar;
        
        mapAlpha=reshape(mean(Alpha),dimensions(1),dimensions(2));
        mapBeta=reshape(mean(Beta),dimensions(1),dimensions(2));
        
        % Plot t
        displayTtest(mapTalpha,TthresholdAlpha,abs(mapTalpha')>=TthresholdAlpha,Fs,xlab,ylab,ylimits,dimensions,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,colorMapDiff)
        dispContour(abs(mapTalpha),TthresholdAlpha,contourColor,dashedColor,transparency,lineWidth,linestyle)
        title(['Alpha RFX t for ' effectNames])
        print('-dtiff',imageResolution,[savedir '\Alpha RFX t for ' effectNames '.tiff'])
        close
        
        displayTtest(mapTbeta,TthresholdBeta,abs(mapTbeta')>=TthresholdBeta,Fs,xlab,ylab,ylimits,dimensions,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,colorMapDiff)
        dispContour(abs(mapTbeta),TthresholdBeta,contourColor,dashedColor,transparency,lineWidth,linestyle)
        title(['Beta RFX t for ' effectNames])
        print('-dtiff',imageResolution,[savedir '\Beta RFX t for ' effectNames '.tiff'])
        close
        
        if dimensions(1)==1
            
            % alpha
            plot1D{1}=Alpha;
            plotmean(plot1D,[],xlab,ylab,Fs,xlimits,nTicksX,[],colorLine,imageFontSize,imageSize,0.1,[])
            hline(0)
            title(['Alpha RFX for ' effectNames])
            print('-dtiff',imageResolution,[savedir '\Alpha RFX for ' effectNames '.tiff'])
            close
            
            % beta
            plot1D{1}=Beta;
            plotmean(plot1D,[],xlab,ylab,Fs,xlimits,nTicksX,[],colorLine,imageFontSize,imageSize,0.1,[])
            title(['Beta RFX for ' effectNames])
            print('-dtiff',imageResolution,[savedir '\Beta RFX for ' effectNames '.tiff'])
            close
            
        else
            
            % Plot alpha (slope) parameter
            displayMeanMapsAlpha(mapAlpha,Fs,xlab,ylab,ylimits,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,colorbarLabel,colorMapDiff,units,effectNames)
            dispContour(abs(mapTalpha),TthresholdAlpha,contourColor,dashedColor,transparency,lineWidth,linestyle)
            title(['Alpha RFX  for ' effectNames])
            print('-dtiff',imageResolution,[savedir '\Alpha RFX for ' effectNames '.tiff'])
            close
            
            % Plot beta (origin) parameter
            displayMeanMaps(mapBeta,Fs,xlab,ylab,ylimits,nTicksX,nTicksY,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMap)
            dispContour(abs(mapTbeta),TthresholdBeta,contourColor,dashedColor,transparency,lineWidth,linestyle)
            title(['Beta RFX for ' effectNames])
            print('-dtiff',imageResolution,[savedir '\Beta RFX for ' effectNames '.tiff'])
            close
            
        end
        
        save([savedir '\SPMRFX'],'alpha','mapTalpha','mapTbeta','TthresholdAlpha','TthresholdBeta','Permutations','mapAlpha','mapBeta', 'Alpha', 'Beta');
        
    end
    
end

%% Correlations
if corrAll==1
    
    spm=spm1d.stats.nonparam.regress(maps_1D,Var_s);
    [nWarning,Permutations,alphaCorrected]=fctWarningPermutations(spm,alpha,1,maximalIT,Permutations);
    spmi=spm.inference(alpha,'Iterations',Permutations);
    mapT=reshape(spmi.z,dimensions(1),dimensions(2));
    Tthreshold=spmi.zstar;
    
    spm2=spm1d.stats.regress(maps_1D,Var_s);
    mapR=reshape(spm2.r,dimensions(1),dimensions(2));
    mapAlpha=reshape(spm2.beta(1,:),dimensions(1),dimensions(2));
    mapBeta=reshape(spm2.beta(2,:),dimensions(1),dimensions(2));
    
    save([savedir '\SPMCorr'],'alpha','mapT','mapR','Tthreshold','Permutations','maps_1D','Var_s','mapAlpha','mapBeta');
    
    
    %% PLOTS
    
    % Plot t
    displayTtest(mapT,Tthreshold,abs(mapT')>=Tthreshold,Fs,xlab,ylab,ylimits,dimensions,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,colorMapDiff)
    dispContour(abs(mapT),Tthreshold,contourColor,dashedColor,transparency,lineWidth,linestyle)
    title(['Correlation with ' effectNames])
    print('-dtiff',imageResolution,[savedir '\t for ' effectNames '.tiff'])
    close
    
    % Plot r
    displayRtest(mapR,1,abs(mapT')>=Tthreshold,Fs,xlab,ylab,ylimits,dimensions,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,colorMapDiff)
    dispContour(abs(mapT),Tthreshold,contourColor,dashedColor,transparency,lineWidth,linestyle)
    title(['Correlation with ' effectNames])
    print('-dtiff',imageResolution,[savedir '\r for ' effectNames '.tiff'])
    close
    
    if min(dimensions)==1 %1D
        
        %mean
        plot1D{1}=meanData;
        plotmean(plot1D,[],xlab,ylab,Fs,xlimits,nTicksX,[],colorLine,imageFontSize,imageSize,0.1,[])
        title(['Mean'])
        print('-dtiff',imageResolution,[savedir '\Mean.tiff'])
        close
        
        % alpha
        plot1D{1}=mapAlpha;
        plotmean(plot1D,[],xlab,ylab,Fs,xlimits,nTicksX,[],colorLine,imageFontSize,imageSize,0.1,[])
        hline(0)
        title(['Alpha for ' effectNames])
        print('-dtiff',imageResolution,[savedir '\Alpha for ' effectNames '.tiff'])
        close
        
        % beta
        plot1D{1}=mapBeta;
        plotmean(plot1D,[],xlab,ylab,Fs,xlimits,nTicksX,[],colorLine,imageFontSize,imageSize,0.1,[])
        title(['Beta for ' effectNames])
        print('-dtiff',imageResolution,[savedir '\Beta for ' effectNames '.tiff'])
        close
        
    else %2D
        
        % Plot mean
        displayMeanMaps(meanData,Fs,xlab,ylab,ylimits,nTicksX,nTicksY,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMap)
        %     dispContour(abs(mapT),Tthreshold,contourColor,dashedColor,transparency,lineWidth,linestyle)
        title(['Mean'])
        print('-dtiff',imageResolution,[savedir '\Mean.tiff'])
        close
        
        % Plot alpha (slope) parameter
        displayMeanMapsAlpha(mapAlpha,Fs,xlab,ylab,ylimits,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,colorbarLabel,colorMapDiff,units,effectNames)
        dispContour(abs(mapT),Tthreshold,contourColor,dashedColor,transparency,lineWidth,linestyle)
        title(['Alpha for ' effectNames])
        print('-dtiff',imageResolution,[savedir '\Alpha for ' effectNames '.tiff'])
        close
        
        % Plot beta (origin) parameter
        displayMeanMaps(mapBeta,Fs,xlab,ylab,ylimits,nTicksX,nTicksY,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMap)
        %     dispContour(abs(mapT),Tthreshold,contourColor,dashedColor,transparency,lineWidth,linestyle)
        title(['Beta for ' effectNames])
        print('-dtiff',imageResolution,[savedir '\Beta for ' effectNames '.tiff'])
        close
        
    end
    
    
end

% Histogram
displayHisto(Var_s,imageFontSize,imageSize,savedir,effectNames,range,rangeVarCorr,units,imageResolution)

% Multiple maps and film
if corrAll==1
    displayCorrFilm(maps_1D,Var_s,dimensions,Fs,xlab,ylab,ylimits,nTicksX,nTicksY,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMap,mapT,Tthreshold,contourColor,dashedColor,transparency,lineWidth,linestyle,savedir,effectNames,range,rangeVarCorr,FrameRate,units,imageResolution,colorLine)
end




end