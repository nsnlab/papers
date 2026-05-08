clear all;
close all;

addpath(genpath('F:\Valeria\m17462\bigdata\matlab\eeglab')); % eeglab toolbox, see README on where to find this
addpath(genpath('F:\Valeria\m17462\bigdata\matlab\Henry\useful_functions')); % contains linspecer function, circular statistics toolbox functions, echt function, shadedErrorBar function, see README on where to find this
addpath(genpath('F:\Valeria\m17462\bigdata\matlab\ScientificColourMaps7')); % ScientificColourMaps toolbox, see README on where to find this
addpath(genpath('F:\Valeria\m17462\bigdata\matlab\DataViz'));  % Dataviz toolbox, see README on where to find this


% load('/parallel_scratch/nemo/RSN/analysis/analysis/frequency_allsub/freqalphatheta_allsub_23-Jan-2024');
% ifq_old = ifq;
% clear ifq

load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure4E_freqalphatheta_allsub_27-May-2024.mat');
% ifq_new = ifq;
% clear ifq

Savefolder = 'F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figures\';

%% Average across on and off blocks and calculate change

on_block = 7:12;
off_block = 1:6;
     
conditions = {'Alpha Phase 0'; 'Alpha Phase 90'; 'Alpha Phase 180'; 'Alpha Phase 270';...
            'Theta Phase 0'; 'Theta Phase 90'; 'Theta Phase 180'; 'Theta Phase 270';};
        
band_name = {'7-12 Hz';'4-7 Hz'};

incl_sub = setdiff(1:19,12);

fs = 500;

colors = linspecer(4);

%%

% load('D:\Valeria\RSN\data\for_sharing\data_to_make_figures\frequency_allsub\statsresult\statsresult_alphastim_alphafreq.mat')
load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure4D_frequency_allsub\statsresult\statsresult_alphastim_alphafreq.mat')
alphastim_alpha_cluster_el = statsresult.WhichCh_1_max_condition; 
clear statsresult

% load('D:\Valeria\RSN\data\for_sharing\data_to_make_figures\frequency_allsub\statsresult\statsresult_alphastim_thetafreq.mat')
load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure4D_frequency_allsub\statsresult\statsresult_alphastim_thetafreq.mat')
alphastim_theta_cluster_el = [statsresult.WhichCh_1_max_condition statsresult.WhichCh_3_max_condition]; 
clear statsresult

% load('D:\Valeria\RSN\data\for_sharing\data_to_make_figures\frequency_allsub\statsresult\statsresult_thetastim_alphafreq.mat')
load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure4D_frequency_allsub\statsresult\statsresult_thetastim_alphafreq.mat')
thetastim_alpha_cluster_el = [statsresult.WhichCh_1_max_condition statsresult.WhichCh_2_max_condition]; 
clear statsresult

% load('D:\Valeria\RSN\data\for_sharing\data_to_make_figures\frequency_allsub\statsresult\statsresult_thetastim_thetafreq.mat')
load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure4D_frequency_allsub\statsresult\statsresult_thetastim_thetafreq.mat')
thetastim_theta_cluster_el = [statsresult.WhichCh_1_max_condition statsresult.WhichCh_2_max_condition]; 
clear statsresult

%% Calculate frequency changes

freq_change_alpha = (ifq.on_ifq_alpha./ifq.off_ifq_alpha-1)*100;
% freq_diff_alpha = ifq.on_ifq_alpha - ifq.off_ifq_alpha;

freq_change_theta = (ifq.on_ifq_theta./ifq.off_ifq_theta-1)*100;
% freq_diff_theta = ifq.on_ifq_theta - ifq.off_ifq_theta;

logfreq_change_alpha = log10(ifq.on_ifq_alpha./ifq.off_ifq_alpha);
logfreq_change_theta = log10(ifq.on_ifq_theta./ifq.off_ifq_theta);

%%

freq_alphastim_alpha_time = squeeze(nanmean(ifq.mifq_trials_alpha(incl_sub,:,alphastim_alpha_cluster_el,:),3)); % sub x con x ch x samps
freq_alphastim_alpha_off = nanmean(freq_alphastim_alpha_time(:,:,1:6*fs),3);

freq_alphastim_theta_time = squeeze(nanmean(ifq.mifq_trials_theta(incl_sub,:,alphastim_theta_cluster_el,:),3)); % sub x con x ch x samps
freq_alphastim_theta_off = nanmean(freq_alphastim_theta_time(:,:,1:6*fs),3);

freq_thetastim_alpha_time = squeeze(nanmean(ifq.mifq_trials_alpha(incl_sub,:,thetastim_alpha_cluster_el,:),3)); % sub x con x ch x samps
freq_thetastim_alpha_off = nanmean(freq_thetastim_alpha_time(:,:,1:6*fs),3);

freq_thetastim_theta_time = squeeze(nanmean(ifq.mifq_trials_theta(incl_sub,:,thetastim_theta_cluster_el,:),3)); % sub x con x ch x samps
freq_thetastim_theta_off = nanmean(freq_thetastim_theta_time(:,:,1:6*fs),3);


freq_alphastim_alpha_time_phasic = squeeze(nanmean(ifq.mifq_trials_alpha_phasic(incl_sub,:,alphastim_alpha_cluster_el,:),3)); % sub x con x ch x samps
freq_alphastim_alpha_off_phasic = nanmean(freq_alphastim_alpha_time_phasic(:,:,1:6*fs),3);

freq_alphastim_theta_time_phasic = squeeze(nanmean(ifq.mifq_trials_theta_phasic(incl_sub,:,alphastim_theta_cluster_el,:),3)); % sub x con x ch x samps
freq_alphastim_theta_off_phasic = nanmean(freq_alphastim_theta_time_phasic(:,:,1:6*fs),3);

freq_thetastim_alpha_time_phasic = squeeze(nanmean(ifq.mifq_trials_alpha_phasic(incl_sub,:,thetastim_alpha_cluster_el,:),3)); % sub x con x ch x samps
freq_thetastim_alpha_off_phasic = nanmean(freq_thetastim_alpha_time_phasic(:,:,1:6*fs),3);

freq_thetastim_theta_time_phasic = squeeze(nanmean(ifq.mifq_trials_theta_phasic(incl_sub,:,thetastim_theta_cluster_el,:),3)); % sub x con x ch x samps
freq_thetastim_theta_off_phasic = nanmean(freq_thetastim_theta_time_phasic(:,:,1:6*fs),3);


freq_alphastim_alpha_time_tonic = squeeze(nanmean(ifq.mifq_trials_alpha_tonic(incl_sub,:,alphastim_alpha_cluster_el,:),3)); % sub x con x ch x samps
freq_alphastim_alpha_off_tonic = nanmean(freq_alphastim_alpha_time_tonic(:,:,1:6*fs),3);

freq_alphastim_theta_time_tonic = squeeze(nanmean(ifq.mifq_trials_theta_tonic(incl_sub,:,alphastim_theta_cluster_el,:),3)); % sub x con x ch x samps
freq_alphastim_theta_off_tonic = nanmean(freq_alphastim_theta_time_tonic(:,:,1:6*fs),3);

