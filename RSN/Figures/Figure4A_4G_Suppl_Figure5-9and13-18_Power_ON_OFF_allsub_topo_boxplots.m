clear all;
close all;

addpath(genpath('F:\Valeria\m17462\bigdata\matlab\eeglab')); % eeglab toolbox, see README on where to find this
addpath(genpath('F:\Valeria\m17462\bigdata\matlab\Henry\useful_functions')); % contains linspecer function, circular statistics toolbox functions, echt function, shadedErrorBar function, see README on where to find this
addpath(genpath('F:\Valeria\m17462\bigdata\matlab\ScientificColourMaps7')); % ScientificColourMaps toolbox, see README on where to find this

addpath(genpath('F:\Valeria\m17462\bigdata\matlab\DataViz'));  % Dataviz toolbox, see README on where to find this

% Folderpath = '/vol/research/nemo/datasets/RSN/data/hdEEG/';
% sub_Folderpath = dir([Folderpath,'RSN*']);

load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure2_Figure3A_Figure4A_psd_allsub_mICA_avref_12-Mar-2023.mat');
load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\chans.mat');

statsresult_path = 'F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure4A_psd_allsub\statsresult\';

Savefolder = 'F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figures\';

%% Average across on and off blocks and calculate change

on_block = 7:12;
off_block = 1:6;

psd_ON = squeeze(nanmean(mpsd_con_ch(:,:,:,:,on_block),5)); % psd_ON: sub x ch x con x bins
psd_OFF = squeeze(nanmean(mpsd_con_ch(:,:,:,:,off_block),5));

psd_ON_phasic = squeeze(nanmean(mpsd_con_ch_phasic(:,:,:,:,on_block),5)); % psd_ON: sub x ch x con x bins
psd_OFF_phasic = squeeze(nanmean(mpsd_con_ch_phasic(:,:,:,:,off_block),5));

psd_ON_tonic = squeeze(nanmean(mpsd_con_ch_tonic(:,:,:,:,on_block),5)); % psd_ON: sub x ch x con x bins
psd_OFF_tonic = squeeze(nanmean(mpsd_con_ch_tonic(:,:,:,:,off_block),5));

band_freq = [1 2;2 3;3 4;4 5; 5 6; 6 7; 7 8; ...
             8 9; 9 10; 10 11; 11 12; 12 13; 13 14; 14 15; 15 16];

band_name = {'1-2 Hz' '2-3 Hz' '3-4 Hz' '4-5 Hz' '5-6 Hz' '6-7 Hz' '7-8 Hz'...
              '8-9 Hz' '9-10 Hz' '10-11 Hz' '11-12 Hz' '12-13 Hz' '13-14 Hz'...
              '14-15 Hz' '15-16 Hz'};

conditions = {'Peak'; 'Falling'; 'Trough'; 'Rising';
    'Peak'; 'Falling'; 'Trough'; 'Rising';}

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


%% Alpha stim- topo lme condition - all bins


close all
figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
hold on

for band = 1:15
% band = 7;  
% band = 10;    
load([statsresult_path,'statsresult_alpha_',band_name{band},'.mat']);
    
% figure('Renderer','painters','units','normalized','outerposition',[0 0 0.5 0.5])

subplot(3,5,band)

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
% scatter(layout2.pos(2,1),layout2.pos(2,2),200,[0.6350 0.0780 0.1840],'x','LineWidth',5);
% 
% hold on
% scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),50,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

scatter(layout2.pos(2,1),layout2.pos(2,2),50,[0.6350 0.0780 0.1840],'x','LineWidth',2);

hold on
scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),20,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

load('lapaz.mat');
colormap(lapaz)
colorbar
set(gca,'FontSize',18);
axis off
axis square
title([band_name{band}])  

% saveas(gcf,[Savefolder,'Figure4_alphastim_topo_lme_condition_',num2str(band_freq(band,1)),'_',num2str(band_freq(band,2)),'Hz_N',num2str(length(incl_sub)),'_lapaz_colorbar.svg']);

end

% saveas(gcf,[Savefolder,'Suppl_Figure5_alphastim_topo_lme_condition_1Hzbands_N',num2str(length(incl_sub)),'_lapaz_colorbar.svg']);



%% Alpha stim- topo lme condition - significant bins

close all
% figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
% hold on

% for band = 1:15
band = 7;  
% band = 10;    
load([statsresult_path,'statsresult_alpha_',band_name{band},'.mat']);
    
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

% scatter(layout2.pos(2,1),layout2.pos(2,2),50,[0.6350 0.0780 0.1840],'x','LineWidth',2);
% 
% hold on
% scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),20,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

load('lapaz.mat');
colormap(lapaz)
colorbar
set(gca,'FontSize',18);
axis off
axis square
title([band_name{band}])  

% saveas(gcf,[Savefolder,'Figure4A_alphastim_topo_lme_condition_',num2str(band_freq(band,1)),'_',num2str(band_freq(band,2)),'Hz_N',num2str(length(incl_sub)),'_lapaz_colorbar.svg']);

% end

% saveas(gcf,[Savefolder,'Suppl_Figure4_alphastim_topo_lme_condition_1Hzbands_N',num2str(length(incl_sub)),'_lapaz_colorbar.svg']);

