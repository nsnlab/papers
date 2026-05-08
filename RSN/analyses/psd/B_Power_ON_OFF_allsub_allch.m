clear all;
close all;

addpath(genpath('/users/nemo/software/eeglab'));
addpath(genpath('/users/nemo/projects/RSN'));

Folderpath = '/parallel_scratch/nemo/RSN/hdEEG/';
sub_Folderpath = dir([Folderpath,'RSN*']);

Savefolder = '/parallel_scratch/nemo/RSN/analysis/analysis/psd_allsub/';

%% Load nm data

for s = 1:length(sub_Folderpath)
    
    display(sub_Folderpath(s).name);

    nm_good_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_nm_good_psd_allch_OFFONOFF.mat']);
    load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name]);
    
    %%
    
    goodREM_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_goodREM.mat']);
    load([Folderpath,sub_Folderpath(s).name,filesep,goodREM_file(1).name]);
    
    phasic_ndx = find(phasic_ep == 1); % phasic epoch (epoch that has at least 1 phasic segment)
    tonic_phasic_ndx = find(tonic_ep == 1);   % epoch that has at least 1 tonic segment 
    tonic_ndx = setdiff(tonic_phasic_ndx,phasic_ndx); % tonic epoch (epoch that has at least 1 tonic and no phasic segment)

   phasic_samp = [];
    
    for ep = 1:length(phasic_ndx)
        
        ep_ndx = phasic_ndx(ep);
        ep_samp = ((ep_ndx-1)*fs*windowl+1):(ep_ndx*fs*windowl);
        phasic_samp = [phasic_samp ep_samp];
        
        clear ep_samp
        
    end
    
    phasic_goodsamp2 = intersect(phasic_samp,rem_goodsamp);
    
    tonic_samp = [];
    
    for ep = 1:length(tonic_ndx)
        
        ep_ndx = tonic_ndx(ep);
        ep_samp = ((ep_ndx-1)*fs*windowl+1):(ep_ndx*fs*windowl);
        tonic_samp = [tonic_samp ep_samp];
        
        clear ep_samp
        
    end
    
    tonic_goodsamp2 = intersect(tonic_samp,rem_goodsamp);
       
    %%
    
   for con = 1:length(nm.psd_ON)
    
    ON_start_all = nm.ON_start_good{con};
    
    art_trial = nm.art_trialndx{con};
    art_trialndx = find(art_trial == 1);
%     good_trialndx = setdiff(1:length(ON_start_all),art_trialndx);
%     nm.good_trialndx{con} = good_trialndx;
    good_trialndx = nm.good_trialndx{con};

%      art_trialndx = find(nm.art_trialndx{con} == 1);
%      art_trialndx_new = find(nm.art_trialndx{con} == 1);
%      good_trialndx = nm.good_trialndx{con};
%      good_trialndx_new = nm.good_trialndx_new{con};
%     
     %% calculate phasic/tonic trial ndx (no rejtrials)
%      phasic_trial = zeros(length(ON_start_all),1);
%      tonic_trial = zeros(length(ON_start_all),1);
%      
%      for t = 1:length(ON_start_all)
%          
%          if ~ismember(t,art_trialndx)
%          
%          dt = 6;
%          trial_samps = ON_start_all(t)-dt*fs:ON_start_all(t)+dt*fs-1;
% 
%             if length(intersect(trial_samps,tonic_goodsamp2)) == 2*dt*fs
%                 tonic_trial(t) = 1;
%             elseif length(intersect(trial_samps,phasic_goodsamp2)) > 0
%                 phasic_trial(t) = 1;   
%             end
%                         
%          end
%           
%      end
     
%      phasic_goodtrialndx = intersect(find(phasic_trial == 1),good_trialndx);
%      tonic_goodtrialndx = intersect(find(tonic_trial == 1),good_trialndx);
%      
%      nm.phasic_goodtrialndx{con} = phasic_goodtrialndx;
%      nm.tonic_goodtrialndx{con} = tonic_goodtrialndx;     
%      nm.ntrials_phasic{con} = length(phasic_goodtrialndx);
%      nm.ntrials_tonic{con} = length(tonic_goodtrialndx);
     
