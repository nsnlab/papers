clear all;
close all;

addpath(genpath('F:\Valeria\m17462\bigdata\matlab\eeglab')); % eeglab toolbox, see README on where to find this
addpath(genpath('F:\Valeria\m17462\bigdata\matlab\eBOSC'));  % eBOSC toolbox, see README on where to find this
addpath(genpath('F:\Valeria\m17462\bigdata\matlab\Henry\useful_functions')); % contains linspecer function, circular statistics toolbox functions, echt function, shadedErrorBar function, see README on where to find this

% Folderpath = '/vol/research/nemo/datasets/RSN/data/hdEEG/';
% sub_Folderpath = dir([Folderpath,'RSN*']);
% 
% waves_folder = '/vol/research/nemo/datasets/RSN/data/analysis/oscillation_detection/';

Folderpath = 'F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure3B_RSN_002\';

Savefolder = 'F:\Valeria\RSN\data\for_sharing\data_to_make_figures\';

load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure3B_ISI_echt_psd_allsub_14-Mar-2023.mat')


%% Average across on and off blocks and calculate change
lower_freq_alpha = 7.5;
higher_freq_alpha = 12.5;
lower_freq_theta = 4.5;
higher_freq_theta = 7.5;

%%

s = 2; %1:length(sub_Folderpath)   
    
% goodREM_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_sleep*_fil_czref_goodREM.mat']);
% load([Folderpath,sub_Folderpath(s).name,filesep,goodREM_file(1).name]);

goodREM_file = dir([Folderpath,'*_sleep*_fil_czref_goodREM.mat']);
load([Folderpath,filesep,goodREM_file(1).name]);

% waves_file = dir([waves_folder,sub_Folderpath(s).name,'*_eBOSC_waves.mat']);
% load([waves_folder,waves_file(1).name])

waves_file = dir([Folderpath,'*_eBOSC_waves.mat']);
load([Folderpath,waves_file(1).name])

%% find waves during good REM sleep

 good_ndx = [];
   for w = 1:length(waves_allepch.startsamp)
       samps = waves_allepch.startsamp(w):waves_allepch.endsamp(w);
       samps_good = intersect(samps,rem_goodsamp2);
       if isequal(length(samps),length(samps_good))
           good_ndx = [good_ndx w]; 
       end 
   end
   
  waves_allepch_good = waves_allepch(good_ndx,:);   

 %% only include waves with more than 3 cycles and 300 ms, find waves in alpha and theta range
waves_ep_3cyc = waves_allepch_good(waves_allepch_good.cycles > 3,:);
waves_ep_3cyc_dur = waves_ep_3cyc(waves_ep_3cyc.duration > 0.3,:);
waves_ep_3cyc_dur_alphatheta = waves_ep_3cyc_dur(waves_ep_3cyc_dur.frequency > 0 & waves_ep_3cyc_dur.frequency < 12.5,:);
waves_ep_3cyc_dur_alpha = waves_ep_3cyc_dur(waves_ep_3cyc_dur.frequency > lower_freq_alpha & waves_ep_3cyc_dur.frequency < higher_freq_alpha,:);
waves_ep_3cyc_dur_theta = waves_ep_3cyc_dur(waves_ep_3cyc_dur.frequency > lower_freq_theta & waves_ep_3cyc_dur.frequency < higher_freq_theta,:);

waves_rem = waves_ep_3cyc_dur_alphatheta(waves_ep_3cyc_dur_alphatheta.stage == 'R',:);
waves_rem_alpha = waves_ep_3cyc_dur_alpha(waves_ep_3cyc_dur_alpha.stage == 'R',:);
waves_rem_theta = waves_ep_3cyc_dur_theta(waves_ep_3cyc_dur_theta.stage == 'R',:);

mdn_rem_alpha(s) = nanmedian(waves_rem_alpha.frequency);
m_rem_alpha(s) = nanmean(waves_rem_alpha.frequency);
n_rem_alpha(s) = length(waves_rem_alpha.frequency);

mdn_rem_theta(s) = nanmedian(waves_rem_theta.frequency);
m_rem_theta(s) = nanmean(waves_rem_theta.frequency);
n_rem_theta(s) = length(waves_rem_theta.frequency);

for ep = 1:nepochs
    
    waves_ep_ndx = find(waves_allepch.nep == ep);
    offset_allep(ep) = waves_allepch.offset(waves_ep_ndx(1));
    exponent_allep(ep) = waves_allepch.exponent(waves_ep_ndx(1));
    
    clear waves_ep_ndx
    