freq_thetastim_alpha_time_tonic = squeeze(nanmean(ifq.mifq_trials_alpha_tonic(incl_sub,:,thetastim_alpha_cluster_el,:),3)); % sub x con x ch x samps
freq_thetastim_alpha_off_tonic = nanmean(freq_thetastim_alpha_time_tonic(:,:,1:6*fs),3);

freq_thetastim_theta_time_tonic = squeeze(nanmean(ifq.mifq_trials_theta_tonic(incl_sub,:,thetastim_theta_cluster_el,:),3)); % sub x con x ch x samps
freq_thetastim_theta_off_tonic = nanmean(freq_thetastim_theta_time_tonic(:,:,1:6*fs),3);

for s = 1:length(incl_sub)
    
    for con = 1:8
        
   freq_change_alphastim_alpha_time(s,con,:) = (squeeze(freq_alphastim_alpha_time(s,con,:))/freq_alphastim_alpha_off(s,con)-1)*100;
   freq_change_alphastim_theta_time(s,con,:) = (squeeze(freq_alphastim_theta_time(s,con,:))/freq_alphastim_theta_off(s,con)-1)*100;

   freq_change_thetastim_alpha_time(s,con,:) = (squeeze(freq_thetastim_alpha_time(s,con,:))/freq_thetastim_alpha_off(s,con)-1)*100;
   freq_change_thetastim_theta_time(s,con,:) = (squeeze(freq_thetastim_theta_time(s,con,:))/freq_thetastim_theta_off(s,con)-1)*100;

   log_freq_change_alphastim_alpha_time(s,con,:) = log10(squeeze(freq_alphastim_alpha_time(s,con,:))/freq_alphastim_alpha_off(s,con));
   log_freq_change_alphastim_theta_time(s,con,:) = log10(squeeze(freq_alphastim_theta_time(s,con,:))/freq_alphastim_theta_off(s,con));

   log_freq_change_thetastim_alpha_time(s,con,:) = log10(squeeze(freq_thetastim_alpha_time(s,con,:))/freq_thetastim_alpha_off(s,con));
   log_freq_change_thetastim_theta_time(s,con,:) = log10(squeeze(freq_thetastim_theta_time(s,con,:))/freq_thetastim_theta_off(s,con));

   
   log_freq_change_alphastim_alpha_time_phasic(s,con,:) = log10(squeeze(freq_alphastim_alpha_time_phasic(s,con,:))/freq_alphastim_alpha_off_phasic(s,con));
   log_freq_change_alphastim_theta_time_phasic(s,con,:) = log10(squeeze(freq_alphastim_theta_time_phasic(s,con,:))/freq_alphastim_theta_off_phasic(s,con));

   log_freq_change_thetastim_alpha_time_phasic(s,con,:) = log10(squeeze(freq_thetastim_alpha_time_phasic(s,con,:))/freq_thetastim_alpha_off_phasic(s,con));
   log_freq_change_thetastim_theta_time_phasic(s,con,:) = log10(squeeze(freq_thetastim_theta_time_phasic(s,con,:))/freq_thetastim_theta_off_phasic(s,con));

   
   log_freq_change_alphastim_alpha_time_tonic(s,con,:) = log10(squeeze(freq_alphastim_alpha_time_tonic(s,con,:))/freq_alphastim_alpha_off_tonic(s,con));
   log_freq_change_alphastim_theta_time_tonic(s,con,:) = log10(squeeze(freq_alphastim_theta_time_tonic(s,con,:))/freq_alphastim_theta_off_tonic(s,con));

   log_freq_change_thetastim_alpha_time_tonic(s,con,:) = log10(squeeze(freq_thetastim_alpha_time_tonic(s,con,:))/freq_thetastim_alpha_off_tonic(s,con));
   log_freq_change_thetastim_theta_time_tonic(s,con,:) = log10(squeeze(freq_thetastim_theta_time_tonic(s,con,:))/freq_thetastim_theta_off_tonic(s,con));

   
    end
      
end


%% alphastim - alpha band 

% lme
for s = 1:19
    sub{s} = num2str(s);
end

cluster_el = alphastim_alpha_cluster_el;

ifq_alphaband_ON_cluster = nanmean(squeeze(ifq.on_ifq_alpha(incl_sub,1:4,cluster_el)),3);
ifq_alphaband_OFF_cluster = nanmean(squeeze(ifq.off_ifq_alpha(incl_sub,1:4,cluster_el)),3);
perc_change_cluster_alphastim_alpha = (ifq_alphaband_ON_cluster./ifq_alphaband_OFF_cluster-1)*100;
perc_change_cluster_long_alphastim_alpha = perc_change_cluster_alphastim_alpha(:);
log_perc_change_cluster_alphastim_alpha = log10(ifq_alphaband_ON_cluster./ifq_alphaband_OFF_cluster);
log_perc_change_cluster_long_alphastim_alpha = log_perc_change_cluster_alphastim_alpha(:);

ifq_alphaband_ON_phasic_cluster = nanmean(squeeze(ifq.on_ifq_alpha_phasic(incl_sub,1:4,cluster_el)),3);
ifq_alphaband_OFF_phasic_cluster = nanmean(squeeze(ifq.off_ifq_alpha_phasic(incl_sub,1:4,cluster_el)),3);
perc_change_phasic_cluster = (ifq_alphaband_ON_phasic_cluster./ifq_alphaband_OFF_phasic_cluster-1)*100;
perc_change_phasic_cluster_long = perc_change_phasic_cluster(:);
log_perc_change_phasic_cluster = log10(ifq_alphaband_ON_phasic_cluster./ifq_alphaband_OFF_phasic_cluster);
log_perc_change_phasic_cluster_long = log_perc_change_phasic_cluster(:);

ifq_alphaband_ON_tonic_cluster = nanmean(squeeze(ifq.on_ifq_alpha_tonic(incl_sub,1:4,cluster_el)),3);
ifq_alphaband_OFF_tonic_cluster = nanmean(squeeze(ifq.off_ifq_alpha_tonic(incl_sub,1:4,cluster_el)),3);
perc_change_tonic_cluster = (ifq_alphaband_ON_tonic_cluster./ifq_alphaband_OFF_tonic_cluster-1)*100;
perc_change_tonic_cluster_long = perc_change_tonic_cluster(:);
log_perc_change_tonic_cluster = log10(ifq_alphaband_ON_tonic_cluster./ifq_alphaband_OFF_tonic_cluster);
log_perc_change_tonic_cluster_long = log_perc_change_tonic_cluster(:);


sub_table = vertcat(sub(incl_sub)',sub(incl_sub)',sub(incl_sub)',sub(incl_sub)');
cond = vertcat(repmat(1,length(incl_sub),1),repmat(2,length(incl_sub),1),repmat(3,length(incl_sub),1),repmat(4,length(incl_sub),1));
table_allcon_alpha_phasic = table(sub_table,cond,log_perc_change_phasic_cluster_long,'VariableNames',{'sub','condition','frequency_change'});
table_allcon_alpha_tonic = table(sub_table,cond,log_perc_change_tonic_cluster_long,'VariableNames',{'sub','condition','frequency_change'});
table_allcon_alpha_phasictonic = vertcat(table_allcon_alpha_phasic,table_allcon_alpha_tonic);
substage = vertcat(repmat(1,length(incl_sub)*4,1),repmat(2,length(incl_sub)*4,1));
table_allcon_alpha_phasictonic.substage = substage;
table_allcon_alpha_phasictonic.substage = categorical(table_allcon_alpha_phasictonic.substage);
table_allcon_alpha_phasictonic.condition = categorical(table_allcon_alpha_phasictonic.condition);
table_allcon_alpha_phasictonic.sub = categorical(table_allcon_alpha_phasictonic.sub);
    
