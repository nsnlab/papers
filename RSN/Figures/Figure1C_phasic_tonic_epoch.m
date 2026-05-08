clear all;
close all;

addpath(genpath('F:\Valeria\m17462\bigdata\matlab\eeglab')); % eeglab toolbox, see README on where to find this
addpath(genpath('F:\Valeria\m17462\bigdata\matlab\eBOSC'));  % eBOSC toolbox, see README on where to find this
addpath(genpath('F:\Valeria\m17462\bigdata\matlab\Henry\useful_functions')); % contains linspecer function, circular statistics toolbox functions, echt function, shadedErrorBar function, see README on where to find this

Folderpath = 'F:\Valeria\RSN\data\for_sharing\data_to_make_figures\';
sub_Folderpath = dir([Folderpath,'Figure1C_RSN_001*']);

Savefolder = 'F:\Valeria\RSN\data\for_sharing\data_to_make_figures\';

%% Average across on and off blocks and calculate change
lower_freq_alpha = 7.5;
higher_freq_alpha = 12.5;
lower_freq_theta = 4.5;
higher_freq_theta = 7.5;

%%

s = 1;

mICA_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_sleep*_fil_czref_mICA_avref.set']);
EEG = pop_loadset('filename',[mICA_file(1).name],'filepath',[Folderpath,sub_Folderpath(s).name]);

auxch_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_sleep*_auxch_all.set']);
EEG_aux = pop_loadset('filename',[auxch_file(1).name],'filepath',[Folderpath,sub_Folderpath(s).name]);
    
goodREM_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_sleep*_fil_czref_goodREM.mat']);
load([Folderpath,sub_Folderpath(s).name,filesep,goodREM_file(1).name]);
    
nm_good_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_nm_good.mat']);
load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name]); 

waves_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_eBOSC_waves.mat']);
load([Folderpath,sub_Folderpath(s).name,filesep,waves_file(1).name])

%%

 ch = 2; % Fz

 % find good waves
 good_ndx = [];
   for w = 1:length(waves_allepch.startsamp)
       samps = waves_allepch.startsamp(w):waves_allepch.endsamp(w);
       samps_good = intersect(samps,rem_goodsamp2);
       if isequal(length(samps),length(samps_good))
           good_ndx = [good_ndx w]; 
       end 
   end
   
  waves_allepch_good = waves_allepch(good_ndx,:);
  
  % extract data for channels to plot
   data = double(EEG.data(ch,:));
   lEOG = EEG_aux.data(3,:);
   rEOG = EEG_aux.data(4,:);
   EMG = EEG_aux.data(2,:);
   ECG = EEG_aux.data(5,:);
      
   % filter EMG data
   order=4;
   Lp=(20/(fs/2)); Hp=(40/(fs/2));
   [b,a] = butter(order,[Lp Hp],'bandpass');
   
   EMG_filt = filtfilt(b,a,EMG);
   
   % filter EEG data in alpha range
   filt_order = 2;
   filt_lf_alpha = 7.5;
   filt_hf_alpha = 12.5;
   [b_alpha,a_alpha] = butter(filt_order, [filt_lf_alpha filt_hf_alpha]/(fs/2), 'bandpass');
   
   data_alphafilt = filtfilt(b_alpha,a_alpha,data);
   
   % filter EEG data in theta range
   filt_lf_theta = 4.5;
   filt_hf_theta = 7.5;
   [b_theta,a_theta] = butter(filt_order, [filt_lf_theta filt_hf_theta]/(fs/2), 'bandpass');
   
   data_thetafilt = filtfilt(b_theta,a_theta,data);
  
   % find rem epochs
   rem_epochs = find(hypno2 == 'R');
   
   % concatenate triggers of all conditions
   trigs_allcon = [];
   allcon = [];
   
   for con = 1:8
       trigs_allcon = [trigs_allcon nm.ON_trigs_StimTrak{con}];
       allcon = [allcon repmat(con,1,length(nm.ON_trigs_StimTrak{con}))];
   end
   
%    trigs = nm.trigs_StimTrak_ERP;

   %% Make plot for tonic epoch
   
   epoch = 21;
   plot_start = 2;
   plot_epochl = 10;
   
%        figure
   ep = rem_epochs(epoch);
   samp_ep = (ep-1)*epochl*fs+1:ep*epochl*fs;
   samp_ep = samp_ep(plot_start*fs+1:plot_start*fs+plot_epochl*fs);
   [trigs_samp_ep trigs_samp_ep_ndx] = intersect(trigs_allcon,samp_ep);
   con_samp_ep = allcon(trigs_samp_ep_ndx)
%    trigs_samp_ep = intersect(trigs,samp_ep);

   phasic_samp_ep = intersect(phasic_goodsamp2,samp_ep);
   tonic_samp_ep = intersect(tonic_goodsamp2,samp_ep);
   diff_phasic_samp_ep = find(diff(phasic_samp_ep)>1);
   phasic_start = [];
   phasic_end = [];
   if ~isempty(phasic_samp_ep) & isempty(diff_phasic_samp_ep)
       phasic_start = phasic_samp_ep(1);
       phasic_end = phasic_samp_ep(end);
   elseif ~isempty(phasic_samp_ep) & ~isempty(diff_phasic_samp_ep)
       phasic_start = [phasic_samp_ep(1) phasic_samp_ep(diff_phasic_samp_ep+1)];
       phasic_end = [phasic_samp_ep(diff_phasic_samp_ep) phasic_samp_ep(end)];
   end

   waves_ep =waves_allepch_good(waves_allepch_good.nep == ep,:);
   startsamp = waves_ep.startsamp;
   endsamp = waves_ep.endsamp;
   duration = waves_ep.duration;
   frequency = waves_ep.frequency;
   cycles = waves_ep.cycles;
   SNR = waves_ep.SNR;
   
   bad_samps = setdiff(samp_ep,rem_goodsamp2);
     
   theta_ndx = find(frequency > lower_freq_theta & frequency < higher_freq_theta);
   alpha_ndx = find(frequency > lower_freq_alpha & frequency < higher_freq_alpha);
%    sigma_ndx = find(frequency > 12.5 & frequency < 16.5);
   cycles_ndx = find(cycles > 3);
   duration_ndx = find(duration > 0.3);

   theta_cycles_ndx = intersect(theta_ndx,cycles_ndx);
   alpha_cycles_ndx = intersect(alpha_ndx,cycles_ndx);
%    sigma_cycles_ndx = intersect(sigma_ndx,cycles_ndx);
   
   theta_cycles_duration_ndx = intersect(theta_cycles_ndx,duration_ndx);
   alpha_cycles_duration_ndx = intersect(alpha_cycles_ndx,duration_ndx);
%    sigma_cycles_duration_ndx = intersect(sigma_cycles_ndx,duration_ndx);

%    SNR_ndx = find(SNR > 1);
%    alpha_cycles_SNR_ndx = intersect(alpha_cycles_ndx,SNR_ndx);
   
   colors = linspecer(4);
     

%%%%%%%%% Tonic - EEG data without additional filtering (just preprocessing filters) %%%%%%%%%

   fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])

   tileplot = tiledlayout(6,2);
   nexttile(1)
   plot(samp_ep,data(samp_ep),'k');
   hold on
   plot(bad_samps,data(bad_samps),'Color',[0.7 0.7 0.7]) % plot badsamps in orange
   hold on
   for c = 1:length(theta_cycles_duration_ndx)   % plot detected theta waves in color
   plot_samps_orig = round(startsamp(theta_cycles_duration_ndx(c)):endsamp(theta_cycles_duration_ndx(c)));
        if ~isempty(intersect(plot_samps_orig,samp_ep))