%% Alpha stim - topo lme substage

incl_sub = setdiff(1:19,12);

close all
figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
hold on

for band = 1:15
    
load([statsresult_path,'statsresult_alpha_',band_name{band},'.mat']);

subplot(3,5,band)
% hold on

% ft_plot_topo(layout2.pos(:,1),layout2.pos(:,2),stat_bands_alpha(band,:),'mask',layout2.mask,'outline',layout2.outline, ...
%     'interplim','mask','clim',[0 35],'gridscale',300);  

PlotChans = [2];
PlotChans2 = [];
    if statsresult.clus_max_substage > statsresult.p95_clus_substage
        if length(statsresult.WhichCh_1_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_1_max_substage]; %find(pvalue_substage(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_2_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_2_max_substage]; %find(pvalue_substage(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_3_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_3_max_substage]; %find(pvalue_substage(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_4_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_4_max_substage]; %find(pvalue_substage(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_5_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_5_max_substage]; %find(pvalue_condition(band,:) < 0.05);
      end
      Plotchans2 = unique(PlotChans2);  
   else
        PlotChans2 = [];
   end
    
ft_plot_topo(layout2.pos(:,1),layout2.pos(:,2),statsresult.Fvalue_substage,'mask',layout2.mask,'outline',layout2.outline, ...
    'interplim','mask','gridscale',300);
hold on
% scatter(layout2.pos(2,1),layout2.pos(2,2),200,[0.6350 0.0780 0.1840],'x','LineWidth',5);
% 
% hold on
% scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),50,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

scatter(layout2.pos(2,1),layout2.pos(2,2),50,[0.6350 0.0780 0.1840],'x','LineWidth',2);

hold on
scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),20,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);    
    
load('lapaz.mat');
colormap(lapaz)
colorbar
set(gca,'FontSize',18);
axis off
axis square
title([band_name{band}])    

end

% saveas(gcf,[Savefolder,'Suppl_Figure6_alphastim_topo_lme_substage_1Hzbands_N',num2str(length(incl_sub)),'_lapaz_colorbar.svg']);


%% power change clusters

band = 2;

load([statsresult_path,'statsresult_alpha_',band_name{band},'.mat']);

band_ndx = find(f >= band_freq(band,1) & f <= band_freq(band,2));

cluster_el = statsresult.WhichCh_1_max_substage;

power_band_ON_phasic = nansum(psd_ON_phasic(incl_sub,:,:,band_ndx),4);
power_band_OFF_phasic = nansum(psd_OFF_phasic(incl_sub,:,:,band_ndx),4);
        
power_band_ON_tonic = nansum(psd_ON_tonic(incl_sub,:,:,band_ndx),4);
power_band_OFF_tonic = nansum(psd_OFF_tonic(incl_sub,:,:,band_ndx),4);
        
perc_change_band_phasic = (power_band_ON_phasic./power_band_OFF_phasic-1)*100; %log10(power_band_ON_phasic./power_band_OFF_phasic);
perc_change_band_tonic = (power_band_ON_tonic./power_band_OFF_tonic-1)*100; %log10(power_band_ON_tonic./power_band_OFF_tonic);

perc_change_band_phasic_cluster = nanmean(squeeze(nanmean(perc_change_band_phasic(:,cluster_el,1:4),2)),2);
perc_change_band_tonic_cluster = nanmean(squeeze(nanmean(perc_change_band_tonic(:,cluster_el,1:4),2)),2);

perc_change_band_phasictonic_2_3 = vertcat(perc_change_band_phasic_cluster,perc_change_band_tonic_cluster);

[h p_phasic_2_3] = ttest(perc_change_band_phasic_cluster)
[h p_tonic_2_3] = ttest(perc_change_band_tonic_cluster)
[h p_phasic_tonic_2_3] = ttest(perc_change_band_phasic_cluster,perc_change_band_tonic_cluster)


band = 3;

load([statsresult_path,'statsresult_alpha_',band_name{band},'.mat']);

band_ndx = find(f >= band_freq(band,1) & f <= band_freq(band,2));

cluster_el = statsresult.WhichCh_1_max_substage;

power_band_ON_phasic = nansum(psd_ON_phasic(incl_sub,:,:,band_ndx),4);
power_band_OFF_phasic = nansum(psd_OFF_phasic(incl_sub,:,:,band_ndx),4);
        
power_band_ON_tonic = nansum(psd_ON_tonic(incl_sub,:,:,band_ndx),4);
power_band_OFF_tonic = nansum(psd_OFF_tonic(incl_sub,:,:,band_ndx),4);
        
perc_change_band_phasic = (power_band_ON_phasic./power_band_OFF_phasic-1)*100; %log10(power_band_ON_phasic./power_band_OFF_phasic);
perc_change_band_tonic = (power_band_ON_tonic./power_band_OFF_tonic-1)*100; %log10(power_band_ON_tonic./power_band_OFF_tonic);

perc_change_band_phasic_cluster = nanmean(squeeze(nanmean(perc_change_band_phasic(:,cluster_el,1:4),2)),2);
perc_change_band_tonic_cluster = nanmean(squeeze(nanmean(perc_change_band_tonic(:,cluster_el,1:4),2)),2);

perc_change_band_phasictonic_3_4 = vertcat(perc_change_band_phasic_cluster,perc_change_band_tonic_cluster);

[h p_phasic_3_4] = ttest(perc_change_band_phasic_cluster)
[h p_tonic_3_4] = ttest(perc_change_band_tonic_cluster)
[h p_phasic_tonic_3_4] = ttest(perc_change_band_phasic_cluster,perc_change_band_tonic_cluster)

perc_change_band_all = horzcat(perc_change_band_phasictonic_2_3,perc_change_band_phasictonic_3_4); 

group_inx = vertcat(repmat(1,length(incl_sub),1),repmat(2,length(incl_sub),1));

condition_names = {'2-3 Hz' '3-4 Hz'};
group_names = {'Phasic' 'Tonic'};

colors = [0.6365 0.3753 0.6753 ; 1 0.3 0.5];

fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
h = daboxplot(perc_change_band_all,'groups',group_inx,'outliers',1,'outsymbol','kx',...
    'xtlabels', condition_names,'fill',1,'color',colors,...
    'whiskers',1,'boxalpha',0.7);
ylabel('Power change (%)');
xl = xlim; xlim([xl(1), xl(2)+1]);     % make more space for the legend
set(h.md,'LineWidth',1.5); % customize median lines
set(h.ot,'SizeData',50); % customize median lines

set(gca,'Fontsize',35,'TickDir','out','LineWidth',3);
xtickangle(45);
box off
axis square

% saveas(gcf,[Savefolder,'Suppl_Figure8_alphastim_lme_substage_cluster_2_3Hz_3_4Hz','.svg']);

%% Alpha stim - topo lme condition*substage

incl_sub = setdiff(1:19,12);

close all
figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
hold on

for band = 1:15
    
load([statsresult_path,'statsresult_alpha_',band_name{band},'.mat']);

%     
subplot(3,5,band)

PlotChans = [2];
PlotChans2 = [];
    if statsresult.clus_max_substage_condition > statsresult.p95_clus_substage_condition
        if length(statsresult.WhichCh_1_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_1_max_substage_condition]; %find(pvalue_substage(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_2_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_2_max_substage_condition]; %find(pvalue_substage(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_3_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_3_max_substage_condition]; %find(pvalue_substage(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_4_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_4_max_substage_condition]; %find(pvalue_substage(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_5_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_5_max_substage_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      Plotchans2 = unique(PlotChans2);  
   else
        PlotChans2 = [];
   end
    
ft_plot_topo(layout2.pos(:,1),layout2.pos(:,2),statsresult.Fvalue_substage_condition,'mask',layout2.mask,'outline',layout2.outline, ...
    'interplim','mask','gridscale',300);
hold on
% scatter(layout2.pos(2,1),layout2.pos(2,2),200,[0.6350 0.0780 0.1840],'x','LineWidth',5);
% 
% hold on
% scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),50,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

scatter(layout2.pos(2,1),layout2.pos(2,2),50,[0.6350 0.0780 0.1840],'x','LineWidth',2);

hold on
scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),20,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);    

load('lapaz.mat');
colormap(lapaz)
colorbar
set(gca,'FontSize',18);
axis off
axis square
title([band_name{band}])    

end

% saveas(gcf,[Savefolder,'Suppl_Figure7_alphastim_topo_lme_substagecondition_1Hzbands_N',num2str(length(incl_sub)),'_lapaz_colorbar.svg']);

%% Theta stim - Topo lme condition - all bins

incl_sub = setdiff(1:19,12);

close all
figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
hold on

for band = 1:15
% band = 7;
    
load([statsresult_path,'statsresult_theta_',band_name{band},'.mat']);

subplot(3,5,band)

% figure('Renderer','painters','units','normalized','outerposition',[0 0 0.5 0.5])
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
% scatter(layout2.pos(2,1),layout2.pos(2,2),200,[0.6350 0.0780 0.1840],'x','LineWidth',5);
% 
% hold on
% scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),50,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

scatter(layout2.pos(2,1),layout2.pos(2,2),50,[0.6350 0.0780 0.1840],'x','LineWidth',2);

hold on
scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),20,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

load('lapaz.mat');
colormap(lapaz)
colorbar
set(gca,'FontSize',18);
axis off
axis square
title([band_name{band}])   

% saveas(gcf,[Savefolder,'Figure4_thetastim_topo_lme_condition_',num2str(band_freq(band,1)),'_',num2str(band_freq(band,2)),'Hz_N',num2str(length(incl_sub)),'_lapaz_colorbar.svg']);


end

% saveas(gcf,[Savefolder,'Suppl_Figure12_thetastim_topo_lme_condition_1Hzbands_N',num2str(length(incl_sub)),'_lapaz_colorbar.svg']);


%% Theta stim - Topo lme condition - significant bins

incl_sub = setdiff(1:19,12);

close all
% figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
% hold on

% for band = 1:15
band = 7;
    
load([statsresult_path,'statsresult_theta_',band_name{band},'.mat']);

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

% scatter(layout2.pos(2,1),layout2.pos(2,2),50,[0.6350 0.0780 0.1840],'x','LineWidth',2);
% 
% hold on
% scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),20,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