end

m_offset_wake(s) = nanmean(offset_allep(find(hypno2 == 'W')));
m_offset_n1(s) = nanmean(offset_allep(find(hypno2 == '1')));
m_offset_n2(s) = nanmean(offset_allep(find(hypno2 == '2')));
m_offset_n3(s) = nanmean(offset_allep(find(hypno2 == '3')));
m_offset_rem(s) = nanmean(offset_allep(find(hypno2 == 'R')));

m_exponent_wake(s) = nanmean(exponent_allep(find(hypno2 == 'W')));
m_exponent_n1(s) = nanmean(exponent_allep(find(hypno2 == '1')));
m_exponent_n2(s) = nanmean(exponent_allep(find(hypno2 == '2')));
m_exponent_n3(s) = nanmean(exponent_allep(find(hypno2 == '3')));
m_exponent_rem(s) = nanmean(exponent_allep(find(hypno2 == 'R')));

%% Stim frequency alpha and theta

mdn_ISI_all = NaN(18,1,1);
mdn_ISI_alpha = NaN(18,1,1);
mdn_ISI_theta = NaN(18,1,1);

% for s = 1:19
    
    ISI_alphastim_all_allcon = [];
    ISI_alphastim_alpha_allcon = [];
    
    for con = 1:4
        
        ISI_subcon = ISI_allsub(s).con{con};
        ISI_freq = 1./ISI_subcon;
        
        ISI_all = ISI_freq;
        ISI_alpha = ISI_freq(find(ISI_freq > lower_freq_alpha & ISI_freq < higher_freq_alpha));
        
        ISI_alphastim_all_allcon = vertcat(ISI_alphastim_all_allcon,ISI_all');
        ISI_alphastim_alpha_allcon = vertcat(ISI_alphastim_alpha_allcon,ISI_alpha');
        
        clear ISI_all ISI_alpha ISI_subcon ISI_freq
      
    end
    
    ISI_thetastim_all_allcon = [];
    ISI_thetastim_theta_allcon = [];
    
      for con = 5:8
        
        ISI_subcon = ISI_allsub(s).con{con};
        ISI_freq = 1./ISI_subcon;
        
        ISI_all = ISI_freq;
        ISI_theta = ISI_freq(find(ISI_freq > lower_freq_theta & ISI_freq < higher_freq_theta));
        
        ISI_thetastim_all_allcon = vertcat(ISI_thetastim_all_allcon,ISI_all');
        ISI_thetastim_theta_allcon = vertcat(ISI_thetastim_theta_allcon,ISI_theta');
        
        clear ISI_all ISI_theta ISI_subcon ISI_freq
      
    end
    
     m_ISI_alphastim_all(s) = nanmean(ISI_alphastim_all_allcon);
     m_ISI_alphastim_alpha(s) = nanmean(ISI_alphastim_alpha_allcon);
     m_ISI_thetastim_all(s) = nanmean(ISI_thetastim_all_allcon);
     m_ISI_thetastim_theta(s) = nanmean(ISI_thetastim_theta_allcon);
     
     mdn_ISI_alphastim_all(s) = nanmedian(ISI_alphastim_all_allcon);
     mdn_ISI_alphastim_alpha(s) = nanmedian(ISI_alphastim_alpha_allcon);
     mdn_ISI_thetastim_all(s) = nanmedian(ISI_thetastim_all_allcon);
     mdn_ISI_thetastim_theta(s) = nanmedian(ISI_thetastim_theta_allcon);

      
%% Oscillation frequency histogram - findpeaks

colors = linspecer(8);
% colors = linspecer(18);

fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])

% Alpha stim frequency - findpeaks

% subplot(2,1,2)
% uisetcolor()
% histogram(ISI_alphastim_all_allcon,30,'FaceColor',colors(7,:),'FaceAlpha',0.5)
histogram(ISI_alphastim_all_allcon,30,'FaceColor',colors(5,:),'FaceAlpha',1)
[f,xi] = ksdensity(ISI_alphastim_all_allcon); 
hold on
% plot(xi,f*4000,'Color',colors(7,:),'LineWidth',5)
plot(xi,f*4000,'Color',colors(5,:),'LineWidth',5)
hold on

[pks,locs] = findpeaks(f);

der = diff(f);
der_ndx = find(der < 0.001 & der > -0.001)
% plot(xi(der_ndx),f(der_ndx),'o');

alphastim_alpha_peak_findpeaks(s) = NaN;
alphastim_theta_peak_findpeaks(s) = NaN;


 if find(xi(locs)>=lower_freq_alpha & xi(locs)<=higher_freq_alpha)
            
     [row,col] = find(xi(locs)>=lower_freq_alpha & xi(locs)<=higher_freq_alpha);
        
            if length(col)>1
                [r,c] = find(pks(col)==max(pks(col)));
                alphastim_alpha_peak_findpeaks(s) = xi(locs(col(r)));
%                 scatter(alphastim_alpha_peak_findpeaks(s),pks(col(r))*4000,700,'o','MarkerFaceColor',colors(7,:),'MarkerEdgeColor','k','LineWidth',3)
                scatter(alphastim_alpha_peak_findpeaks(s),pks(col(r))*4000,700,'o','MarkerFaceColor',colors(5,:),'MarkerEdgeColor','k','LineWidth',3)
            else
                alphastim_alpha_peak_findpeaks(s) = xi(locs(col));
%                 scatter(alphastim_alpha_peak_findpeaks(s),pks(col)*4000,700,'o','MarkerFaceColor',colors(7,:),'MarkerEdgeColor','k','LineWidth',3)
                scatter(alphastim_alpha_peak_findpeaks(s),pks(col)*4000,700,'o','MarkerFaceColor',colors(5,:),'MarkerEdgeColor','k','LineWidth',3)
            end
 end
 
  
 
% Alpha oscillation frequency

% subplot(2,1,1)
% histogram(waves_rem.frequency,30,'FaceColor',colors(5,:),'FaceAlpha',1)
histogram(waves_rem.frequency,30,'FaceColor',colors(7,:),'FaceAlpha',0.6)
% histogram(waves_rem.frequency,30,'FaceColor',colors(1,:),'FaceAlpha',1)
[f,xi] = ksdensity(waves_rem.frequency); 
hold on
% plot(xi,f*2500,'Color',[0.5216 0.3686 0.0627],'LineWidth',5)
plot(xi,f*2500,'Color',colors(7,:),'LineWidth',5)
hold on

[pks,locs] = findpeaks(f);

der = diff(f);
der_ndx = find(der < 0.001 & der > -0.001);
% plot(xi(der_ndx),f(der_ndx),'o');

alpha_peak_findpeaks(s) = NaN;
theta_peak_findpeaks(s) = NaN;


 if find(xi(locs)>=lower_freq_alpha & xi(locs)<=higher_freq_alpha)
            
     [row,col] = find(xi(locs)>=lower_freq_alpha & xi(locs)<=higher_freq_alpha);
        
            if length(col)>1
                [r,c] = find(pks(col)==max(pks(col)));
                alpha_peak_findpeaks(s) = xi(locs(col(r)));
%                 scatter(alpha_peak_findpeaks(s),pks(col(r))*2500,700,'o','MarkerFaceColor',[0.5216 0.3686 0.0627],'MarkerEdgeColor','k','LineWidth',3)
                scatter(alpha_peak_findpeaks(s),pks(col(r))*2500,700,'o','MarkerFaceColor',colors(7,:),'MarkerEdgeColor','k','LineWidth',3)
            else
                alpha_peak_findpeaks(s) = xi(locs(col));
%                 scatter(alpha_peak_findpeaks(s),pks(col)*2500,700,'o','MarkerFaceColor',[0.5216 0.3686 0.0627],'MarkerEdgeColor','k','LineWidth',3)
                scatter(alpha_peak_findpeaks(s),pks(col)*2500,700,'o','MarkerFaceColor',colors(7,:),'MarkerEdgeColor','k','LineWidth',3)
            end
 end

set(gca,'Fontsize',35,'TickDir','out','LineWidth',3);
box off
axis square
xlim([0 14]);
xticks(0:2:14);
xlabel('Frequency (Hz)');
ylabel('Number')
 
% saveas(fig,[Savefolder,'Figure3B_example_alphastim_freq_findpeaks.svg']);

%% Theta stim frequency histogram - findpeaks

fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])

