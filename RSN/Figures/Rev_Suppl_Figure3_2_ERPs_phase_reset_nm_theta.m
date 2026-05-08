clear all;
close all;

addpath(genpath('F:\Valeria\m17462\bigdata\matlab\eeglab')); % eeglab toolbox, see README on where to find this
% addpath(genpath('/users/nemo/projects/RSN'));
addpath(genpath('F:\Valeria\m17462\bigdata\matlab\Henry\useful_functions')); % contains linspecer function, circular statistics toolbox functions, echt function, shadedErrorBar function, see README on where to find this
% addpath(genpath('/user/HS301/m17462/matlab/colorGradient'));

Savefolder = 'F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figures\';

% incl_sub = setdiff(1:19,[12]); % 14 excluded because no phasic trials, 9 because no wake eve trials
incl_sub = setdiff(1:19,[12]); % 14 excluded because no phasic trials, 9 because no wake eve trials


%% ERP phase bins - REM

% load('/parallel_scratch/nemo/RSN/analysis/analysis/erp_allsub/ERP_nm_allsub_REM_mICA_avref09-Feb-2024.mat');
load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Rev_Suppl_Figure3_2_ERP_nm_broadband_allsub_REM_mICA_avref07-Jun-2024.mat');

%% plot alpha ERP - averaged across triggers

t = (-dt*fs:dt*fs-1)/fs*1000; % time in ms

colors = linspecer(4);

fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
fig.WindowState = 'maximized';

% tileplot = tiledlayout(1,4);
% 
% nexttile(1)
% for trig = 1:10
trig = 1:30;



% trig = 1;

% subplot(2,5,trig)
for con = 5:8
    
%     for s = 1:size(ERP_nm_all.trial_data,1)
%         nonan_trig = find(~isnan(squeeze(ERP_nm_all.trial_data(s,con,:,1))) == 1);
%         last_trig(s) = nonan_trig(end);
%     end

plot(t,squeeze(nanmean(nanmean(ERP_nm_all.trial_data(incl_sub,con,trig,:),1),3)),'Color',colors(con-4,:),'LineWidth',2)
hold on

% m_ERP_nm_con = squeeze(nanmean(nanmean(ERP_nm_all.trial_data(incl_sub,con,trig,:),1),3));
% sem_ERP_nm_con = squeeze(nanmean(nanstd(ERP_nm_all.trial_data(incl_sub,con,trig,:),1),3))./sqrt(length(incl_sub));
% 
% shadedErrorBar(t,m_ERP_nm_con,sem_ERP_nm_con,'lineProps',{'Color',colors(con,:),'LineWidth',3},'patchSaturation',.3);
% hold on
% 
% clear m_ERP_nm_con sem_ERP_nm_con

end


hold on
plot(t,squeeze(nanmean(nanmean(nanmean(ERP_nm_all.trial_data(incl_sub,1:4,trig,:),3),2),1)),'Color','k','LineWidth',3)

xline(0,'LineStyle','--','LineWidth',5);

xlim([-200 1000]);
xlabel('Time (ms)')
ylabel('Amplitude (\muV)')
set(gca,'Fontsize',35,'TickDir','out','LineWidth',3);
box off
axis square
% legend({'Peak' 'Falling' 'Trough' 'Rising'});
legend off
ylim([-3 4]);
xticks(-200:200:1000);
% title(['Stimulus ',num2str(trig)]);
xtickangle(0)
set(groot,'defaultAxesXTickLabelRotationMode','manual')

% end

% saveas(fig,[Savefolder,'Suppl_Figure4_ERP_nm_thetastim.svg']);

%% plot alpha ERP - averaged across first 10 triggers - alphafilt

t = (-dt*fs:dt*fs-1)/fs*1000; % time in ms

colors = linspecer(4);

fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
fig.WindowState = 'maximized';

% tileplot = tiledlayout(1,4);
% 
% nexttile(1)
% for trig = 1:10
trig = 1:30;
% subplot(2,5,trig)
for con = 5:8
plot(t,squeeze(nanmean(nanmean(ERP_nm_all.trial_data_thetafilt_real(incl_sub,con,trig,:),1),3)),'Color',colors(con-4,:),'LineWidth',2)
hold on
end

hold on
plot(t,squeeze(nanmean(nanmean(nanmean(ERP_nm_all.trial_data_thetafilt_real(incl_sub,1:4,:,:),3),2),1)),'Color','k','LineWidth',3)

xline(0,'LineStyle','--','LineWidth',2);

xlim([-200 1000]);
xlabel('Time (ms)')
ylabel('Amplitude (\muV)')
set(gca,'Fontsize',35,'TickDir','out','LineWidth',3);
box off
axis square
% legend({'Peak' 'Falling' 'Trough' 'Rising'});
legend off
ylim([-3 3]);
xticks(-200:200:1000);
% title(['Stimulus ',num2str(trig)]);
xtickangle(0)
set(groot,'defaultAxesXTickLabelRotationMode','manual')

% end
% saveas(fig,[Savefolder,'Suppl_Figure4_ERP_nm_thetastim_thetafilt.svg']);