lme = fitlme(table_allcon_alpha_phasictonic,'frequency_change ~ substage * condition + (1|sub)','FitMethod','REML','DummyVarCoding','effects');
stats = anova(lme);
p_con_alphastim_alpha = stats.pValue(2);
p_substage_alphastim_alpha = stats.pValue(3);
p_con_substage_alphastim_alpha  = stats.pValue(4);


% t-test
[h p_alphastim_alpha_peak] = ttest(log_perc_change_cluster_alphastim_alpha(:,1))
[h p_alphastim_alpha_falling] = ttest(log_perc_change_cluster_alphastim_alpha(:,2))
[h p_alphastim_alpha_trough] = ttest(log_perc_change_cluster_alphastim_alpha(:,3))
[h p_alphastim_alpha_rising] = ttest(log_perc_change_cluster_alphastim_alpha(:,4))

%% alphastim - theta band 

% lme
for s = 1:19
    sub{s} = num2str(s);
end

cluster_el = alphastim_theta_cluster_el;

ifq_thetaband_ON_cluster = nanmean(squeeze(ifq.on_ifq_theta(incl_sub,1:4,cluster_el)),3);
ifq_thetaband_OFF_cluster = nanmean(squeeze(ifq.off_ifq_theta(incl_sub,1:4,cluster_el)),3);
perc_change_cluster_alphastim_theta = (ifq_thetaband_ON_cluster./ifq_thetaband_OFF_cluster-1)*100;
perc_change_cluster_long_alphastim_theta = perc_change_cluster_alphastim_theta(:);
log_perc_change_cluster_alphastim_theta = log10(ifq_thetaband_ON_cluster./ifq_thetaband_OFF_cluster);
log_perc_change_cluster_long_alphastim_theta = log_perc_change_cluster_alphastim_theta(:);

ifq_thetaband_ON_phasic_cluster = nanmean(squeeze(ifq.on_ifq_theta_phasic(incl_sub,1:4,cluster_el)),3);
ifq_thetaband_OFF_phasic_cluster = nanmean(squeeze(ifq.off_ifq_theta_phasic(incl_sub,1:4,cluster_el)),3);
perc_change_phasic_cluster = (ifq_thetaband_ON_phasic_cluster./ifq_thetaband_OFF_phasic_cluster-1)*100;
perc_change_phasic_cluster_long = perc_change_phasic_cluster(:);
log_perc_change_phasic_cluster = log10(ifq_thetaband_ON_phasic_cluster./ifq_thetaband_OFF_phasic_cluster);
log_perc_change_phasic_cluster_long = log_perc_change_phasic_cluster(:);

ifq_thetaband_ON_tonic_cluster = nanmean(squeeze(ifq.on_ifq_theta_tonic(incl_sub,1:4,cluster_el)),3);
ifq_thetaband_OFF_tonic_cluster = nanmean(squeeze(ifq.off_ifq_theta_tonic(incl_sub,1:4,cluster_el)),3);
perc_change_tonic_cluster = (ifq_thetaband_ON_tonic_cluster./ifq_thetaband_OFF_tonic_cluster-1)*100;
perc_change_tonic_cluster_long = perc_change_tonic_cluster(:);
log_perc_change_tonic_cluster = log10(ifq_thetaband_ON_tonic_cluster./ifq_thetaband_OFF_tonic_cluster);
log_perc_change_tonic_cluster_long = log_perc_change_tonic_cluster(:);


sub_table = vertcat(sub(incl_sub)',sub(incl_sub)',sub(incl_sub)',sub(incl_sub)');
cond = vertcat(repmat(1,length(incl_sub),1),repmat(2,length(incl_sub),1),repmat(3,length(incl_sub),1),repmat(4,length(incl_sub),1));
% psd_change_bin_con = vertcat(psd_change_phasic_bin(:,con),psd_change_tonic_bin(:,con));
table_allcon_alpha_phasic = table(sub_table,cond,log_perc_change_phasic_cluster_long,'VariableNames',{'sub','condition','frequency_change'});
table_allcon_alpha_tonic = table(sub_table,cond,log_perc_change_tonic_cluster_long,'VariableNames',{'sub','condition','frequency_change'});
table_allcon_alpha_phasictonic = vertcat(table_allcon_alpha_phasic,table_allcon_alpha_tonic);
substage = vertcat(repmat(1,length(incl_sub)*4,1),repmat(2,length(incl_sub)*4,1));
table_allcon_alpha_phasictonic.substage = substage;
table_allcon_alpha_phasictonic.substage = categorical(table_allcon_alpha_phasictonic.substage);
table_allcon_alpha_phasictonic.condition = categorical(table_allcon_alpha_phasictonic.condition);
table_allcon_alpha_phasictonic.sub = categorical(table_allcon_alpha_phasictonic.sub);
    
lme = fitlme(table_allcon_alpha_phasictonic,'frequency_change ~ substage * condition + (1|sub)','FitMethod','REML','DummyVarCoding','effects');
stats = anova(lme);
p_con_alphastim_theta = stats.pValue(2);
p_substage_alphastim_theta = stats.pValue(3);
p_con_substage_alphastim_theta  = stats.pValue(4);


% t-test
[h p_alphastim_theta_peak] = ttest(log_perc_change_cluster_alphastim_theta(:,1))
[h p_alphastim_theta_falling] = ttest(log_perc_change_cluster_alphastim_theta(:,2))
[h p_alphastim_theta_trough] = ttest(log_perc_change_cluster_alphastim_theta(:,3))
[h p_alphastim_theta_rising] = ttest(log_perc_change_cluster_alphastim_theta(:,4))

%% alphastim boxplot

perc_change_band_all = horzcat(perc_change_cluster_long_alphastim_theta,perc_change_cluster_long_alphastim_alpha); 

group_inx = vertcat(repmat(1,length(incl_sub),1),repmat(2,length(incl_sub),1),repmat(3,length(incl_sub),1),repmat(4,length(incl_sub),1));

condition_names = {'4-7 Hz' '7-12 Hz'};
group_names = {'Peak' 'Falling' 'Trough' 'Rising'};

colors = linspecer(4)

fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
h = daboxplot(perc_change_band_all,'groups',group_inx,'outliers',1,'outsymbol','kx',...
    'xtlabels', condition_names,'fill',1,'color',colors,...
    'whiskers',1,'boxalpha',0.7);
ylabel('Frequency change (%)');
xl = xlim; xlim([xl(1), xl(2)+1]);     % make more space for the legend
set(h.md,'LineWidth',1.5); % customize median lines
set(h.ot,'SizeData',50); % customize median lines