%      if ~ nm.ntrials_phasic{con} + nm.ntrials_tonic{con} + length(art_trialndx) == length(ON_start_all)
%         warning('trials have not been assigned to tonic/phasic/artefact') ;
%      end
%      
%      clear tonic_trial phasic_trial

    phasic_goodtrialndx = nm.phasic_goodtrialndx{con};
    tonic_goodtrialndx = nm.tonic_goodtrialndx{con};
    
      %% calculate phasic/tonic trial ndx (rejtrials)
%      phasic_trial = zeros(length(ON_start_all),1);
%      tonic_trial = zeros(length(ON_start_all),1);
%      
%      
%      for t = 1:length(ON_start_all)
%          
%          if ~ismember(t,art_trialndx)
%          
%          dt = 6;
%          trial_samps = ON_start_all(t)-dt*fs:ON_start_all(t)+dt*fs-1;
% 
%             if length(intersect(trial_samps,tonic_goodsamp2)) == 2*dt*fs
%                 tonic_trial(t) = 1;
%             elseif length(intersect(trial_samps,phasic_goodsamp2)) > 0
%                 phasic_trial(t) = 1;   
%             end
%                         
%          end
%           
%      end
     
%      phasic_goodtrialndx_new = intersect(find(phasic_trial == 1),good_trialndx_new);
%      tonic_goodtrialndx_new = intersect(find(tonic_trial == 1),good_trialndx_new);
     
%      nm.phasic_goodtrialndx_new{con} = phasic_goodtrialndx_new;
%      nm.tonic_goodtrialndx_new{con} = tonic_goodtrialndx_new;     
%      nm.ntrials_phasic_new{con} = length(phasic_goodtrialndx_new);
%      nm.ntrials_tonic_new{con} = length(tonic_goodtrialndx_new);
     
%      if ~ nm.ntrials_phasic_new{con} + nm.ntrials_tonic_new{con} + length(art_trialndx_new) == length(ON_start_all)
%         warning('trials have not been assigned to tonic/phasic/artefact') ;
%      end
     
     clear tonic_trial phasic_trial
     
    %%
    
    f = nm.f;
    off_block = 1:6;
    on_block = 7:12;
    
        display(['con',num2str(con)]);
        
        psd_con = nm.psd{con}; % psd: bins x ep x trials x ch
        
        for ch = 1:size(psd_con,4)
        
        psd_con_ch = squeeze(psd_con(:,:,:,ch));
        mpsd_con_ch(s,ch,con,:,:) = squeeze(nanmean(psd_con_ch(:,:,good_trialndx),3)); % average across all trials, mpsd_con_ch: sub x ch x con x bins x ep
        mpsd_con_ch_phasic(s,ch,con,:,:) = squeeze(nanmean(psd_con_ch(:,:,phasic_goodtrialndx),3)); % average across all trials, mpsd_con_ch: sub x ch x con x bins x ep
        mpsd_con_ch_tonic(s,ch,con,:,:) = squeeze(nanmean(psd_con_ch(:,:,tonic_goodtrialndx),3)); % average across all trials, mpsd_con_ch: sub x ch x con x bins x ep

%         mpsd_con_ch_new(s,ch,con,:,:) = squeeze(nanmean(psd_con_ch(:,:,good_trialndx_new),3)); % average across all trials, mpsd_con_ch: sub x ch x con x bins x ep
%         mpsd_con_ch_phasic_new(s,ch,con,:,:) = squeeze(nanmean(psd_con_ch(:,:,phasic_goodtrialndx_new),3)); % average across all trials, mpsd_con_ch: sub x ch x con x bins x ep
%         mpsd_con_ch_tonic_new(s,ch,con,:,:) = squeeze(nanmean(psd_con_ch(:,:,tonic_goodtrialndx_new),3)); % average across all trials, mpsd_con_ch: sub x ch x con x bins x ep

        
        end
        

    end
    
    ntrials(s,:) = nm.ntrials_good;
    ntrials_phasic(s,:) = nm.ntrials_phasic;
    ntrials_tonic(s,:) = nm.ntrials_tonic;
    
%     ntrials_new(s,:) = nm.ntrials_good_new;
%     ntrials_phasic_new(s,:) = nm.ntrials_phasic_new;
%     ntrials_tonic_new(s,:) = nm.ntrials_tonic_new;
    
end


save([Savefolder,'psd_allsub_mICA_avref_OFFONOFF',date,'.mat'],'mpsd_con_ch','mpsd_con_ch_phasic','mpsd_con_ch_tonic','ntrials','ntrials_phasic','ntrials_tonic','f');
