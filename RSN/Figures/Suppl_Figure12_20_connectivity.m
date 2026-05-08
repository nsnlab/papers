clear all;
close all;

addpath(genpath('F:\Valeria\m17462\bigdata\matlab\eeglab')); % eeglab toolbox, see README on where to find this
addpath(genpath('F:\Valeria\m17462\bigdata\matlab\Henry\useful_functions')); % contains linspecer function, circular statistics toolbox functions, echt function, shadedErrorBar function, see README on where to find this
addpath(genpath('F:\Valeria\m17462\bigdata\matlab\ScientificColourMaps7')); % ScientificColourMaps toolbox, see README on where to find this
addpath(genpath('F:\Valeria\m17462\bigdata\matlab\DataViz'));  % Dataviz toolbox, see README on where to find this


load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Suppl_Figure12_20_connectivity_allsub_07-Dec-2023.mat');
load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\chans.mat');

band_name = {'1-4 Hz' '4-7 Hz' '7-12 Hz' '13-30 Hz' '8-12 Hz'};

conditions = {'Peak'; 'Falling'; 'Trough'; 'Rising';
    'Peak'; 'Falling'; 'Trough'; 'Rising';}

statsresult_folder = 'F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Suppl_Figure12_20_connectivity_allsub\statsresult_sensor\';

Savefolder = 'F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figures\';

%% topoplot layout 

close all

% Computes electrode location

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

%% alphastim lme PLV

for band1 = 3
    
    for band2 = 3

figure('Renderer','painters','units','normalized','outerposition',[0 0 0.5 0.5])

subplot(1,2,1)

PlotChans = [2];
PlotChans3 = [2 34 65 94];

clear statsresult
PlotChans2 = [];

 load([statsresult_folder,'statsresult_alphastim_PLV_frontalseeds_',band_name{band1},'-',band_name{band2},'.mat']);
        
        
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
scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),50,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

hold on
scatter(layout2.pos(PlotChans3,1),layout2.pos(PlotChans3,2),50,[0.6350 0.0780 0.1840],'o','filled','LineWidth',2);


load('lapaz.mat');
colormap(lapaz)
colorbar
set(gca,'FontSize',18);
axis off
axis square
title(['PLV'])  

% saveas(gcf,[Savefolder,'Suppl_Figure11_lme_alphastim_PLV_frontalseeds_',band_name{band1},'-',band_name{band2},'.svg'])

    end

end


%% PLV Alpha stim on vs off (t-test)

incl_sub = setdiff(1:19,12);

colors = linspecer(4);

Y = -.2.*zeros(128,1);


for band1 = 3 

    for band2 = 3 
    
figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
hold on


clear statsresult
PlotChans2 = [];

 load([statsresult_folder,'statsresult_alphastim_PLV_frontalseeds_',band_name{band1},'-',band_name{band2},'.mat']);
        
        
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

   tileplot = tiledlayout(1,4);

for cond = 1:4
    
   nexttile(cond)

    hold on
    %
    ft_plot_topo(layout2.pos(:,1),layout2.pos(:,2),Y,'mask',layout2.mask,'outline',layout2.outline, ...
    'interplim','mask','clim',[-1 1]);
  
ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
colormap(flipud(brewermap(64,'RdBu')))

    
    for seed = [2 34 65 94]
           
    P =0;
    T = 0;
    T2 = 0;
    
    for chan = PlotChans2
        
         x = squeeze(PLV_on.band1{band1}.band2{band2}.cond{cond}(chan,seed,:));
         y = squeeze(PLV_off.band1{band1}.band2{band2}.cond{cond}(chan,seed,:)); 

        change = log10(x./y);
                
        [h,p,ci,stats] = ttest(change(incl_sub));

        if ~isnan(stats.tstat)
            T2 = T2 + stats.tstat;
        end

        if p <=.01
          if ~isnan(stats.tstat)
            T = T+stats.tstat; 
          end
        end
          
    
            if stats.tstat>0 
            
            pl_ = plot([layout2.pos(seed,1) layout2.pos(chan,1)],[layout2.pos(seed,2) layout2.pos(chan,2)],'Color',colors(2,:),'Linewidth',2);%,.5*abs(stats.tstat));
            pl_.Color(4) = .2;
            
            else
                
            pl_ = plot([layout2.pos(seed,1) layout2.pos(chan,1)],[layout2.pos(seed,2) layout2.pos(chan,2)],'Color',colors(1,:),'Linewidth',2);%.5*abs(stats.tstat));
            pl_.Color(4) = .2;
                
            end

        
    end  
    
        scatter(layout2.pos(PlotChans3,1),layout2.pos(PlotChans3,2),50,[0.6350 0.0780 0.1840],'o','filled','LineWidth',2);

 
    Ts.band1{band1}.band2{band2}(seed,cond) = T;
    Ts2.band1{band1}.band2{band2}(seed,cond) = T2;

    end
    
