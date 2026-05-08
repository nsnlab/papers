clear all;
close all;

addpath(genpath('F:\Valeria\m17462\bigdata\matlab\eeglab')); % eeglab toolbox, see README on where to find this
addpath(genpath('F:\Valeria\m17462\bigdata\matlab\Scripts\RSN'));  % contains distinguishable colors function, see README on where to find this
addpath(genpath('F:\Valeria\m17462\bigdata\matlab\Henry\useful_functions')); % contains linspecer function, circular statistics toolbox functions, echt function, shadedErrorBar function, see README on where to find this

Savefolder = 'F:\Valeria\RSN\data\for_sharing\data_to_make_figures\';

load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure2_Figure3A_Figure4A_psd_allsub_mICA_avref_12-Mar-2023.mat');

incl_sub = setdiff(1:19,12);

conditions = {'Alpha Phase 0'; 'Alpha Phase 90'; 'Alpha Phase 180'; 'Alpha Phase 270';...
            'Theta Phase 0'; 'Theta Phase 90'; 'Theta Phase 180'; 'Theta Phase 270';};

%% Average across on and off blocks and calculate change
ch = [2 34 65 94]; % Fz, AFz, AFF1h, AFF2h
% ch = 16:18; % O1, Oz, Oz
lower_freq_alpha = 7.5;
higher_freq_alpha = 12.5;
lower_freq_theta = 4.5;
higher_freq_theta = 7.5;

mpsd_con_ch_stage = mpsd_con_ch; % mpsd_con_ch: sub x ch x con x bins x ep

on_block = 7:12;
off_block = 1:6;

psd_ON_block = squeeze(nanmean(mpsd_con_ch_stage(:,:,:,:,on_block),5)); % average across on block 
psd_OFF_block = squeeze(nanmean(mpsd_con_ch_stage(:,:,:,:,off_block),5));

psd_ON = squeeze(nanmean(psd_ON_block(:,ch,:,:),2)); % average across channels
psd_OFF = squeeze(nanmean(psd_OFF_block(:,ch,:,:),2));

psd_ONOFF_change = (psd_ON - psd_OFF)./psd_OFF *100;

% ff = [2:.1:30];%was [2:.25:30]

psd_OFF_allcon = squeeze(nanmean(psd_OFF,2));

%% hdEEG - Alpha

colors = distinguishable_colors(18);

% colors = colorGradient([0.1 0.1 0.1],[0.8 0.8 0.8],18)
% colors = linspecer(18);
   
% for con = 1:8
    
    fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
        
        for s = 1:length(incl_sub)
            
        zpower = (psd_OFF_allcon(incl_sub(s),:) - nanmean(psd_OFF_allcon(incl_sub(s),:)))/nanstd(psd_OFF_allcon(incl_sub(s),:));
        zpower_off(s,:) = zpower;
        
        
        plot(f,zpower,'Color',[0 0 0 0.3],'LineWidth',7);
        hold on
            
        plot(f,zpower,'Color',[colors(s,:) 0.3],'LineWidth',5); 
        
%         plot(f,zpower,'Color',[0.5 0.5 0.5 0.6],'LineWidth',3);
        hold on

        end
        
        s = 2;
        zpower = (psd_OFF_allcon(incl_sub(s),:) - nanmean(psd_OFF_allcon(incl_sub(s),:)))/nanstd(psd_OFF_allcon(incl_sub(s),:));
        zpower_off(s,:) = zpower;
        
        plot(f,zpower,'Color',[0 0 0 0.3],'LineWidth',7);
        hold on
            
        plot(f,zpower,'Color',[0.9718 0.5553 0.7741 1],'LineWidth',5); 
        
%         plot(f,zpower,'Color',[0.5 0.5 0.5 0.6],'LineWidth',3);
        hold on
        
         plot(f,nanmean(zpower_off,1),'--','Color',[0 0 0 1],'LineWidth',8); 
               
        
        for s = 1:length(incl_sub)

        [pks,locs] = findpeaks(zpower_off(s,:));
    
        indiv_peaks(s,locs) = 1;
            
        IAPF_off_hdEEG(s) = NaN;
        ITPF_off_hdEEG(s) = NaN;
            
        if find(f(locs)>=lower_freq_alpha & f(locs)<=higher_freq_alpha)
        
            [row,col] = find(f(locs)>=lower_freq_alpha & f(locs)<=higher_freq_alpha);
        
            if length(col)>1
           
                [r,c] = find(pks(col)==max(pks(col)));
            
                IAPF_off_hdEEG(s) = f(locs(col(r)));
                scatter(IAPF_off_hdEEG(s),pks(col(r)),700,'MarkerFaceColor',colors(s,:),'MarkerEdgeColor','k','MarkerFaceAlpha',1,'LineWidth',2)