%             plot(plot_samps_orig,data(plot_samps_orig),'Color',[0.4660 0.6740 0.1880]) %green 
            plot(plot_samps_orig,data(plot_samps_orig),'Color',[1.0000    0.0745    0.6510]) %pink
            hold on
        end
   end
   hold on
   for c = 1:length(alpha_cycles_duration_ndx)   % plot detected alpha waves in color
   plot_samps_orig = round(startsamp(alpha_cycles_duration_ndx(c)):endsamp(alpha_cycles_duration_ndx(c)));
           if ~isempty(intersect(plot_samps_orig,samp_ep))
              plot(plot_samps_orig,data(plot_samps_orig),'Color',[0.3010 0.7450 0.9330]) %clear blue
              hold on
           end
   end
   hold on
%    xticks((ep-1)*epochl*fs+1:2*fs:ep*epochl*fs);
   xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0:1:epochl);
%    for c = 1:length(sigma_cycles_duration_ndx)   
%    plot_samps_orig = round(startsamp(sigma_cycles_duration_ndx(c)):endsamp(sigma_cycles_duration_ndx(c)));
%    plot(plot_samps_orig,data(ch,plot_samps_orig),'Color',[0.8500 0.3250 0.0980]) %orange
%    hold on
%    end
%    title('Fz')
   ylim([-30 30])
   yticks(-30:10:30);
   set(gca,'Fontsize',15);
%    ylabel('Amplitude (\muV)');
   set(gca, 'box','off');
   h = gca;
   h.XAxis.Visible = 'off';
   h.YAxis.Visible = 'off';
    xlim([samp_ep(1) samp_ep(end)])
   xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0-plot_start:1:epochl-plot_start);
   

   
%%%%%%%%% Tonic - EEG data filtered in alpha range %%%%%%%%%

   nexttile(3)
   plot(samp_ep,data_alphafilt(samp_ep),'k');
   hold on
%    if ~isempty(trigs_samp_ep)
%    plot(trigs_samp_ep,-9,'o','MarkerFaceColor',[0.8500 0.3250 0.0980],'MarkerEdgeColor',[0.8500 0.3250 0.0980],'MarkerSize',4); % orange
%    end
   for t = 1:length(trigs_samp_ep)
       con = con_samp_ep(t)
       if con < 5
%        plot(trigs_samp_ep(t),data_alphafilt(trigs_samp_ep(t)),'o','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',4);
       plot(trigs_samp_ep(t),-10,'o','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',4);
       else
%        plot(trigs_samp_ep(t),data_alphafilt(trigs_samp_ep(t)),'o','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',4);
       plot(trigs_samp_ep(t),-10,'o','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',4);
       end
   end
   hold on
   plot(bad_samps,data_alphafilt(bad_samps),'Color',[0.7 0.7 0.7]) %orange
   hold on
%    for c = 1:length(theta_cycles_duration_ndx)   
%    plot_samps_orig = round(startsamp(theta_cycles_duration_ndx(c)):endsamp(theta_cycles_duration_ndx(c)));
%         if ~isempty(intersect(plot_samps_orig,samp_ep))
%             plot(plot_samps_orig,data_alphafilt(plot_samps_orig),'Color',[0.4660 0.6740 0.1880]) %green
%             hold on
%         end
%    end
%    hold on
   for c = 1:length(alpha_cycles_duration_ndx)   
   plot_samps_orig = round(startsamp(alpha_cycles_duration_ndx(c)):endsamp(alpha_cycles_duration_ndx(c)));
           if ~isempty(intersect(plot_samps_orig,samp_ep))
              plot(plot_samps_orig,data_alphafilt(plot_samps_orig),'Color',[0.3010 0.7450 0.9330]) %clear blue
              hold on
           end
   end
   hold on
%    xticks((ep-1)*epochl*fs+1:2*fs:ep*epochl*fs);
   xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0:1:epochl);
   ylim([-10 10])
   yticks(-10:2:10);
   set(gca,'Fontsize',15);
%    ylabel('Amplitude (\muV)');
   set(gca, 'box','off');
   h = gca;
   h.XAxis.Visible = 'off';
   h.YAxis.Visible = 'off';
    xlim([samp_ep(1) samp_ep(end)])
   xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0-plot_start:1:epochl-plot_start); 
   

   
%%%%%%%%% Tonic - EEG data filtered in theta range %%%%%%%%%
   
   nexttile(5)
   plot(samp_ep,data_thetafilt(samp_ep),'k');
   hold on
   hold on
%    if ~isempty(trigs_samp_ep)
%    plot(trigs_samp_ep,-9,'o','MarkerFaceColor',[0.8500 0.3250 0.0980],'MarkerEdgeColor',[0.8500 0.3250 0.0980],'MarkerSize',4); % orange
%    end
%     for t = 1:length(trigs_samp_ep)
%        con = con_samp_ep(t)
%        if con < 5
%        plot(trigs_samp_ep(t),data_thetafilt(trigs_samp_ep(t)),'o','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',4);
% %        plot(trigs_samp_ep(t),-25,'o','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',4);
%        else
%        plot(trigs_samp_ep(t),data_thetafilt(trigs_samp_ep(t)),'o','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',4);
% %        plot(trigs_samp_ep(t),-25,'o','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',4);
%        end
%    end
   hold on
   plot(bad_samps,data(bad_samps),'Color',[0.7 0.7 0.7]) %orange
   hold on
   for c = 1:length(theta_cycles_duration_ndx)   
   plot_samps_orig = round(startsamp(theta_cycles_duration_ndx(c)):endsamp(theta_cycles_duration_ndx(c)));
        if ~isempty(intersect(plot_samps_orig,samp_ep))
            plot(plot_samps_orig,data_thetafilt(plot_samps_orig),'Color',[1.0000    0.0745    0.6510]) %pink
            hold on
        end
   end
%    hold on
%    for c = 1:length(alpha_cycles_duration_ndx)   
%    plot_samps_orig = round(startsamp(alpha_cycles_duration_ndx(c)):endsamp(alpha_cycles_duration_ndx(c)));
%            if ~isempty(intersect(plot_samps_orig,samp_ep))
%               plot(plot_samps_orig,data_thetafilt(plot_samps_orig),'Color',[0.3010 0.7450 0.9330]) %clear blue
%               hold on
%            end
%    end
   hold on
%    xticks((ep-1)*epochl*fs+1:2*fs:ep*epochl*fs);
   xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0:1:epochl);
   ylim([-10 10])
   yticks(-10:2:10);
   set(gca,'Fontsize',15);
%    ylabel('Amplitude (\muV)');
   set(gca, 'box','off');
   h = gca;
   h.XAxis.Visible = 'off';
   h.YAxis.Visible = 'off';
   xlim([samp_ep(1) samp_ep(end)])
   xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0-plot_start:1:epochl-plot_start);   
   
  
    
%%%%%%%%% Tonic - EOG left %%%%%%%%%

    nexttile(7)
    plot(samp_ep,lEOG(samp_ep),'Color',[1 0 0])
    hold on
%    for p = 1:length(phasic_start)
%    area([phasic_start(p) phasic_end(p)],[150 150],-150,'FaceColor',[0.3 0.3 0.3],'FaceAlpha',.1,'EdgeColor','none','LineStyle','none')
%    end
    ylim([-130 130])