set(gca,'FontSize',18);
axis off
axis square

title([conditions{cond}])
end

tileplot.TileSpacing = 'tight';
tileplot.Padding = 'compact';

% saveas(gcf,[Savefolder,'Suppl_Figure11_ttest_frontalseeds_',band_name{band1},'-',band_name{band2},'allch_alpha_dots_PLV.svg']);

    end

end

clear pl_

%% alphastim lme PLI

for band1 = 3
    
    for band2 = 3

figure('Renderer','painters','units','normalized','outerposition',[0 0 0.5 0.5])

subplot(1,2,1)

PlotChans = [2];
PlotChans3 = [2 34 65 94];

clear statsresult
PlotChans2 = [];

 load([statsresult_folder,'statsresult_alphastim_PLI_frontalseeds_',band_name{band1},'-',band_name{band2},'.mat']);
        
        
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
scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),50,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

hold on
scatter(layout2.pos(PlotChans3,1),layout2.pos(PlotChans3,2),50,[0.6350 0.0780 0.1840],'o','filled','LineWidth',2);

load('lapaz.mat');
colormap(lapaz)
colorbar
set(gca,'FontSize',18);
axis off
axis square
title(['PLI'])  

% saveas(gcf,[Savefolder,'Suppl_Figure11_lme_alphastim_PLI_frontalseeds_',band_name{band1},'-',band_name{band2},'.svg'])

    end

end


%% thetastim lme PLV

for band1 = 2
    
    for band2 = 2

figure('Renderer','painters','units','normalized','outerposition',[0 0 0.5 0.5])

subplot(1,2,1)

PlotChans = [2];
PlotChans3 = [2 34 65 94];

clear statsresult
PlotChans2 = [];

load([statsresult_folder,'statsresult_thetastim_PLV_frontalseeds_',band_name{band1},'-',band_name{band2},'.mat']);
        
        
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
scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),50,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

hold on
scatter(layout2.pos(PlotChans3,1),layout2.pos(PlotChans3,2),50,[0.6350 0.0780 0.1840],'o','filled','LineWidth',2);

load('lapaz.mat');
colormap(lapaz)
colorbar
set(gca,'FontSize',18);
axis off
axis square
title(['PLV'])  

% saveas(gcf,[Savefolder,'Suppl_Figure19_lme_thetastim_PLV_frontalseeds_',band_name{band1},'-',band_name{band2},'.svg'])

    end

end

%% thetastim lme PLI

for band1 = 2
    
    for band2 = 2

figure('Renderer','painters','units','normalized','outerposition',[0 0 0.5 0.5])

subplot(1,2,1)

addpath(genpath('/user/HS301/m17462/matlab/kispi'));
PlotChans = [2];
PlotChans3 = [2 34 65 94];

clear statsresult
PlotChans2 = [];

 load([statsresult_folder,'statsresult_thetastim_PLI_frontalseeds_',band_name{band1},'-',band_name{band2},'.mat']);
        
        
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
scatter(layout2.pos(PlotChans2,1),layout2.pos(PlotChans2,2),50,[0.9098 0.4588 0.4275],'o','filled','LineWidth',2);

hold on
scatter(layout2.pos(PlotChans3,1),layout2.pos(PlotChans3,2),50,[0.6350 0.0780 0.1840],'o','filled','LineWidth',2);

load('lapaz.mat');
colormap(lapaz)
colorbar
set(gca,'FontSize',18);
axis off
axis square
title(['PLI'])  

% saveas(gcf,[Savefolder,'Suppl_Figure19_lme_thetastim_PLI_frontalseeds_',band_name{band1},'-',band_name{band2},'.svg'])

    end

end

%% boxplots alpha-alpha

incl_sub = setdiff(1:19,12);

band1 = 3;
band2 = 3;

clear statsresult
PlotChans2 = [];

