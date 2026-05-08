clear all;
close all;

addpath(genpath('F:\Valeria\m17462\bigdata\matlab\eeglab')); % eeglab toolbox, see README on where to find this
% addpath(genpath('/users/nemo/projects/RSN'));
addpath(genpath('F:\Valeria\m17462\bigdata\matlab\Henry\useful_functions')); % contains linspecer function, circular statistics toolbox functions, echt function, shadedErrorBar function, see README on where to find this
addpath(genpath('F:\Valeria\m17462\bigdata\matlab\colorGradient'));

Savefolder = 'F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figures\';

incl_sub = setdiff(1:19,[9 12 14]); % 14 excluded because no phasic trials, 9 because no wake eve trials


%% ERP phase bins - REM

load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure2_ERP_allsub_REM_mICA_avref04-Jun-2023.mat');
ERP = ERP_all;

state = 1; % 1 = tonic, 2 = phasic

m_ERP.REM_con_tonic = squeeze(nanmean(ERP.REM_con{state}(incl_sub,:,:),1));
sem_ERP.REM_con_tonic = squeeze(nanstd(ERP.REM_con{state}(incl_sub,:,:),1)./sqrt(size(ERP.REM_con{state}(incl_sub,:,:),1)));

m_ERP.REM_con_thetafilt_tonic = squeeze(nanmean(ERP.REM_con_thetafilt{state}(incl_sub,:,:),1));
sem_ERP.REM_con_thetafilt_tonic = squeeze(nanstd(ERP.REM_con_thetafilt{state}(incl_sub,:,:),1)./sqrt(size(ERP.REM_con_thetafilt{state}(incl_sub,:,:),1)));

m_ERP.REM_con_thetafilt_hilb_tonic = squeeze(circ_mean(ERP.REM_con_thetafilt_hilb{state}(incl_sub,:,:)));
sem_ERP.REM_con_thetafilt_hilb_tonic = squeeze(circ_std(ERP.REM_con_thetafilt_hilb{state}(incl_sub,:,:))./sqrt(size(ERP.REM_con_thetafilt_hilb{state}(incl_sub,:,:),1)));

m_ERP.REM_con_theta_bins_tonic = squeeze(nanmean(ERP.REM_con_theta_bins{state}(incl_sub,:,:,:),1)); % cond x bin x samp
sem_ERP.REM_con_theta_bins_tonic = squeeze(nanstd(ERP.REM_con_theta_bins{state}(incl_sub,:,:,:),1)./sqrt(size(ERP.REM_con_theta_bins{state}(incl_sub,:,:,:),1)));

m_ERP.REM_con_theta_bins_thetafilt_hilb_tonic = squeeze(circ_mean(ERP.REM_con_theta_bins_thetafilt_hilb{state}(incl_sub,:,:,:))); % cond x bin x samp
sem_ERP.REM_con_theta_bins_thetafilt_hilb_tonic = squeeze(circ_std(ERP.REM_con_theta_bins_thetafilt_hilb{state}(incl_sub,:,:,:))./sqrt(size(ERP.REM_con_theta_bins_thetafilt_hilb{state}(incl_sub,:,:,:),1)));

m_ERP.REM_con_theta_pre_tonic = squeeze(nanmean(ERP.REM_con_theta_pre{state}(incl_sub,:,:),1));
sem_ERP.REM_con_theta_pre_tonic = squeeze(nanstd(ERP.REM_con_theta_pre{state}(incl_sub,:,:),1)./sqrt(size(ERP.REM_con_theta_pre{state}(incl_sub,:,:),1)));


state = 2; % 1 = tonic, 2 = phasic

m_ERP.REM_con_phasic = squeeze(nanmean(ERP.REM_con{state}(incl_sub,:,:),1));
sem_ERP.REM_con_phasic = squeeze(nanstd(ERP.REM_con{state}(incl_sub,:,:),1)./sqrt(size(ERP.REM_con{state}(incl_sub,:,:),1)));

m_ERP.REM_con_thetafilt_phasic = squeeze(nanmean(ERP.REM_con_thetafilt{state}(incl_sub,:,:),1));
sem_ERP.REM_con_thetafilt_phasic = squeeze(nanstd(ERP.REM_con_thetafilt{state}(incl_sub,:,:),1)./sqrt(size(ERP.REM_con_thetafilt{state}(incl_sub,:,:),1)));

m_ERP.REM_con_thetafilt_hilb_phasic = squeeze(circ_mean(ERP.REM_con_thetafilt_hilb{state}(incl_sub,:,:)));
sem_ERP.REM_con_thetafilt_hilb_phasic = squeeze(circ_std(ERP.REM_con_thetafilt_hilb{state}(incl_sub,:,:))./sqrt(size(ERP.REM_con_thetafilt_hilb{state}(incl_sub,:,:),1)));

