clear all;
close all;

addpath(genpath('F:\Valeria\m17462\bigdata\matlab\eeglab')); % eeglab toolbox, see README on where to find this
addpath(genpath('F:\Valeria\m17462\bigdata\matlab\Henry\useful_functions')); % contains linspecer function, circular statistics toolbox functions, echt function, shadedErrorBar function, see README on where to find this
addpath(genpath('F:\Valeria\m17462\bigdata\matlab\ScientificColourMaps7')); % ScientificColourMaps toolbox, see README on where to find this
addpath(genpath('F:\Valeria\m17462\bigdata\matlab\DataViz'));  % Dataviz toolbox, see README on where to find this

% load('D:\Valeria\RSN\data\for_sharing\data_to_make_figures\freqalphatheta_allsub_23-Jan-2024');
load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\chans.mat');

Savefolder = 'F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figures\';

%% Average across on and off blocks and calculate change

on_block = 7:12;
off_block = 1:6;
          
conditions = {'Alpha Phase 0'; 'Alpha Phase 90'; 'Alpha Phase 180'; 'Alpha Phase 270';...
            'Theta Phase 0'; 'Theta Phase 90'; 'Theta Phase 180'; 'Theta Phase 270';};
        
band_name = {'7-12 Hz';'4-7 Hz'};

incl_sub = setdiff(1:19,12);

%% topoplot layout 

close all

% Computes electrode locations 

cfg = []; 
cfg.layout = 'EEG1005.lay';
   
layout = ft_prepare_layout(cfg);

figure
hold on
ylim([min(layout.pos(:,2)) max(layout.pos(:,2))])
xlim([min(layout.pos(:,1)) max(layout.pos(:,1))])


for i = 1:128

%scatter(layout.pos(i,1),layout.pos(i,2))

clear indx
indx = strcmp(chans(i),layout.label);
text(layout.pos(indx,1),layout.pos(indx,2),chans(i))
layout2.pos(i,:) = layout.pos(indx,:);
layout2.pos(i,:) = layout.pos(indx,:);
layout2.width(i,:) = layout.width(indx,:);
layout2.height(i,:) = layout.height(indx,:);
layout2.label{i} = chans{i};

end

layout2.mask = layout.mask;
layout2.outline = layout.outline;

% Scalp Current Density - create electrode positions

[~,ftpath] = ft_version; 
elec = ft_read_sens(strcat(ftpath, '/template/electrode/standard_1005.elc' )); 

clear elec2

for i = 1:128

%scatter(layout.pos(i,1),layout.pos(i,2))

clear indx

indx = strcmp(chans(i),elec.label);

%text(layout.pos(indx,1),layout.pos(indx,2),chans(i))

elec2.chanpos(i,:) = elec.chanpos(indx,:);
elec2.elecpos(i,:) = elec.elecpos(indx,:);
elec2.label(i,:) = elec.label(indx,:);


end

elec2.chantype = elec.chantype;
elec2.unit = elec.unit;
elec2.chanunit = elec.chanunit;
elec2.type = elec.type;

%

clc

cfg = [];
cfg.layout = layout2;
cfg.method = 'triangulation';
cfg.compress = 'yes';
cfg.feedback = 'yes';%'yes';
neighbours = ft_prepare_neighbours(cfg);

%% Alpha stim - Topo lme condition

close all

band = 1;

load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure4D_frequency_allsub\statsresult\statsresult_alphastim_alphafreq.mat')
    
figure('Renderer','painters','units','normalized','outerposition',[0 0 0.5 0.5])

PlotChans = [2];
PlotChans2 = [];
  if statsresult.clus_max_condition > statsresult.p95_clus_condition
      if length(statsresult.WhichCh_1_max_condition) > statsresult.p95_clus_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_1_max_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_2_max_condition) > statsresult.p95_clus_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_2_max_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_3_max_condition) > statsresult.p95_clus_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_3_max_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_4_max_condition) > statsresult.p95_clus_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_4_max_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_5_max_condition) > statsresult.p95_clus_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_5_max_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      Plotchans2 = unique(PlotChans2);  
  else
        PlotChans2 = [];
  end

ft_plot_topo(layout2.pos(:,1),layout2.pos(:,2),statsresult.Fvalue_condition,'mask',layout2.mask,'outline',layout2.outline, ...
    'interplim','mask','gridscale',300);