%     title('EOG')
%     legend({'lEOG' 'rEOG'})
     xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0:1:epochl);
    set(gca,'Fontsize',15);
%     ylabel('Amplitude (\muV)');
    set(gca, 'box','off');
    h = gca;
    h.XAxis.Visible = 'off';
    h.YAxis.Visible = 'off';
    xlim([samp_ep(1) samp_ep(end)]);
    
    
    
%%%%%%%%% Tonic - EOG right %%%%%%%%%

    nexttile(9)
    plot(samp_ep,rEOG(samp_ep),'Color',[1 0 0])
    hold on
%    for p = 1:length(phasic_start)
%    area([phasic_start(p) phasic_end(p)],[150 150],-150,'FaceColor',[0.3 0.3 0.3],'FaceAlpha',.1,'EdgeColor','none','LineStyle','none')
%    end
    ylim([-130 130])
%     title('EOG')
%     legend({'lEOG' 'rEOG'})
     xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0:1:epochl);
    set(gca,'Fontsize',15);
%     ylabel('Amplitude (\muV)');
    set(gca, 'box','off');
    h = gca;
    h.XAxis.Visible = 'off';
    h.YAxis.Visible = 'off';
    xlim([samp_ep(1) samp_ep(end)]);
  
    
    
%%%%%%%%% Tonic - EMG %%%%%%%%%

    nexttile(11)
    plot(samp_ep,EMG_filt(samp_ep),'Color','b')
    hold on
%    for p = 1:length(phasic_start)
%    area([phasic_start(p) phasic_end(p)],[50 50],-50,'FaceColor',[0.3 0.3 0.3],'FaceAlpha',.1,'EdgeColor','none','LineStyle','none')
%    end
   ylim([-15 15])
    yticks(-15:5:15);
%     title('EMG')
    xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0-plot_start:1:epochl-plot_start);
    set(gca,'Fontsize',15);
    set(gca, 'box','off');
%     xlabel('Time (s)');
%     ylabel('Amplitude (\muV)');
    h = gca;
    h.XAxis.Visible = 'off';
    h.YAxis.Visible = 'off';
    xlim([samp_ep(1) samp_ep(end)])
  

    tileplot.TileSpacing = 'tight';
    tileplot.Padding = 'compact';
    
    

   %% Make plot for phasic epoch

   epoch = 123; %5 124 195 206 215 252 257
   plot_start = 9;
   plot_epochl = 10;
   
%        figure
   ep = rem_epochs(epoch);
   samp_ep = (ep-1)*epochl*fs+1:ep*epochl*fs;
%    samp_ep = samp_ep(1:plot_epochl*fs);
   samp_ep = samp_ep(plot_start*fs+1:plot_start*fs+plot_epochl*fs);
   [trigs_samp_ep trigs_samp_ep_ndx] = intersect(trigs_allcon,samp_ep);
   con_samp_ep = allcon(trigs_samp_ep_ndx)
%    trigs_samp_ep = intersect(trigs,samp_ep);

   phasic_samp_ep = intersect(phasic_goodsamp2,samp_ep);
   tonic_samp_ep = intersect(tonic_goodsamp2,samp_ep);
   diff_phasic_samp_ep = find(diff(phasic_samp_ep)>1);
   phasic_start = [];
   phasic_end = [];
   if ~isempty(phasic_samp_ep) & isempty(diff_phasic_samp_ep)
       phasic_start = phasic_samp_ep(1);
       phasic_end = phasic_samp_ep(end);
   elseif ~isempty(phasic_samp_ep) & ~isempty(diff_phasic_samp_ep)
       phasic_start = [phasic_samp_ep(1) phasic_samp_ep(diff_phasic_samp_ep+1)];
       phasic_end = [phasic_samp_ep(diff_phasic_samp_ep) phasic_samp_ep(end)];
   end

   waves_ep =waves_allepch_good(waves_allepch_good.nep == ep,:);
   startsamp = waves_ep.startsamp;
   endsamp = waves_ep.endsamp;
   duration = waves_ep.duration;
   frequency = waves_ep.frequency;
   cycles = waves_ep.cycles;
   SNR = waves_ep.SNR;
   
   bad_samps = setdiff(samp_ep,rem_goodsamp2);
     
   theta_ndx = find(frequency > lower_freq_theta & frequency < higher_freq_theta);
   alpha_ndx = find(frequency > lower_freq_alpha & frequency < higher_freq_alpha);
%    sigma_ndx = find(frequency > 12.5 & frequency < 16.5);
   cycles_ndx = find(cycles > 3);
   duration_ndx = find(duration > 0.3);

   theta_cycles_ndx = intersect(theta_ndx,cycles_ndx);
   alpha_cycles_ndx = intersect(alpha_ndx,cycles_ndx);
%    sigma_cycles_ndx = intersect(sigma_ndx,cycles_ndx);
   
   theta_cycles_duration_ndx = intersect(theta_cycles_ndx,duration_ndx);
   alpha_cycles_duration_ndx = intersect(alpha_cycles_ndx,duration_ndx);
%    sigma_cycles_duration_ndx = intersect(sigma_cycles_ndx,duration_ndx);

%    SNR_ndx = find(SNR > 1);
%    alpha_cycles_SNR_ndx = intersect(alpha_cycles_ndx,SNR_ndx);
   
   colors = linspecer(4);

   
%%%%%%%%% Phasic - EEG data without additional filtering (just preprocessing filters) %%%%%%%%%

%    fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])

%    tileplot = tiledlayout(6,2);
   nexttile(2)
   plot(samp_ep,data(samp_ep),'k');
   hold on
   plot(bad_samps,data(bad_samps),'Color',[0.7 0.7 0.7]) %orange
   hold on
   for c = 1:length(theta_cycles_duration_ndx)   
   plot_samps_orig = round(startsamp(theta_cycles_duration_ndx(c)):endsamp(theta_cycles_duration_ndx(c)));
        if ~isempty(intersect(plot_samps_orig,samp_ep))
%             plot(plot_samps_orig,data(plot_samps_orig),'Color',[0.4660 0.6740 0.1880]) %green
            plot(plot_samps_orig,data(plot_samps_orig),'Color',[1.0000    0.0745    0.6510]) %pink
            hold on
        end
   end
   hold on
   for c = 1:length(alpha_cycles_duration_ndx)   
   plot_samps_orig = round(startsamp(alpha_cycles_duration_ndx(c)):endsamp(alpha_cycles_duration_ndx(c)));
           if ~isempty(intersect(plot_samps_orig,samp_ep))
              plot(plot_samps_orig,data(plot_samps_orig),'Color',[0.3010 0.7450 0.9330]) %clear blue
              hold on
           end
   end
   hold on
%    xticks((ep-1)*epochl*fs+1:2*fs:ep*epochl*fs);
   xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0:1:epochl);
%    for c = 1:length(sigma_cycles_duration_ndx)   
%    plot_samps_orig = round(startsamp(sigma_cycles_duration_ndx(c)):endsamp(sigma_cycles_duration_ndx(c)));
%    plot(plot_samps_orig,data(ch,plot_samps_orig),'Color',[0.8500 0.3250 0.0980]) %orange
%    hold on
%    end
%    title('Fz')
   ylim([-30 30])
   yticks(-30:10:30);
   set(gca,'Fontsize',15);
