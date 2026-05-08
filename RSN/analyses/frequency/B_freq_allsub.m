clear all;
close all;

addpath(genpath('/users/nemo/software/eeglab'));
addpath(genpath('/users/nemo/projects/RSN'));

addpath /users/nemo/software/Henry/useful_functions

Folderpath = '/parallel_scratch/nemo/RSN/hdEEG/';
sub_Folderpath = dir([Folderpath,'RSN*']);

Savefolder = '/parallel_scratch/nemo/RSN/analysis/analysis/frequency_allsub/';

%% Load freq for all subjects and channels

fs = 500;

for s = 1:length(sub_Folderpath)
        
    display(sub_Folderpath(s).name);

    freq_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_freq.mat']);
    load([Folderpath,sub_Folderpath(s).name,filesep,freq_file(1).name]);
    
    goodREM_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_sleep*_fil_czref_goodREM.mat']);
    load([Folderpath,sub_Folderpath(s).name,filesep,goodREM_file(1).name]);
    
    nm_good_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_nm_good_psd_allch.mat']);
    load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name]);
    
    
    freq_allch = nanmean(freq.ifq_rem_alpha,1);
        
    %%
    freq.ifq_rem_alpha(:,end:end+1) = NaN;
    
    if ~isequal(length(rem_goodsamp2),length(freq.ifq_rem_alpha))
        error('wrong data length');
    end

    freq_allnight_alpha = NaN(128,nepochs*epochl*fs);
    
    for ch = 1:128
        freq_allnight_alpha(ch,rem_goodsamp2) = freq.ifq_rem_alpha(ch,:); 
    end
    
    %%
    
    freq.ifq_rem_theta(:,end:end+1) = NaN;
    
    if ~isequal(length(rem_goodsamp2),length(freq.ifq_rem_theta))
        error('wrong data length');
    end
    
    
    freq_allnight_theta = NaN(128,nepochs*epochl*fs);
    
    for ch = 1:128
        freq_allnight_theta(ch,rem_goodsamp2) = freq.ifq_rem_theta(ch,:); 
    end
    
    
    %% calculate mean frequency for rem, phasic and tonic, first half, second half
        
    ifq.rem_alpha_allsub(s,:) = nanmean(freq_allnight_alpha(:,rem_goodsamp2),2);
    ifq.phasic_alpha_allsub(s,:) = nanmean(freq_allnight_alpha(:,phasic_goodsamp2),2);
    ifq.tonic_alpha_allsub(s,:) = nanmean(freq_allnight_alpha(:,tonic_goodsamp2),2);
    
    ifq.rem_theta_allsub(s,:) = nanmean(freq_allnight_theta(:,rem_goodsamp2),2);
    ifq.phasic_theta_allsub(s,:) = nanmean(freq_allnight_theta(:,phasic_goodsamp2),2);
    ifq.tonic_theta_allsub(s,:) = nanmean(freq_allnight_theta(:,tonic_goodsamp2),2);
    
    firsthalf_samp = rem_goodsamp2(1:floor(length(rem_goodsamp2)/2)-1);
    secondhalf_samp = rem_goodsamp2(floor(length(rem_goodsamp2)/2):end);
    
    firsthalf_phasic_samp = intersect(firsthalf_samp,phasic_goodsamp2);
    secondhalf_phasic_samp = intersect(secondhalf_samp,phasic_goodsamp2);
    
    firsthalf_tonic_samp = intersect(firsthalf_samp,tonic_goodsamp2);
    secondhalf_tonic_samp = intersect(secondhalf_samp,tonic_goodsamp2);
    
    ifq.rem_firsthalf_alpha_allsub(s,:) = nanmean(freq_allnight_alpha(:,firsthalf_samp),2);
    ifq.rem_secondhalf_alpha_allsub(s,:) = nanmean(freq_allnight_alpha(:,secondhalf_samp),2);
    
    ifq.rem_firsthalf_phasic_alpha_allsub(s,:) = nanmean(freq_allnight_alpha(:,firsthalf_phasic_samp),2);
    ifq.rem_secondhalf_phasic_alpha_allsub(s,:) = nanmean(freq_allnight_alpha(:,secondhalf_phasic_samp),2);
    
    ifq.rem_firsthalf_tonic_alpha_allsub(s,:) = nanmean(freq_allnight_alpha(:,firsthalf_tonic_samp),2);
    ifq.rem_secondhalf_tonic_alpha_allsub(s,:) = nanmean(freq_allnight_alpha(:,secondhalf_tonic_samp),2);
    
    ifq.rem_firsthalf_theta_allsub(s,:) = nanmean(freq_allnight_theta(:,firsthalf_samp),2);
    ifq.rem_secondhalf_theta_allsub(s,:) = nanmean(freq_allnight_theta(:,secondhalf_samp),2);
    
    ifq.rem_firsthalf_phasic_theta_allsub(s,:) = nanmean(freq_allnight_theta(:,firsthalf_phasic_samp),2);
    ifq.rem_secondhalf_phasic_theta_allsub(s,:) = nanmean(freq_allnight_theta(:,secondhalf_phasic_samp),2);
    
    ifq.rem_firsthalf_tonic_theta_allsub(s,:) = nanmean(freq_allnight_theta(:,firsthalf_tonic_samp),2);
    ifq.rem_secondhalf_tonic_theta_allsub(s,:) = nanmean(freq_allnight_theta(:,secondhalf_tonic_samp),2);
    
    
      %% calculate phasic/tonic trial ndx
      
     for con = 1:8
         
     ON_start_all = nm.ON_start_good{con}; 
          
     art_trial = nm.art_trialndx{con};
     art_trialndx = find(art_trial == 1);
     good_trialndx = setdiff(1:length(ON_start_all),art_trialndx);