hold on
scatter(layout2.pos(2,1),layout2.pos(2,2),200,[0.6350 0.0780 0.1840],'x','LineWidth',5);

hold on
scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),50,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

load('lapaz.mat');
colormap(lapaz)
colorbar
set(gca,'FontSize',18);
axis off
axis square
title([band_name{band}])   

% saveas(gcf,[Savefolder,'Figure4D_alphastim_topo_lme_condition_alphaband_N',num2str(length(incl_sub)),'_lapaz_colorbar.svg']);

%%

band = 2;

load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure4D_frequency_allsub\statsresult\statsresult_alphastim_thetafreq.mat')
    
figure('Renderer','painters','units','normalized','outerposition',[0 0 0.5 0.5])

PlotChans2 = [];
  if statsresult.clus_max_condition > statsresult.p95_clus_condition
      if length(statsresult.WhichCh_1_max_condition) > statsresult.p95_clus_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_1_max_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_2_max_condition) > statsresult.p95_clus_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_2_max_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_3_max_condition) > statsresult.p95_clus_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_3_max_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_4_max_condition) > statsresult.p95_clus_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_4_max_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_5_max_condition) > statsresult.p95_clus_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_5_max_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      Plotchans2 = unique(PlotChans2);
  else
        PlotChans2 = [];
  end

ft_plot_topo(layout2.pos(:,1),layout2.pos(:,2),statsresult.Fvalue_condition,'mask',layout2.mask,'outline',layout2.outline, ...
    'interplim','mask','gridscale',300,'clim',[0 8]);
hold on
scatter(layout2.pos(2,1),layout2.pos(2,2),200,[0.6350 0.0780 0.1840],'x','LineWidth',5);

hold on
scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),50,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

load('lapaz.mat');
colormap(lapaz)
colorbar
set(gca,'FontSize',18);
axis off
axis square
title([band_name{band}])   

% saveas(gcf,[Savefolder,'Figure4D_alphastim_topo_lme_condition_thetaband_N',num2str(length(incl_sub)),'_lapaz_colorbar.svg']);

%% Alpha stim - Topo lme substage

band = 1;%:15

load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure4D_frequency_allsub\statsresult\statsresult_alphastim_alphafreq.mat')
  
figure('Renderer','painters','units','normalized','outerposition',[0 0 0.5 0.5])

PlotChans = [2];
PlotChans2 = [];
  if statsresult.clus_max_substage > statsresult.p95_clus_substage
      if length(statsresult.WhichCh_1_max_substage) > statsresult.p95_clus_substage
      PlotChans2 = [PlotChans2 statsresult.WhichCh_1_max_substage]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_2_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_2_max_substage]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_3_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_3_max_substage]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_4_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_4_max_substage]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_5_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_5_max_substage]; %find(pvalue_condition(band,:) < 0.05);
      end
      Plotchans2 = unique(PlotChans2);
  else
        PlotChans2 = [];
  end

ft_plot_topo(layout2.pos(:,1),layout2.pos(:,2),statsresult.Fvalue_substage,'mask',layout2.mask,'outline',layout2.outline, ...
    'interplim','mask','gridscale',300,'clim',[0 9]);
hold on
scatter(layout2.pos(2,1),layout2.pos(2,2),200,[0.6350 0.0780 0.1840],'x','LineWidth',5);

hold on
scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),50,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

load('lapaz.mat');
colormap(lapaz)
colorbar
set(gca,'FontSize',18);
axis off
axis square
title([band_name{band}])    

% saveas(gcf,[Savefolder,'Suppl_Figure10_alphastim_topo_lme_substage_alphaband_N',num2str(length(incl_sub)),'_lapaz_colorbar.svg']);

%%

band = 2;%:15
    
load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure4D_frequency_allsub\statsresult\statsresult_alphastim_thetafreq.mat')
    
figure('Renderer','painters','units','normalized','outerposition',[0 0 0.5 0.5])

PlotChans = [2];
PlotChans2 = [];
  if statsresult.clus_max_substage > statsresult.p95_clus_substage
      if length(statsresult.WhichCh_1_max_substage) > statsresult.p95_clus_substage
      PlotChans2 = [PlotChans2 statsresult.WhichCh_1_max_substage]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_2_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_2_max_substage]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_3_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_3_max_substage]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_4_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_4_max_substage]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_5_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_5_max_substage]; %find(pvalue_condition(band,:) < 0.05);
      end
      Plotchans2 = unique(PlotChans2);  
  else
        PlotChans2 = [];
  end