%    ylabel('Amplitude (\muV)');
   set(gca, 'box','off');
   h = gca;
   h.XAxis.Visible = 'off';
   h.YAxis.Visible = 'off';
    xlim([samp_ep(1) samp_ep(end)])
   xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0-plot_start:1:epochl-plot_start);
   

   
%%%%%%%%% Phasic - EEG data filtered in alpha range %%%%%%%%%

   nexttile(4)
   plot(samp_ep,data_alphafilt(samp_ep),'k');
   hold on
%    if ~isempty(trigs_samp_ep)
%    plot(trigs_samp_ep,-9,'o','MarkerFaceColor',[0.8500 0.3250 0.0980],'MarkerEdgeColor',[0.8500 0.3250 0.0980],'MarkerSize',4); % orange
%    end
   for t = 1:length(trigs_samp_ep)
       con = con_samp_ep(t)
       if con < 5
%        plot(trigs_samp_ep(t),data_alphafilt(trigs_samp_ep(t)),'o','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',4);
       plot(trigs_samp_ep(t),-10,'o','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',4);
       else
%        plot(trigs_samp_ep(t),data_alphafilt(trigs_samp_ep(t)),'o','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',4);
       plot(trigs_samp_ep(t),-10,'o','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',4);
       end
   end
   hold on
   plot(bad_samps,data_alphafilt(bad_samps),'Color',[0.7 0.7 0.7]) %orange
   hold on
%    for c = 1:length(theta_cycles_duration_ndx)   
%    plot_samps_orig = round(startsamp(theta_cycles_duration_ndx(c)):endsamp(theta_cycles_duration_ndx(c)));
%         if ~isempty(intersect(plot_samps_orig,samp_ep))
%             plot(plot_samps_orig,data_alphafilt(plot_samps_orig),'Color',[0.4660 0.6740 0.1880]) %green
%             hold on
%         end
%    end
   hold on
   for c = 1:length(alpha_cycles_duration_ndx)   
   plot_samps_orig = round(startsamp(alpha_cycles_duration_ndx(c)):endsamp(alpha_cycles_duration_ndx(c)));
           if ~isempty(intersect(plot_samps_orig,samp_ep))
              plot(plot_samps_orig,data_alphafilt(plot_samps_orig),'Color',[0.3010 0.7450 0.9330]) %clear blue
              hold on
           end
   end
   hold on
%    xticks((ep-1)*epochl*fs+1:2*fs:ep*epochl*fs);
   xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0:1:epochl);
   ylim([-10 10])
   yticks(-10:2:10);
   set(gca,'Fontsize',15);
%    ylabel('Amplitude (\muV)');
   set(gca, 'box','off');
   h = gca;
   h.XAxis.Visible = 'off';
   h.YAxis.Visible = 'off';
    xlim([samp_ep(1) samp_ep(end)])
   xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0-plot_start:1:epochl-plot_start); 
   

   
%%%%%%%%% Phasic - EEG data filtered in theta range %%%%%%%%%
   
   nexttile(6)
   plot(samp_ep,data_thetafilt(samp_ep),'k');
   hold on
   hold on
%    if ~isempty(trigs_samp_ep)
%    plot(trigs_samp_ep,-9,'o','MarkerFaceColor',[0.8500 0.3250 0.0980],'MarkerEdgeColor',[0.8500 0.3250 0.0980],'MarkerSize',4); % orange
%    end
%   for t = 1:length(trigs_samp_ep)
%        con = con_samp_ep(t)
%        if con < 5
%        plot(trigs_samp_ep(t),data_thetafilt(trigs_samp_ep(t)),'o','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',4);
% %        plot(trigs_samp_ep(t),-10,'o','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',4);
%        else
%        plot(trigs_samp_ep(t),data_thetafilt(trigs_samp_ep(t)),'o','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',4);
% %        plot(trigs_samp_ep(t),-10,'o','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',4);
%        end
%    end
   hold on
   plot(bad_samps,data(bad_samps),'Color',[0.7 0.7 0.7]) %orange
   hold on
   for c = 1:length(theta_cycles_duration_ndx)   
   plot_samps_orig = round(startsamp(theta_cycles_duration_ndx(c)):endsamp(theta_cycles_duration_ndx(c)));
        if ~isempty(intersect(plot_samps_orig,samp_ep))
            plot(plot_samps_orig,data_thetafilt(plot_samps_orig),'Color',[1.0000    0.0745    0.6510]) %pink
            hold on
        end
   end
%    hold on
%    for c = 1:length(alpha_cycles_duration_ndx)   
%    plot_samps_orig = round(startsamp(alpha_cycles_duration_ndx(c)):endsamp(alpha_cycles_duration_ndx(c)));
%            if ~isempty(intersect(plot_samps_orig,samp_ep))
%               plot(plot_samps_orig,data_thetafilt(plot_samps_orig),'Color',[0.3010 0.7450 0.9330]) %clear blue
%               hold on
%            end
%    end
   hold on
%    xticks((ep-1)*epochl*fs+1:2*fs:ep*epochl*fs);
   xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0:1:epochl);
   ylim([-10 10])
   yticks(-10:2:10);
   set(gca,'Fontsize',15);
%    ylabel('Amplitude (\muV)');
   set(gca, 'box','off');
   h = gca;
   h.XAxis.Visible = 'off';
   h.YAxis.Visible = 'off';
   xlim([samp_ep(1) samp_ep(end)])
   xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0-plot_start:1:epochl-plot_start);   
   
  
    
%%%%%%%%% Phasic - EOG left %%%%%%%%%

    nexttile(8)
    plot(samp_ep,lEOG(samp_ep),'Color',[1 0 0])
    hold on
%    for p = 1:length(phasic_start)
%    area([phasic_start(p) phasic_end(p)],[150 150],-150,'FaceColor',[0.3 0.3 0.3],'FaceAlpha',.1,'EdgeColor','none','LineStyle','none')
%    end
    ylim([-130 130])
%     title('EOG')
%     legend({'lEOG' 'rEOG'})
     xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0:1:epochl);
    set(gca,'Fontsize',15);
%     ylabel('Amplitude (\muV)');
    set(gca, 'box','off');
    h = gca;
    h.XAxis.Visible = 'off';
    h.YAxis.Visible = 'off';
    xlim([samp_ep(1) samp_ep(end)]);
    
    
    
%%%%%%%%% Phasic - EOG right %%%%%%%%%

    nexttile(10)
%     plot(samp_ep,rEOG(samp_ep),'Color',[0.6350 0.0780 0.1840])
    plot(samp_ep,rEOG(samp_ep),'Color',[1 0 0])
    hold on
%    for p = 1:length(phasic_start)
%    area([phasic_start(p) phasic_end(p)],[150 150],-150,'FaceColor',[0.3 0.3 0.3],'FaceAlpha',.1,'EdgeColor','none','LineStyle','none')
%    end
    ylim([-130 130])
%     title('EOG')
%     legend({'lEOG' 'rEOG'})
     xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0:1:epochl);
    set(gca,'Fontsize',15);
%     ylabel('Amplitude (\muV)');
    set(gca, 'box','off');
    h = gca;
    h.XAxis.Visible = 'off';
    h.YAxis.Visible = 'off';
    xlim([samp_ep(1) samp_ep(end)]);
  
    
    
%%%%%%%%% Phasic - EMG %%%%%%%%%

    nexttile(12)
    plot(samp_ep,EMG_filt(samp_ep),'Color','b')
    hold on
%    for p = 1:length(phasic_start)
%    area([phasic_start(p) phasic_end(p)],[50 50],-50,'FaceColor',[0.3 0.3 0.3],'FaceAlpha',.1,'EdgeColor','none','LineStyle','none')
%    end
   ylim([-15 15])
    yticks(-15:5:15);
