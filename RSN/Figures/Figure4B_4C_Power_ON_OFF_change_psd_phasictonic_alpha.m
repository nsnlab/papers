clear all;
close all;

addpath(genpath('F:\Valeria\m17462\bigdata\matlab\eeglab')); % eeglab toolbox, see README on where to find this
addpath(genpath('F:\Valeria\m17462\bigdata\matlab\Henry\useful_functions')); % contains linspecer function, circular statistics toolbox functions, echt function, shadedErrorBar function, see README on where to find this

load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure2_Figure3A_Figure4A_psd_allsub_mICA_avref_12-Mar-2023.mat');

Savefolder = 'F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figures\';


%%

load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure4A_psd_allsub\statsresult\statsresult_alpha_7-8 Hz.mat');
alpha_cluster_el1 = statsresult.WhichCh_1_max_condition; 
clear statsresult

load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure4A_psd_allsub\statsresult\statsresult_alpha_10-11 Hz.mat');
alpha_cluster_el2 = statsresult.WhichCh_1_max_condition; 
clear statsresult

alpha_cluster_combined = unique([alpha_cluster_el1,alpha_cluster_el2]);

load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure4A_psd_allsub\statsresult\statsresult_theta_7-8 Hz.mat');
theta_cluster_el = statsresult.WhichCh_1_max_condition; 
clear statsresult


conditions = {'Peak'; 'Falling'; 'Trough'; 'Rising';
    'Peak'; 'Falling'; 'Trough'; 'Rising';}

%% Average across on and off blocks and calculate change - alpha cluster

mpsd_con_ch_stage = mpsd_con_ch; % mpsd_con_ch: sub x ch x con x bins x ep

on_block = 7:12;
off_block = 1:6;

ch = alpha_cluster_combined; %[2 34 65 94]; % Fz, AFz, AFF1h, AFF2h

psd_ON_block = squeeze(nanmean(mpsd_con_ch_stage(:,:,:,:,on_block),5)); % average across on block 
psd_OFF_block = squeeze(nanmean(mpsd_con_ch_stage(:,:,:,:,off_block),5));

psd_ON = squeeze(nanmean(psd_ON_block(:,ch,:,:),2)); % average across channels
psd_OFF = squeeze(nanmean(psd_OFF_block(:,ch,:,:),2));

psd_ON_block_phasic = squeeze(nanmean(mpsd_con_ch_phasic(:,:,:,:,on_block),5)); % psd_ON: sub x ch x con x bins
psd_OFF_block_phasic = squeeze(nanmean(mpsd_con_ch_phasic(:,:,:,:,off_block),5));

psd_ON_block_tonic = squeeze(nanmean(mpsd_con_ch_tonic(:,:,:,:,on_block),5)); % psd_ON: sub x ch x con x bins
psd_OFF_block_tonic = squeeze(nanmean(mpsd_con_ch_tonic(:,:,:,:,off_block),5));

psd_ON_phasic = squeeze(nanmean(psd_ON_block_phasic(:,ch,:,:),2));
psd_OFF_phasic = squeeze(nanmean(psd_OFF_block_phasic(:,ch,:,:),2));

psd_ON_tonic = squeeze(nanmean(psd_ON_block_tonic(:,ch,:,:),2));
psd_OFF_tonic = squeeze(nanmean(psd_OFF_block_tonic(:,ch,:,:),2));

psd_ONOFF_change = (psd_ON - psd_OFF)./psd_OFF *100;
log_psd_ONOFF_change = log10(psd_ON./psd_OFF);
log_npsd_ONOFF_change = log_psd_ONOFF_change-nanmean(log_psd_ONOFF_change(:,1:4,:),2);

psd_ONOFF_change_phasic = (psd_ON_phasic - psd_OFF_phasic)./psd_OFF_phasic *100;
log_psd_ONOFF_change_phasic = log10(psd_ON_phasic./psd_OFF_phasic);
log_npsd_ONOFF_change_phasic = log_psd_ONOFF_change_phasic-nanmean(log_psd_ONOFF_change_phasic(:,1:4,:),2);

psd_ONOFF_change_tonic = (psd_ON_tonic - psd_OFF_tonic)./psd_OFF_tonic *100;
log_psd_ONOFF_change_tonic = log10(psd_ON_tonic./psd_OFF_tonic);
log_npsd_ONOFF_change_tonic = log_psd_ONOFF_change_tonic-nanmean(log_psd_ONOFF_change_tonic(:,1:4,:),2);

npsd_ONOFF_change = psd_ONOFF_change-nanmean(psd_ONOFF_change(:,1:4,:),2);

incl_sub = setdiff(1:19,12);
mpsd_ONOFF_change = squeeze(nanmean(psd_ONOFF_change(incl_sub,:,:),1));
sem_psd_ONOFF_change = squeeze(nanstd(psd_ONOFF_change(incl_sub,:,:))./sqrt(size(psd_ONOFF_change(incl_sub,:,:),1)));