ft_plot_topo(layout2.pos(:,1),layout2.pos(:,2),statsresult.Fvalue_substage,'mask',layout2.mask,'outline',layout2.outline, ...
    'interplim','mask','gridscale',300,'clim',[0 9]);
hold on
scatter(layout2.pos(2,1),layout2.pos(2,2),200,[0.6350 0.0780 0.1840],'x','LineWidth',5);

hold on
scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),50,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

load('lapaz.mat');
colormap(lapaz)
colorbar
set(gca,'FontSize',18);
axis off
axis square
title([band_name{band}])    


% saveas(gcf,[Savefolder,'Suppl_Figure10_alphastim_topo_lme_substage_thetaband_N',num2str(length(incl_sub)),'_lapaz_colorbar.svg']);


%% Alpha stim - Topo lme condition*substage

band = 1; %:15
load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure4D_frequency_allsub\statsresult\statsresult_alphastim_alphafreq.mat')
    
figure('Renderer','painters','units','normalized','outerposition',[0 0 0.5 0.5])

PlotChans = [2];
PlotChans2 = [];
  if statsresult.clus_max_substage_condition > statsresult.p95_clus_substage_condition
      if length(statsresult.WhichCh_1_max_substage_condition) > statsresult.p95_clus_substage_condition
      PlotChans2 = [PlotChans2 statsresult.WhichCh_1_max_substage_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_2_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_2_max_substage_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_3_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_3_max_substage_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_4_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_4_max_substage_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_5_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_5_max_substage_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      Plotchans2 = unique(PlotChans2);  
  else
        PlotChans2 = [];
  end

ft_plot_topo(layout2.pos(:,1),layout2.pos(:,2),statsresult.Fvalue_substage_condition,'mask',layout2.mask,'outline',layout2.outline, ...
    'interplim','mask','gridscale',300,'clim',[0 7]);
hold on
scatter(layout2.pos(2,1),layout2.pos(2,2),200,[0.6350 0.0780 0.1840],'x','LineWidth',5);

hold on
scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),50,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

load('lapaz.mat');
colormap(lapaz)
colorbar
set(gca,'FontSize',18);
axis off
axis square
title([band_name{band}])    

% saveas(gcf,[Savefolder,'Suppl_Figure10_alphastim_topo_lme_substagecondition_alphaband_N',num2str(length(incl_sub)),'_lapaz_colorbar.svg']);

%%

band = 2; %:15

load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure4D_frequency_allsub\statsresult\statsresult_alphastim_thetafreq.mat')
    
figure('Renderer','painters','units','normalized','outerposition',[0 0 0.5 0.5])

PlotChans = [2];
PlotChans2 = [];
  if statsresult.clus_max_substage_condition > statsresult.p95_clus_substage_condition
      if length(statsresult.WhichCh_1_max_substage_condition) > statsresult.p95_clus_substage_condition
      PlotChans2 = [PlotChans2 statsresult.WhichCh_1_max_substage_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_2_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_2_max_substage_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_3_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_3_max_substage_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_4_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_4_max_substage_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_5_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_5_max_substage_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      Plotchans2 = unique(PlotChans2);  
  else
        PlotChans2 = [];
  end

ft_plot_topo(layout2.pos(:,1),layout2.pos(:,2),statsresult.Fvalue_substage_condition,'mask',layout2.mask,'outline',layout2.outline, ...
    'interplim','mask','gridscale',300,'clim',[0 7]);
hold on
scatter(layout2.pos(2,1),layout2.pos(2,2),200,[0.6350 0.0780 0.1840],'x','LineWidth',5);

hold on
scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),50,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

load('lapaz.mat');
colormap(lapaz)
colorbar
set(gca,'FontSize',18);
axis off
axis square
title([band_name{band}])    

% saveas(gcf,[Savefolder,'Suppl_Figure10_alphastim_topo_lme_substagecondition_thetaband_N',num2str(length(incl_sub)),'_lapaz_colorbar.svg']);


%% Theta stim - Topo lme condition

band = 1;

load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure4D_frequency_allsub\statsresult\statsresult_thetastim_alphafreq.mat')
 
figure('Renderer','painters','units','normalized','outerposition',[0 0 0.5 0.5])