%     title('EMG')
    xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0-plot_start:1:epochl-plot_start);
    set(gca,'Fontsize',15);
    set(gca, 'box','off');
%     xlabel('Time (s)');
%     ylabel('Amplitude (\muV)');
    h = gca;
    h.XAxis.Visible = 'off';
    h.YAxis.Visible = 'off';
    xlim([samp_ep(1) samp_ep(end)])
  

    tileplot.TileSpacing = 'compact';
    tileplot.Padding = 'compact';
    
%     saveas(fig,[Savefolder,'Figure1C_phasic_tonic_epoch.svg']);
    

%%%%%%%%%%%%%%%%%%%%% With axis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

     %% Tonic


   % example plot with RSN_001 and epoch 5
%    for epoch = 1:10 % 42,46 muscle twitches, 52 has very clear alpha

   epoch = 21; %21 193 217
   plot_start = 2;
   plot_epochl = 10;
   
%        figure
   ep = rem_epochs(epoch);
   samp_ep = (ep-1)*epochl*fs+1:ep*epochl*fs;
   samp_ep = samp_ep(plot_start*fs+1:plot_start*fs+plot_epochl*fs);
   [trigs_samp_ep trigs_samp_ep_ndx] = intersect(trigs_allcon,samp_ep);
   con_samp_ep = allcon(trigs_samp_ep_ndx)
%    trigs_samp_ep = intersect(trigs,samp_ep);

   phasic_samp_ep = intersect(phasic_goodsamp2,samp_ep);
   tonic_samp_ep = intersect(tonic_goodsamp2,samp_ep);
   diff_phasic_samp_ep = find(diff(phasic_samp_ep)>1);
   phasic_start = [];
   phasic_end = [];
   if ~isempty(phasic_samp_ep) & isempty(diff_phasic_samp_ep)
       phasic_start = phasic_samp_ep(1);
       phasic_end = phasic_samp_ep(end);
   elseif ~isempty(phasic_samp_ep) & ~isempty(diff_phasic_samp_ep)
       phasic_start = [phasic_samp_ep(1) phasic_samp_ep(diff_phasic_samp_ep+1)];
       phasic_end = [phasic_samp_ep(diff_phasic_samp_ep) phasic_samp_ep(end)];
   end

   waves_ep =waves_allepch_good(waves_allepch_good.nep == ep,:);
   startsamp = waves_ep.startsamp;
   endsamp = waves_ep.endsamp;
   duration = waves_ep.duration;
   frequency = waves_ep.frequency;
   cycles = waves_ep.cycles;
   SNR = waves_ep.SNR;
   
   bad_samps = setdiff(samp_ep,rem_goodsamp2);
     
   theta_ndx = find(frequency > lower_freq_theta & frequency < higher_freq_theta);
   alpha_ndx = find(frequency > lower_freq_alpha & frequency < higher_freq_alpha);
%    sigma_ndx = find(frequency > 12.5 & frequency < 16.5);
   cycles_ndx = find(cycles > 3);
   duration_ndx = find(duration > 0.3);

   theta_cycles_ndx = intersect(theta_ndx,cycles_ndx);
   alpha_cycles_ndx = intersect(alpha_ndx,cycles_ndx);
%    sigma_cycles_ndx = intersect(sigma_ndx,cycles_ndx);
   
   theta_cycles_duration_ndx = intersect(theta_cycles_ndx,duration_ndx);
   alpha_cycles_duration_ndx = intersect(alpha_cycles_ndx,duration_ndx);
%    sigma_cycles_duration_ndx = intersect(sigma_cycles_ndx,duration_ndx);

%    SNR_ndx = find(SNR > 1);
%    alpha_cycles_SNR_ndx = intersect(alpha_cycles_ndx,SNR_ndx);
   
   colors = linspecer(4);
     

   
% EEG Tonic

   fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])

   tileplot = tiledlayout(6,2);
   nexttile(1)
   plot(samp_ep,data(samp_ep),'k');
   hold on
%    for p = 1:length(phasic_start)
%    area([phasic_start(p) phasic_end(p)],[50 50],-50,'FaceColor',[0.3 0.3 0.3],'FaceAlpha',.1,'EdgeColor','none','LineStyle','none')
%    end
%    for p = 1:length(phasic_samp_ep)
%    plot(phasic_samp_ep(p),data(ch,phasic_samp_ep(p)),'o','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',4);
%    hold on
%    end
%    hold on
%    if ~isempty(trigs_samp_ep)
%    plot(trigs_samp_ep,-25,'o','MarkerFaceColor',[0.8500 0.3250 0.0980],'MarkerEdgeColor',[0.8500 0.3250 0.0980],'MarkerSize',4); % orange
%    end
%    for t = 1:length(trigs_samp_ep)
% %        con = con_samp_ep(t)
%        if con < 5
%        plot(trigs_samp_ep(t),data(ch,trigs_samp_ep(t)),'o','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',4);
% %        plot(trigs_samp_ep(t),-25,'o','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',4);
%        else
%        plot(trigs_samp_ep(t),data(ch,trigs_samp_ep(t)),'o','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',4);
% %        plot(trigs_samp_ep(t),-25,'o','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',4);
%        end
%    end
   hold on
   plot(bad_samps,data(bad_samps),'Color',[0.7 0.7 0.7]) %orange
   hold on
   for c = 1:length(theta_cycles_duration_ndx)   
   plot_samps_orig = round(startsamp(theta_cycles_duration_ndx(c)):endsamp(theta_cycles_duration_ndx(c)));
        if ~isempty(intersect(plot_samps_orig,samp_ep))
%             plot(plot_samps_orig,data(plot_samps_orig),'Color',[0.4660 0.6740 0.1880]) %green 
            plot(plot_samps_orig,data(plot_samps_orig),'Color',[0.9290 0.6940 0.1250]) %orange 
            hold on
        end
   end
   hold on
   for c = 1:length(alpha_cycles_duration_ndx)   
   plot_samps_orig = round(startsamp(alpha_cycles_duration_ndx(c)):endsamp(alpha_cycles_duration_ndx(c)));
           if ~isempty(intersect(plot_samps_orig,samp_ep))
              plot(plot_samps_orig,data(plot_samps_orig),'Color',[0.3010 0.7450 0.9330]) %clear blue
              hold on
           end
   end
   hold on
%    xticks((ep-1)*epochl*fs+1:2*fs:ep*epochl*fs);
   xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0:1:epochl);
%    for c = 1:length(sigma_cycles_duration_ndx)   
%    plot_samps_orig = round(startsamp(sigma_cycles_duration_ndx(c)):endsamp(sigma_cycles_duration_ndx(c)));
%    plot(plot_samps_orig,data(ch,plot_samps_orig),'Color',[0.8500 0.3250 0.0980]) %orange
%    hold on
%    end
%    title('Fz')
   ylim([-30 30])
   yticks(-30:10:30);
   set(gca,'Fontsize',15);
%    ylabel('Amplitude (\muV)');
   set(gca, 'box','off');
%    h = gca;
%    h.XAxis.Visible = 'off';
%    h.YAxis.Visible = 'off';
    xlim([samp_ep(1) samp_ep(end)])
   xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0-plot_start:1:epochl-plot_start);
   

   
% EEG alphafilt Tonic
   nexttile(3)
   plot(samp_ep,data_alphafilt(samp_ep),'k');
   hold on