set(gca,'Fontsize',35,'TickDir','out','LineWidth',3);
xtickangle(45);
box off
axis square
ylim([-3 4]);

% saveas(gcf,[Savefolder,'Figure4E_InstFreq_boxplot_conditions_alphastim','.svg']);

%% thetastim - alpha band 

% lme
for s = 1:19
    sub{s} = num2str(s);
end

cluster_el = thetastim_alpha_cluster_el;

ifq_alphaband_ON_cluster = nanmean(squeeze(ifq.on_ifq_alpha(incl_sub,5:8,cluster_el)),3);
ifq_alphaband_OFF_cluster = nanmean(squeeze(ifq.off_ifq_alpha(incl_sub,5:8,cluster_el)),3);
perc_change_cluster_thetastim_alpha = (ifq_alphaband_ON_cluster./ifq_alphaband_OFF_cluster-1)*100;
perc_change_cluster_long_thetastim_alpha = perc_change_cluster_thetastim_alpha(:);
log_perc_change_cluster_thetastim_alpha = log10(ifq_alphaband_ON_cluster./ifq_alphaband_OFF_cluster);
log_perc_change_cluster_long_thetastim_alpha = log_perc_change_cluster_thetastim_alpha(:);

ifq_alphaband_ON_phasic_cluster = nanmean(squeeze(ifq.on_ifq_alpha_phasic(incl_sub,5:8,cluster_el)),3);
ifq_alphaband_OFF_phasic_cluster = nanmean(squeeze(ifq.off_ifq_alpha_phasic(incl_sub,5:8,cluster_el)),3);
perc_change_phasic_cluster = (ifq_alphaband_ON_phasic_cluster./ifq_alphaband_OFF_phasic_cluster-1)*100;
perc_change_phasic_cluster_long = perc_change_phasic_cluster(:);
log_perc_change_phasic_cluster = log10(ifq_alphaband_ON_phasic_cluster./ifq_alphaband_OFF_phasic_cluster);
log_perc_change_phasic_cluster_long = log_perc_change_phasic_cluster(:);

ifq_alphaband_ON_tonic_cluster = nanmean(squeeze(ifq.on_ifq_alpha_tonic(incl_sub,5:8,cluster_el)),3);
ifq_alphaband_OFF_tonic_cluster = nanmean(squeeze(ifq.off_ifq_alpha_tonic(incl_sub,5:8,cluster_el)),3);
perc_change_tonic_cluster = (ifq_alphaband_ON_tonic_cluster./ifq_alphaband_OFF_tonic_cluster-1)*100;
perc_change_tonic_cluster_long = perc_change_tonic_cluster(:);
log_perc_change_tonic_cluster = log10(ifq_alphaband_ON_tonic_cluster./ifq_alphaband_OFF_tonic_cluster);
log_perc_change_tonic_cluster_long = log_perc_change_tonic_cluster(:);


sub_table = vertcat(sub(incl_sub)',sub(incl_sub)',sub(incl_sub)',sub(incl_sub)');
cond = vertcat(repmat(1,length(incl_sub),1),repmat(2,length(incl_sub),1),repmat(3,length(incl_sub),1),repmat(4,length(incl_sub),1));
table_allcon_theta_phasic = table(sub_table,cond,log_perc_change_phasic_cluster_long,'VariableNames',{'sub','condition','frequency_change'});
table_allcon_theta_tonic = table(sub_table,cond,log_perc_change_tonic_cluster_long,'VariableNames',{'sub','condition','frequency_change'});
table_allcon_theta_phasictonic = vertcat(table_allcon_theta_phasic,table_allcon_theta_tonic);
substage = vertcat(repmat(1,length(incl_sub)*4,1),repmat(2,length(incl_sub)*4,1));
table_allcon_theta_phasictonic.substage = substage;
table_allcon_theta_phasictonic.substage = categorical(table_allcon_theta_phasictonic.substage);
table_allcon_theta_phasictonic.condition = categorical(table_allcon_theta_phasictonic.condition);
table_allcon_theta_phasictonic.sub = categorical(table_allcon_theta_phasictonic.sub);
    
lme = fitlme(table_allcon_theta_phasictonic,'frequency_change ~ substage * condition + (1|sub)','FitMethod','REML','DummyVarCoding','effects');
stats = anova(lme);
p_con_thetastim_alpha = stats.pValue(2);
p_substage_thetastim_alpha = stats.pValue(3);
p_con_substage_thetastim_alpha  = stats.pValue(4);


% t-test
[h p_thetastim_alpha_peak] = ttest(log_perc_change_cluster_thetastim_alpha(:,1))
[h p_thetastim_alpha_falling] = ttest(log_perc_change_cluster_thetastim_alpha(:,2))
[h p_thetastim_alpha_trough] = ttest(log_perc_change_cluster_thetastim_alpha(:,3))
[h p_thetastim_alpha_rising] = ttest(log_perc_change_cluster_thetastim_alpha(:,4))

%% thetastim - theta band 

% lme
for s = 1:19
    sub{s} = num2str(s);
end

cluster_el = thetastim_theta_cluster_el;

ifq_thetaband_ON_cluster = nanmean(squeeze(ifq.on_ifq_theta(incl_sub,5:8,cluster_el)),3);
ifq_thetaband_OFF_cluster = nanmean(squeeze(ifq.off_ifq_theta(incl_sub,5:8,cluster_el)),3);
perc_change_cluster_thetastim_theta = (ifq_thetaband_ON_cluster./ifq_thetaband_OFF_cluster-1)*100;
perc_change_cluster_long_thetastim_theta = perc_change_cluster_thetastim_theta(:);
log_perc_change_cluster_thetastim_theta = log10(ifq_thetaband_ON_cluster./ifq_thetaband_OFF_cluster);
log_perc_change_cluster_long_thetastim_theta = log_perc_change_cluster_thetastim_theta(:);

ifq_thetaband_ON_phasic_cluster = nanmean(squeeze(ifq.on_ifq_theta_phasic(incl_sub,5:8,cluster_el)),3);
ifq_thetaband_OFF_phasic_cluster = nanmean(squeeze(ifq.off_ifq_theta_phasic(incl_sub,5:8,cluster_el)),3);
perc_change_phasic_cluster = (ifq_thetaband_ON_phasic_cluster./ifq_thetaband_OFF_phasic_cluster-1)*100;
perc_change_phasic_cluster_long = perc_change_phasic_cluster(:);
log_perc_change_phasic_cluster = log10(ifq_thetaband_ON_phasic_cluster./ifq_thetaband_OFF_phasic_cluster);
log_perc_change_phasic_cluster_long = log_perc_change_phasic_cluster(:);

ifq_thetaband_ON_tonic_cluster = nanmean(squeeze(ifq.on_ifq_theta_tonic(incl_sub,5:8,cluster_el)),3);
ifq_thetaband_OFF_tonic_cluster = nanmean(squeeze(ifq.off_ifq_theta_tonic(incl_sub,5:8,cluster_el)),3);
perc_change_tonic_cluster = (ifq_thetaband_ON_tonic_cluster./ifq_thetaband_OFF_tonic_cluster-1)*100;
perc_change_tonic_cluster_long = perc_change_tonic_cluster(:);
log_perc_change_tonic_cluster = log10(ifq_thetaband_ON_tonic_cluster./ifq_thetaband_OFF_tonic_cluster);
log_perc_change_tonic_cluster_long = log_perc_change_tonic_cluster(:);