m_ERP.REM_con_theta_bins_phasic = squeeze(nanmean(ERP.REM_con_theta_bins{state}(incl_sub,:,:,:),1)); % cond x bin x samp
sem_ERP.REM_con_theta_bins_phasic = squeeze(nanstd(ERP.REM_con_theta_bins{state}(incl_sub,:,:,:),1)./sqrt(size(ERP.REM_con_theta_bins{state}(incl_sub,:,:,:),1)));

m_ERP.REM_con_theta_bins_thetafilt_hilb_phasic = squeeze(circ_mean(ERP.REM_con_theta_bins_thetafilt_hilb{state}(incl_sub,:,:,:))); % cond x bin x samp
sem_ERP.REM_con_theta_bins_thetafilt_hilb_phasic = squeeze(circ_std(ERP.REM_con_theta_bins_thetafilt_hilb{state}(incl_sub,:,:,:))./sqrt(size(ERP.REM_con_theta_bins_thetafilt_hilb{state}(incl_sub,:,:,:),1)));

m_ERP.REM_con_theta_pre_phasic = squeeze(nanmean(ERP.REM_con_theta_pre{state}(incl_sub,:,:),1));
sem_ERP.REM_con_theta_pre_phasic = squeeze(nanstd(ERP.REM_con_theta_pre{state}(incl_sub,:,:),1)./sqrt(size(ERP.REM_con_theta_pre{state}(incl_sub,:,:),1)));

ERP_REM = ERP;
clear ERP

%% ERP phase bins - wake

load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure2_ERP_allsub_wake_mICA_avref02-Jun-2023.mat');
ERP = ERP_all;

state = 1; % 1 = eyes open, 2 = eyes closed

wake_con_EO  = (ERP.wake_e_con{state}+ERP.wake_m_con{state})/2; % average eve and mor
m_ERP.wake_con_EO = squeeze(nanmean(wake_con_EO(incl_sub,:,:),1));
sem_ERP.wake_con_EO = squeeze(nanstd(wake_con_EO(incl_sub,:,:),1)./sqrt(size(wake_con_EO(incl_sub,:,:),1)));

wake_con_thetafilt_EO  = (ERP.wake_e_con_thetafilt{state}+ERP.wake_m_con_thetafilt{state})/2; % average eve and mor
m_ERP.wake_con_thetafilt_EO = squeeze(nanmean(wake_con_thetafilt_EO(incl_sub,:,:),1));
sem_ERP.wake_con_thetafilt_EO = squeeze(nanstd(wake_con_thetafilt_EO(incl_sub,:,:),1)./sqrt(size(wake_con_thetafilt_EO(incl_sub,:,:),1)));

for s = 1:size(ERP.wake_e_con_thetafilt_hilb{state},1) 
    for con = 1:size(ERP.wake_e_con_thetafilt_hilb{state},2)
        for samp = 1:size(ERP.wake_e_con_thetafilt_hilb{state},3)
            wake_con_thetafilt_hilb_EO(s,con,samp)  = circ_mean(vertcat(ERP.wake_e_con_thetafilt_hilb{state}(s,con,samp),ERP.wake_m_con_thetafilt_hilb{state}(s,con,samp))); % average eve and mor
        end
    end
end
m_ERP.wake_con_thetafilt_hilb_EO = squeeze(circ_mean(wake_con_thetafilt_hilb_EO(incl_sub,:,:)));
sem_ERP.wake_con_thetafilt_hilb_EO = squeeze(circ_std(wake_con_thetafilt_hilb_EO(incl_sub,:,:))./sqrt(size(wake_con_thetafilt_hilb_EO(incl_sub,:,:),1)));

wake_con_theta_bins_EO  = (ERP.wake_e_con_theta_bins{state}+ERP.wake_m_con_theta_bins{state})/2; % average eve and mor
m_ERP.wake_con_theta_bins_EO = squeeze(nanmean(wake_con_theta_bins_EO(incl_sub,:,:,:),1)); % cond x bin x samp
sem_ERP.wake_con_theta_bins_EO = squeeze(nanstd(wake_con_theta_bins_EO(incl_sub,:,:,:),1)./sqrt(size(wake_con_theta_bins_EO(incl_sub,:,:,:),1)));


for s = 1:size(ERP.wake_e_con_theta_bins_thetafilt_hilb{state},1) 
    for con = 1:size(ERP.wake_e_con_theta_bins_thetafilt_hilb{state},2) 
        for b = 1:size(ERP.wake_e_con_theta_bins_thetafilt_hilb{state},3) 
            for samp = 1:size(ERP.wake_e_con_theta_bins_thetafilt_hilb{state},4)
                wake_con_theta_bins_thetafilt_hilb_EO(s,con,b,samp)  = circ_mean(vertcat(ERP.wake_e_con_theta_bins_thetafilt_hilb{state}(s,con,b,samp),ERP.wake_e_con_theta_bins_thetafilt_hilb{state}(s,con,b,samp))); % average eve and mor
            end
        end
    end