%      nm.good_trialndx{con} = good_trialndx;

%         art_trialndx = find(nm.art_trialndx{con} == 1);
%         art_trialndx_new = find(nm.art_trialndx{con} == 1);
%         good_trialndx = nm.good_trialndx{con};
%         good_trialndx_new = nm.good_trialndx_new{con};
        
%      phasic_trial = zeros(length(ON_start_all),1);
%      tonic_trial = zeros(length(ON_start_all),1);
%      
%      
     for t = 1:length(ON_start_all)
         
         if ~ismember(t,art_trialndx)
         
         dt = 6;
         trial_samps = ON_start_all(t)-dt*fs:ON_start_all(t)+2*dt*fs-1;
         ifq_trials_alpha(t,:,:) = freq_allnight_alpha(:,trial_samps);
         ifq_trials_theta(t,:,:) = freq_allnight_theta(:,trial_samps);

%             if length(intersect(trial_samps,tonic_goodsamp2)) == 2*dt*fs
%                 tonic_trial(t) = 1;
%             elseif length(intersect(trial_samps,phasic_goodsamp2)) > 0
%                 phasic_trial(t) = 1;   
%             end
                        
         end
          
     end
%      
%      phasic_goodtrialndx = intersect(find(phasic_trial == 1),good_trialndx);
%      tonic_goodtrialndx = intersect(find(tonic_trial == 1),good_trialndx);

    phasic_goodtrialndx = nm.phasic_goodtrialndx{con};
    tonic_goodtrialndx = nm.tonic_goodtrialndx{con};
    