sub_table = vertcat(sub(incl_sub)',sub(incl_sub)',sub(incl_sub)',sub(incl_sub)');
cond = vertcat(repmat(1,length(incl_sub),1),repmat(2,length(incl_sub),1),repmat(3,length(incl_sub),1),repmat(4,length(incl_sub),1));
table_allcon_theta_phasic = table(sub_table,cond,log_perc_change_phasic_cluster_long,'VariableNames',{'sub','condition','frequency_change'});
table_allcon_theta_tonic = table(sub_table,cond,log_perc_change_tonic_cluster_long,'VariableNames',{'sub','condition','frequency_change'});
table_allcon_theta_phasictonic = vertcat(table_allcon_theta_phasic,table_allcon_theta_tonic);
substage = vertcat(repmat(1,length(incl_sub)*4,1),repmat(2,length(incl_sub)*4,1));
table_allcon_theta_phasictonic.substage = substage;
table_allcon_theta_phasictonic.substage = categorical(table_allcon_theta_phasictonic.substage);
table_allcon_theta_phasictonic.condition = categorical(table_allcon_theta_phasictonic.condition);
table_allcon_theta_phasictonic.sub = categorical(table_allcon_theta_phasictonic.sub);
    
lme = fitlme(table_allcon_theta_phasictonic,'frequency_change ~ substage * condition + (1|sub)','FitMethod','REML','DummyVarCoding','effects');
stats = anova(lme);
p_con_thetastim_theta = stats.pValue(2);
p_substage_thetastim_theta = stats.pValue(3);
p_con_substage_thetastim_theta  = stats.pValue(4);


% t-test
[h p_thetastim_theta_peak] = ttest(log_perc_change_cluster_thetastim_theta(:,1))
[h p_thetastim_theta_falling] = ttest(log_perc_change_cluster_thetastim_theta(:,2))
[h p_thetastim_theta_trough] = ttest(log_perc_change_cluster_thetastim_theta(:,3))
[h p_thetastim_theta_rising] = ttest(log_perc_change_cluster_thetastim_theta(:,4))

%% thetastim boxplot

perc_change_band_all = horzcat(perc_change_cluster_long_thetastim_theta,perc_change_cluster_long_thetastim_alpha); 

group_inx = vertcat(repmat(1,length(incl_sub),1),repmat(2,length(incl_sub),1),repmat(3,length(incl_sub),1),repmat(4,length(incl_sub),1));

condition_names = {'4-7 Hz' '7-12 Hz'};
group_names = {'Peak' 'Falling' 'Trough' 'Rising'};

colors = linspecer(4)

fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
h = daboxplot(perc_change_band_all,'groups',group_inx,'outliers',1,'outsymbol','kx',...
    'xtlabels', condition_names,'fill',1,'color',colors,...
    'whiskers',1,'boxalpha',0.7);
ylabel('Frequency change (%)');
xl = xlim; xlim([xl(1), xl(2)+1]);     % make more space for the legend
set(h.md,'LineWidth',1.5); % customize median lines
set(h.ot,'SizeData',50); % customize median lines

set(gca,'Fontsize',35,'TickDir','out','LineWidth',3);
xtickangle(45);
box off
axis square
ylim([-3 4]);

% saveas(gcf,[Savefolder,'Figure4K_InstFreq_boxplot_conditions_thetastim','.svg']);

%% Time course - Alphastim - alpha freq - Compare conditions using a lme - OFF to ON

movmean_samp = 500;
movmean_samp2 = 500;

freq_change_smoothed_alphastim_alpha = movmean(freq_change_alphastim_alpha_time,[movmean_samp movmean_samp2],3); % smooth across 2 s before (and 1 samp after)
log_freq_change_smoothed_phasic = movmean(log_freq_change_alphastim_alpha_time_phasic,[movmean_samp movmean_samp2],3);
log_freq_change_smoothed_tonic = movmean(log_freq_change_alphastim_alpha_time_tonic,[movmean_samp movmean_samp2],3);

clear sub p_con_alphastim_alpha

sub = 1:18;

for samp = 1:size(freq_change_smoothed_alphastim_alpha,3)
   
    freq_change_phasic_samp = log_freq_change_smoothed_phasic(:,:,samp);
    freq_change_tonic_samp = log_freq_change_smoothed_tonic(:,:,samp);

    table_allcon_alphastim_alpha = [];
    
    for con = 1:4
        
        sub_table = vertcat(sub',sub');
        cond = repmat(con,length(sub)*2,1);
        substage = vertcat(repmat(1,length(sub),1),repmat(2,length(sub),1));
        freq_change_samp_con = vertcat(freq_change_phasic_samp(:,con),freq_change_tonic_samp(:,con));
        table_samp_con_alpha = table(sub_table,cond,substage,freq_change_samp_con,'VariableNames',{'sub','condition','substage','freq_change'});
        table_allcon_alphastim_alpha = vertcat(table_allcon_alphastim_alpha,table_samp_con_alpha);
        
    end
    
    table_allcon_alphastim_alpha.substage = categorical(table_allcon_alphastim_alpha.substage);
    table_allcon_alphastim_alpha.condition = categorical(table_allcon_alphastim_alpha.condition);
    table_allcon_alphastim_alpha.sub = categorical(table_allcon_alphastim_alpha.sub);
    
   lme = fitlme(table_allcon_alphastim_alpha,'freq_change ~ substage * condition + (1|sub)','FitMethod','REML','DummyVarCoding','effects');

   stats = anova(lme);
   p_con_alphastim_alpha(samp) = stats.pValue(2);
   p_substage_alphastim_alpha(samp) = stats.pValue(3);
   p_con_substage_alphastim_alpha(samp) = stats.pValue(4);

    
end


%% Alphastim - alpha freq - one-sampe t-tests - OFF to ON

clear p_alphastim_alpha p_alphastim_alpha_peak_trough p_alphastim_alpha_falling_rising
for con = 1:4
    
  for samp = 1:size(freq_change_smoothed_alphastim_alpha(:,con,:),3)
    
  [h p_alphastim_alpha(con,samp)] =  ttest(freq_change_smoothed_alphastim_alpha(:,con,samp));
  
  end
  
end

for samp = 1:size(freq_change_smoothed_alphastim_alpha,3)
    
  [h p_alphastim_alpha_peak_trough(samp)] =  ttest(freq_change_smoothed_alphastim_alpha(:,1,samp),freq_change_smoothed_alphastim_alpha(:,3,samp));
  
end

for samp = 1:size(freq_change_smoothed_alphastim_alpha,3)
    
  [h p_alphastim_alpha_falling_rising(samp)] =  ttest(freq_change_smoothed_alphastim_alpha(:,2,samp),freq_change_smoothed_alphastim_alpha(:,4,samp));
  
end


%% Alphastim - alpha freq - Time course plot - OFF to ON

fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])