%                 scatter(ITPF_off_hdEEG(s),pks(col(r)),300,'k','filled','MarkerFaceAlpha',.6)


            else
            
                IAPF_off_hdEEG(s) = f(locs(col));
                scatter(IAPF_off_hdEEG(s),pks(col),700,'MarkerFaceColor',colors(s,:),'MarkerEdgeColor','k','MarkerFaceAlpha',1,'LineWidth',3)
%                 scatter(ITPF_off_hdEEG(s),pks(col),300,'k','filled','MarkerFaceAlpha',.6)

            end
        
        
        end
        
        end
        
        
        
        
        
        s = 2;

        [pks,locs] = findpeaks(zpower_off(s,:));
    
        indiv_peaks(s,locs) = 1;
            
        IAPF_off_hdEEG(s) = NaN;
        ITPF_off_hdEEG(s) = NaN;
            
        if find(f(locs)>=lower_freq_alpha & f(locs)<=higher_freq_alpha)
        
            [row,col] = find(f(locs)>=lower_freq_alpha & f(locs)<=higher_freq_alpha);
        
            if length(col)>1
           
                [r,c] = find(pks(col)==max(pks(col)));
            
                IAPF_off_hdEEG(s) = f(locs(col(r)));
                scatter(IAPF_off_hdEEG(s),pks(col(r)),700,'MarkerFaceColor',[0.9718 0.5553 0.7741],'MarkerEdgeColor','k','MarkerFaceAlpha',1,'LineWidth',2)
%                 scatter(ITPF_off_hdEEG(s),pks(col(r)),300,'k','filled','MarkerFaceAlpha',.6)


            else
            
                IAPF_off_hdEEG(s) = f(locs(col));
                scatter(IAPF_off_hdEEG(s),pks(col),700,'MarkerFaceColor',[0.9718 0.5553 0.7741],'MarkerEdgeColor','k','MarkerFaceAlpha',1,'LineWidth',3)
%                 scatter(ITPF_off_hdEEG(s),pks(col),300,'k','filled','MarkerFaceAlpha',.6)

            end
        
        
        end
        
        

% end

  set(gca,'Fontsize',35,'TickDir','out','LineWidth',3);
  box off
  axis square
  xlabel('Frequency (Hz)');
  ylabel({'Normalized power','(z-score)'});
  xlim([5 15]);
  ylim([-0.5 1.5]);
  xticks(6:2:14);
  xtickformat('%.1f')
  ytickformat('%.1f')
%   area([4.5 7.5],[2 2],0,'FaceColor',[0.5 0.5 0.5],'FaceAlpha',.1,'EdgeColor','none','LineStyle','none')
  area([7.5 12.5],[1.5 1.5],-0.5,'FaceColor',[0.5 0.5 0.5],'FaceAlpha',.1,'EdgeColor','none','LineStyle','none')
%   xline(4.5,'LineWidth',1,'LineStyle','--')
  xline(7.5,'LineWidth',1,'LineStyle','--')
  xline(12.5,'LineWidth',1,'LineStyle','--')
  
% saveas(fig,[Savefolder,'Figure3A_Ind_spectrum_alpha.svg']);  
  
%% hdEEG - Theta

colors = distinguishable_colors(18);

% colors = colorGradient([0.2 0.2 0.2],[0.7 0.7 0.7],18)

% colors = linspecer(18);
    
% for con = 1:8
    
    fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
        
       for s = 1:length(incl_sub)

    
        zpower = (psd_OFF_allcon(incl_sub(s),:) - nanmean(psd_OFF_allcon(incl_sub(s),:)))/nanstd(psd_OFF_allcon(incl_sub(s),:));
        zpower_off(s,:) = zpower;
        
        
        plot(f,zpower,'Color',[0 0 0 0.3],'LineWidth',7);
        hold on
        plot(f,zpower,'Color',[colors(s,:) 0.3],'LineWidth',5);
%         plot(f,zpower,'Color',[0.5 0.5 0.5 0.6],'LineWidth',3);
        hold on

        end
        
        plot(f,nanmean(zpower_off,1),'--','Color',[0 0 0 1],'LineWidth',8); 
        
        s = 2;
        zpower = (psd_OFF_allcon(incl_sub(s),:) - nanmean(psd_OFF_allcon(incl_sub(s),:)))/nanstd(psd_OFF_allcon(incl_sub(s),:));
        zpower_off(s,:) = zpower;
        
        plot(f,zpower,'Color',[0 0 0 0.3],'LineWidth',7);
        hold on
            
        plot(f,zpower,'Color',[0.9718 0.5553 0.7741 1],'LineWidth',5); 
        