end
m_ERP.wake_con_theta_bins_thetafilt_hilb_EO = squeeze(circ_mean(wake_con_theta_bins_thetafilt_hilb_EO(incl_sub,:,:,:))); % sub x cond x bin x samp
sem_ERP.wake_con_theta_bins_thetafilt_hilb_EO = squeeze(circ_std(wake_con_theta_bins_thetafilt_hilb_EO(incl_sub,:,:,:))./sqrt(size(wake_con_theta_bins_thetafilt_hilb_EO(incl_sub,:,:,:),1)));

wake_con_thetafilt_hilb_r_EO = (ERP.wake_e_con_thetafilt_hilb_r{state}+ERP.wake_m_con_thetafilt_hilb_r{state})/2;  % average eve and mor
wake_con_theta_bins_thetafilt_hilb_r_EO = (ERP.wake_e_con_theta_bins_thetafilt_hilb_r{state}+ERP.wake_m_con_theta_bins_thetafilt_hilb_r{state})/2;  % average eve and mor

wake_con_theta_pre_EO  = (ERP.wake_e_con_theta_pre{state}+ERP.wake_m_con_theta_pre{state})/2; % average eve and mor
m_ERP.wake_con_theta_pre_EO = squeeze(nanmean(wake_con_theta_pre_EO(incl_sub,:,:),1));
sem_ERP.wake_con_theta_pre_EO = squeeze(nanstd(wake_con_theta_pre_EO(incl_sub,:,:),1)./sqrt(size(wake_con_theta_pre_EO(incl_sub,:,:),1)));


state = 2; % 1 = eyes open, 2 = eyes closed

wake_con_EC  = (ERP.wake_e_con{state}+ERP.wake_m_con{state})/2; % average eve and mor
m_ERP.wake_con_EC = squeeze(nanmean(wake_con_EC(incl_sub,:,:),1));
sem_ERP.wake_con_EC = squeeze(nanstd(wake_con_EC(incl_sub,:,:),1)./sqrt(size(wake_con_EC(incl_sub,:,:),1)));

wake_con_thetafilt_EC  = (ERP.wake_e_con_thetafilt{state}+ERP.wake_m_con_thetafilt{state})/2; % average eve and mor
m_ERP.wake_con_thetafilt_EC = squeeze(nanmean(wake_con_thetafilt_EC(incl_sub,:,:),1));
sem_ERP.wake_con_thetafilt_EC = squeeze(nanstd(wake_con_thetafilt_EC(incl_sub,:,:),1)./sqrt(size(wake_con_thetafilt_EC(incl_sub,:,:),1)));

for s = 1:size(ERP.wake_e_con_thetafilt_hilb{state},1) 
    for con = 1:size(ERP.wake_e_con_thetafilt_hilb{state},2)
        for samp = 1:size(ERP.wake_e_con_thetafilt_hilb{state},3)
            wake_con_thetafilt_hilb_EC(s,con,samp)  = circ_mean(vertcat(ERP.wake_e_con_thetafilt_hilb{state}(s,con,samp),ERP.wake_m_con_thetafilt_hilb{state}(s,con,samp))); % average eve and mor
        end
    end
end
m_ERP.wake_con_thetafilt_hilb_EC = squeeze(circ_mean(wake_con_thetafilt_hilb_EC(incl_sub,:,:)));
sem_ERP.wake_con_thetafilt_hilb_EC = squeeze(circ_std(wake_con_thetafilt_hilb_EC(incl_sub,:,:))./sqrt(size(wake_con_thetafilt_hilb_EC(incl_sub,:,:),1)));

wake_con_theta_bins_EC  = (ERP.wake_e_con_theta_bins{state}+ERP.wake_m_con_theta_bins{state})/2; % average eve and mor
m_ERP.wake_con_theta_bins_EC = squeeze(nanmean(wake_con_theta_bins_EC(incl_sub,:,:,:),1)); % cond x bin x samp
sem_ERP.wake_con_theta_bins_EC = squeeze(nanstd(wake_con_theta_bins_EC(incl_sub,:,:,:),1)./sqrt(size(wake_con_theta_bins_EC(incl_sub,:,:,:),1)));

for s = 1:size(ERP.wake_e_con_theta_bins_thetafilt_hilb{state},1) 
    for con = 1:size(ERP.wake_e_con_theta_bins_thetafilt_hilb{state},2) 
        for b = 1:size(ERP.wake_e_con_theta_bins_thetafilt_hilb{state},3) 
            for samp = 1:size(ERP.wake_e_con_theta_bins_thetafilt_hilb{state},4)
                wake_con_theta_bins_thetafilt_hilb_EC(s,con,b,samp)  = circ_mean(vertcat(ERP.wake_e_con_theta_bins_thetafilt_hilb{state}(s,con,b,samp),ERP.wake_e_con_theta_bins_thetafilt_hilb{state}(s,con,b,samp))); % average eve and mor
            end
        end
    end