load('lapaz.mat');
colormap(lapaz)
colorbar
set(gca,'FontSize',18);
axis off
axis square
title([band_name{band}])   

% saveas(gcf,[Savefolder,'Figure4G_thetastim_topo_lme_condition_',num2str(band_freq(band,1)),'_',num2str(band_freq(band,2)),'Hz_N',num2str(length(incl_sub)),'_lapaz_colorbar.svg']);

% end

% saveas(gcf,[Savefolder,'Suppl_Figure4_thetastim_topo_lme_condition_1Hzbands_N',num2str(length(incl_sub)),'_lapaz_colorbar.svg']);


%% Theta stim - Topo lme substage

incl_sub = setdiff(1:19,12);

close all
figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
hold on

for band = 1:15
    
load([statsresult_path,'statsresult_theta_',band_name{band},'.mat']);

%     
subplot(3,5,band)

PlotChans = [2];
PlotChans2 = [];
    if statsresult.clus_max_substage > statsresult.p95_clus_substage
        if length(statsresult.WhichCh_1_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_1_max_substage]; %find(pvalue_substage(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_2_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_2_max_substage]; %find(pvalue_substage(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_3_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_3_max_substage]; %find(pvalue_substage(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_4_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_4_max_substage]; %find(pvalue_substage(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_5_max_substage) > statsresult.p95_clus_substage
        PlotChans2 = [PlotChans2 statsresult.WhichCh_5_max_substage]; %find(pvalue_condition(band,:) < 0.05);
      end
      Plotchans2 = unique(PlotChans2);  
   else
        PlotChans2 = [];
   end
    
ft_plot_topo(layout2.pos(:,1),layout2.pos(:,2),statsresult.Fvalue_substage,'mask',layout2.mask,'outline',layout2.outline, ...
    'interplim','mask','gridscale',300);
hold on
% scatter(layout2.pos(2,1),layout2.pos(2,2),200,[0.6350 0.0780 0.1840],'x','LineWidth',5);
% 
% hold on
% scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),50,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

scatter(layout2.pos(2,1),layout2.pos(2,2),50,[0.6350 0.0780 0.1840],'x','LineWidth',2);

hold on
scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),20,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);    

load('lapaz.mat');
colormap(lapaz)
colorbar
set(gca,'FontSize',18);
axis off
axis square
title([band_name{band}])    

end

% saveas(gcf,[Savefolder,'Suppl_Figure13_thetastim_topo_lme_substage_1Hzbands_N',num2str(length(incl_sub)),'_lapaz_colorbar.svg']);


%% power change clusters

band = 2;

load([statsresult_path,'statsresult_theta_',band_name{band},'.mat']);

band_ndx = find(f >= band_freq(band,1) & f <= band_freq(band,2));

cluster_el = statsresult.WhichCh_1_max_substage;

power_band_ON_phasic = nansum(psd_ON_phasic(incl_sub,:,:,band_ndx),4);
power_band_OFF_phasic = nansum(psd_OFF_phasic(incl_sub,:,:,band_ndx),4);
        
power_band_ON_tonic = nansum(psd_ON_tonic(incl_sub,:,:,band_ndx),4);
power_band_OFF_tonic = nansum(psd_OFF_tonic(incl_sub,:,:,band_ndx),4);
        
perc_change_band_phasic = (power_band_ON_phasic./power_band_OFF_phasic-1)*100; %log10(power_band_ON_phasic./power_band_OFF_phasic);
perc_change_band_tonic = (power_band_ON_tonic./power_band_OFF_tonic-1)*100; %log10(power_band_ON_tonic./power_band_OFF_tonic);

perc_change_band_phasic_cluster = nanmean(squeeze(nanmean(perc_change_band_phasic(:,cluster_el,5:8),2)),2);
perc_change_band_tonic_cluster = nanmean(squeeze(nanmean(perc_change_band_tonic(:,cluster_el,5:8),2)),2);

perc_change_band_phasictonic_2_3 = vertcat(perc_change_band_phasic_cluster,perc_change_band_tonic_cluster);

[h p_phasic_cluster_band2_3] = ttest(perc_change_band_phasic_cluster)
[h p_tonic_cluster_band2_3] = ttest(perc_change_band_tonic_cluster)
[h p_phasic_tonic_cluster_band2_3] = ttest(perc_change_band_phasic_cluster,perc_change_band_tonic_cluster)


band = 3;

load([statsresult_path,'statsresult_theta_',band_name{band},'.mat']);

band_ndx = find(f >= band_freq(band,1) & f <= band_freq(band,2));

cluster_el = statsresult.WhichCh_1_max_substage;

power_band_ON_phasic = nansum(psd_ON_phasic(incl_sub,:,:,band_ndx),4);
power_band_OFF_phasic = nansum(psd_OFF_phasic(incl_sub,:,:,band_ndx),4);
        
power_band_ON_tonic = nansum(psd_ON_tonic(incl_sub,:,:,band_ndx),4);
power_band_OFF_tonic = nansum(psd_OFF_tonic(incl_sub,:,:,band_ndx),4);
        
perc_change_band_phasic = (power_band_ON_phasic./power_band_OFF_phasic-1)*100; %log10(power_band_ON_phasic./power_band_OFF_phasic);
perc_change_band_tonic = (power_band_ON_tonic./power_band_OFF_tonic-1)*100; %log10(power_band_ON_tonic./power_band_OFF_tonic);

perc_change_band_phasic_cluster = nanmean(squeeze(nanmean(perc_change_band_phasic(:,cluster_el,5:8),2)),2);
perc_change_band_tonic_cluster = nanmean(squeeze(nanmean(perc_change_band_tonic(:,cluster_el,5:8),2)),2);

perc_change_band_phasictonic_3_4 = vertcat(perc_change_band_phasic_cluster,perc_change_band_tonic_cluster);

[h p_phasic_cluster_band3_4] = ttest(perc_change_band_phasic_cluster)
[h p_tonic_cluster_band3_4] = ttest(perc_change_band_tonic_cluster)
[h p_phasic_tonic_cluster_band3_4] = ttest(perc_change_band_phasic_cluster,perc_change_band_tonic_cluster)



band = 4;

load([statsresult_path,'statsresult_theta_',band_name{band},'.mat']);

band_ndx = find(f >= band_freq(band,1) & f <= band_freq(band,2));

cluster_el = statsresult.WhichCh_1_max_substage;

power_band_ON_phasic = nansum(psd_ON_phasic(incl_sub,:,:,band_ndx),4);
power_band_OFF_phasic = nansum(psd_OFF_phasic(incl_sub,:,:,band_ndx),4);
        
power_band_ON_tonic = nansum(psd_ON_tonic(incl_sub,:,:,band_ndx),4);
power_band_OFF_tonic = nansum(psd_OFF_tonic(incl_sub,:,:,band_ndx),4);
        
perc_change_band_phasic = (power_band_ON_phasic./power_band_OFF_phasic-1)*100; %log10(power_band_ON_phasic./power_band_OFF_phasic);
perc_change_band_tonic = (power_band_ON_tonic./power_band_OFF_tonic-1)*100; %log10(power_band_ON_tonic./power_band_OFF_tonic);

perc_change_band_phasic_cluster = nanmean(squeeze(nanmean(perc_change_band_phasic(:,cluster_el,5:8),2)),2);
perc_change_band_tonic_cluster = nanmean(squeeze(nanmean(perc_change_band_tonic(:,cluster_el,5:8),2)),2);

perc_change_band_phasictonic_4_5 = vertcat(perc_change_band_phasic_cluster,perc_change_band_tonic_cluster);

[h p_phasic_cluster_band4_5] = ttest(perc_change_band_phasic_cluster)
[h p_tonic_cluster_band4_5] = ttest(perc_change_band_tonic_cluster)
[h p_phasic_tonic_cluster_band4_5] = ttest(perc_change_band_phasic_cluster,perc_change_band_tonic_cluster)


band = 5;

load([statsresult_path,'statsresult_theta_',band_name{band},'.mat']);

band_ndx = find(f >= band_freq(band,1) & f <= band_freq(band,2));

cluster_el = statsresult.WhichCh_1_max_substage;

power_band_ON_phasic = nansum(psd_ON_phasic(incl_sub,:,:,band_ndx),4);
power_band_OFF_phasic = nansum(psd_OFF_phasic(incl_sub,:,:,band_ndx),4);
        
power_band_ON_tonic = nansum(psd_ON_tonic(incl_sub,:,:,band_ndx),4);
power_band_OFF_tonic = nansum(psd_OFF_tonic(incl_sub,:,:,band_ndx),4);
        
perc_change_band_phasic = (power_band_ON_phasic./power_band_OFF_phasic-1)*100; %log10(power_band_ON_phasic./power_band_OFF_phasic);
perc_change_band_tonic = (power_band_ON_tonic./power_band_OFF_tonic-1)*100; %log10(power_band_ON_tonic./power_band_OFF_tonic);

perc_change_band_phasic_cluster = nanmean(squeeze(nanmean(perc_change_band_phasic(:,cluster_el,5:8),2)),2);
perc_change_band_tonic_cluster = nanmean(squeeze(nanmean(perc_change_band_tonic(:,cluster_el,5:8),2)),2);

perc_change_band_phasictonic_5_6 = vertcat(perc_change_band_phasic_cluster,perc_change_band_tonic_cluster);

[h p_phasic_cluster_band5_6] = ttest(perc_change_band_phasic_cluster)
[h p_tonic_cluster_band5_6] = ttest(perc_change_band_tonic_cluster)
[h p_phasic_tonic_cluster_band5_6] = ttest(perc_change_band_phasic_cluster,perc_change_band_tonic_cluster)


band = 6;

load([statsresult_path,'statsresult_theta_',band_name{band},'.mat']);

band_ndx = find(f >= band_freq(band,1) & f <= band_freq(band,2));

cluster_el = statsresult.WhichCh_1_max_substage;

power_band_ON_phasic = nansum(psd_ON_phasic(incl_sub,:,:,band_ndx),4);
power_band_OFF_phasic = nansum(psd_OFF_phasic(incl_sub,:,:,band_ndx),4);
        
power_band_ON_tonic = nansum(psd_ON_tonic(incl_sub,:,:,band_ndx),4);
power_band_OFF_tonic = nansum(psd_OFF_tonic(incl_sub,:,:,band_ndx),4);
        
perc_change_band_phasic = (power_band_ON_phasic./power_band_OFF_phasic-1)*100; %log10(power_band_ON_phasic./power_band_OFF_phasic);
perc_change_band_tonic = (power_band_ON_tonic./power_band_OFF_tonic-1)*100; %log10(power_band_ON_tonic./power_band_OFF_tonic);

perc_change_band_phasic_cluster = nanmean(squeeze(nanmean(perc_change_band_phasic(:,cluster_el,5:8),2)),2);
perc_change_band_tonic_cluster = nanmean(squeeze(nanmean(perc_change_band_tonic(:,cluster_el,5:8),2)),2);

perc_change_band_phasictonic_6_7 = vertcat(perc_change_band_phasic_cluster,perc_change_band_tonic_cluster);

[h p_phasic_cluster_band6_7] = ttest(perc_change_band_phasic_cluster)
[h p_tonic_cluster_band6_7] = ttest(perc_change_band_tonic_cluster)
[h p_phasic_tonic_cluster_band6_7] = ttest(perc_change_band_phasic_cluster,perc_change_band_tonic_cluster)


band = 12;

load([statsresult_path,'statsresult_theta_',band_name{band},'.mat']);

band_ndx = find(f >= band_freq(band,1) & f <= band_freq(band,2));

cluster_el = statsresult.WhichCh_1_max_substage;

power_band_ON_phasic = nansum(psd_ON_phasic(incl_sub,:,:,band_ndx),4);
power_band_OFF_phasic = nansum(psd_OFF_phasic(incl_sub,:,:,band_ndx),4);
        
power_band_ON_tonic = nansum(psd_ON_tonic(incl_sub,:,:,band_ndx),4);
power_band_OFF_tonic = nansum(psd_OFF_tonic(incl_sub,:,:,band_ndx),4);
        
perc_change_band_phasic = (power_band_ON_phasic./power_band_OFF_phasic-1)*100; %log10(power_band_ON_phasic./power_band_OFF_phasic);
perc_change_band_tonic = (power_band_ON_tonic./power_band_OFF_tonic-1)*100; %log10(power_band_ON_tonic./power_band_OFF_tonic);

perc_change_band_phasic_cluster = nanmean(squeeze(nanmean(perc_change_band_phasic(:,cluster_el,5:8),2)),2);
perc_change_band_tonic_cluster = nanmean(squeeze(nanmean(perc_change_band_tonic(:,cluster_el,5:8),2)),2);

perc_change_band_phasictonic_12_13 = vertcat(perc_change_band_phasic_cluster,perc_change_band_tonic_cluster);

[h p_phasic_cluster_band12_13] = ttest(perc_change_band_phasic_cluster)
[h p_tonic_cluster_band12_13] = ttest(perc_change_band_tonic_cluster)
[h p_phasic_tonic_cluster_band12_13] = ttest(perc_change_band_phasic_cluster,perc_change_band_tonic_cluster)


perc_change_band_all = horzcat(perc_change_band_phasictonic_2_3,perc_change_band_phasictonic_3_4,perc_change_band_phasictonic_4_5,perc_change_band_phasictonic_5_6,perc_change_band_phasictonic_6_7,perc_change_band_phasictonic_12_13); 

group_inx = vertcat(repmat(1,length(incl_sub),1),repmat(2,length(incl_sub),1));

condition_names = {'2-3 Hz' '3-4 Hz' '4-5 Hz' '5-6 Hz' '6-7 Hz' '12-13 Hz'};
group_names = {'Phasic' 'Tonic'};

colors = [0.6365 0.3753 0.6753 ; 1 0.3 0.5];

fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
h = daboxplot(perc_change_band_all,'groups',group_inx,'outliers',1,'outsymbol','kx',...
    'xtlabels', condition_names,'fill',1,'color',colors,...
    'whiskers',1,'boxalpha',0.7);
ylabel('Power change (%)');
xl = xlim; xlim([xl(1), xl(2)+1]);     % make more space for the legend
set(h.md,'LineWidth',1.5); % customize median lines
set(h.ot,'SizeData',50); % customize median lines

set(gca,'Fontsize',35,'TickDir','out','LineWidth',3);
xtickangle(45);
box off
axis square

% saveas(gcf,[Savefolder,'Suppl_Figure15_thetastim_lme_substage_cluster_2_3_4_5_6_12_Hz','.svg']);


%% Theta stim - Topo lme condition*substage

incl_sub = setdiff(1:19,12);

close all
figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
hold on

for band = 1:15
%     
load([statsresult_path,'statsresult_theta_',band_name{band},'.mat']);

%     
subplot(3,5,band) 

PlotChans = [2];
PlotChans2 = [];
    if statsresult.clus_max_substage_condition > statsresult.p95_clus_substage_condition
        if length(statsresult.WhichCh_1_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_1_max_substage_condition]; %find(pvalue_substage(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_2_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_2_max_substage_condition]; %find(pvalue_substage(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_3_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_3_max_substage_condition]; %find(pvalue_substage(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_4_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_4_max_substage_condition]; %find(pvalue_substage(band,:) < 0.05);
      end
      if length(statsresult.WhichCh_5_max_substage_condition) > statsresult.p95_clus_substage_condition
        PlotChans2 = [PlotChans2 statsresult.WhichCh_5_max_substage_condition]; %find(pvalue_condition(band,:) < 0.05);
      end
      Plotchans2 = unique(PlotChans2);  
   else
        PlotChans2 = [];
   end
    
ft_plot_topo(layout2.pos(:,1),layout2.pos(:,2),statsresult.Fvalue_substage_condition,'mask',layout2.mask,'outline',layout2.outline, ...
    'interplim','mask','gridscale',300);
hold on
% scatter(layout2.pos(2,1),layout2.pos(2,2),200,[0.6350 0.0780 0.1840],'x','LineWidth',5);
% 
% hold on
% scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),50,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

scatter(layout2.pos(2,1),layout2.pos(2,2),50,[0.6350 0.0780 0.1840],'x','LineWidth',2);

hold on
scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),20,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);    

load('lapaz.mat');
colormap(lapaz)
colorbar
set(gca,'FontSize',18);
axis off
axis square
title([band_name{band}])    

end

% saveas(gcf,[Savefolder,'Suppl_Figure14_thetastim_topo_lme_substagecondition_1Hzbands_N',num2str(length(incl_sub)),'_lapaz_colorbar.svg']);


%% power change clusters

band = 3;

load([statsresult_path,'statsresult_theta_',band_name{band},'.mat']);

band_ndx = find(f >= band_freq(band,1) & f <= band_freq(band,2));

cluster_el = statsresult.WhichCh_1_max_substage_condition;

power_band_ON_phasic = nansum(psd_ON_phasic(incl_sub,:,:,band_ndx),4);
power_band_OFF_phasic = nansum(psd_OFF_phasic(incl_sub,:,:,band_ndx),4);
        
power_band_ON_tonic = nansum(psd_ON_tonic(incl_sub,:,:,band_ndx),4);
power_band_OFF_tonic = nansum(psd_OFF_tonic(incl_sub,:,:,band_ndx),4);
        
perc_change_band_phasic = (power_band_ON_phasic./power_band_OFF_phasic-1)*100; %log10(power_band_ON_phasic./power_band_OFF_phasic);
perc_change_band_tonic = (power_band_ON_tonic./power_band_OFF_tonic-1)*100; %log10(power_band_ON_tonic./power_band_OFF_tonic);

perc_change_band_phasic_cluster = squeeze(nanmean(perc_change_band_phasic(:,cluster_el,5:8),2));
perc_change_band_tonic_cluster = squeeze(nanmean(perc_change_band_tonic(:,cluster_el,5:8),2));

for con = 1:4
    
   [h p_phasic_cluster(con)] = ttest(perc_change_band_phasic_cluster(:,con))
   [h p_tonic_cluster(con)] = ttest(perc_change_band_tonic_cluster(:,con))
   [h p_phasic_tonic_cluster(con)] = ttest(perc_change_band_phasic_cluster(:,con),perc_change_band_tonic_cluster(:,con))
     
end


perc_change_band_phasictonic_3_4 = vertcat(perc_change_band_phasic_cluster,perc_change_band_tonic_cluster);

perc_change_band_all = perc_change_band_phasictonic_3_4; % vertcat(perc_change_band_phasictonic_3_4); 

group_inx = vertcat(repmat(1,length(incl_sub),1),repmat(2,length(incl_sub),1));

condition_names = {'Peak' 'Falling' 'Trough' 'Rising'};
group_names = {'Phasic' 'Tonic'};

colors = [0.6365 0.3753 0.6753 ; 1 0.3 0.5];

% colors = linspecer(4);

fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
h = daboxplot(perc_change_band_all,'groups',group_inx,'outliers',1,'outsymbol','kx',...
    'xtlabels', condition_names,'fill',1,'color',colors,...
    'whiskers',1,'boxalpha',0.7);
ylabel('Power change (%)');
xl = xlim; xlim([xl(1), xl(2)+1]);     % make more space for the legend
set(h.md,'LineWidth',1.5); % customize median lines
set(h.ot,'SizeData',50); % customize median lines

set(gca,'Fontsize',35,'TickDir','out','LineWidth',3);
xtickangle(45);
box off
axis square


% saveas(gcf,[Savefolder,'Suppl_Figure16_thetastim_lme_substagecondition_cluster_phasic_',band_name{band},'.svg']);


%% Alpha stimulation - t-test ON vs OFF 
 
incl_sub = setdiff(1:19,12);

close all

cfg = [];
cfg.method      = 'montecarlo';
cfg.statistic   = 'ft_statfun_depsamplesT';%dependent samples T-test
cfg.alpha       = 0.025; %significance level
cfg.numrandomization = 1000;%'all';%number of permutations
cfg.design = [ones(1,length(incl_sub))  2.*ones(1,length(incl_sub))];%off or on
cfg.design(2,:) = [1:length(incl_sub) 1:length(incl_sub)];
cfg.ivar   = 1;%the row on which the independent variable is (in this case, on or off)
cfg.uvar = 2;
cfg.parameter = 'parameter';
cfg.channel = layout2.label;    
cfg.neighbours = neighbours;    
cfg.dim = [128 1];
cfg.correctm = 'cluster';

for band = 1:15    
        

%     for con = 1:4
            
        band_ndx = find(f >= band_freq(band,1) & f <= band_freq(band,2));
       
        power_band_ON = nanmean(nansum(psd_ON(incl_sub,:,1:4,band_ndx),4),3); % mean across all alpha conditions
        power_band_OFF = nanmean(nansum(psd_OFF(incl_sub,:,1:4,band_ndx),4),3); % mean across all alpha conditions
        
%         perc_change_band = (power_band_ON - power_band_OFF)./power_band_OFF *100;
        perc_change_band = log10(power_band_ON./power_band_OFF);
      
        dat = [power_band_ON' power_band_OFF'];
        stat = ft_statistics_montecarlo(cfg,dat,cfg.design);

        stat_ttest_alpha(band,:) = stat.stat;
        mask_ttest_alpha(band,:) = stat.mask;  
     
%     end
    
end

%% Alpha stimulation - Plot ON vs OFF usual bands

figure('units','normalized','outerposition',[0 0 1 1],'Renderer','painters')
hold on    

clear V

%     for con = 1:4
        
        figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
        
      
        
        for band = 1:15
            
        PlotChans = [2];
        PlotChans2 = find(mask_ttest_alpha(band,:)==1);
        
        subplot(3,5,band)
%         ft_plot_topo(layout2.pos(:,1),layout2.pos(:,2),squeeze(stat_ttest(band,con,:)),'mask',layout2.mask,'outline',layout2.outline, ...
%         'interplim','mask','clim',[-3 3],'gridscale',300);
        ft_plot_topo(layout2.pos(:,1),layout2.pos(:,2),squeeze(stat_ttest_alpha(band,:)),'mask',layout2.mask,'outline',layout2.outline, ...
        'interplim','mask','clim',[-4 4],'gridscale',300);
        axis square
        ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
        colormap(flipud(brewermap(64,'RdBu')))
        cb = colorbar;
        axis off
        hold on
        
        
        scatter(layout2.pos(2,1),layout2.pos(2,2),50,[0.6350 0.0780 0.1840],'x','LineWidth',2);

        hold on
        scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),20,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);    

        load('lapaz.mat');
        colormap(lapaz)
        colorbar
        set(gca,'FontSize',18);
        axis off
        axis square
        title([band_name{band}]) 

        end
    