colors = linspecer(8);

fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])


% Theta stim frequency - findpeaks

% histogram(ISI_thetastim_all_allcon,30,'FaceColor',colors(7,:),'FaceAlpha',0.5)
histogram(ISI_thetastim_all_allcon,30,'FaceColor',colors(5,:),'FaceAlpha',1)
[f,xi] = ksdensity(ISI_thetastim_all_allcon); 
hold on
% plot(xi,f*2000,'Color',colors(7,:),'LineWidth',5)
plot(xi,f*2000,'Color',colors(5,:),'LineWidth',5)
hold on

[pks,locs] = findpeaks(f);

der = diff(f);
der_ndx = find(der < 0.001 & der > -0.001)
% plot(xi(der_ndx),f(der_ndx),'o');

thetastim_alpha_peak_findpeaks(s) = NaN;
thetastim_theta_peak_findpeaks(s) = NaN;

 if find(xi(locs)>=lower_freq_theta & xi(locs)<=higher_freq_theta)
            
     [row,col] = find(xi(locs)>=lower_freq_theta & xi(locs)<=higher_freq_theta);
        
            if length(col)>1
                [r,c] = find(pks(col)==max(pks(col)));
                thetastim_theta_peak_findpeaks(s) = xi(locs(col(r)));
%                 scatter(thetastim_theta_peak_findpeaks(s),pks(col(r))*2000,700,'o','MarkerFaceColor',colors(7,:),'MarkerEdgeColor','k','LineWidth',3)
                scatter(thetastim_theta_peak_findpeaks(s),pks(col(r))*2000,700,'o','MarkerFaceColor',colors(5,:),'MarkerEdgeColor','k','LineWidth',3)
            else
                thetastim_theta_peak_findpeaks(s) = xi(locs(col));