PlotChans = [2];
PlotChans2 = [];
  if statsresult.clus_max_condition > statsresult.p95_clus_condition
      if length(statsresult.WhichCh_1_max_condition) > statsresult.p95_clus_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_1_max_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_2_max_condition) > statsresult.p95_clus_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_2_max_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_3_max_condition) > statsresult.p95_clus_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_3_max_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_4_max_condition) > statsresult.p95_clus_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_4_max_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_5_max_condition) > statsresult.p95_clus_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_5_max_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      Plotchans2 = unique(PlotChans2);  
  else
        PlotChans2 = [];
  end

ft_plot_topo(layout2.pos(:,1),layout2.pos(:,2),statsresult.Fvalue_condition,'mask',layout2.mask,'outline',layout2.outline, ...
    'interplim','mask','gridscale',300,'clim',[0 8]);
hold on
scatter(layout2.pos(2,1),layout2.pos(2,2),200,[0.6350 0.0780 0.1840],'x','LineWidth',5);

hold on
scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),50,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

load('lapaz.mat');
colormap(lapaz)
colorbar
set(gca,'FontSize',18);
axis off
axis square
title([band_name{band}])   

% saveas(gcf,[Savefolder,'Figure4J_thetastim_topo_lme_condition_alphaband_N',num2str(length(incl_sub)),'_lapaz_colorbar.svg']);

%%

band = 2;

load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure4D_frequency_allsub\statsresult\statsresult_thetastim_thetafreq.mat')
    
figure('Renderer','painters','units','normalized','outerposition',[0 0 0.5 0.5])

PlotChans = [2];
PlotChans2 = [];
  if statsresult.clus_max_condition > statsresult.p95_clus_condition
      if length(statsresult.WhichCh_1_max_condition) > statsresult.p95_clus_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_1_max_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_2_max_condition) > statsresult.p95_clus_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_2_max_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_3_max_condition) > statsresult.p95_clus_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_3_max_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_4_max_condition) > statsresult.p95_clus_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_4_max_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_5_max_condition) > statsresult.p95_clus_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_5_max_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      Plotchans2 = unique(PlotChans2);  
  else
        PlotChans2 = [];
  end

ft_plot_topo(layout2.pos(:,1),layout2.pos(:,2),statsresult.Fvalue_condition,'mask',layout2.mask,'outline',layout2.outline, ...
    'interplim','mask','gridscale',300,'clim',[0 7]);
hold on
scatter(layout2.pos(2,1),layout2.pos(2,2),200,[0.6350 0.0780 0.1840],'x','LineWidth',5);

hold on
scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),50,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

load('lapaz.mat');
colormap(lapaz)
colorbar
set(gca,'FontSize',18);
axis off
axis square
title([band_name{band}])   

% saveas(gcf,[Savefolder,'Figure4J_thetastim_topo_lme_condition_thetaband_N',num2str(length(incl_sub)),'_lapaz_colorbar.svg']);

%% Theta stim - Topo lme substage

band = 1;

load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure4D_frequency_allsub\statsresult\statsresult_thetastim_alphafreq.mat')
    
figure('Renderer','painters','units','normalized','outerposition',[0 0 0.5 0.5])

PlotChans = [2];
PlotChans2 = [];
  if statsresult.clus_max_substage > statsresult.p95_clus_substage
      if length(statsresult.WhichCh_1_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_1_max_substage]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_2_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_2_max_substage]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_3_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_3_max_substage]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_4_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_4_max_substage]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_5_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_5_max_substage]; %find(pvalue_condition(band,:) < 0.05);
      end
      Plotchans2 = unique(PlotChans2);  
  else
        PlotChans2 = [];
  end
  
ft_plot_topo(layout2.pos(:,1),layout2.pos(:,2),statsresult.Fvalue_substage,'mask',layout2.mask,'outline',layout2.outline, ...
    'interplim','mask','gridscale',300,'clim',[0 7]);
hold on
scatter(layout2.pos(2,1),layout2.pos(2,2),200,[0.6350 0.0780 0.1840],'x','LineWidth',5);

hold on
scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),50,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

load('lapaz.mat');
colormap(lapaz)
colorbar
set(gca,'FontSize',18);
axis off
axis square
title([band_name{band}])   

% saveas(gcf,[Savefolder,'Suppl_Figure18_thetastim_topo_lme_substage_alphaband_N',num2str(length(incl_sub)),'_lapaz_colorbar.svg']);

%%

band = 2;