m_npsd_ONOFF_change = squeeze(nanmean(npsd_ONOFF_change(incl_sub,:,:),1));
sem_npsd_ONOFF_change = squeeze(nanstd(npsd_ONOFF_change(incl_sub,:,:))./sqrt(size(npsd_ONOFF_change(incl_sub,:,:),1)));

%% Compare On to Off using a t-test

% one sample
for con = 1:size(psd_ON,2)
    
    for b = 1:size(psd_ON,3)
    
    [h(con,b) p_abs(con,b) ci stats] = ttest(log_psd_ONOFF_change(incl_sub,con,b));
    tvalue_abs(con,b) = stats.tstat;
     
    end

end

%% Compare normalized On to Off using a t-test

% one sample
for con = 1:size(psd_ON,2)
    
    for b = 1:size(psd_ON,3)
    
    [h(con,b) p_norm(con,b) ci stats] = ttest(npsd_ONOFF_change(incl_sub,con,b));
    tvalue_norm(con,b) = stats.tstat;
    cohens_d_norm(con,b) = nanmean(psd_ON(incl_sub,con,b)-psd_OFF(incl_sub,con,b))/nanstd(psd_ON(incl_sub,con,b)-psd_OFF(incl_sub,con,b));
    
    end

end

%% Compare conditions using a lme - alpha

clear sub

for s = 1:19
   
    sub{s} = num2str(s);
    
end


for b = 1:size(psd_ONOFF_change,3)
   
    psd_change_phasic_bin = log_psd_ONOFF_change_phasic(incl_sub,:,b);
    psd_change_tonic_bin = log_psd_ONOFF_change_tonic(incl_sub,:,b);

    table_allcon_alpha = [];
    
    for con = 1:4
        
        sub_table = vertcat(sub(incl_sub)',sub(incl_sub)');
        cond = repmat(con,length(incl_sub)*2,1);
        substage = vertcat(repmat(1,length(incl_sub),1),repmat(2,length(incl_sub),1));
        psd_change_bin_con = vertcat(psd_change_phasic_bin(:,con),psd_change_tonic_bin(:,con));
        table_bin_con_alpha = table(sub_table,cond,substage,psd_change_bin_con,'VariableNames',{'sub','condition','substage','power_change'});
        table_allcon_alpha = vertcat(table_allcon_alpha,table_bin_con_alpha);
        
    end
    
    table_allcon_alpha.substage = categorical(table_allcon_alpha.substage);
    table_allcon_alpha.condition = categorical(table_allcon_alpha.condition);
    table_allcon_alpha.sub = categorical(table_allcon_alpha.sub);
    
   lme = fitlme(table_allcon_alpha,'power_change ~ substage * condition + (1|sub)','FitMethod','REML','DummyVarCoding','effects');

   stats = anova(lme);
   p_con_alpha(b) = stats.pValue(2);
   p_substage_alpha(b) = stats.pValue(3);
   p_con_substage_alpha(b) = stats.pValue(4);

    
end

%% Compare conditions using a lme - alpha normalized

clear sub

for s = 1:19
   
    sub{s} = num2str(s);
    
end


for b = 1:size(npsd_ONOFF_change,3)
   
    npsd_change_phasic_bin = log_npsd_ONOFF_change_phasic(incl_sub,:,b);
    npsd_change_tonic_bin = log_npsd_ONOFF_change_tonic(incl_sub,:,b);

    table_allcon_alpha = [];
    
    for con = 1:4
        
        sub_table = vertcat(sub(incl_sub)',sub(incl_sub)');
        cond = repmat(con,length(incl_sub)*2,1);
        substage = vertcat(repmat(1,length(incl_sub),1),repmat(2,length(incl_sub),1));
        npsd_change_bin_con = vertcat(npsd_change_phasic_bin(:,con),npsd_change_tonic_bin(:,con));
        table_bin_con_alpha = table(sub_table,cond,substage,npsd_change_bin_con,'VariableNames',{'sub','condition','substage','power_change'});
        table_allcon_alpha = vertcat(table_allcon_alpha,table_bin_con_alpha);
        
    end
    
    table_allcon_alpha.substage = categorical(table_allcon_alpha.substage);
    table_allcon_alpha.condition = categorical(table_allcon_alpha.condition);
    table_allcon_alpha.sub = categorical(table_allcon_alpha.sub);
    
   lme = fitlme(table_allcon_alpha,'power_change ~ substage * condition + (1|sub)','FitMethod','REML','DummyVarCoding','effects');
   
   stats = anova(lme);
   p_con_alpha_norm(b) = stats.pValue(2);
   p_substage_alpha_norm(b) = stats.pValue(3);
   p_con_substage_alpha_norm(b) = stats.pValue(4);

    
end

%% Plot power spectrum ON-OFF change for Alpha stimulation