%                 scatter(thetastim_theta_peak_findpeaks(s),pks(col)*2000,700,'o','MarkerFaceColor',colors(7,:),'MarkerEdgeColor','k','LineWidth',3)
                scatter(thetastim_theta_peak_findpeaks(s),pks(col)*2000,700,'o','MarkerFaceColor',colors(5,:),'MarkerEdgeColor','k','LineWidth',3)
            end
 end
   
 
 
% Theta oscillation frequency

% subplot(2,1,1)
% histogram(waves_rem.frequency,30,'FaceColor',colors(5,:),'FaceAlpha',1)
histogram(waves_rem.frequency,30,'FaceColor',colors(7,:),'FaceAlpha',0.6)
[f,xi] = ksdensity(waves_rem.frequency); 
hold on
% plot(xi,f*2500,'Color',[0.5216 0.3686 0.0627],'LineWidth',5)
plot(xi,f*2500,'Color',colors(7,:),'LineWidth',5)
hold on

[pks,locs] = findpeaks(f);

der = diff(f);
der_ndx = find(der < 0.001 & der > -0.001);
% plot(xi(der_ndx),f(der_ndx),'o');

alpha_peak_findpeaks(s) = NaN;
theta_peak_findpeaks(s) = NaN;


 if find(xi(locs)>=lower_freq_theta & xi(locs)<=higher_freq_theta)
            
     [row,col] = find(xi(locs)>=lower_freq_theta & xi(locs)<=higher_freq_theta);
        
            if length(col)>1
                [r,c] = find(pks(col)==max(pks(col)));
                theta_peak_findpeaks(s) = xi(locs(col(r)));
%                 scatter(theta_peak_findpeaks(s),pks(col(r))*2500,700,'o','MarkerFaceColor',[0.5216 0.3686 0.0627],'MarkerEdgeColor','k','LineWidth',3)
                scatter(theta_peak_findpeaks(s),pks(col(r))*2500,700,'o','MarkerFaceColor',colors(7,:),'MarkerEdgeColor','k','LineWidth',3)
            else
                theta_peak_findpeaks(s) = xi(locs(col));
%                 scatter(theta_peak_findpeaks(s),pks(col)*2500,700,'o','MarkerFaceColor',[0.5216 0.3686 0.0627],'MarkerEdgeColor','k','LineWidth',3)
                scatter(theta_peak_findpeaks(s),pks(col)*2500,700,'o','MarkerFaceColor',colors(7,:),'MarkerEdgeColor','k','LineWidth',3)
            end
 end 
 
 
set(gca,'Fontsize',35,'TickDir','out','LineWidth',3);
box off
axis square
xlim([0 14]);
xticks(0:2:14);
xlabel('Frequency (Hz)');
ylabel('Number')
 
% saveas(fig,[Savefolder,'Figure3G_example_thetastim_freq_findpeaks.svg']);