%         plot(f,zpower,'Color',[0.5 0.5 0.5 0.6],'LineWidth',3);
        hold on
        
         plot(f,nanmean(zpower_off,1),'--','Color',[0 0 0 1],'LineWidth',8); 
        
        
        for s = 1:length(incl_sub)

        [pks,locs] = findpeaks(zpower_off(s,:));
    
        indiv_peaks(s,locs) = 1;
            
        IAPF_off_hdEEG(s) = NaN;
        ITPF_off_hdEEG(s) = NaN;
            
        if find(f(locs)>=lower_freq_theta & f(locs)<=higher_freq_theta)
        
            [row,col] = find(f(locs)>=lower_freq_theta & f(locs)<=higher_freq_theta);
        
            if length(col)>1
           
                [r,c] = find(pks(col)==max(pks(col)));
            
                ITPF_off_hdEEG(s) = f(locs(col(r)));
                scatter(ITPF_off_hdEEG(s),pks(col(r)),700,'MarkerFaceColor',colors(s,:),'MarkerEdgeColor','k','MarkerFaceAlpha',1,'LineWidth',2)
%                 scatter(ITPF_off_hdEEG(s),pks(col(r)),300,'k','filled','MarkerFaceAlpha',.6)


            else
            
                ITPF_off_hdEEG(s) = f(locs(col));
                scatter(ITPF_off_hdEEG(s),pks(col),700,'MarkerFaceColor',colors(s,:),'MarkerEdgeColor','k','MarkerFaceAlpha',1,'LineWidth',3)
%                 scatter(ITPF_off_hdEEG(s),pks(col),300,'k','filled','MarkerFaceAlpha',.6)

            end
        
        
        end
        
        end
        
        
        
        s = 2;

        [pks,locs] = findpeaks(zpower_off(s,:));
    
        indiv_peaks(s,locs) = 1;
            
        IAPF_off_hdEEG(s) = NaN;
        ITPF_off_hdEEG(s) = NaN;
            
        if find(f(locs)>=lower_freq_theta & f(locs)<=higher_freq_theta)
        
            [row,col] = find(f(locs)>=lower_freq_theta & f(locs)<=higher_freq_theta);
        
            if length(col)>1
           
                [r,c] = find(pks(col)==max(pks(col)));
            
                ITPF_off_hdEEG(s) = f(locs(col(r)));
                scatter(ITPF_off_hdEEG(s),pks(col(r)),700,'MarkerFaceColor',[0.9718 0.5553 0.7741],'MarkerEdgeColor','k','MarkerFaceAlpha',1,'LineWidth',2)
%                 scatter(ITPF_off_hdEEG(s),pks(col(r)),300,'k','filled','MarkerFaceAlpha',.6)


            else
            
                ITPF_off_hdEEG(s) = f(locs(col));
                scatter(ITPF_off_hdEEG(s),pks(col),700,'MarkerFaceColor',[0.9718 0.5553 0.7741],'MarkerEdgeColor','k','MarkerFaceAlpha',1,'LineWidth',3)
%                 scatter(ITPF_off_hdEEG(s),pks(col),300,'k','filled','MarkerFaceAlpha',.6)

            end
        
        
        end
        
        
        

% end

  set(gca,'Fontsize',35,'TickDir','out','LineWidth',3);
  box off
  axis square
  xlabel('Frequency (Hz)');
  ylabel({'Normalized power','(z-score)'});
  xlim([3 9]);
  ylim([0 2]);
  xticks(3:1:9);
  xtickformat('%.1f')
  ytickformat('%.1f')
  area([4.5 7.5],[2 2],0,'FaceColor',[0.5 0.5 0.5],'FaceAlpha',.1,'EdgeColor','none','LineStyle','none')
%   area([7.5 12.5],[3 3],-1,'FaceColor',[0.5 0.5 0.5],'FaceAlpha',.1,'EdgeColor','none','LineStyle','none')
  xline(4.5,'LineWidth',1,'LineStyle','--')
  xline(7.5,'LineWidth',1,'LineStyle','--')
%   xline(12.5,'LineWidth',1,'LineStyle','--')
  
%   saveas(fig,[Savefolder,'Figure3B_Ind_spectrum_theta.svg']);  
  