end
m_ERP.wake_con_theta_bins_thetafilt_hilb_EC = squeeze(circ_mean(wake_con_theta_bins_thetafilt_hilb_EC(incl_sub,:,:,:))); % cond x bin x samp
sem_ERP.wake_con_theta_bins_thetafilt_hilb_EC = squeeze(circ_std(wake_con_theta_bins_thetafilt_hilb_EC(incl_sub,:,:,:))./sqrt(size(wake_con_theta_bins_thetafilt_hilb_EC(incl_sub,:,:,:),1)));

wake_con_thetafilt_hilb_r_EC = (ERP.wake_e_con_thetafilt_hilb_r{state}+ERP.wake_m_con_thetafilt_hilb_r{state})/2;  % average eve and mor
wake_con_theta_bins_thetafilt_hilb_r_EC = (ERP.wake_e_con_theta_bins_thetafilt_hilb_r{state}+ERP.wake_m_con_theta_bins_thetafilt_hilb_r{state})/2;  % average eve and mor

wake_con_theta_pre_EC  = (ERP.wake_e_con_theta_pre{state}+ERP.wake_m_con_theta_pre{state})/2; % average eve and mor
m_ERP.wake_con_theta_pre_EC = squeeze(nanmean(wake_con_theta_pre_EC(incl_sub,:,:),1));
sem_ERP.wake_con_theta_pre_EC = squeeze(nanstd(wake_con_theta_pre_EC(incl_sub,:,:),1)./sqrt(size(wake_con_theta_pre_EC(incl_sub,:,:),1)));

ERP_wake = ERP;
clear ERP

%% plot theta ERP

t = (-dt*fs:dt*fs-1)/fs*1000;

colors = linspecer(4);

fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
fig.WindowState = 'maximized';

tileplot = tiledlayout(1,4);

nexttile(1)

for con = 5:8
shadedErrorBar(t,m_ERP.wake_con_EO(con,:),sem_ERP.wake_con_EO(con,:),'lineProps',{'Color',colors(con-4,:),'LineWidth',0.5},'patchSaturation',.3);
hold on
end

hold on
xline(0,'LineStyle','--','LineWidth',2);

xlim([-200 1000]);
xlabel('Time (ms)')
ylabel('Amplitude (\muV)')
set(gca,'Fontsize',15,'TickDir','out','LineWidth',2);
box off
axis square
% legend({'Peak' 'Falling' 'Trough' 'Rising'});
legend off
ylim([-6 6]);
xticks(-200:200:1000);
% title('EO');
xtickangle(0)
set(groot,'defaultAxesXTickLabelRotationMode','manual')


nexttile(2)

for con = 5:8
shadedErrorBar(t,m_ERP.wake_con_EC(con,:),sem_ERP.wake_con_EC(con,:),'lineProps',{'Color',colors(con-4,:),'LineWidth',0.5},'patchSaturation',.3);
hold on
end

hold on
xline(0,'LineStyle','--','LineWidth',2);

xlim([-200 1000]);
xlabel('Time (ms)')
% ylabel(tileplot,'Amplitude (\muV)')
set(gca,'Fontsize',15,'TickDir','out','LineWidth',2);
box off
axis square
% legend({'Peak' 'Falling' 'Trough' 'Rising'});
legend off
ylim([-6 6]);
xticks(-200:200:1000);
% title('EC');
xtickangle(0)
set(groot,'defaultAxesXTickLabelRotationMode','manual')


nexttile(3)

for con = 5:8
shadedErrorBar(t,m_ERP.REM_con_tonic(con,:),sem_ERP.REM_con_tonic(con,:),'lineProps',{'Color',colors(con-4,:),'LineWidth',1},'patchSaturation',.3);
hold on
end

hold on
xline(0,'LineStyle','--','LineWidth',2);

xlim([-200 1000]);
xlabel('Time (ms)')
% ylabel('Amplitude (\muV)')
set(gca,'Fontsize',15,'TickDir','out','LineWidth',2);
box off
axis square
% legend({'Peak' 'Falling' 'Trough' 'Rising'});
legend off
ylim([-6 6]);
xticks(-200:200:1000);
% title('tonic');
xtickangle(0)
set(groot,'defaultAxesXTickLabelRotationMode','manual')


nexttile(4)

for con = 5:8
shadedErrorBar(t,m_ERP.REM_con_phasic(con,:),sem_ERP.REM_con_phasic(con,:),'lineProps',{'Color',colors(con-4,:),'LineWidth',1},'patchSaturation',.3);
hold on
end

hold on
xline(0,'LineStyle','--','LineWidth',2);

xlim([-200 1000]);
xlabel('Time (ms)')
% ylabel('Amplitude (\muV)')
set(gca,'Fontsize',15,'TickDir','out','LineWidth',2);
box off
axis square
% legend({'Peak' 'Falling' 'Trough' 'Rising'});
legend off
ylim([-6 6]);
xticks(-200:200:1000);
% title('phasic');
xtickangle(0)
set(groot,'defaultAxesXTickLabelRotationMode','manual')