%    if ~isempty(trigs_samp_ep)
%    plot(trigs_samp_ep,-9,'o','MarkerFaceColor',[0.8500 0.3250 0.0980],'MarkerEdgeColor',[0.8500 0.3250 0.0980],'MarkerSize',4); % orange
%    end
   for t = 1:length(trigs_samp_ep)
       con = con_samp_ep(t)
       if con < 5
%        plot(trigs_samp_ep(t),data_alphafilt(trigs_samp_ep(t)),'o','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',4);
       plot(trigs_samp_ep(t),-10,'o','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',4);
       else
%        plot(trigs_samp_ep(t),data_alphafilt(trigs_samp_ep(t)),'o','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',4);
       plot(trigs_samp_ep(t),-10,'o','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',4);
       end
   end
   hold on
   plot(bad_samps,data_alphafilt(bad_samps),'Color',[0.7 0.7 0.7]) %orange
   hold on
%    for c = 1:length(theta_cycles_duration_ndx)   
%    plot_samps_orig = round(startsamp(theta_cycles_duration_ndx(c)):endsamp(theta_cycles_duration_ndx(c)));
%         if ~isempty(intersect(plot_samps_orig,samp_ep))
%             plot(plot_samps_orig,data_alphafilt(plot_samps_orig),'Color',[0.4660 0.6740 0.1880]) %green
%             hold on
%         end
%    end
%    hold on
   for c = 1:length(alpha_cycles_duration_ndx)   
   plot_samps_orig = round(startsamp(alpha_cycles_duration_ndx(c)):endsamp(alpha_cycles_duration_ndx(c)));
           if ~isempty(intersect(plot_samps_orig,samp_ep))
              plot(plot_samps_orig,data_alphafilt(plot_samps_orig),'Color',[0.3010 0.7450 0.9330]) %clear blue
              hold on
           end
   end
   hold on
%    xticks((ep-1)*epochl*fs+1:2*fs:ep*epochl*fs);
   xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0:1:epochl);
   ylim([-10 10])
   yticks(-10:2:10);
   set(gca,'Fontsize',15);
%    ylabel('Amplitude (\muV)');
   set(gca, 'box','off');
%    h = gca;
%    h.XAxis.Visible = 'off';
%    h.YAxis.Visible = 'off';
    xlim([samp_ep(1) samp_ep(end)])
   xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0-plot_start:1:epochl-plot_start); 
   

   
   %    EEG thetafilt Tonic
   
   nexttile(5)
   plot(samp_ep,data_thetafilt(samp_ep),'k');
   hold on
   hold on
%    if ~isempty(trigs_samp_ep)
%    plot(trigs_samp_ep,-9,'o','MarkerFaceColor',[0.8500 0.3250 0.0980],'MarkerEdgeColor',[0.8500 0.3250 0.0980],'MarkerSize',4); % orange
%    end
%     for t = 1:length(trigs_samp_ep)
%        con = con_samp_ep(t)
%        if con < 5
%        plot(trigs_samp_ep(t),data_thetafilt(trigs_samp_ep(t)),'o','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',4);
% %        plot(trigs_samp_ep(t),-25,'o','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',4);
%        else
%        plot(trigs_samp_ep(t),data_thetafilt(trigs_samp_ep(t)),'o','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',4);
% %        plot(trigs_samp_ep(t),-25,'o','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',4);
%        end
%    end
   hold on
   plot(bad_samps,data(bad_samps),'Color',[0.7 0.7 0.7]) %orange
   hold on
   for c = 1:length(theta_cycles_duration_ndx)   
   plot_samps_orig = round(startsamp(theta_cycles_duration_ndx(c)):endsamp(theta_cycles_duration_ndx(c)));
        if ~isempty(intersect(plot_samps_orig,samp_ep))
            plot(plot_samps_orig,data_thetafilt(plot_samps_orig),'Color',[0.9290 0.6940 0.1250]) %orange
            hold on
        end
   end
%    hold on
%    for c = 1:length(alpha_cycles_duration_ndx)   
%    plot_samps_orig = round(startsamp(alpha_cycles_duration_ndx(c)):endsamp(alpha_cycles_duration_ndx(c)));
%            if ~isempty(intersect(plot_samps_orig,samp_ep))
%               plot(plot_samps_orig,data_thetafilt(plot_samps_orig),'Color',[0.3010 0.7450 0.9330]) %clear blue
%               hold on
%            end
%    end
   hold on
%    xticks((ep-1)*epochl*fs+1:2*fs:ep*epochl*fs);
   xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0:1:epochl);
   ylim([-10 10])
   yticks(-10:2:10);
   set(gca,'Fontsize',15);
%    ylabel('Amplitude (\muV)');
   set(gca, 'box','off');
%    h = gca;
%    h.XAxis.Visible = 'off';
%    h.YAxis.Visible = 'off';
   xlim([samp_ep(1) samp_ep(end)])
   xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0-plot_start:1:epochl-plot_start);   
   
  
    
%   EOG left Tonic
    nexttile(7)
    plot(samp_ep,lEOG(samp_ep),'Color',[1 0 0])
    hold on
%    for p = 1:length(phasic_start)
%    area([phasic_start(p) phasic_end(p)],[150 150],-150,'FaceColor',[0.3 0.3 0.3],'FaceAlpha',.1,'EdgeColor','none','LineStyle','none')
%    end
    ylim([-130 130])
%     title('EOG')
%     legend({'lEOG' 'rEOG'})
     xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0:1:epochl);
    set(gca,'Fontsize',15);
%     ylabel('Amplitude (\muV)');
    set(gca, 'box','off');
%     h = gca;
%     h.XAxis.Visible = 'off';
%     h.YAxis.Visible = 'off';
    xlim([samp_ep(1) samp_ep(end)]);
    
    
    
%   EOG right Tonic
    nexttile(9)
    plot(samp_ep,rEOG(samp_ep),'Color',[1 0 0])
    hold on
%    for p = 1:length(phasic_start)
%    area([phasic_start(p) phasic_end(p)],[150 150],-150,'FaceColor',[0.3 0.3 0.3],'FaceAlpha',.1,'EdgeColor','none','LineStyle','none')
%    end
    ylim([-130 130])
%     title('EOG')
%     legend({'lEOG' 'rEOG'})
     xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0:1:epochl);
    set(gca,'Fontsize',15);
%     ylabel('Amplitude (\muV)');
    set(gca, 'box','off');
%     h = gca;
%     h.XAxis.Visible = 'off';
%     h.YAxis.Visible = 'off';
    xlim([samp_ep(1) samp_ep(end)]);
  
    
    
%   EMG Tonic
    nexttile(11)
    plot(samp_ep,EMG_filt(samp_ep),'Color','b')
    hold on
%    for p = 1:length(phasic_start)
%    area([phasic_start(p) phasic_end(p)],[50 50],-50,'FaceColor',[0.3 0.3 0.3],'FaceAlpha',.1,'EdgeColor','none','LineStyle','none')
%    end
   ylim([-15 15])
    yticks(-15:5:15);
%     title('EMG')
    xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0-plot_start:1:epochl-plot_start);
    set(gca,'Fontsize',15);
    set(gca, 'box','off');
%     xlabel('Time (s)');
%     ylabel('Amplitude (\muV)');
%     h = gca;
%     h.XAxis.Visible = 'off';
%     h.YAxis.Visible = 'off';
    xlim([samp_ep(1) samp_ep(end)])
  

    tileplot.TileSpacing = 'tight';
    tileplot.Padding = 'compact';
    
    
    % Phasic
  

   % example plot with RSN_001 and epoch 5
