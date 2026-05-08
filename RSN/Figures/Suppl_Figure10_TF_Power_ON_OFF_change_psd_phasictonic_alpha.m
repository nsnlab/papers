clear all;
close all;

addpath(genpath('F:\Valeria\m17462\bigdata\matlab\eeglab')); % eeglab toolbox, see README on where to find this
addpath(genpath('F:\Valeria\m17462\bigdata\matlab\Henry\useful_functions')); % contains linspecer function, circular statistics toolbox functions, echt function, shadedErrorBar function, see README on where to find this

Savefolder = 'F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figures\';

load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Suppl_Figure10_psd_allsub_mICA_avref_OFFONOFF28-May-2024');

conditions = {'Alpha Peak' 'Alpha Falling' 'Alpha Trough' 'Alpha Rising' 'Theta Peak' 'Theta Falling' 'Theta Trough' 'Theta Rising'};

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

%% Average across on and off blocks and calculate change

mpsd_con_ch_stage = mpsd_con_ch; % mpsd_con_ch: sub x ch x con x bins x ep
% mpsd_con_ch_stage = mpsd_con_ch_phasic;

% mpsd_con_ch_stage(3,:,7,:,:) = NaN; % should be NaN as this participant did not have this condition

on_block = 7:12;
off_block = 1:6;
all_ep = 1:18;

ch = alpha_cluster_combined; %[2 34 65 94]; % Fz, AFz, AFF1h, AFF2h
% ch = 16:18; % O1, Oz, Oz
% ch = cluster_el

incl_sub = setdiff(1:19,12);

%% Plot power change all con

% fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
% 
% for cond = 1:8
% 
%     subplot(2,4,cond)
%     
%     psd_on_ch = squeeze(nanmean(mpsd_con_ch_stage(incl_sub,ch,cond,:,all_ep),2));
%     m_psd_off_ch = nanmean(squeeze(nanmean(mpsd_con_ch_stage(incl_sub,ch,cond,:,off_block),2)),3);
%     perc_change = (psd_on_ch./m_psd_off_ch-1)*100;
%     
% %     psd_tf = smoothdata(perc_change,3,'movmean',2);
%     
%     movmean_s = 2;
%     psd_tf = movmean(perc_change,[movmean_s 0],3);
%     
%     m_psd_tf = squeeze(nanmean(psd_tf,1));
%     
% %     mpsd_tf_flipped = flip(mpsd_tf,1);
% %     f_flipped = flip(f);
%    
% %     imagesc(1:length(on_block),f(f<20),m_psd_tf(f<20,:),[-30 30]);  
%     imagesc(all_ep,f,m_psd_tf,[-50 50]);  
%     axis tight
%     yline(4.5)
%     yline(7.5)
%     yline(12.5)
%     ylim([0 18]);
% %     title(plot_cond_name{cond})
%     ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
%     colormap(flipud(brewermap(64,'RdBu')))
%     set(gca,'YDir','normal')
%     title(conditions(cond));
% %     xticks(0:5:40)
% %     xticklabels(0:5:40)
%     xlabel('Time (s)')
%     ylabel('Frequency (Hz)')
% 
%     xline(6)
%     xline(12)
% 
% 
%     
% end
% 
% % saveas(fig,[Savefolder,'TF_change_alpha_statsresult_cluster_con',conditions{cond},'.svg']);
% 

%% Plots stats all con

% fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])

cond = 1 %:4

%     subplot(2,4,cond)
fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
   
    psd_on_ch = squeeze(nanmean(mpsd_con_ch_stage(incl_sub,ch,cond,:,all_ep),2));
    m_psd_off_ch = nanmean(squeeze(nanmean(mpsd_con_ch_stage(incl_sub,ch,cond,:,off_block),2)),3);
    perc_change = (psd_on_ch./m_psd_off_ch-1)*100;
    
    psd_on_ch_allcon = squeeze(nanmean(nanmean(mpsd_con_ch_stage(incl_sub,ch,1:4,:,all_ep),2),3));
    m_psd_off_ch_allcon = nanmean(squeeze(nanmean(nanmean(mpsd_con_ch_stage(incl_sub,ch,1:4,:,off_block),2),3)),3);
    perc_change_allcon = (psd_on_ch_allcon./m_psd_off_ch_allcon-1)*100;
    
    perc_change_norm = perc_change - perc_change_allcon;
    