% xlabel(tileplot,'Time (ms)')
% ylabel(tileplot,'Amplitude (\muV)')

% tileplot.TileSpacing = 'compact';
% tileplot.Padding = 'compact';

% Savefolder = '/vol/research/nemo/datasets/RSN/data/analysis/Figures/';
% saveas(fig,[Savefolder,'Suppl_Figure23_ERP_phase_reset_theta.svg']);


%% check non-uniformity across circle - REM

state = 1; % 1 = tonic, 2 = phasic

for samp = 1:size(ERP_REM.REM_con_thetafilt_hilb{state},3)
        
    mean_phase_allcon_REM_tonic = reshape(ERP_REM.REM_con_thetafilt_hilb{state}(incl_sub,5:8,samp),[length(incl_sub)*4 1]);
    resultant_phase_allcon_REM_tonic = reshape(ERP_REM.REM_con_thetafilt_hilb_r{state}(incl_sub,5:8,samp),[length(incl_sub)*4 1]);
    
    mean_phase_allcon_REM_tonic(isnan(mean_phase_allcon_REM_tonic))= [];
    resultant_phase_allcon_REM_tonic(isnan(resultant_phase_allcon_REM_tonic))= [];
    
    [p_val_tonic(samp) z_val_tonic(samp)] = circ_rtest(mean_phase_allcon_REM_tonic,resultant_phase_allcon_REM_tonic);
    
end


state = 2; % 1 = tonic, 2 = phasic

for samp = 1:size(ERP_REM.REM_con_thetafilt_hilb{state},3)
        
    mean_phase_allcon_REM_phasic = reshape(ERP_REM.REM_con_thetafilt_hilb{state}(incl_sub,5:8,samp),[length(incl_sub)*4 1]);
    resultant_phase_allcon_REM_phasic = reshape(ERP_REM.REM_con_thetafilt_hilb_r{state}(incl_sub,5:8,samp),[length(incl_sub)*4 1]);
    
    mean_phase_allcon_REM_phasic(isnan(mean_phase_allcon_REM_phasic))= [];
    resultant_phase_allcon_REM_phasic(isnan(resultant_phase_allcon_REM_phasic))= [];
    
    [p_val_phasic(samp) z_val_phasic(samp)] = circ_rtest(mean_phase_allcon_REM_phasic,resultant_phase_allcon_REM_phasic);
    
end


%% check non-uniformity across circle - wake

for samp = 1:size(wake_con_thetafilt_hilb_EO,3)
        
    mean_phase_allcon_EO = reshape(wake_con_thetafilt_hilb_EO(incl_sub,5:8,samp),[length(incl_sub)*4 1]);
    resultant_phase_allcon_EO = reshape(wake_con_thetafilt_hilb_r_EO(incl_sub,5:8,samp),[length(incl_sub)*4 1]);
    
    mean_phase_allcon_EO(isnan(mean_phase_allcon_EO))= [];
    resultant_phase_allcon_EO(isnan(resultant_phase_allcon_EO))= [];
    
    [p_val_EO(samp) z_val_EO(samp)] = circ_rtest(mean_phase_allcon_EO,resultant_phase_allcon_EO);
    
end


for samp = 1:size(wake_con_thetafilt_hilb_EC,3)
        
    mean_phase_allcon_EC = reshape(wake_con_thetafilt_hilb_EC(incl_sub,5:8,samp),[length(incl_sub)*4 1]);
    resultant_phase_allcon_EC = reshape(wake_con_thetafilt_hilb_r_EC(incl_sub,5:8,samp),[length(incl_sub)*4 1]);
    
    mean_phase_allcon_EC(isnan(mean_phase_allcon_EC))= [];
    resultant_phase_allcon_EC(isnan(resultant_phase_allcon_EC))= [];
    
    [p_val_EC(samp) z_val_EC(samp)] = circ_rtest(mean_phase_allcon_EC,resultant_phase_allcon_EC);
    
end

%% plot hilbert thetafilt phase angle

t = (-dt*fs:dt*fs-1)/fs*1000;

colors = linspecer(4);

fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
fig.WindowState = 'maximized';

tileplot = tiledlayout(1,4);

nexttile(1)

for con = 5:8
shadedErrorBar(t,m_ERP.wake_con_thetafilt_hilb_EO(con,:),sem_ERP.wake_con_thetafilt_hilb_EO(con,:),'lineProps',{'Color',colors(con-4,:),'LineWidth',1},'patchSaturation',.3);
hold on
sig_samps = find(p_val_EO < 0.05);
plot(t(sig_samps),ones(length(sig_samps),1)*3.5,'*','Color','k');
hold on
end

hold on
xline(0,'LineStyle','--','LineWidth',2);