for con = 1:4
m_freq_change_alphastim_alpha_time_con = nanmean(freq_change_smoothed_alphastim_alpha(:,con,:),1);
sem_freq_change_alphastim_alpha_time_con = nanstd(freq_change_smoothed_alphastim_alpha(:,con,:),1)./sqrt(size(freq_change_smoothed_alphastim_alpha,1));

% shadedErrorBar([1:6000],m_freq_change_alphastim_alpha_time_con,sem_freq_change_alphastim_alpha_time_con,'lineProps',{'Color',colors(con,:),'LineWidth',1},'patchSaturation',.3);
plot([1:9000],squeeze(m_freq_change_alphastim_alpha_time_con),'Color',colors(con,:),'LineWidth',7);
hold on
errorbar(7500+con*250/2,-0.5,nanmean(squeeze(sem_freq_change_alphastim_alpha_time_con)),'Color',colors(con,:),'LineWidth',3);
hold on

end


con = 1;
sig_samps = find(p_alphastim_alpha(con,:) < 0.05);
plot(sig_samps,ones(length(sig_samps),1,1)*-0.9,'square','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',5);
hold on

con = 2;
sig_samps = find(p_alphastim_alpha(con,:) < 0.05);
plot(sig_samps,ones(length(sig_samps),1,1)*-1,'square','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',5);
hold on

con = 3;
sig_samps = find(p_alphastim_alpha(con,:) < 0.05);
plot(sig_samps,ones(length(sig_samps),1,1)*-1.1,'square','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',5);
hold on

con = 4;
sig_samps = find(p_alphastim_alpha(con,:) < 0.05);
plot(sig_samps,ones(length(sig_samps),1,1)*-1.2,'square','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',5);
hold on

sig_samps_lme = find(p_con_alphastim_alpha < 0.05);
plot(sig_samps_lme,ones(length(sig_samps_lme),1)*-1.4,'square','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',10);


xlim([501 8500]);
xline(2500,'LineStyle','--','LineWidth',2);
xline(3000,'LineStyle','-','LineWidth',2);
xline(6000,'LineStyle','-','LineWidth',2);
xline(6500,'LineStyle','--','LineWidth',2);
area([3000 6000],[1.5 1.5],-1.5,'FaceColor',[0.5 0.5 0.5],'FaceAlpha',.1,'EdgeColor','none','LineStyle','none')
ylim([-1.5 1.5]);
xticks(1:1000:9000);
xticklabels(0:2:18);
xlabel('Time (s)');
ylabel('Frequency change (%)');
set(gca,'Fontsize',35,'TickDir','out','LineWidth',3);
box off
axis square
yline(-1.3,'LineWidth',2);
title('7-12 Hz');

% saveas(fig,[Savefolder,'Figure4F_alphastim_alpha_frequency_change_time.png']);


%% Time course - Alphastim - theta freq - Compare conditions using a lme 

movmean_samp = 500;
movmean_samp2 = 500;

freq_change_smoothed_alphastim_theta = movmean(freq_change_alphastim_theta_time,[movmean_samp movmean_samp2],3); % smooth across 2 s before (and 1 samp after)
log_freq_change_smoothed_phasic = movmean(log_freq_change_alphastim_theta_time_phasic,[movmean_samp movmean_samp2],3);
log_freq_change_smoothed_tonic = movmean(log_freq_change_alphastim_theta_time_tonic,[movmean_samp movmean_samp2],3);

clear sub p_con_alphastim_theta

sub = 1:18;

for samp = 1:size(freq_change_smoothed_alphastim_theta,3)
   
    freq_change_phasic_samp = log_freq_change_smoothed_phasic(:,:,samp);
    freq_change_tonic_samp = log_freq_change_smoothed_tonic(:,:,samp);

    table_allcon_alphastim_theta = [];
    
    for con = 1:4
        
        sub_table = vertcat(sub',sub');
        cond = repmat(con,length(sub)*2,1);
        substage = vertcat(repmat(1,length(sub),1),repmat(2,length(sub),1));
        freq_change_samp_con = vertcat(freq_change_phasic_samp(:,con),freq_change_tonic_samp(:,con));
        table_samp_con_alpha = table(sub_table,cond,substage,freq_change_samp_con,'VariableNames',{'sub','condition','substage','freq_change'});
        table_allcon_alphastim_theta = vertcat(table_allcon_alphastim_theta,table_samp_con_alpha);
        
    end
    
    table_allcon_alphastim_theta.substage = categorical(table_allcon_alphastim_theta.substage);
    table_allcon_alphastim_theta.condition = categorical(table_allcon_alphastim_theta.condition);
    table_allcon_alphastim_theta.sub = categorical(table_allcon_alphastim_theta.sub);
    
   lme = fitlme(table_allcon_alphastim_theta,'freq_change ~ substage * condition + (1|sub)','FitMethod','REML','DummyVarCoding','effects');

   stats = anova(lme);
   p_con_alphastim_theta(samp) = stats.pValue(2);
   p_substage_alphastim_theta(samp) = stats.pValue(3);
   p_con_substage_alphastim_theta(samp) = stats.pValue(4);

    
end


%% Alphastim - theta freq - one-sampe t-tests

clear p_alphastim_theta p_alphastim_theta_peak_trough p_alphastim_theta_falling_rising
for con = 1:4
    
  for samp = 1:size(freq_change_smoothed_alphastim_theta(:,con,:),3)
    
  [h p_alphastim_theta(con,samp)] =  ttest(freq_change_smoothed_alphastim_theta(:,con,samp));
  
  end
  
end

for samp = 1:size(freq_change_smoothed_alphastim_theta,3)
    
  [h p_alphastim_theta_peak_trough(samp)] =  ttest(freq_change_smoothed_alphastim_theta(:,1,samp),freq_change_smoothed_alphastim_theta(:,3,samp));
  
end

for samp = 1:size(freq_change_smoothed_alphastim_theta,3)
    
  [h p_alphastim_theta_falling_rising(samp)] =  ttest(freq_change_smoothed_alphastim_theta(:,2,samp),freq_change_smoothed_alphastim_theta(:,4,samp));
  
end


%% Alphastim - theta freq - Time course plot

fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])

for con = 1:4
m_freq_change_alphastim_theta_time_con = nanmean(freq_change_smoothed_alphastim_theta(:,con,:),1);
sem_freq_change_alphastim_theta_time_con = nanstd(freq_change_smoothed_alphastim_theta(:,con,:),1)./sqrt(size(freq_change_smoothed_alphastim_theta,1));

% shadedErrorBar([1:6000],m_freq_change_alphastim_theta_time_con,sem_freq_change_alphastim_theta_time_con,'lineProps',{'Color',colors(con,:),'LineWidth',1},'patchSaturation',.3);
plot([1:9000],squeeze(m_freq_change_alphastim_theta_time_con),'Color',colors(con,:),'LineWidth',7);
hold on
errorbar(7500+con*250/2,-0.8,nanmean(squeeze(sem_freq_change_alphastim_theta_time_con)),'Color',colors(con,:),'LineWidth',3);
hold on

end


con = 1;
sig_samps = find(p_alphastim_theta(con,:) < 0.05);
plot(sig_samps,ones(length(sig_samps),1,1)*-1.2,'square','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',5);
hold on