%    for epoch = 1:10 % 42,46 muscle twitches, 52 has very clear alpha

   epoch = 123; %5 124 195 206 215 252 257
   plot_start = 9;
   plot_epochl = 10;
   
%        figure
   ep = rem_epochs(epoch);
   samp_ep = (ep-1)*epochl*fs+1:ep*epochl*fs;
%    samp_ep = samp_ep(1:plot_epochl*fs);
   samp_ep = samp_ep(plot_start*fs+1:plot_start*fs+plot_epochl*fs);
   [trigs_samp_ep trigs_samp_ep_ndx] = intersect(trigs_allcon,samp_ep);
   con_samp_ep = allcon(trigs_samp_ep_ndx)
%    trigs_samp_ep = intersect(trigs,samp_ep);

   phasic_samp_ep = intersect(phasic_goodsamp2,samp_ep);
   tonic_samp_ep = intersect(tonic_goodsamp2,samp_ep);
   diff_phasic_samp_ep = find(diff(phasic_samp_ep)>1);
   phasic_start = [];
   phasic_end = [];
   if ~isempty(phasic_samp_ep) & isempty(diff_phasic_samp_ep)
       phasic_start = phasic_samp_ep(1);
       phasic_end = phasic_samp_ep(end);
   elseif ~isempty(phasic_samp_ep) & ~isempty(diff_phasic_samp_ep)
       phasic_start = [phasic_samp_ep(1) phasic_samp_ep(diff_phasic_samp_ep+1)];
       phasic_end = [phasic_samp_ep(diff_phasic_samp_ep) phasic_samp_ep(end)];
   end

   waves_ep =waves_allepch_good(waves_allepch_good.nep == ep,:);
   startsamp = waves_ep.startsamp;
   endsamp = waves_ep.endsamp;
   duration = waves_ep.duration;
   frequency = waves_ep.frequency;
   cycles = waves_ep.cycles;
   SNR = waves_ep.SNR;
   
   bad_samps = setdiff(samp_ep,rem_goodsamp2);
     
   theta_ndx = find(frequency > lower_freq_theta & frequency < higher_freq_theta);
   alpha_ndx = find(frequency > lower_freq_alpha & frequency < higher_freq_alpha);
%    sigma_ndx = find(frequency > 12.5 & frequency < 16.5);
   cycles_ndx = find(cycles > 3);
   duration_ndx = find(duration > 0.3);

   theta_cycles_ndx = intersect(theta_ndx,cycles_ndx);
   alpha_cycles_ndx = intersect(alpha_ndx,cycles_ndx);
%    sigma_cycles_ndx = intersect(sigma_ndx,cycles_ndx);
   
   theta_cycles_duration_ndx = intersect(theta_cycles_ndx,duration_ndx);
   alpha_cycles_duration_ndx = intersect(alpha_cycles_ndx,duration_ndx);
%    sigma_cycles_duration_ndx = intersect(sigma_cycles_ndx,duration_ndx);

%    SNR_ndx = find(SNR > 1);
%    alpha_cycles_SNR_ndx = intersect(alpha_cycles_ndx,SNR_ndx);
   
   colors = linspecer(4);

   
   % EEG Phasic

%    fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])

%    tileplot = tiledlayout(6,2);
   nexttile(2)
   plot(samp_ep,data(samp_ep),'k');
   hold on
%    for p = 1:length(phasic_start)
%    area([phasic_start(p) phasic_end(p)],[50 50],-50,'FaceColor',[0.3 0.3 0.3],'FaceAlpha',.1,'EdgeColor','none','LineStyle','none')
%    end
%    for p = 1:length(phasic_samp_ep)
%    plot(phasic_samp_ep(p),data(ch,phasic_samp_ep(p)),'o','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',4);
%    hold on
%    end
%    hold on
%    if ~isempty(trigs_samp_ep)
%    plot(trigs_samp_ep,-25,'o','MarkerFaceColor',[0.8500 0.3250 0.0980],'MarkerEdgeColor',[0.8500 0.3250 0.0980],'MarkerSize',4); % orange
%    end
%    for t = 1:length(trigs_samp_ep)
% %        con = con_samp_ep(t)
%        if con < 5
%        plot(trigs_samp_ep(t),data(ch,trigs_samp_ep(t)),'o','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',4);
% %        plot(trigs_samp_ep(t),-25,'o','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',4);
%        else
%        plot(trigs_samp_ep(t),data(ch,trigs_samp_ep(t)),'o','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',4);
% %        plot(trigs_samp_ep(t),-25,'o','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',4);
%        end
%    end
   hold on
   plot(bad_samps,data(bad_samps),'Color',[0.7 0.7 0.7]) %orange
   hold on
   for c = 1:length(theta_cycles_duration_ndx)   
   plot_samps_orig = round(startsamp(theta_cycles_duration_ndx(c)):endsamp(theta_cycles_duration_ndx(c)));
        if ~isempty(intersect(plot_samps_orig,samp_ep))
%             plot(plot_samps_orig,data(plot_samps_orig),'Color',[0.4660 0.6740 0.1880]) %green
            plot(plot_samps_orig,data(plot_samps_orig),'Color',[0.9290 0.6940 0.1250]) %orange 
            hold on
        end
   end
   hold on
   for c = 1:length(alpha_cycles_duration_ndx)   
   plot_samps_orig = round(startsamp(alpha_cycles_duration_ndx(c)):endsamp(alpha_cycles_duration_ndx(c)));
           if ~isempty(intersect(plot_samps_orig,samp_ep))
              plot(plot_samps_orig,data(plot_samps_orig),'Color',[0.3010 0.7450 0.9330]) %clear blue
              hold on
           end
   end
   hold on
%    xticks((ep-1)*epochl*fs+1:2*fs:ep*epochl*fs);
   xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0:1:epochl);
%    for c = 1:length(sigma_cycles_duration_ndx)   
%    plot_samps_orig = round(startsamp(sigma_cycles_duration_ndx(c)):endsamp(sigma_cycles_duration_ndx(c)));
%    plot(plot_samps_orig,data(ch,plot_samps_orig),'Color',[0.8500 0.3250 0.0980]) %orange
%    hold on
%    end
%    title('Fz')
   ylim([-30 30])
   yticks(-30:10:30);
   set(gca,'Fontsize',15);
%    ylabel('Amplitude (\muV)');
   set(gca, 'box','off');
%    h = gca;
%    h.XAxis.Visible = 'off';
%    h.YAxis.Visible = 'off';
    xlim([samp_ep(1) samp_ep(end)])
   xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0-plot_start:1:epochl-plot_start);
   

   
% EEG alphafilt Phasic
   nexttile(4)
   plot(samp_ep,data_alphafilt(samp_ep),'k');
   hold on
%    if ~isempty(trigs_samp_ep)
%    plot(trigs_samp_ep,-9,'o','MarkerFaceColor',[0.8500 0.3250 0.0980],'MarkerEdgeColor',[0.8500 0.3250 0.0980],'MarkerSize',4); % orange
%    end
   for t = 1:length(trigs_samp_ep)
       con = con_samp_ep(t)
       if con < 5
%        plot(trigs_samp_ep(t),data_alphafilt(trigs_samp_ep(t)),'o','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',4);
       plot(trigs_samp_ep(t),-10,'o','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',4);
       else
