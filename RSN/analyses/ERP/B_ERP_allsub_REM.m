clear all;
close all;

% addpath(genpath('/user/HS301/m17462/matlab/eeglab'));
% addpath(genpath('/user/HS301/m17462/matlab/Scripts/RSN'));
% 
% addpath /user/HS301/m17462/matlab/Henry/useful_functions
% addpath /user/HS301/m17462/matlab/colorGradient
% 
% addpath('/user/HS301/m17462/matlab/eBOSC/external/BOSC/')

erpfolder = '/parallel_scratch/nemo/RSN/analysis/analysis/erp_allsub/';

%% Load data

Folderpath = '/parallel_scratch/nemo/RSN/hdEEG/';
sub_Folderpath = dir([Folderpath,'RSN*']);

dt = 1;
dt_phasictonic = 6;
fs = 500;
bin_no = 8;

for state = 1:2
    
ERP_all.REM_ERP{state} = NaN(length(sub_Folderpath),2*dt*fs);
ERP_all.REM_ERP_vol{state} = NaN(length(sub_Folderpath),1);
ERP_all.REM_ERP_rand{state} = NaN(length(sub_Folderpath),2*dt*fs);
ERP_all.REM_ERP_rand_vol{state} = NaN(length(sub_Folderpath),1);

ERP_all.REM_vol80{state} = NaN(length(sub_Folderpath),2*dt*fs);
ERP_all.REM_vol85{state} = NaN(length(sub_Folderpath),2*dt*fs);
ERP_all.REM_vol90{state} = NaN(length(sub_Folderpath),2*dt*fs);

ERP_all.REM_con{state} = NaN(length(sub_Folderpath),8,2*dt*fs);
ERP_all.REM_con_alphafilt{state} = NaN(length(sub_Folderpath),8,2*dt*fs);
ERP_all.REM_con_thetafilt{state} = NaN(length(sub_Folderpath),8,2*dt*fs);
ERP_all.REM_con_alphafilt_hilb{state} = NaN(length(sub_Folderpath),8,2*dt*fs);
ERP_all.REM_con_thetafilt_hilb{state} = NaN(length(sub_Folderpath),8,2*dt*fs);
ERP_all.REM_con_alphafilt_hilb_r{state} = NaN(length(sub_Folderpath),8,2*dt*fs);
ERP_all.REM_con_thetafilt_hilb_r{state} = NaN(length(sub_Folderpath),8,2*dt*fs);
ERP_all.REM_con_vol{state} = NaN(length(sub_Folderpath),8);
ERP_all.REM_con_con_ntrials{state} = NaN(length(sub_Folderpath),8);

ERP_all.REM_con_alpha_pre{state} = NaN(length(sub_Folderpath),8,bin_no);
ERP_all.REM_con_theta_pre{state} = NaN(length(sub_Folderpath),8,bin_no);
ERP_all.REM_con_alpha_bins{state} = NaN(length(sub_Folderpath),8,bin_no,2*dt*fs);
ERP_all.REM_con_theta_bins{state} = NaN(length(sub_Folderpath),8,bin_no,2*dt*fs);
ERP_all.REM_con_alpha_bins_alphafilt{state} = NaN(length(sub_Folderpath),8,bin_no,2*dt*fs);
ERP_all.REM_con_theta_bins_thetafilt{state} = NaN(length(sub_Folderpath),8,bin_no,2*dt*fs);
ERP_all.REM_con_alpha_bins_alphafilt_hilb{state} = NaN(length(sub_Folderpath),8,bin_no,2*dt*fs);
ERP_all.REM_con_theta_bins_thetafilt_hilb{state} = NaN(length(sub_Folderpath),8,bin_no,2*dt*fs);
ERP_all.REM_con_alpha_bins_alphafilt_hilb_r{state} = NaN(length(sub_Folderpath),8,bin_no,2*dt*fs);
ERP_all.REM_con_theta_bins_thetafilt_hilb_r{state} = NaN(length(sub_Folderpath),8,bin_no,2*dt*fs);

end