xlim([-200 1000]);
xlabel('Time (ms)')
ylabel('Phase (radians)')
set(gca,'Fontsize',15,'TickDir','out','LineWidth',2);
box off
axis square
% legend({'Peak' 'Falling' 'Trough' 'Rising'});
legend off
ylim([-4 4]);
yticks([-pi:pi:pi]);
yticklabels({'-\pi' '0' '\pi'})
xticks(-200:200:1000);
xtickangle(0)
set(groot,'defaultAxesXTickLabelRotationMode','manual')


nexttile(2)

for con = 5:8
shadedErrorBar(t,m_ERP.wake_con_thetafilt_hilb_EC(con,:),sem_ERP.wake_con_thetafilt_hilb_EC(con,:),'lineProps',{'Color',colors(con-4,:),'LineWidth',1},'patchSaturation',.3);
hold on
sig_samps = find(p_val_EC < 0.05);
plot(t(sig_samps),ones(length(sig_samps),1)*3.5,'*','Color','k');
hold on
end

hold on
xline(0,'LineStyle','--','LineWidth',2);

xlim([-200 1000]);
xlabel('Time (ms)')
% ylabel('Phase (radians)')
set(gca,'Fontsize',15,'TickDir','out','LineWidth',2);
box off
axis square
% legend({'Peak' 'Falling' 'Trough' 'Rising'});
legend off
ylim([-4 4]);
yticks([-pi:pi:pi]);
yticklabels({'-\pi' '0' '\pi'})
xticks(-200:200:1000);
xtickangle(0)
set(groot,'defaultAxesXTickLabelRotationMode','manual')


nexttile(3)

for con = 5:8
shadedErrorBar(t,m_ERP.REM_con_thetafilt_hilb_tonic(con,:),sem_ERP.REM_con_thetafilt_hilb_tonic(con,:),'lineProps',{'Color',colors(con-4,:),'LineWidth',1},'patchSaturation',.3);
hold on
sig_samps = find(p_val_tonic < 0.05);
plot(t(sig_samps),ones(length(sig_samps),1)*3.5,'*','Color','k');
hold on
end

hold on
xline(0,'LineStyle','--','LineWidth',2);

xlim([-200 1000]);
xlabel('Time (ms)')
% ylabel('Phase (radians)')
set(gca,'Fontsize',15,'TickDir','out','LineWidth',2);
box off
axis square
% legend({'Peak' 'Falling' 'Trough' 'Rising'});
legend off
ylim([-4 4]);
yticks([-pi:pi:pi]);
yticklabels({'-\pi' '0' '\pi'})
xticks(-200:200:1000);
xtickangle(0)
set(groot,'defaultAxesXTickLabelRotationMode','manual')


nexttile(4)

for con = 5:8
shadedErrorBar(t,m_ERP.REM_con_thetafilt_hilb_phasic(con,:),sem_ERP.REM_con_thetafilt_hilb_phasic(con,:),'lineProps',{'Color',colors(con-4,:),'LineWidth',1},'patchSaturation',.3);
hold on
sig_samps = find(p_val_phasic < 0.05);
plot(t(sig_samps),ones(length(sig_samps),1)*3.5,'*','Color','k');
hold on
end

hold on
xline(0,'LineStyle','--','LineWidth',2);

xlim([-200 1000]);
xlabel('Time (ms)')
% ylabel('Phase (radians)')
set(gca,'Fontsize',15,'TickDir','out','LineWidth',2);
box off
axis square
% legend({'Peak' 'Falling' 'Trough' 'Rising'});
legend off
ylim([-4 4]);
yticks([-pi:pi:pi]);
yticklabels({'-\pi' '0' '\pi'})
xticks(-200:200:1000);
xtickangle(0)
set(groot,'defaultAxesXTickLabelRotationMode','manual')


% Savefolder = '/vol/research/nemo/datasets/RSN/data/analysis/Figures/';
% saveas(fig,[Savefolder,'Suppl_Figure23_ERP_phase_reset_theta_phase.svg']);


%% check non-uniformity across circle for bins - REM

state = 1; % 1 = tonic, 2 = phasic

for b = 1:size(ERP_REM.REM_con_theta_bins_thetafilt_hilb{state},3)
    
    
    for samp = 1:size(ERP_REM.REM_con_theta_bins_thetafilt_hilb{state},4)
        
        mean_phase_allcon_REM_theta_bin_tonic = reshape(ERP_REM.REM_con_theta_bins_thetafilt_hilb{state}(incl_sub,5:8,b,samp),[length(incl_sub)*4 1]);
        resultant_phase_allcon_REM_theta_bin_tonic = reshape(ERP_REM.REM_con_theta_bins_thetafilt_hilb_r{state}(incl_sub,5:8,b,samp),[length(incl_sub)*4 1]);
        
        mean_phase_allcon_REM_theta_bin_tonic(isnan(mean_phase_allcon_REM_theta_bin_tonic))= [];
        resultant_phase_allcon_REM_theta_bin_tonic(isnan(resultant_phase_allcon_REM_theta_bin_tonic))= [];
        
        [p_val_tonic(samp) z_val_tonic(samp)] = circ_rtest( mean_phase_allcon_REM_theta_bin_tonic,resultant_phase_allcon_REM_theta_bin_tonic);
        
    end
    
        
    z_val_tonic(p_val_tonic > 0.05) = NaN;