%        plot(trigs_samp_ep(t),data_alphafilt(trigs_samp_ep(t)),'o','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',4);
       plot(trigs_samp_ep(t),-10,'o','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',4);
       end
   end
   hold on
   plot(bad_samps,data_alphafilt(bad_samps),'Color',[0.7 0.7 0.7]) %orange
   hold on
%    for c = 1:length(theta_cycles_duration_ndx)   
%    plot_samps_orig = round(startsamp(theta_cycles_duration_ndx(c)):endsamp(theta_cycles_duration_ndx(c)));
%         if ~isempty(intersect(plot_samps_orig,samp_ep))
%             plot(plot_samps_orig,data_alphafilt(plot_samps_orig),'Color',[0.4660 0.6740 0.1880]) %green
%             hold on
%         end
%    end
   hold on
   for c = 1:length(alpha_cycles_duration_ndx)   
   plot_samps_orig = round(startsamp(alpha_cycles_duration_ndx(c)):endsamp(alpha_cycles_duration_ndx(c)));
           if ~isempty(intersect(plot_samps_orig,samp_ep))
              plot(plot_samps_orig,data_alphafilt(plot_samps_orig),'Color',[0.3010 0.7450 0.9330]) %clear blue
              hold on
           end
   end
   hold on
%    xticks((ep-1)*epochl*fs+1:2*fs:ep*epochl*fs);
   xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0:1:epochl);
   ylim([-10 10])
   yticks(-10:2:10);
   set(gca,'Fontsize',15);
%    ylabel('Amplitude (\muV)');
   set(gca, 'box','off');
%    h = gca;
%    h.XAxis.Visible = 'off';
%    h.YAxis.Visible = 'off';
    xlim([samp_ep(1) samp_ep(end)])
   xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0-plot_start:1:epochl-plot_start); 
   

   
   %    EEG thetafilt Phasic
   
   nexttile(6)
   plot(samp_ep,data_thetafilt(samp_ep),'k');
   hold on
   hold on
%    if ~isempty(trigs_samp_ep)
%    plot(trigs_samp_ep,-9,'o','MarkerFaceColor',[0.8500 0.3250 0.0980],'MarkerEdgeColor',[0.8500 0.3250 0.0980],'MarkerSize',4); % orange
%    end
%   for t = 1:length(trigs_samp_ep)
%        con = con_samp_ep(t)
%        if con < 5
%        plot(trigs_samp_ep(t),data_thetafilt(trigs_samp_ep(t)),'o','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',4);
% %        plot(trigs_samp_ep(t),-10,'o','MarkerFaceColor',colors(con,:),'MarkerEdgeColor',colors(con,:),'MarkerSize',4);
%        else
%        plot(trigs_samp_ep(t),data_thetafilt(trigs_samp_ep(t)),'o','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',4);
% %        plot(trigs_samp_ep(t),-10,'o','MarkerFaceColor',colors(con-4,:),'MarkerEdgeColor',colors(con-4,:),'MarkerSize',4);
%        end
%    end
   hold on
   plot(bad_samps,data(bad_samps),'Color',[0.7 0.7 0.7]) %orange
   hold on
   for c = 1:length(theta_cycles_duration_ndx)   
   plot_samps_orig = round(startsamp(theta_cycles_duration_ndx(c)):endsamp(theta_cycles_duration_ndx(c)));
        if ~isempty(intersect(plot_samps_orig,samp_ep))
            plot(plot_samps_orig,data_thetafilt(plot_samps_orig),'Color',[0.9290 0.6940 0.1250]) %orange
            hold on
        end
   end
%    hold on
%    for c = 1:length(alpha_cycles_duration_ndx)   
%    plot_samps_orig = round(startsamp(alpha_cycles_duration_ndx(c)):endsamp(alpha_cycles_duration_ndx(c)));
%            if ~isempty(intersect(plot_samps_orig,samp_ep))
%               plot(plot_samps_orig,data_thetafilt(plot_samps_orig),'Color',[0.3010 0.7450 0.9330]) %clear blue
%               hold on
%            end
%    end
   hold on
%    xticks((ep-1)*epochl*fs+1:2*fs:ep*epochl*fs);
   xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0:1:epochl);
   ylim([-10 10])
   yticks(-10:2:10);
   set(gca,'Fontsize',15);
%    ylabel('Amplitude (\muV)');
   set(gca, 'box','off');
%    h = gca;
%    h.XAxis.Visible = 'off';
%    h.YAxis.Visible = 'off';
   xlim([samp_ep(1) samp_ep(end)])
   xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0-plot_start:1:epochl-plot_start);   
   
  
    
%   EOG left Phasic
    nexttile(8)
    plot(samp_ep,lEOG(samp_ep),'Color',[1 0 0])
    hold on
%    for p = 1:length(phasic_start)
%    area([phasic_start(p) phasic_end(p)],[150 150],-150,'FaceColor',[0.3 0.3 0.3],'FaceAlpha',.1,'EdgeColor','none','LineStyle','none')
%    end
    ylim([-130 130])
%     title('EOG')
%     legend({'lEOG' 'rEOG'})
     xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0:1:epochl);
    set(gca,'Fontsize',15);
%     ylabel('Amplitude (\muV)');
    set(gca, 'box','off');
%     h = gca;
%     h.XAxis.Visible = 'off';
%     h.YAxis.Visible = 'off';
    xlim([samp_ep(1) samp_ep(end)]);
    
    
    
%   EOG right Phasic
    nexttile(10)
%     plot(samp_ep,rEOG(samp_ep),'Color',[0.6350 0.0780 0.1840])
    plot(samp_ep,rEOG(samp_ep),'Color',[1 0 0])
    hold on
%    for p = 1:length(phasic_start)
%    area([phasic_start(p) phasic_end(p)],[150 150],-150,'FaceColor',[0.3 0.3 0.3],'FaceAlpha',.1,'EdgeColor','none','LineStyle','none')
%    end
    ylim([-130 130])
%     title('EOG')
%     legend({'lEOG' 'rEOG'})
     xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0:1:epochl);
    set(gca,'Fontsize',15);
%     ylabel('Amplitude (\muV)');
    set(gca, 'box','off');
%     h = gca;
%     h.XAxis.Visible = 'off';
%     h.YAxis.Visible = 'off';
    xlim([samp_ep(1) samp_ep(end)]);
  
    
    
%   EMG Phasic
    nexttile(12)
    plot(samp_ep,EMG_filt(samp_ep),'Color','b')
    hold on
%    for p = 1:length(phasic_start)
%    area([phasic_start(p) phasic_end(p)],[50 50],-50,'FaceColor',[0.3 0.3 0.3],'FaceAlpha',.1,'EdgeColor','none','LineStyle','none')
%    end
   ylim([-15 15])
    yticks(-15:5:15);
%     title('EMG')
    xticks((ep-1)*epochl*fs+1:1*fs:ep*epochl*fs);
   xticklabels(0-plot_start:1:epochl-plot_start);
    set(gca,'Fontsize',15);
    set(gca, 'box','off');
%     xlabel('Time (s)');
%     ylabel('Amplitude (\muV)');
%     h = gca;
%     h.XAxis.Visible = 'off';
%     h.YAxis.Visible = 'off';
    xlim([samp_ep(1) samp_ep(end)])
  

    tileplot.TileSpacing = 'compact';
    tileplot.Padding = 'compact';
    
    
%     saveas(fig,[Savefolder,'Figure1C_phasic_tonic_epoch_axes.svg']);