%     psd_tf = smoothdata(perc_change,2,'movmean',5);

    movmean_s = 1;
    movmean_s2 = 1;
    psd_tf = movmean(perc_change,[movmean_s movmean_s2],3);
%     psd_tf = movmean(perc_change_norm,[movmean_s movmean_s2],3);
    
    clear p_value t_value
    for ep = 1:size(psd_tf,3)
        
        for b = 1:size(psd_tf,2)
        
            [h,p,ci,stats] = ttest(psd_tf(:,b,ep));
            p_value(ep,b) = p;
            t_value(ep,b) = stats.tstat;
       
        end
          
    end
    
    
    sigvals = p_value;
    sigvals(p_value <= 0.05) = 1;
    sigvals(p_value > 0.05)=0;
    
    [L,n] = bwlabel(sigvals);
    
    plotVals = zeros(size(psd_tf,3),size(psd_tf,2));
    
    for i = 1:n
       
        if sum(sum(L==i))>=1
           
            for r = 1:length(plotVals(:,1))
            
            plotVals(r,L(r,:)==i) = 1;
            
            end
            
        end
        
    end
    
    
    y = t_value;
    
    y2 = y;
    for r = 1:length(y2(:,1))
    y2(r,plotVals(r,:)==0) = 0;
    end

    x = 1:size(y2,1);
    ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
    colormap(flipud(brewermap(64,'RdBu')))
    imagesc(1:size(y2,1),f,y2',[-2 2]); 
    hold on
    ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
    colormap(flipud(brewermap(64,'RdBu')))
    imagesc(1:size(y,1),f,y','AlphaData',0.4,[-5 5]);  
    hold on
    
    [B,L] = bwboundaries(plotVals,'noholes');
    
    for k = 1:length(B)
        boundary = B{k};
        
        f_unique = unique(f(boundary(:,2)))
        
        clear x_lower x_upper
        for ff=1:length(f_unique)
            fff = f_unique(ff);
            fff_ndx = find(f(boundary(:,2))==fff);
            if length(fff_ndx) >= 2
            x_lower(ff) = boundary(fff_ndx(1),1)-0.5;
            x_upper(ff) = boundary(fff_ndx(end),1)+0.5;
            elseif length(fff_ndx) < 2
            x_lower(ff) = boundary(fff_ndx(1),1)-0.5;
            x_upper(ff) = boundary(fff_ndx(1),1)+0.5;
            end

        end
%         plot(boundary(:,1), f(boundary(:,2)), 'k', 'LineWidth', 1)
%           plot(x(boundary(:,1)), f(boundary(:,2)), 'k', 'LineWidth', 1)
        plot(x_lower, f_unique, 'k', 'LineWidth', 1)
        hold on
        plot(x_upper, f_unique, 'k', 'LineWidth', 1)
        hold on
        plot([x_lower(1) x_upper(1)], [f_unique(1) f_unique(1)], 'k', 'LineWidth', 1)
        hold on
        plot([x_lower(end) x_upper(end)], [f_unique(end) f_unique(end)], 'k', 'LineWidth', 1)

    end

        
    set(gca,'YDir','normal')
    axis tight
%     yline(4.5,'LineStyle','--','LineWidth',2)
    yline(7.5,'LineStyle','-','LineWidth',2)
    yline(12.5,'-','LineWidth',2)
%     title(plot_cond_name{cond})
   
%     xticks(0:5:40)
%     xticklabels(0:5:40)
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')
    xlim([1 17]);
    ylim([0 18]);
    box off
    axis square
    set(gca,'Fontsize',35,'TickDir','out','LineWidth',3);
    
    xline(6,'LineStyle','-','LineWidth',2)
    xline(5,'LineStyle','--','LineWidth',2)
    xline(12,'LineStyle','-','LineWidth',2)
    xline(13,'LineStyle','--','LineWidth',2)
    
    title(conditions{cond});
    
%     saveas(fig,[Savefolder,'TF_ttest_alpha_statsresult_cluster_con',conditions{cond},'_notnorm.svg']);

    
% end


% saveas(fig,[Savefolder,'TF_ttest_alpha_statsresult_cluster_con',conditions{cond},'.svg']);


%% Alpha Peak vs Trough

fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])