%     plot(z_val);
    z_val_bin_tonic(b,:) = z_val_tonic;
    max_z_tonic(b) = max(z_val_tonic);
    
end


state = 2; % 1 = tonic, 2 = phasic

for b = 1:size(ERP_REM.REM_con_theta_bins_thetafilt_hilb{state},3)
    
    
    for samp = 1:size(ERP_REM.REM_con_theta_bins_thetafilt_hilb{state},4)
        
        mean_phase_allcon_REM_theta_bin_phasic = reshape(ERP_REM.REM_con_theta_bins_thetafilt_hilb{state}(incl_sub,5:8,b,samp),[length(incl_sub)*4 1]);
        resultant_phase_allcon_REM_theta_bin_phasic = reshape(ERP_REM.REM_con_theta_bins_thetafilt_hilb_r{state}(incl_sub,5:8,b,samp),[length(incl_sub)*4 1]);
        
        mean_phase_allcon_REM_theta_bin_phasic(isnan(mean_phase_allcon_REM_theta_bin_phasic))= [];
        resultant_phase_allcon_REM_theta_bin_phasic(isnan(resultant_phase_allcon_REM_theta_bin_phasic))= [];
        
        [p_val_phasic(samp) z_val_phasic(samp)] = circ_rtest( mean_phase_allcon_REM_theta_bin_phasic,resultant_phase_allcon_REM_theta_bin_phasic);
        
    end
    
        
    z_val_phasic(p_val_phasic > 0.05) = NaN;
%     plot(z_val);
    z_val_bin_phasic(b,:) = z_val_phasic;
    max_z_phasic(b) = max(z_val_phasic);
    
end


%% check non-uniformity across circle for bins - wake

for b = 1:size(wake_con_theta_bins_thetafilt_hilb_EO,3)
    
    
    for samp = 1:size(wake_con_theta_bins_thetafilt_hilb_EO,4)
        
        mean_phase_allcon_REM_theta_bin_EO = reshape(wake_con_theta_bins_thetafilt_hilb_EO(incl_sub,5:8,b,samp),[length(incl_sub)*4 1]);
        resultant_phase_allcon_REM_theta_bin_EO = reshape(wake_con_theta_bins_thetafilt_hilb_r_EO(incl_sub,5:8,b,samp),[length(incl_sub)*4 1]);
        
        mean_phase_allcon_REM_theta_bin_EO(isnan(mean_phase_allcon_REM_theta_bin_EO))= [];
        resultant_phase_allcon_REM_theta_bin_EO(isnan(resultant_phase_allcon_REM_theta_bin_EO))= [];
        
        [p_val_EO(samp) z_val_EO(samp)] = circ_rtest(mean_phase_allcon_REM_theta_bin_EO,resultant_phase_allcon_REM_theta_bin_EO);
        
    end
    
        
    z_val_EO(p_val_EO > 0.05) = NaN;
%     plot(z_val);
    z_val_bin_EO(b,:) = z_val_EO;
    max_z_EO(b) = max(z_val_EO);
    
end



for b = 1:size(wake_con_theta_bins_thetafilt_hilb_EC,3)
    
    
    for samp = 1:size(wake_con_theta_bins_thetafilt_hilb_EC,4)
        
        mean_phase_allcon_REM_theta_bin_EC = reshape(wake_con_theta_bins_thetafilt_hilb_EC(incl_sub,5:8,b,samp),[length(incl_sub)*4 1]);
        resultant_phase_allcon_REM_theta_bin_EC = reshape(wake_con_theta_bins_thetafilt_hilb_r_EC(incl_sub,5:8,b,samp),[length(incl_sub)*4 1]);
        
        mean_phase_allcon_REM_theta_bin_EC(isnan(mean_phase_allcon_REM_theta_bin_EC))= [];
        resultant_phase_allcon_REM_theta_bin_EC(isnan(resultant_phase_allcon_REM_theta_bin_EC))= [];
        
        [p_val_EC(samp) z_val_EC(samp)] = circ_rtest(mean_phase_allcon_REM_theta_bin_EC,resultant_phase_allcon_REM_theta_bin_EC);
        
    end
    
        
    z_val_EC(p_val_EC > 0.05) = NaN;
%     plot(z_val);
    z_val_bin_EC(b,:) = z_val_EC;
    max_z_EC(b) = max(z_val_EC);
    
end

%% regression between max z and theta power octile

fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
fig.WindowState = 'maximized';

tileplot = tiledlayout(1,4);

nexttile(1)