%      
% %      nm.phasic_goodtrialndx{con} = phasic_goodtrialndx;
% %      nm.tonic_goodtrialndx{con} = tonic_goodtrialndx;     
% %      nm.ntrials_phasic{con} = length(phasic_goodtrialndx);
% %      nm.ntrials_tonic{con} = length(tonic_goodtrialndx);
% %      
% %      if ~ nm.ntrials_phasic{con} + nm.ntrials_tonic{con} + length(art_trialndx) == length(ON_start_all)
% %         warning('trials have not been assigned to tonic/phasic/artefact') ;
% %      end
%      
%      clear tonic_trial phasic_trial
        
    %% calculate mean across all good, phasic and tonic trials
            
        if ~isempty(good_trialndx)
            mifq_trials_alpha = squeeze(nanmean(ifq_trials_alpha(good_trialndx,:,:),1));            
            ifq.mifq_trials_alpha(s,con,:,:) = mifq_trials_alpha;
            ifq.off_ifq_alpha(s,con,:) = nanmean(mifq_trials_alpha(:,1:6*fs),2);
            ifq.on_ifq_alpha(s,con,:) = nanmean(mifq_trials_alpha(:,6*fs+1:12*fs),2);
        else
            ifq.mifq_trials_alpha(s,con,:,:) = NaN(128,9000);
            ifq.off_ifq_alpha(s,con,:) = NaN(128,1);
            ifq.on_ifq_alpha(s,con,:) = NaN(128,1); 
        end
        
        if ~isempty(phasic_goodtrialndx)         
            mifq_trials_alpha_phasic = squeeze(nanmean(ifq_trials_alpha(phasic_goodtrialndx,:,:),1));
            ifq.mifq_trials_alpha_phasic(s,con,:,:) = mifq_trials_alpha_phasic;
            ifq.off_ifq_alpha_phasic(s,con,:) = nanmean(mifq_trials_alpha_phasic(:,1:6*fs),2);
            ifq.on_ifq_alpha_phasic(s,con,:) = nanmean(mifq_trials_alpha_phasic(:,6*fs+1:12*fs),2);
        else
            ifq.mifq_trials_alpha_phasic(s,con,:,:) = NaN(128,9000);
            ifq.off_ifq_alpha_phasic(s,con,:) = NaN(128,1);
            ifq.on_ifq_alpha_phasic(s,con,:) = NaN(128,1); 
        end
        
        if ~isempty(tonic_goodtrialndx)  
            mifq_trials_alpha_tonic = squeeze(nanmean(ifq_trials_alpha(tonic_goodtrialndx,:,:),1));
            ifq.mifq_trials_alpha_tonic(s,con,:,:) = mifq_trials_alpha_tonic;
            ifq.off_ifq_alpha_tonic(s,con,:) = nanmean(mifq_trials_alpha_tonic(:,1:6*fs),2);
            ifq.on_ifq_alpha_tonic(s,con,:) = nanmean(mifq_trials_alpha_tonic(:,6*fs+1:12*fs),2);
        else
            ifq.mifq_trials_alpha_tonic(s,con,:,:) = NaN(128,9000);
            ifq.off_ifq_alpha_tonic(s,con,:) = NaN(128,1);
            ifq.on_ifq_alpha_tonic(s,con,:) = NaN(128,1); 
        end
        
        
        
         if ~isempty(good_trialndx)
            mifq_trials_theta = squeeze(nanmean(ifq_trials_theta(good_trialndx,:,:),1));            
            ifq.mifq_trials_theta(s,con,:,:) = mifq_trials_theta;
            ifq.off_ifq_theta(s,con,:) = nanmean(mifq_trials_theta(:,1:6*fs),2);
            ifq.on_ifq_theta(s,con,:) = nanmean(mifq_trials_theta(:,6*fs+1:12*fs),2);
        else
            ifq.mifq_trials_theta(s,con,:,:) = NaN(128,9000);
            ifq.off_ifq_theta(s,con,:) = NaN(128,1);
            ifq.on_ifq_theta(s,con,:) = NaN(128,1); 
        end
        
        if ~isempty(phasic_goodtrialndx)         
            mifq_trials_theta_phasic = squeeze(nanmean(ifq_trials_theta(phasic_goodtrialndx,:,:),1));
            ifq.mifq_trials_theta_phasic(s,con,:,:) = mifq_trials_theta_phasic;
            ifq.off_ifq_theta_phasic(s,con,:) = nanmean(mifq_trials_theta_phasic(:,1:6*fs),2);
            ifq.on_ifq_theta_phasic(s,con,:) = nanmean(mifq_trials_theta_phasic(:,6*fs+1:12*fs),2);
        else
            ifq.mifq_trials_theta_phasic(s,con,:,:) = NaN(128,9000);
            ifq.off_ifq_theta_phasic(s,con,:) = NaN(128,1);
            ifq.on_ifq_theta_phasic(s,con,:) = NaN(128,1); 
        end
        
        if ~isempty(tonic_goodtrialndx)  
            mifq_trials_theta_tonic = squeeze(nanmean(ifq_trials_theta(tonic_goodtrialndx,:,:),1));
            ifq.mifq_trials_theta_tonic(s,con,:,:) = mifq_trials_theta_tonic;
            ifq.off_ifq_theta_tonic(s,con,:) = nanmean(mifq_trials_theta_tonic(:,1:6*fs),2);
            ifq.on_ifq_theta_tonic(s,con,:) = nanmean(mifq_trials_theta_tonic(:,6*fs+1:12*fs),2);
        else
            ifq.mifq_trials_theta_tonic(s,con,:,:) = NaN(128,9000);
            ifq.off_ifq_theta_tonic(s,con,:) = NaN(128,1);
            ifq.on_ifq_theta_tonic(s,con,:) = NaN(128,1); 
        end
        
        clear mifq_trials_alpha mifq_trials_alpha_phasic mifq_trials_alpha_tonic mifq_trials_theta mifq_trials_theta_phasic mifq_trials_theta_tonic
     
    
     end
     