% subplot(2,4,1)

psd_on_ch_peak = squeeze(nanmean(mpsd_con_ch_stage(incl_sub,ch,1,:,all_ep),2));
m_psd_off_ch_peak = nanmean(squeeze(nanmean(mpsd_con_ch_stage(incl_sub,ch,1,:,off_block),2)),3);
perc_change_peak = (psd_on_ch_peak./m_psd_off_ch_peak-1)*100;

psd_on_ch_allcon = squeeze(nanmean(nanmean(mpsd_con_ch_stage(incl_sub,ch,1:4,:,all_ep),2),3));
m_psd_off_ch_allcon = nanmean(squeeze(nanmean(nanmean(mpsd_con_ch_stage(incl_sub,ch,1:4,:,off_block),2),3)),3);
perc_change_allcon = (psd_on_ch_allcon./m_psd_off_ch_allcon-1)*100;
    
perc_change_peak_norm = perc_change_peak; %- perc_change_allcon;

% psd_tf_peak = smoothdata(perc_change_peak,2,'movmean',5);
movmean_s = 1;
movmean_s2 = 1;
% psd_tf_peak = movmean(perc_change_peak,[movmean_s 0],3);
psd_tf_peak = movmean(perc_change_peak_norm,[movmean_s movmean_s2],3);

psd_on_ch_trough = squeeze(nanmean(mpsd_con_ch_stage(incl_sub,ch,3,:,all_ep),2));
m_psd_off_ch_trough = nanmean(squeeze(nanmean(mpsd_con_ch_stage(incl_sub,ch,3,:,off_block),2)),3);
perc_change_trough = (psd_on_ch_trough./m_psd_off_ch_trough-1)*100;

perc_change_trough_norm = perc_change_trough; % - perc_change_allcon;
  
% psd_tf_trough = smoothdata(perc_change_trough,2,'movmean',5);
% psd_tf_trough = movmean(perc_change_trough,[movmean_s 0],3);
psd_tf_trough = movmean(perc_change_trough_norm,[movmean_s movmean_s2],3);