%%
for s = 1:length(sub_Folderpath)
    
    display(s); 
    
    nm_good_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_sleep*_nm_good.mat']);
    goodREM_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_czref_goodREM.mat']);
 
    %% REM - phasic and tonic

    load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name]);
    load([Folderpath,sub_Folderpath(s).name,filesep,goodREM_file(1).name]);
    load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name(1:15),'_erp.mat'],'ERP'); 
    
    ERP_all.channels{s} = ERP.channels;
    
    trigs = nm.trigs_StimTrak_ERP;
    vol = nm.vol_trigs_StimTrak_ERP;
    
    if length(trigs) ~= length(ERP.trigs)
       error('ERP and nm trigs file length not the same'); 
    end
    
    
    if ~isempty(trigs)
        
        good_trial = zeros(length(trigs),1);
        phasic_trial = zeros(length(trigs),1);
        tonic_trial = zeros(length(trigs),1);
        
     for t = 1:length(trigs)
         
         if ismember(trigs(t),rem_goodsamp2)
         
         trial_samps = trigs(t)-dt_phasictonic*fs:trigs(t)+dt_phasictonic*fs-1;
         
            if length(intersect(trial_samps,rem_goodsamp2)) == 2*dt_phasictonic*fs
                good_trial(t) = 1;
            end

            if length(intersect(trial_samps,tonic_goodsamp2)) == 2*dt_phasictonic*fs
                tonic_trial(t) = 1;
            elseif length(intersect(trial_samps,phasic_goodsamp2))+length(intersect(trial_samps,tonic_goodsamp2)) == 2*dt_phasictonic*fs
                phasic_trial(t) = 1;   
            end
                        
         end
          
     end
     
     goodtrial_ndx = find(good_trial == 1);
     tonic_ndx = find(tonic_trial == 1);
     phasic_ndx = find(phasic_trial == 1);
     
     ERP.goodtrial_ndx = goodtrial_ndx;
     ERP.tonic_ndx = tonic_ndx;
     ERP.phasic_ndx = phasic_ndx;
     
     for cond = 1:8
         trigs_state_good_all{cond} = intersect(cell2mat(ERP.trigs_con(1,cond)),goodtrial_ndx);
         trigs_state_good_vol_all{cond} = vol(intersect(cell2mat(ERP.trigs_con(1,cond)),goodtrial_ndx));          
     end
     
     ERP.trigs_state_good_all = trigs_state_good_all;
     ERP.trigs_state_good_vol_all = trigs_state_good_vol_all;
     
     %% tonic
     
     state = 1; % tonic
     
     ERP_all.ntrials_REM{state}(s) = length(tonic_ndx);
    
     for cond = 1:8
         trigs_state_good{state,cond} = intersect(cell2mat(ERP.trigs_con(1,cond)),tonic_ndx);
         trigs_state_good_vol{state,cond} = vol(intersect(cell2mat(ERP.trigs_con(1,cond)),tonic_ndx)); 
     end
            
     trial_data = ERP.trial_data;
     trial_data_alphafilt_phase = ERP.trial_data_alphafilt_phase;
     trial_data_alphafilt_real = ERP.trial_data_alphafilt_real;
     trial_data_thetafilt_phase = ERP.trial_data_alphafilt_phase;
     trial_data_thetafilt_real = ERP.trial_data_alphafilt_real;
              
     if ~isempty(tonic_ndx)
        ERP_all.REM_ERP{state}(s,:) = nanmean(trial_data(tonic_ndx,:),1);
        ERP_all.REM_ERP_vol{state}(s) = nanmean(vol(tonic_ndx));
        
        rand_ndx = randi([1 length(tonic_ndx)],1,length(phasic_ndx));
        tonic_rand_ndx = tonic_ndx(rand_ndx);
                
     else
        tonic_rand_ndx = [];         
     end
     
     if ~isempty(tonic_rand_ndx)
        ERP_all.REM_ERP_rand{state}(s,:) = nanmean(trial_data(tonic_rand_ndx,:),1);
        ERP_all.REM_ERP_rand_vol{state}(s) = nanmean(vol(tonic_rand_ndx));
     end
     
     vol80_ndx = intersect(tonic_ndx,find(vol == 80));
     vol85_ndx = intersect(tonic_ndx,find(vol == 85));
     vol90_ndx = intersect(tonic_ndx,find(vol == 90));
        
     if ~isempty(vol80_ndx)
        ERP_all.REM_vol80{state}(s,:) = nanmean(trial_data(vol80_ndx,:),1);
     end
     
     if ~isempty(vol85_ndx)
        ERP_all.REM_vol85{state}(s,:) = nanmean(trial_data(vol85_ndx,:),1);
     end
        
     if ~isempty(vol90_ndx)
        ERP_all.REM_vol90{state}(s,:) = nanmean(trial_data(vol90_ndx,:),1);
     end
     
     
     for cond = 1:8

            if ~isempty(trigs_state_good{state,cond}) 
                
             ERP_all.REM_con{state}(s,cond,:) = nanmean(trial_data(trigs_state_good{state,cond},:),1);
             ERP_all.REM_con_alphafilt{state}(s,cond,:) = nanmean(trial_data_alphafilt_real(trigs_state_good{state,cond},:),1);
             ERP_all.REM_con_thetafilt{state}(s,cond,:) = nanmean(trial_data_thetafilt_real(trigs_state_good{state,cond},:),1);
             ERP_all.REM_con_alphafilt_hilb{state}(s,cond,:) = circ_mean(trial_data_alphafilt_phase(trigs_state_good{state,cond},:));
             ERP_all.REM_con_thetafilt_hilb{state}(s,cond,:) = circ_mean(trial_data_thetafilt_phase(trigs_state_good{state,cond},:));
             ERP_all.REM_con_alphafilt_hilb_r{state}(s,cond,:) = circ_r(trial_data_alphafilt_phase(trigs_state_good{state,cond},:));
             ERP_all.REM_con_thetafilt_hilb_r{state}(s,cond,:) = circ_r(trial_data_thetafilt_phase(trigs_state_good{state,cond},:));
             ERP_all.REM_con_vol{state}(s,cond) = nanmean(trigs_state_good_vol{cond});
             ERP_all.REM_con_ntrials{state}(s,cond) = length(trigs_state_good{state,cond});
             
             % calculate ERP for trials divided by pre-stim amplitude
             trial_data_alphafilt_real_good = trial_data_alphafilt_real(trigs_state_good{state,cond},:);
             trial_data_thetafilt_real_good = trial_data_thetafilt_real(trigs_state_good{state,cond},:);
             
                for t = 1:size(trial_data_alphafilt_real_good,1)
                    trial_data_alphafilt_trials_envelope(t,:) = envelope(trial_data_alphafilt_real_good(t,:));
                    trial_data_thetafilt_trials_envelope(t,:) = envelope(trial_data_thetafilt_real_good(t,:)); 
                end
             
             alpha_pre = nanmean(trial_data_alphafilt_trials_envelope(:,fs+1-0.2*fs:fs+1-0.1*fs-1),2);
             [alpha_pre_sorted alpha_pre_sorted_ndx] = sort(alpha_pre);
             theta_pre = nanmean(trial_data_thetafilt_trials_envelope(:,fs+1-0.2*fs:fs+1-0.1*fs-1),2);
             [theta_pre_sorted theta_pre_sorted_ndx] = sort(theta_pre); 
            
             no_elements = floor(length(alpha_pre_sorted_ndx)/bin_no);
             
             if no_elements > 0
                for bin = 1:bin_no
                 bin_ndx_alpha = alpha_pre_sorted_ndx((bin-1)*no_elements+1:bin*no_elements);
                 bin_ndx_theta = theta_pre_sorted_ndx((bin-1)*no_elements+1:bin*no_elements);
                 ERP_all.REM_con_alpha_pre{state}(s,cond,bin) = nanmean(alpha_pre(bin_ndx_alpha));
                 ERP_all.REM_con_theta_pre{state}(s,cond,bin) = nanmean(theta_pre(bin_ndx_theta));
                 ERP_all.REM_con_alpha_bins{state}(s,cond,bin,:) = nanmean(trial_data(trigs_state_good{state,cond}(bin_ndx_alpha),:),1);
                 ERP_all.REM_con_theta_bins{state}(s,cond,bin,:) = nanmean(trial_data(trigs_state_good{state,cond}(bin_ndx_theta),:),1);
                 ERP_all.REM_con_alpha_bins_alphafilt{state}(s,cond,bin,:) = nanmean(trial_data_alphafilt_real(trigs_state_good{state,cond}(bin_ndx_alpha),:),1);
                 ERP_all.REM_con_theta_bins_thetafilt{state}(s,cond,bin,:) = nanmean(trial_data_thetafilt_real(trigs_state_good{state,cond}(bin_ndx_theta),:),1);
                 ERP_all.REM_con_alpha_bins_alphafilt_hilb{state}(s,cond,bin,:) = circ_mean(trial_data_alphafilt_phase(trigs_state_good{state,cond}(bin_ndx_alpha),:));
                 ERP_all.REM_con_theta_bins_thetafilt_hilb{state}(s,cond,bin,:) = circ_mean(trial_data_thetafilt_phase(trigs_state_good{state,cond}(bin_ndx_theta),:));
                 ERP_all.REM_con_alpha_bins_alphafilt_hilb_r{state}(s,cond,bin,:) = circ_r(trial_data_alphafilt_phase(trigs_state_good{state,cond}(bin_ndx_alpha),:));
                 ERP_all.REM_con_theta_bins_thetafilt_hilb_r{state}(s,cond,bin,:) = circ_r(trial_data_thetafilt_phase(trigs_state_good{state,cond}(bin_ndx_theta),:));
                end
             end
                
             clear trial_data_alphafilt_real_good trial_data_alphafilt_trials_envelope alpha_pre alpha_pre_sorted_ndx no_elements bin_ndx*
             clear trial_data_thetafilt_real_good trial_data_thetafilt_trials_envelope theta_pre theta_pre_sorted_ndx
             
            end
        
     end
     
     
      %% phasic
     
     state = 2; % phasic
     
     ERP_all.ntrials_REM{state}(s) = length(phasic_ndx);
    
     for cond = 1:8
         trigs_state_good{state,cond} = intersect(cell2mat(ERP.trigs_con(1,cond)),phasic_ndx);
         trigs_state_good_vol{state,cond} = vol(intersect(cell2mat(ERP.trigs_con(1,cond)),phasic_ndx));    
     end
     
     ERP.trigs_state_good = trigs_state_good;
     ERP.trigs_state_good_vol = trigs_state_good_vol;
        
     trial_data = ERP.trial_data;
     trial_data_alphafilt_phase = ERP.trial_data_alphafilt_phase;
     trial_data_alphafilt_real = ERP.trial_data_alphafilt_real;
     trial_data_thetafilt_phase = ERP.trial_data_alphafilt_phase;
     trial_data_thetafilt_real = ERP.trial_data_alphafilt_real;
       
     phasic_rand_ndx = phasic_ndx;
                
     if ~isempty(phasic_ndx)
        ERP_all.REM_ERP{state}(s,:) = nanmean(trial_data(phasic_ndx,:),1);
        ERP_all.REM_ERP_vol{state}(s) = nanmean(vol(phasic_ndx));
        
        ERP_all.REM_ERP_rand{state}(s,:) = nanmean(trial_data(phasic_rand_ndx,:),1);
        ERP_all.REM_ERP_rand_vol{state}(s) = nanmean(vol(phasic_rand_ndx));
     end
     
     vol80_ndx = intersect(phasic_ndx,find(vol == 80));
     vol85_ndx = intersect(phasic_ndx,find(vol == 85));
     vol90_ndx = intersect(phasic_ndx,find(vol == 90));
        
     if ~isempty(vol80_ndx)
        ERP_all.REM_vol80{state}(s,:) = nanmean(trial_data(vol80_ndx,:),1);
     end
     
     if ~isempty(vol85_ndx)
        ERP_all.REM_vol85{state}(s,:) = nanmean(trial_data(vol85_ndx,:),1);
     end
        
     if ~isempty(vol90_ndx)
        ERP_all.REM_vol90{state}(s,:) = nanmean(trial_data(vol90_ndx,:),1);
     end
     
     
     for cond = 1:8

            if ~isempty(trigs_state_good{state,cond}) 
                
             ERP_all.REM_con{state}(s,cond,:) = nanmean(trial_data(trigs_state_good{state,cond},:),1);
             ERP_all.REM_con_alphafilt{state}(s,cond,:) = nanmean(trial_data_alphafilt_real(trigs_state_good{state,cond},:),1);
             ERP_all.REM_con_thetafilt{state}(s,cond,:) = nanmean(trial_data_thetafilt_real(trigs_state_good{state,cond},:),1);
             ERP_all.REM_con_alphafilt_hilb{state}(s,cond,:) = circ_mean(trial_data_alphafilt_phase(trigs_state_good{state,cond},:));
             ERP_all.REM_con_thetafilt_hilb{state}(s,cond,:) = circ_mean(trial_data_thetafilt_phase(trigs_state_good{state,cond},:));
             ERP_all.REM_con_alphafilt_hilb_r{state}(s,cond,:) = circ_r(trial_data_alphafilt_phase(trigs_state_good{state,cond},:));
             ERP_all.REM_con_thetafilt_hilb_r{state}(s,cond,:) = circ_r(trial_data_thetafilt_phase(trigs_state_good{state,cond},:));
             ERP_all.REM_con_vol{state}(s,cond) = nanmean(trigs_state_good_vol{cond});
             ERP_all.REM_con_ntrials{state}(s,cond) = length(trigs_state_good{state,cond});
             
             % calculate ERP for trials divided by pre-stim amplitude
             trial_data_alphafilt_real_good = trial_data_alphafilt_real(trigs_state_good{state,cond},:);
             trial_data_thetafilt_real_good = trial_data_thetafilt_real(trigs_state_good{state,cond},:);
             
                for t = 1:size(trial_data_alphafilt_real_good,1)
                    trial_data_alphafilt_trials_envelope(t,:) = envelope(trial_data_alphafilt_real_good(t,:));
                    trial_data_thetafilt_trials_envelope(t,:) = envelope(trial_data_thetafilt_real_good(t,:)); 
                end
             
             alpha_pre = nanmean(trial_data_alphafilt_trials_envelope(:,fs+1-0.2*fs:fs+1-0.1*fs-1),2);
             [alpha_pre_sorted alpha_pre_sorted_ndx] = sort(alpha_pre);
             theta_pre = nanmean(trial_data_thetafilt_trials_envelope(:,fs+1-0.2*fs:fs+1-0.1*fs-1),2);
             [theta_pre_sorted theta_pre_sorted_ndx] = sort(theta_pre); 
            
             no_elements = floor(length(alpha_pre_sorted_ndx)/bin_no);
             
             if no_elements > 0
                for bin = 1:bin_no
                 bin_ndx_alpha = alpha_pre_sorted_ndx((bin-1)*no_elements+1:bin*no_elements);
                 bin_ndx_theta = theta_pre_sorted_ndx((bin-1)*no_elements+1:bin*no_elements);
                 ERP_all.REM_con_alpha_pre{state}(s,cond,bin) = nanmean(alpha_pre(bin_ndx_alpha));
                 ERP_all.REM_con_theta_pre{state}(s,cond,bin) = nanmean(theta_pre(bin_ndx_theta));
                 ERP_all.REM_con_alpha_bins{state}(s,cond,bin,:) = nanmean(trial_data(trigs_state_good{state,cond}(bin_ndx_alpha),:),1);
                 ERP_all.REM_con_theta_bins{state}(s,cond,bin,:) = nanmean(trial_data(trigs_state_good{state,cond}(bin_ndx_theta),:),1);
                 ERP_all.REM_con_alpha_bins_alphafilt{state}(s,cond,bin,:) = nanmean(trial_data_alphafilt_real(trigs_state_good{state,cond}(bin_ndx_alpha),:),1);
                 ERP_all.REM_con_theta_bins_thetafilt{state}(s,cond,bin,:) = nanmean(trial_data_thetafilt_real(trigs_state_good{state,cond}(bin_ndx_theta),:),1);
                 ERP_all.REM_con_alpha_bins_alphafilt_hilb{state}(s,cond,bin,:) = circ_mean(trial_data_alphafilt_phase(trigs_state_good{state,cond}(bin_ndx_alpha),:));
                 ERP_all.REM_con_theta_bins_thetafilt_hilb{state}(s,cond,bin,:) = circ_mean(trial_data_thetafilt_phase(trigs_state_good{state,cond}(bin_ndx_theta),:));
                 ERP_all.REM_con_alpha_bins_alphafilt_hilb_r{state}(s,cond,bin,:) = circ_r(trial_data_alphafilt_phase(trigs_state_good{state,cond}(bin_ndx_alpha),:));
                 ERP_all.REM_con_theta_bins_thetafilt_hilb_r{state}(s,cond,bin,:) = circ_r(trial_data_thetafilt_phase(trigs_state_good{state,cond}(bin_ndx_theta),:));
                end
             end
                
             clear trial_data_alphafilt_real_good trial_data_alphafilt_trials_envelope alpha_pre alpha_pre_sorted_ndx no_elements bin_ndx*
             clear trial_data_thetafilt_real_good trial_data_thetafilt_trials_envelope theta_pre theta_pre_sorted_ndx
             
            end
        
     end    
     
     
     
    end

    save([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name(1:15),'_erp_good.mat'],'ERP'); 
    
    clear nm trigs vol* trial_data* ERP
    
    
    
end

%%

save([erpfolder,'ERP_allsub_REM_mICA_avref',date,'.mat'],'ERP_all','dt','fs');