%         saveas(gcf,[Savefolder,'Suppl_Figure9_alphastim_on_vs_off_topo.svg'])
    
%     end
  
%% Theta stimulation - t-test ON vs OFF 
 
incl_sub = setdiff(1:19,12);

close all

cfg = [];
cfg.method      = 'montecarlo';
cfg.statistic   = 'ft_statfun_depsamplesT';%dependent samples T-test
cfg.alpha       = 0.025; %significance level
cfg.numrandomization = 1000;%'all';%number of permutations
cfg.design = [ones(1,length(incl_sub))  2.*ones(1,length(incl_sub))];%off or on
cfg.design(2,:) = [1:length(incl_sub) 1:length(incl_sub)];
cfg.ivar   = 1;%the row on which the independent variable is (in this case, on or off)
cfg.uvar = 2;
cfg.parameter = 'parameter';
cfg.channel = layout2.label;    
cfg.neighbours = neighbours;    
cfg.dim = [128 1];
cfg.correctm = 'cluster';

for band = 1:15    
        

%     for con = 1:4
            
        band_ndx = find(f >= band_freq(band,1) & f <= band_freq(band,2));
        

        power_band_ON = nanmean(nansum(psd_ON(incl_sub,:,5:8,band_ndx),4),3); % mean across all alpha conditions
        power_band_OFF = nanmean(nansum(psd_OFF(incl_sub,:,5:8,band_ndx),4),3); % mean across all alpha conditions
        