load([statsresult_folder,'statsresult_alphastim_PLV_frontalseeds_',band_name{band1},'-',band_name{band2},'.mat']);
        
        
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

      seed = [2 34 65 94];
      chan = PlotChans2;
      
      for cond = 1:4
      
         plv_on(:,cond) = squeeze(nanmean(nanmean(PLV_on.band1{band1}.band2{band2}.cond{cond}(chan,seed,incl_sub),1),2));
         plv_off(:,cond) = squeeze(nanmean(nanmean(PLV_off.band1{band1}.band2{band2}.cond{cond}(chan,seed,incl_sub),1),2));
         
         plv_on_phasic(:,cond) = squeeze(nanmean(nanmean(PLV_on_phasic.band1{band1}.band2{band2}.cond{cond}(chan,seed,incl_sub),1),2));
         plv_off_phasic(:,cond) = squeeze(nanmean(nanmean(PLV_off_phasic.band1{band1}.band2{band2}.cond{cond}(chan,seed,incl_sub),1),2));
         
         plv_on_tonic(:,cond) = squeeze(nanmean(nanmean(PLV_on_tonic.band1{band1}.band2{band2}.cond{cond}(chan,seed,incl_sub),1),2));
         plv_off_tonic(:,cond) = squeeze(nanmean(nanmean(PLV_off_tonic.band1{band1}.band2{band2}.cond{cond}(chan,seed,incl_sub),1),2));
         
      end
      
      plv_change = (plv_on./plv_off-1)*100;
      plv_change_long = plv_change(:);
      
      plv_change_phasic = (plv_on_phasic./plv_off_phasic-1)*100;
      plv_change_long_phasic = plv_change_phasic(:);
      
      plv_change_tonic = (plv_on_tonic./plv_off_tonic-1)*100;
      plv_change_long_tonic = plv_change_tonic(:);
      
      [h p_peak] = ttest(plv_change(:,1))
      [h p_falling] = ttest(plv_change(:,2))
      [h p_trough] = ttest(plv_change(:,3))
      [h p_rising] = ttest(plv_change(:,4))
      

      plv_change_long_groups = horzcat(plv_change_long,plv_change_long);
      group_inx = vertcat(repmat(1,length(incl_sub),1),repmat(2,length(incl_sub),1),repmat(3,length(incl_sub),1),repmat(4,length(incl_sub),1));

     condition_names = {'Alpha' 'Alpha'};
     group_names = {'Peak' 'Falling' 'Trough' 'Rising'};

colors = linspecer(4)

fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
h = daboxplot(plv_change_long_groups,'groups',group_inx,'outliers',1,'outsymbol','kx',...
    'xtlabels', condition_names,'fill',1,'color',colors,...
    'whiskers',1,'boxalpha',0.7);
ylabel('Connectivity change (%)');
xl = xlim; xlim([xl(1), xl(2)+1]);     % make more space for the legend
set(h.md,'LineWidth',1.5); % customize median lines
set(h.ot,'SizeData',50); % customize median lines

set(gca,'Fontsize',35,'TickDir','out','LineWidth',3);
xtickangle(45);
box off
axis square
ylim([-10 10]);

% saveas(gcf,[Savefolder,'Suppl_Figure11_Connectivity_boxplot_alphastim_',band_name{band1},'-',band_name{band2},'.svg']);


for s = 1:19
    sub{s} = num2str(s);
end

sub_table = vertcat(sub(incl_sub)',sub(incl_sub)',sub(incl_sub)',sub(incl_sub)');
cond = vertcat(repmat(1,length(incl_sub),1),repmat(2,length(incl_sub),1),repmat(3,length(incl_sub),1),repmat(4,length(incl_sub),1));
table_allcon_alpha_phasic = table(sub_table,cond,plv_change_long_phasic,'VariableNames',{'sub','condition','connectivity_change'});
table_allcon_alpha_tonic = table(sub_table,cond,plv_change_long_tonic,'VariableNames',{'sub','condition','connectivity_change'});
table_allcon_alpha_phasictonic = vertcat(table_allcon_alpha_phasic,table_allcon_alpha_tonic);
substage = vertcat(repmat(1,length(incl_sub)*4,1),repmat(2,length(incl_sub)*4,1));
table_allcon_alpha_phasictonic.substage = substage;
table_allcon_alpha_phasictonic.substage = categorical(table_allcon_alpha_phasictonic.substage);
table_allcon_alpha_phasictonic.condition = categorical(table_allcon_alpha_phasictonic.condition);
table_allcon_alpha_phasictonic.sub = categorical(table_allcon_alpha_phasictonic.sub);
    
lme = fitlme(table_allcon_alpha_phasictonic,'connectivity_change ~ substage * condition + (1|sub)','FitMethod','REML','DummyVarCoding','effects');
stats = anova(lme);
p_con_alphastim_alpha_alpha = stats.pValue(2);
p_substage_alphastim_alpha_alpha = stats.pValue(3);
p_con_substage_alphastim_alpha_alpha  = stats.pValue(4);