mdl = fitlm([1:8],max_z_EO);
pl = plot(mdl);
pl(2,1).Color = [0.5 0.5 0.5];
pl(3,1).Color = [0.5 0.5 0.5];
pl(4,1).Color = [0.5 0.5 0.5];
pl(2,1).LineWidth = 3;
pl(3,1).LineWidth = 3;
pl(4,1).LineWidth = 3;

hold on
plot([1:8],max_z_EO,'o','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',10);  
p_reg_EO = mdl.Coefficients(2,4)
r_squared_EO = mdl.Rsquared.Ordinary
% text(double(6),double(max(max_z)),{['p = ',num2str(round(table2array(mdl.Coefficients(2,4)),2,'significant'))],['r_2 = ',num2str(round(mdl.Rsquared.Ordinary,2,'significant'))]});
%lsline
legend off
xlim([0 9]);
ylim([0 20]);
xticks(1:8);
xlabel('Theta Power Octile');
ylabel('Max Z-Stat');
axis square
box off
set(gca,'Fontsize',15,'TickDir','out','LineWidth',2);
title('');
xtickangle(0)
set(groot,'defaultAxesXTickLabelRotationMode','manual')


nexttile(2)

mdl = fitlm([1:8],max_z_EC);
pl = plot(mdl);
pl(2,1).Color = [0.5 0.5 0.5];
pl(3,1).Color = [0.5 0.5 0.5];
pl(4,1).Color = [0.5 0.5 0.5];
pl(2,1).LineWidth = 3;
pl(3,1).LineWidth = 3;
pl(4,1).LineWidth = 3;

hold on
plot([1:8],max_z_EC,'o','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',10);  
p_reg_EC = mdl.Coefficients(2,4)
r_squared_EC = mdl.Rsquared.Ordinary
% text(double(6),double(max(max_z)),{['p = ',num2str(round(table2array(mdl.Coefficients(2,4)),2,'significant'))],['r_2 = ',num2str(round(mdl.Rsquared.Ordinary,2,'significant'))]});
%lsline
legend off
xlim([0 9]);
ylim([0 20]);
xticks(1:8);
xlabel('Theta Power Octile');
% ylabel('Max Z-Stat');
axis square
box off
set(gca,'Fontsize',15,'TickDir','out','LineWidth',2);
title('');
xtickangle(0)
set(groot,'defaultAxesXTickLabelRotationMode','manual')


nexttile(3)

mdl = fitlm([1:8],max_z_tonic);
pl = plot(mdl);
pl(2,1).Color = [0.5 0.5 0.5];
pl(3,1).Color = [0.5 0.5 0.5];
pl(4,1).Color = [0.5 0.5 0.5];
pl(2,1).LineWidth = 3;
pl(3,1).LineWidth = 3;
pl(4,1).LineWidth = 3;

hold on
plot([1:8],max_z_tonic,'o','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',10);  
p_reg_tonic = mdl.Coefficients(2,4)
r_squared_tonic = mdl.Rsquared.Ordinary
% text(double(6),double(max(max_z)),{['p = ',num2str(round(table2array(mdl.Coefficients(2,4)),2,'significant'))],['r_2 = ',num2str(round(mdl.Rsquared.Ordinary,2,'significant'))]});
%lsline
legend off
xlim([0 9]);
ylim([0 20]);
xticks(1:8);
xlabel('Theta Power Octile');
% ylabel('Max Z-Stat');
axis square
box off
set(gca,'Fontsize',15,'TickDir','out','LineWidth',2);
title('');
xtickangle(0)
set(groot,'defaultAxesXTickLabelRotationMode','manual')


% nexttile(4)
% 
% mdl = fitlm([1:8],max_z_phasic);
% pl = plot(mdl);
% pl(2,1).Color = [0.5 0.5 0.5];
% pl(3,1).Color = [0.5 0.5 0.5];
% pl(4,1).Color = [0.5 0.5 0.5];
% pl(2,1).LineWidth = 3;
% pl(3,1).LineWidth = 3;
% pl(4,1).LineWidth = 3;
% 
% hold on
% plot([1:8],max_z_phasic,'o','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',10);  
% p_reg_phasic = mdl.Coefficients(2,4)
% r_squared_phasic = mdl.Rsquared.Ordinary
% % text(double(6),double(max(max_z)),{['p = ',num2str(round(table2array(mdl.Coefficients(2,4)),2,'significant'))],['r_2 = ',num2str(round(mdl.Rsquared.Ordinary,2,'significant'))]});
% %lsline
% legend off
% xlim([0 9]);
% ylim([0 20]);
% xticks(1:8);
% xlabel('Theta Power Octile');
% % ylabel('Max Z-Stat');
% axis square
% box off
% set(gca,'Fontsize',15,'TickDir','out','LineWidth',2);
% title('');

% saveas(fig,[Savefolder,'Suppl_Figure23_ERP_phase_reset_theta_regression.svg']);