psd_tf_peak_minus_trough = psd_tf_peak-psd_tf_trough;


 clear p_value t_value
    for ep = 1:size(psd_tf,3)
        
        for b = 1:size(psd_tf,2)
        
            [h,p,ci,stats] = ttest(psd_tf_peak_minus_trough(:,b,ep));
            p_value(ep,b) = p;
            t_value(ep,b) = stats.tstat;
       
        end
          
    end
    
    
    sigvals = p_value;
    sigvals(p_value <= 0.05) = 1;
    sigvals(p_value > 0.05)=0;
    
    [L,n] = bwlabel(sigvals);
    
    plotVals = zeros(size(psd_tf,3),size(psd_tf,2));
    
    for i = 1:n
       
        if sum(sum(L==i))>=1
           
            for r = 1:length(plotVals(:,1))
            
            plotVals(r,L(r,:)==i) = 1;
            
            end
            
        end
        
    end
    
    
    y = t_value;
    
    y2 = y;
    for r = 1:length(y2(:,1))
    y2(r,plotVals(r,:)==0) = 0;
    end
 
    
    x = 1:size(y2,1);
    ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
    colormap(flipud(brewermap(64,'RdBu')))
    imagesc(1:size(y2,1),f,y2',[-2 2]); 
    hold on
    ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
    colormap(flipud(brewermap(64,'RdBu')))
    imagesc(1:size(y,1),f,y','AlphaData',0.4,[-5 5]);  
    hold on
    
    [B,L] = bwboundaries(plotVals,'noholes');
    
    for k = 1:length(B)
        boundary = B{k};
        
        f_unique = unique(f(boundary(:,2)))
        
        clear x_lower x_upper
        for ff=1:length(f_unique)
            fff = f_unique(ff);
            fff_ndx = find(f(boundary(:,2))==fff);
            if length(fff_ndx) >= 2
            x_lower(ff) = boundary(fff_ndx(1),1)-0.5;
            x_upper(ff) = boundary(fff_ndx(end),1)+0.5;
            elseif length(fff_ndx) < 2
            x_lower(ff) = boundary(fff_ndx(1),1)-0.5;
            x_upper(ff) = boundary(fff_ndx(1),1)+0.5;
            end

        end
%         plot(boundary(:,1), f(boundary(:,2)), 'k', 'LineWidth', 1)
%           plot(x(boundary(:,1)), f(boundary(:,2)), 'k', 'LineWidth', 1)
        plot(x_lower, f_unique, 'k', 'LineWidth', 1)
        hold on
        plot(x_upper, f_unique, 'k', 'LineWidth', 1)
        hold on
        plot([x_lower(1) x_upper(1)], [f_unique(1) f_unique(1)], 'k', 'LineWidth', 1)
        hold on
        plot([x_lower(end) x_upper(end)], [f_unique(end) f_unique(end)], 'k', 'LineWidth', 1)

    end

        
    set(gca,'YDir','normal')
    axis tight
%     yline(4.5,'LineStyle','--','LineWidth',2)
    yline(7.5,'LineStyle','-','LineWidth',2)
    yline(12.5,'-','LineWidth',2)
%     title(plot_cond_name{cond})
   
%     xticks(0:5:40)
%     xticklabels(0:5:40)
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')
    xlim([1 17]);
    ylim([0 18]);
    box off
    axis square
    set(gca,'Fontsize',35,'TickDir','out','LineWidth',3);
    
    xline(6,'LineStyle','-','LineWidth',2)
    xline(5,'LineStyle','--','LineWidth',2)
    xline(12,'LineStyle','-','LineWidth',2)
    xline(13,'LineStyle','--','LineWidth',2)

    title('Alpha Peak vs Alpha Trough');

% saveas(fig,[Savefolder,'TF_ttest_alpha_statsresult_cluster_peak_vs_trough.svg']);

    
%% Alpha Falling vs Rising

fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])

% subplot(2,4,2)

psd_on_ch_falling = squeeze(nanmean(mpsd_con_ch_stage(incl_sub,ch,2,:,all_ep),2));
m_psd_off_ch_falling = nanmean(squeeze(nanmean(mpsd_con_ch_stage(incl_sub,ch,2,:,off_block),2)),3);
perc_change_falling = (psd_on_ch_falling./m_psd_off_ch_falling-1)*100;

psd_on_ch_allcon = squeeze(nanmean(nanmean(mpsd_con_ch_stage(incl_sub,ch,1:4,:,all_ep),2),3));
m_psd_off_ch_allcon = nanmean(squeeze(nanmean(nanmean(mpsd_con_ch_stage(incl_sub,ch,1:4,:,off_block),2),3)),3);
perc_change_allcon = (psd_on_ch_allcon./m_psd_off_ch_allcon-1)*100;
    
perc_change_falling_norm = perc_change_falling; % - perc_change_allcon;
    
% psd_tf_falling = smoothdata(perc_change_falling,2,'movmean',5);
movmean_s = 1;
movmean_s2 = 1;
psd_tf_falling = movmean(perc_change_falling_norm,[movmean_s movmean_s2],3);

psd_on_ch_rising = squeeze(nanmean(mpsd_con_ch_stage(incl_sub,ch,4,:,all_ep),2));
m_psd_off_ch_rising = nanmean(squeeze(nanmean(mpsd_con_ch_stage(incl_sub,ch,4,:,off_block),2)),3);
perc_change_rising = (psd_on_ch_rising./m_psd_off_ch_rising-1)*100;
    
perc_change_rising_norm = perc_change_rising; % - perc_change_allcon;