%         perc_change_band = (power_band_ON - power_band_OFF)./power_band_OFF *100;
        perc_change_band = log10(power_band_ON./power_band_OFF);
      
        dat = [power_band_ON' power_band_OFF'];
        stat = ft_statistics_montecarlo(cfg,dat,cfg.design);

        stat_ttest_theta(band,:) = stat.stat;
        mask_ttest_theta(band,:) = stat.mask;  
     
%     end
    
end

%% Theta stimulation - Plot ON vs OFF usual bands

figure('units','normalized','outerposition',[0 0 1 1],'Renderer','painters')
% hold on    

clear V

%     for con = 1:4
        
%         figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
        

        for band = 1:15
            
        PlotChans = [2];
        PlotChans2 = find(mask_ttest_theta(band,:)==1);
        
        subplot(3,5,band)
        ft_plot_topo(layout2.pos(:,1),layout2.pos(:,2),squeeze(stat_ttest_theta(band,:)),'mask',layout2.mask,'outline',layout2.outline, ...
        'interplim','mask','clim',[-4 4],'gridscale',300);
        axis square
        ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
        colormap(flipud(brewermap(64,'RdBu')))
        cb = colorbar;
        axis off
        hold on
        
        
        scatter(layout2.pos(2,1),layout2.pos(2,2),50,[0.6350 0.0780 0.1840],'x','LineWidth',2);

        hold on
        scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),20,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);    
        load('lapaz.mat');
        colormap(lapaz)
        colorbar
        set(gca,'FontSize',18);
        axis off
        axis square
        title([band_name{band}]) 

        end
    
%         saveas(gcf,[Savefolder,'Suppl_Figure17_thetastim_on_vs_off_topo.svg'])
    
%     end


      