%      save([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name],'nm','-append','-v7.3');
    clear nm

 %% calculate mean frequency for wake eve, eyes open, and eyes closed
  
     
%     nm_good_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_wake_e*_nm_good.mat']);
%     load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name]); 
%     
%     goodwake_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_wake_e_fil_czref_goodwake.mat']);
%     load([Folderpath,sub_Folderpath(s).name,filesep,goodwake_file(1).name]);
%        
%     freq.ifq_wake_e_alpha(:,end:end+1) = NaN;
%     freq.ifq_wake_e_theta(:,end:end+1) = NaN;
%     
%     freq_allwake_e_alpha = freq.ifq_wake_e_alpha;
%     freq_allwake_e_theta = freq.ifq_wake_e_theta;
%    
%     eye_closure_samp = nm.startsamp_ERP{2}(1);
%     EO_samp = 1:eye_closure_samp;
%     EC_samp = eye_closure_samp+1:size(freq_allwake_e_alpha,2);
%     EO_e_goodsamp2 = intersect(EO_samp,wake_goodsamp2);
%     EC_e_goodsamp2 = intersect(EC_samp,wake_goodsamp2);
% 
%     ifq.wake_e_alpha_allsub(s,:) = nanmean(freq_allwake_e_alpha(:,wake_goodsamp2),2);
%     ifq.wake_e_EO_alpha_allsub(s,:) = nanmean(freq_allwake_e_alpha(:,EO_e_goodsamp2),2);
%     ifq.wake_e_EC_alpha_allsub(s,:) = nanmean(freq_allwake_e_alpha(:,EC_e_goodsamp2),2);
%     
%     ifq.wake_e_theta_allsub(s,:) = nanmean(freq_allwake_e_theta(:,wake_goodsamp2),2);
%     ifq.wake_e_EO_theta_allsub(s,:) = nanmean(freq_allwake_e_theta(:,EO_e_goodsamp2),2);
%     ifq.wake_e_EC_theta_allsub(s,:) = nanmean(freq_allwake_e_theta(:,EC_e_goodsamp2),2);
%     
%    clear nm
   
 %% calculate mean frequency for wake mor, eyes open, and eyes closed
  
     
%     nm_good_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_wake_m*_nm_good.mat']);
%     load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name]); 
%     
%     goodwake_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_wake_m_fil_czref_goodwake.mat']);
%     load([Folderpath,sub_Folderpath(s).name,filesep,goodwake_file(1).name]);
%        
%     freq.ifq_wake_m_alpha(:,end:end+1) = NaN;
%     freq.ifq_wake_m_theta(:,end:end+1) = NaN;
%     
%     freq_allwake_m_alpha = freq.ifq_wake_m_alpha;
%     freq_allwake_m_theta = freq.ifq_wake_m_theta;
%    
%     eye_closure_samp = nm.startsamp_ERP{2}(1);
%     EO_samp = 1:eye_closure_samp;
%     EC_samp = eye_closure_samp+1:size(freq_allwake_m_alpha,2);
%     EO_m_goodsamp2 = intersect(EO_samp,wake_goodsamp2);
%     EC_m_goodsamp2 = intersect(EC_samp,wake_goodsamp2);
% 
%     ifq.wake_m_alpha_allsub(s,:) = nanmean(freq_allwake_m_alpha(:,wake_goodsamp2),2);
%     ifq.wake_m_EO_alpha_allsub(s,:) = nanmean(freq_allwake_m_alpha(:,EO_m_goodsamp2),2);
%     ifq.wake_m_EC_alpha_allsub(s,:) = nanmean(freq_allwake_m_alpha(:,EC_m_goodsamp2),2);
%     
%     ifq.wake_m_theta_allsub(s,:) = nanmean(freq_allwake_m_theta(:,wake_goodsamp2),2);
%     ifq.wake_m_EO_theta_allsub(s,:) = nanmean(freq_allwake_m_theta(:,EO_m_goodsamp2),2);
%     ifq.wake_m_EC_theta_allsub(s,:) = nanmean(freq_allwake_m_theta(:,EC_m_goodsamp2),2);    
    
      
end


save([Savefolder,'freqalphatheta_allsub_',date,'.mat'],'ifq','-v7.3');