con = 2;
sig_samps = find(p_alphastim_theta(con,:) < 0.05);
plot(sig_samps,ones(length(sig_samps),1,1)*-1.3,'square','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',5);
hold on

con = 3;
sig_samps = find(p_alphastim_theta(con,:) < 0.05);
plot(sig_samps,ones(length(sig_samps),1,1)*-1.4,'square','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',5);
hold on

con = 4;
sig_samps = find(p_alphastim_theta(con,:) < 0.05);
plot(sig_samps,ones(length(sig_samps),1,1)*-1.5,'square','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',5);
hold on

sig_samps_lme = find(p_con_alphastim_theta <= 0.05);
plot(sig_samps_lme,ones(length(sig_samps_lme),1)*-1.7,'square','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',10);


xlim([501 8500]);
xline(2500,'LineStyle','--','LineWidth',2);
xline(3000,'LineStyle','-','LineWidth',2);
xline(6000,'LineStyle','-','LineWidth',2);
xline(6500,'LineStyle','--','LineWidth',2);
area([3000 6000],[2.5 2.5],-1.8,'FaceColor',[0.5 0.5 0.5],'FaceAlpha',.1,'EdgeColor','none','LineStyle','none')
ylim([-1.8 2.5]);
xticks(1:1000:9000);
xticklabels(0:2:18);
xlabel('Time (s)');
ylabel('Frequency change (%)');
set(gca,'Fontsize',35,'TickDir','out','LineWidth',3);
box off
axis square
yline(-1.6,'LineWidth',2);
title('4-7 Hz');


% saveas(fig,[Savefolder,'Figure4F_alphastim_theta_frequency_change_time.svg']);
% saveas(fig,[Savefolder,'Figure4F_alphastim_theta_frequency_change_time.png']);


%% Time course - Thetastim - alpha freq - Compare conditions using a lme 

movmean_samp = 500;
movmean_samp2 = 500;

freq_change_smoothed_thetastim_alpha = movmean(freq_change_thetastim_alpha_time,[movmean_samp movmean_samp2],3); % smooth across 2 s before (and 1 samp after)
log_freq_change_smoothed_phasic = movmean(log_freq_change_thetastim_alpha_time_phasic,[movmean_samp movmean_samp2],3);
log_freq_change_smoothed_tonic = movmean(log_freq_change_thetastim_alpha_time_tonic,[movmean_samp movmean_samp2],3);

clear sub p_con_thetastim_alpha

sub = 1:18;

for samp = 1:size(freq_change_smoothed_thetastim_alpha,3)
   
    freq_change_phasic_samp = log_freq_change_smoothed_phasic(:,:,samp);
    freq_change_tonic_samp = log_freq_change_smoothed_tonic(:,:,samp);

    table_allcon_thetastim_alpha = [];
    
    for con = 5:8
        
        sub_table = vertcat(sub',sub');
        cond = repmat(con,length(sub)*2,1);
        substage = vertcat(repmat(1,length(sub),1),repmat(2,length(sub),1));
        freq_change_samp_con = vertcat(freq_change_phasic_samp(:,con),freq_change_tonic_samp(:,con));
        table_samp_con_alpha = table(sub_table,cond,substage,freq_change_samp_con,'VariableNames',{'sub','condition','substage','freq_change'});
        table_allcon_thetastim_alpha = vertcat(table_allcon_thetastim_alpha,table_samp_con_alpha);
        
    end
    
    table_allcon_thetastim_alpha.substage = categorical(table_allcon_thetastim_alpha.substage);
    table_allcon_thetastim_alpha.condition = categorical(table_allcon_thetastim_alpha.condition);
    table_allcon_thetastim_alpha.sub = categorical(table_allcon_thetastim_alpha.sub);
    
   lme = fitlme(table_allcon_thetastim_alpha,'freq_change ~ substage * condition + (1|sub)','FitMethod','REML','DummyVarCoding','effects');

   stats = anova(lme);
   p_con_thetastim_alpha(samp) = stats.pValue(2);
   p_substage_thetastim_alpha(samp) = stats.pValue(3);
   p_con_substage_thetastim_alpha(samp) = stats.pValue(4);

end

%% Thetastim - alpha freq - one-sampe t-tests

clear p_thetastim_alpha p_thetastim_alpha_peak_trough p_thetastim_alpha_falling_rising
for con = 5:8
    
  for samp = 1:size(freq_change_smoothed_thetastim_alpha(:,con,:),3)
    
  [h p_thetastim_alpha(con,samp)] =  ttest(freq_change_smoothed_thetastim_alpha(:,con,samp));
  
  end
  
end

for samp = 1:size(freq_change_smoothed_thetastim_alpha,3)
    
  [h p_thetastim_alpha_peak_trough(samp)] =  ttest(freq_change_smoothed_thetastim_alpha(:,5,samp),freq_change_smoothed_thetastim_alpha(:,7,samp));
  
end

for samp = 1:size(freq_change_smoothed_thetastim_alpha,3)
    
  [h p_thetastim_alpha_falling_rising(samp)] =  ttest(freq_change_smoothed_thetastim_alpha(:,6,samp),freq_change_smoothed_thetastim_alpha(:,8,samp));
  
end


%% Thetastim - alpha freq - Time course plot

fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])


for con = 5:8
m_freq_change_thetastim_alpha_time_con = nanmean(freq_change_smoothed_thetastim_alpha(:,con,:),1);
sem_freq_change_thetastim_alpha_time_con = nanstd(freq_change_smoothed_thetastim_alpha(:,con,:),1)./sqrt(size(freq_change_smoothed_thetastim_alpha,1));

% shadedErrorBar([1:6000],m_freq_change_thetastim_alpha_time_con,sem_freq_change_thetastim_alpha_time_con,'lineProps',{'Color',colors(con-4,:),'LineWidth',1},'patchSaturation',.3);
plot([1:9000],squeeze(m_freq_change_thetastim_alpha_time_con),'Color',colors(con-4,:),'LineWidth',7);
hold on
errorbar(7500+(con-4)*250/2,-0.6,nanmean(squeeze(sem_freq_change_thetastim_alpha_time_con)),'Color',colors(con-4,:),'LineWidth',3);
hold on

end


con = 5;
sig_samps = find(p_thetastim_alpha(con,:) < 0.05);
plot(sig_samps,ones(length(sig_samps),1,1)*-0.9,'square','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',5);
hold on

con = 6;
sig_samps = find(p_thetastim_alpha(con,:) < 0.05);
plot(sig_samps,ones(length(sig_samps),1,1)*-1,'square','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',5);
hold on

con = 7;
sig_samps = find(p_thetastim_alpha(con,:) < 0.05);
plot(sig_samps,ones(length(sig_samps),1,1)*-1.1,'square','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',5);
hold on

con = 8;
sig_samps = find(p_thetastim_alpha(con,:) < 0.05);
plot(sig_samps,ones(length(sig_samps),1,1)*-1.2,'square','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',5);
hold on

sig_samps_lme = find(p_con_thetastim_alpha <= 0.05);
plot(sig_samps_lme,ones(length(sig_samps_lme),1)*-1.4,'square','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',10);