% incl_sub = 1:19;

colors = linspecer(4);

fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
for con = 1:4
    
%     shadedErrorBar(f,mpsd_ONOFF_change(con,:),sem_psd_ONOFF_change(con,:),'lineProps',{'Color',colors(con,:),'LineWidth',1},'patchSaturation',.3);
    plot(f,mpsd_ONOFF_change(con,:),'Color',colors(con,:),'LineWidth',7);
    
    hold on
    
    errorbar(15+con/2,0,nanmean(sem_psd_ONOFF_change(con,:),2),'Color',colors(con,:),'LineWidth',3);
   
end


con = 1;
sig_bins_ttest = find(p_abs(con,:) <= 0.05);
plot(f(sig_bins_ttest),ones(length(sig_bins_ttest),1)*-18,'square','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',5);

con = 2;
sig_bins_ttest = find(p_abs(con,:) <= 0.05);
plot(f(sig_bins_ttest),ones(length(sig_bins_ttest),1)*-20,'square','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',5);

con = 3;
sig_bins_ttest = find(p_abs(con,:) <= 0.05);
plot(f(sig_bins_ttest),ones(length(sig_bins_ttest),1)*-22,'square','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',5);

con = 4;
sig_bins_ttest = find(p_abs(con,:) <= 0.05);
plot(f(sig_bins_ttest),ones(length(sig_bins_ttest),1)*-24,'square','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',5);


sig_bins_lme = find(p_con_alpha <= 0.05);
plot(f(sig_bins_lme),ones(length(sig_bins_lme),1)*-28,'square','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',10);


ylim([-30 30])
hold on

xlabel('Frequency (Hz)');
ylabel('Power change (%)');
set(gca,'Fontsize',35,'TickDir','out','LineWidth',3);
xlim([0 18]);
xticks(0:2:18);
yline(0,'LineWidth',2);
yline(-26,'LineWidth',2);
  area([7.5 12.5],[30 30],-130,'FaceColor',[0.5 0.5 0.5],'FaceAlpha',.1,'EdgeColor','none','LineStyle','none')
  xline(7.5,'LineWidth',1,'LineStyle','--')
  xline(12.5,'LineWidth',1,'LineStyle','--')

box off
axis square

% saveas(fig,[Savefolder,'Figure4B_psd_change_alpha_ttest_statsresult_cluster.svg']);

%% Plot normalized power spectrum ON-OFF change for Alpha stimulation

colors = linspecer(4);

fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
% fig.WindowState = 'maximized';

for con = 1:4
    
%     shadedErrorBar(f,mpsd_ONOFF_change(con,:),sem_psd_ONOFF_change(con,:),'lineProps',{'Color',colors(con,:),'LineWidth',1},'patchSaturation',.3);
    plot(f,m_npsd_ONOFF_change(con,:),'Color',colors(con,:),'LineWidth',7);
    
    hold on
    
    errorbar(11.3+con/4,-12,nanmean(sem_npsd_ONOFF_change(con,:),2),'Color',colors(con,:),'LineWidth',3);
   
end


con = 1;
sig_bins_ttest = find(p_norm(con,:) <= 0.05);
plot(f(sig_bins_ttest),ones(length(sig_bins_ttest),1)*-15,'square','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',5);

con = 2;
sig_bins_ttest = find(p_norm(con,:) <= 0.05);
plot(f(sig_bins_ttest),ones(length(sig_bins_ttest),1)*-16,'square','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',5);

con = 3;
sig_bins_ttest = find(p_norm(con,:) <= 0.05);
plot(f(sig_bins_ttest),ones(length(sig_bins_ttest),1)*-17,'square','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',5);

con = 4;
sig_bins_ttest = find(p_norm(con,:) <= 0.05);
plot(f(sig_bins_ttest),ones(length(sig_bins_ttest),1)*-18,'square','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',5);


sig_bins_lme = find(p_con_alpha_norm <= 0.05);
plot(f(sig_bins_lme),ones(length(sig_bins_lme),1)*-20,'square','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',10);


xlim([3.5 13]);
ylim([-21 13])
xticks(4:1:12);

xlabel('Frequency (Hz)');
ylabel('Normalized power change (%)');
set(gca,'Fontsize',35,'TickDir','out','LineWidth',3);
yline(0,'LineWidth',2);
yline(-19,'LineWidth',2);
area([7.5 12.5],[13 13],-21,'FaceColor',[0.5 0.5 0.5],'FaceAlpha',.1,'EdgeColor','none','LineStyle','none')
xline(7.5,'LineWidth',1,'LineStyle','--')
xline(12.5,'LineWidth',1,'LineStyle','--')
xtickangle(0)
set(groot,'defaultAxesXTickLabelRotationMode','manual')

box off
axis square

% saveas(fig,[Savefolder,'Figure4C_npsd_change_alpha_ttest_statsresult_cluster.svg']);