% psd_tf_rising = smoothdata(perc_change_rising,2,'movmean',5);
psd_tf_rising = movmean(perc_change_rising_norm,[movmean_s movmean_s2],3);

psd_tf_falling_minus_rising = psd_tf_falling-psd_tf_rising;


 clear p_value t_value
    for ep = 1:size(psd_tf,3)
        
        for b = 1:size(psd_tf,2)
        
            [h,p,ci,stats] = ttest(psd_tf_falling_minus_rising(:,b,ep));
            p_value(ep,b) = p;
            t_value(ep,b) = stats.tstat;
       
        end
          
    end
    
    
    sigvals = p_value;
    sigvals(p_value <= 0.05) = 1;
    sigvals(p_value > 0.05)=0;
    
    [L,n] = bwlabel(sigvals);
    
    plotVals = zeros(size(psd_tf,3),size(psd_tf,2));
    
    for i = 1:n
       
        if sum(sum(L==i))>=1
           
            for r = 1:length(plotVals(:,1))
            
            plotVals(r,L(r,:)==i) = 1;
            
            end
            
        end
        
    end
    
    
    y = t_value;
    
    y2 = y;
    for r = 1:length(y2(:,1))
    y2(r,plotVals(r,:)==0) = 0;
    end

    x = 1:size(y2,1);
    ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
    colormap(flipud(brewermap(64,'RdBu')))
    imagesc(1:size(y2,1),f,y2',[-2 2]); 
    hold on
    ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
    colormap(flipud(brewermap(64,'RdBu')))
    imagesc(1:size(y,1),f,y','AlphaData',0.4,[-5 5]);  
    hold on
    
    [B,L] = bwboundaries(plotVals,'noholes');
    
    for k = 1:length(B)
        boundary = B{k};
        
        f_unique = unique(f(boundary(:,2)))
        
        clear x_lower x_upper
        for ff=1:length(f_unique)
            fff = f_unique(ff);
            fff_ndx = find(f(boundary(:,2))==fff);
            if length(fff_ndx) >= 2
            x_lower(ff) = boundary(fff_ndx(1),1)-0.5;
            x_upper(ff) = boundary(fff_ndx(end),1)+0.5;
            elseif length(fff_ndx) < 2
            x_lower(ff) = boundary(fff_ndx(1),1)-0.5;
            x_upper(ff) = boundary(fff_ndx(1),1)+0.5;
            end

        end
%         plot(boundary(:,1), f(boundary(:,2)), 'k', 'LineWidth', 1)
%           plot(x(boundary(:,1)), f(boundary(:,2)), 'k', 'LineWidth', 1)
        plot(x_lower, f_unique, 'k', 'LineWidth', 1)
        hold on
        plot(x_upper, f_unique, 'k', 'LineWidth', 1)
        hold on
        plot([x_lower(1) x_upper(1)], [f_unique(1) f_unique(1)], 'k', 'LineWidth', 1)
        hold on
        plot([x_lower(end) x_upper(end)], [f_unique(end) f_unique(end)], 'k', 'LineWidth', 1)

    end
    
    
   set(gca,'YDir','normal')
    axis tight
%     yline(4.5,'LineStyle','--','LineWidth',2)
    yline(7.5,'LineStyle','-','LineWidth',2)
    yline(12.5,'-','LineWidth',2)
%     title(plot_cond_name{cond})
   
%     xticks(0:5:40)
%     xticklabels(0:5:40)
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')
    xlim([1 17]);
    ylim([0 18]);
    box off
    axis square
    set(gca,'Fontsize',35,'TickDir','out','LineWidth',3);
    
    xline(6,'LineStyle','-','LineWidth',2)
    xline(5,'LineStyle','--','LineWidth',2)
    xline(12,'LineStyle','-','LineWidth',2)
    xline(13,'LineStyle','--','LineWidth',2)

    title('Alpha Falling vs Alpha Rising');

%     saveas(fig,[Savefolder,'TF_ttest_alpha_statsresult_cluster_falling_vs_rising.svg']);