xlim([501 8500]);
xline(2500,'LineStyle','--','LineWidth',2);
xline(3000,'LineStyle','-','LineWidth',2);
xline(6000,'LineStyle','-','LineWidth',2);
xline(6500,'LineStyle','--','LineWidth',2);
area([3000 6000],[1.5 1.5],-1.5,'FaceColor',[0.5 0.5 0.5],'FaceAlpha',.1,'EdgeColor','none','LineStyle','none')
ylim([-1.5 1.5]);
xticks(1:1000:9000);
xticklabels(0:2:18);
xlabel('Time (s)');
ylabel('Frequency change (%)');
set(gca,'Fontsize',35,'TickDir','out','LineWidth',3);
box off
axis square
yline(-1.3,'LineWidth',2);
title('7-12 Hz');


% saveas(fig,[Savefolder,'Figure4L_thetastim_alpha_frequency_change_time.svg']);
% saveas(fig,[Savefolder,'Figure4L_thetastim_alpha_frequency_change_time.png']);


%% Time course - Thetastim - theta freq - Compare conditions using a lme 

movmean_samp = 500;
movmean_samp2 = 500;

freq_change_smoothed_thetastim_theta = movmean(freq_change_thetastim_theta_time,[movmean_samp movmean_samp2],3); % smooth across 2 s before (and 1 samp after)
log_freq_change_smoothed_phasic = movmean(log_freq_change_thetastim_theta_time_phasic,[movmean_samp movmean_samp2],3);
log_freq_change_smoothed_tonic = movmean(log_freq_change_thetastim_theta_time_tonic,[movmean_samp movmean_samp2],3);

clear sub p_con_thetastim_theta

sub = 1:18;

for samp = 1:size(freq_change_smoothed_thetastim_theta,3)
   
    freq_change_phasic_samp = log_freq_change_smoothed_phasic(:,:,samp);
    freq_change_tonic_samp = log_freq_change_smoothed_tonic(:,:,samp);

    table_allcon_thetastim_theta = [];
    
    for con = 5:8
        
        sub_table = vertcat(sub',sub');
        cond = repmat(con,length(sub)*2,1);
        substage = vertcat(repmat(1,length(sub),1),repmat(2,length(sub),1));
        freq_change_samp_con = vertcat(freq_change_phasic_samp(:,con),freq_change_tonic_samp(:,con));
        table_samp_con_alpha = table(sub_table,cond,substage,freq_change_samp_con,'VariableNames',{'sub','condition','substage','freq_change'});
        table_allcon_thetastim_theta = vertcat(table_allcon_thetastim_theta,table_samp_con_alpha);
        
    end
    
    table_allcon_thetastim_theta.substage = categorical(table_allcon_thetastim_theta.substage);
    table_allcon_thetastim_theta.condition = categorical(table_allcon_thetastim_theta.condition);
    table_allcon_thetastim_theta.sub = categorical(table_allcon_thetastim_theta.sub);
    
   lme = fitlme(table_allcon_thetastim_theta,'freq_change ~ substage * condition + (1|sub)','FitMethod','REML','DummyVarCoding','effects');

   stats = anova(lme);
   p_con_thetastim_theta(samp) = stats.pValue(2);
   p_substage_thetastim_theta(samp) = stats.pValue(3);
   p_con_substage_thetastim_theta(samp) = stats.pValue(4);

end


%% Thetastim - theta freq - one-sampe t-tests

clear p_thetastim_theta p_thetastim_theta_peak_trough p_thetastim_theta_falling_rising
for con = 5:8
    
  for samp = 1:size(freq_change_smoothed_thetastim_theta(:,con,:),3)
    
  [h p_thetastim_theta(con,samp)] =  ttest(freq_change_smoothed_thetastim_theta(:,con,samp));
  
  end
  
end

for samp = 1:size(freq_change_smoothed_thetastim_theta,3)
    
  [h p_thetastim_theta_peak_trough(samp)] =  ttest(freq_change_smoothed_thetastim_theta(:,5,samp),freq_change_smoothed_thetastim_theta(:,7,samp));
  
end

for samp = 1:size(freq_change_smoothed_thetastim_theta,3)
    
  [h p_thetastim_theta_falling_rising(samp)] =  ttest(freq_change_smoothed_thetastim_theta(:,6,samp),freq_change_smoothed_thetastim_theta(:,8,samp));
  
end


%% Thetastim - theta freq - Time course plot

fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])

for con = 5:8
m_freq_change_thetastim_theta_time_con = nanmean(freq_change_smoothed_thetastim_theta(:,con,:),1);
sem_freq_change_thetastim_theta_time_con = nanstd(freq_change_smoothed_thetastim_theta(:,con,:),1)./sqrt(size(freq_change_smoothed_thetastim_theta,1));

% shadedErrorBar([1:6000],m_freq_change_thetastim_theta_time_con,sem_freq_change_thetastim_theta_time_con,'lineProps',{'Color',colors(con-4,:),'LineWidth',1},'patchSaturation',.3);
plot([1:9000],squeeze(m_freq_change_thetastim_theta_time_con),'Color',colors(con-4,:),'LineWidth',7);
hold on
errorbar(7500+(con-4)*250/2,-0.6,nanmean(squeeze(sem_freq_change_thetastim_theta_time_con)),'Color',colors(con-4,:),'LineWidth',3);
hold on

end


con = 5;
sig_samps = find(p_thetastim_theta(con,:) < 0.05);
plot(sig_samps,ones(length(sig_samps),1,1)*-0.9,'square','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',5);
hold on

con = 6;
sig_samps = find(p_thetastim_theta(con,:) < 0.05);
plot(sig_samps,ones(length(sig_samps),1,1)*-1,'square','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',5);
hold on

con = 7;
sig_samps = find(p_thetastim_theta(con,:) < 0.05);
plot(sig_samps,ones(length(sig_samps),1,1)*-1.1,'square','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',5);
hold on

con = 8;
sig_samps = find(p_thetastim_theta(con,:) < 0.05);
plot(sig_samps,ones(length(sig_samps),1,1)*-1.2,'square','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',5);
hold on

sig_samps_lme = find(p_con_thetastim_theta <= 0.05);
plot(sig_samps_lme,ones(length(sig_samps_lme),1)*-1.4,'square','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',10);

xlim([501 8500]);
xline(2500,'LineStyle','--','LineWidth',2);
xline(3000,'LineStyle','-','LineWidth',2);
xline(6000,'LineStyle','-','LineWidth',2);
xline(6500,'LineStyle','--','LineWidth',2);
area([3000 6000],[1.5 1.5],-1.5,'FaceColor',[0.5 0.5 0.5],'FaceAlpha',.1,'EdgeColor','none','LineStyle','none')
ylim([-1.5 1.5]);
xticks(1:1000:9000);
xticklabels(0:2:18);
xlabel('Time (s)');
ylabel('Frequency change (%)');
set(gca,'Fontsize',35,'TickDir','out','LineWidth',3);
box off
axis square
yline(-1.3,'LineWidth',2);
title('4-7 Hz');

% saveas(fig,[Savefolder,'Figure4L_thetastim_theta_frequency_change_time.svg']);
% saveas(fig,[Savefolder,'Figure4L_thetastim_theta_frequency_change_time.png']);