load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure4D_frequency_allsub\statsresult\statsresult_thetastim_thetafreq.mat')

figure('Renderer','painters','units','normalized','outerposition',[0 0 0.5 0.5])

PlotChans = [2];
PlotChans2 = [];
  if statsresult.clus_max_substage > statsresult.p95_clus_substage
      if length(statsresult.WhichCh_1_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_1_max_substage]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_2_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_2_max_substage]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_3_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_3_max_substage]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_4_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_4_max_substage]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_5_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_5_max_substage]; %find(pvalue_condition(band,:) < 0.05);
      end
      Plotchans2 = unique(PlotChans2);  
  else
        PlotChans2 = [];
  end
  
ft_plot_topo(layout2.pos(:,1),layout2.pos(:,2),statsresult.Fvalue_substage,'mask',layout2.mask,'outline',layout2.outline, ...
    'interplim','mask','gridscale',300,'clim',[0 7]);
hold on
scatter(layout2.pos(2,1),layout2.pos(2,2),200,[0.6350 0.0780 0.1840],'x','LineWidth',5);

hold on
scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),50,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

load('lapaz.mat');
colormap(lapaz)
colorbar
set(gca,'FontSize',18);
axis off
axis square
title([band_name{band}])   

% saveas(gcf,[Savefolder,'Suppl_Figure18_thetastim_topo_lme_substage_thetaband_N',num2str(length(incl_sub)),'_lapaz_colorbar.svg']);


%% Theta stim - Topo lme substage *condition

band = 1;

load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure4D_frequency_allsub\statsresult\statsresult_thetastim_alphafreq.mat')
    
figure('Renderer','painters','units','normalized','outerposition',[0 0 0.5 0.5])

PlotChans = [2];
PlotChans2 = [];
  if statsresult.clus_max_substage_condition > statsresult.p95_clus_substage_condition
      if length(statsresult.WhichCh_1_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_1_max_substage_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_2_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_2_max_substage_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_3_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_3_max_substage_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_4_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_4_max_substage_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_5_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_5_max_substage_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      Plotchans2 = unique(PlotChans2);  
  else
        PlotChans2 = [];
  end
  
ft_plot_topo(layout2.pos(:,1),layout2.pos(:,2),statsresult.Fvalue_substage_condition,'mask',layout2.mask,'outline',layout2.outline, ...
    'interplim','mask','gridscale',300,'clim',[0 7]);
hold on
scatter(layout2.pos(2,1),layout2.pos(2,2),200,[0.6350 0.0780 0.1840],'x','LineWidth',5);

hold on
scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),50,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

load('lapaz.mat');
colormap(lapaz)
colorbar
set(gca,'FontSize',18);
axis off
axis square
title([band_name{band}])   

% saveas(gcf,[Savefolder,'Suppl_Figure18_thetastim_topo_lme_substage_condition_alphaband_N',num2str(length(incl_sub)),'_lapaz_colorbar.svg']);

%%

band = 2;

load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure4D_frequency_allsub\statsresult\statsresult_thetastim_thetafreq.mat')
   
figure('Renderer','painters','units','normalized','outerposition',[0 0 0.5 0.5])

PlotChans = [2];
PlotChans2 = [];
  if statsresult.clus_max_substage_condition > statsresult.p95_clus_substage_condition
      if length(statsresult.WhichCh_1_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_1_max_substage_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_2_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_2_max_substage_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_3_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_3_max_substage_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_4_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_4_max_substage_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_5_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_5_max_substage_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      Plotchans2 = unique(PlotChans2);  
  else
        PlotChans2 = [];
  end
  
ft_plot_topo(layout2.pos(:,1),layout2.pos(:,2),statsresult.Fvalue_substage_condition,'mask',layout2.mask,'outline',layout2.outline, ...
    'interplim','mask','gridscale',300,'clim',[0 7]);
hold on
scatter(layout2.pos(2,1),layout2.pos(2,2),200,[0.6350 0.0780 0.1840],'x','LineWidth',5);

hold on
scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),50,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

load('lapaz.mat');
colormap(lapaz)
colorbar
set(gca,'FontSize',18);
axis off
axis square
title([band_name{band}])   

% saveas(gcf,[Savefolder,'Suppl_Figure18_thetastim_topo_lme_substage_condition_thetaband_N',num2str(length(incl_sub)),'_lapaz_colorbar.svg']);

