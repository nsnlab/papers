clear all;
close all;

addpath(genpath('/user/HS301/m17462/matlab/eeglab'));
addpath(genpath('/user/HS301/m17462/matlab/Scripts/RSN'));

addpath /user/HS301/m17462/matlab/Henry/useful_functions
addpath /user/HS301/m17462/matlab/colorGradient

% addpath('/user/HS301/m17462/matlab/eBOSC/external/BOSC/')

erpfolder = '/vol/research/nemo/datasets/RSN/data/analysis/erp_allsub/';

load('/vol/research/nemo/datasets/RSN/data/analysis/erp_allsub/ERP_allsub_REM_mICA_avref04-Jun-2023','ERP_all');
ntrials_phasic = ERP_all.ntrials_REM{2};
clear ERP_all;

load('/vol/research/nemo/datasets/RSN/data/analysis/erp_allsub/ERP_allsub_wake_mICA_avref02-Jun-2023','ERP_all');

%% Load data

Folderpath = '/vol/research/nemo/datasets/RSN/data/hdEEG/';
sub_Folderpath = dir([Folderpath,'RSN*']);

dt = 1;
fs = 500;
bin_no = 8;

for state = 1:2
ERP_all.wake_e_ERP{state} = NaN(length(sub_Folderpath),2*dt*fs);
ERP_all.wake_e_ERP_vol{state} = NaN(length(sub_Folderpath),1);
ERP_all.wake_e_ERP_rand{state} = NaN(length(sub_Folderpath),2*dt*fs);
ERP_all.wake_e_ERP_rand_vol{state} = NaN(length(sub_Folderpath),1);

ERP_all.wake_e_vol80{state} = NaN(length(sub_Folderpath),2*dt*fs);
ERP_all.wake_e_vol85{state} = NaN(length(sub_Folderpath),2*dt*fs);
ERP_all.wake_e_vol90{state} = NaN(length(sub_Folderpath),2*dt*fs);

ERP_all.wake_e_con{state} = NaN(length(sub_Folderpath),8,2*dt*fs);
ERP_all.wake_e_con_alphafilt{state} = NaN(length(sub_Folderpath),8,2*dt*fs);
ERP_all.wake_e_con_thetafilt{state} = NaN(length(sub_Folderpath),8,2*dt*fs);
ERP_all.wake_e_con_alphafilt_hilb{state} = NaN(length(sub_Folderpath),8,2*dt*fs);
ERP_all.wake_e_con_thetafilt_hilb{state} = NaN(length(sub_Folderpath),8,2*dt*fs);
ERP_all.wake_e_con_alphafilt_hilb_r{state} = NaN(length(sub_Folderpath),8,2*dt*fs);
ERP_all.wake_e_con_thetafilt_hilb_r{state} = NaN(length(sub_Folderpath),8,2*dt*fs);
ERP_all.wake_e_con_vol{state} = NaN(length(sub_Folderpath),8);
ERP_all.wake_e_con_con_ntrials{state} = NaN(length(sub_Folderpath),8);

ERP_all.wake_e_con_alpha_pre{state} = NaN(length(sub_Folderpath),8,bin_no);
ERP_all.wake_e_con_theta_pre{state} = NaN(length(sub_Folderpath),8,bin_no);
ERP_all.wake_e_con_alpha_bins{state} = NaN(length(sub_Folderpath),8,bin_no,2*dt*fs);
ERP_all.wake_e_con_theta_bins{state} = NaN(length(sub_Folderpath),8,bin_no,2*dt*fs);
ERP_all.wake_e_con_alpha_bins_alphafilt{state} = NaN(length(sub_Folderpath),8,bin_no,2*dt*fs);
ERP_all.wake_e_con_theta_bins_thetafilt{state} = NaN(length(sub_Folderpath),8,bin_no,2*dt*fs);
ERP_all.wake_e_con_alpha_bins_alphafilt_hilb{state} = NaN(length(sub_Folderpath),8,bin_no,2*dt*fs);
ERP_all.wake_e_con_theta_bins_thetafilt_hilb{state} = NaN(length(sub_Folderpath),8,bin_no,2*dt*fs);
ERP_all.wake_e_con_alpha_bins_alphafilt_hilb_r{state} = NaN(length(sub_Folderpath),8,bin_no,2*dt*fs);
ERP_all.wake_e_con_theta_bins_thetafilt_hilb_r{state} = NaN(length(sub_Folderpath),8,bin_no,2*dt*fs);


ERP_all.wake_m_ERP{state} = NaN(length(sub_Folderpath),2*dt*fs);
ERP_all.wake_m_ERP_vol{state} = NaN(length(sub_Folderpath),1);
ERP_all.wake_m_ERP_rand{state} = NaN(length(sub_Folderpath),2*dt*fs);
ERP_all.wake_m_ERP_rand_vol{state} = NaN(length(sub_Folderpath),1);

ERP_all.wake_m_vol80{state} = NaN(length(sub_Folderpath),2*dt*fs);
ERP_all.wake_m_vol85{state} = NaN(length(sub_Folderpath),2*dt*fs);
ERP_all.wake_m_vol90{state} = NaN(length(sub_Folderpath),2*dt*fs);

ERP_all.wake_m_con{state} = NaN(length(sub_Folderpath),8,2*dt*fs);
ERP_all.wake_m_con_alphafilt{state} = NaN(length(sub_Folderpath),8,2*dt*fs);
ERP_all.wake_m_con_thetafilt{state} = NaN(length(sub_Folderpath),8,2*dt*fs);
ERP_all.wake_m_con_alphafilt_hilb{state} = NaN(length(sub_Folderpath),8,2*dt*fs);
ERP_all.wake_m_con_thetafilt_hilb{state} = NaN(length(sub_Folderpath),8,2*dt*fs);
ERP_all.wake_m_con_alphafilt_hilb_r{state} = NaN(length(sub_Folderpath),8,2*dt*fs);
ERP_all.wake_m_con_thetafilt_hilb_r{state} = NaN(length(sub_Folderpath),8,2*dt*fs);
ERP_all.wake_m_con_vol{state} = NaN(length(sub_Folderpath),8);
ERP_all.wake_m_con_con_ntrials{state} = NaN(length(sub_Folderpath),8);

ERP_all.wake_m_con_alpha_pre{state} = NaN(length(sub_Folderpath),8,bin_no);
ERP_all.wake_m_con_theta_pre{state} = NaN(length(sub_Folderpath),8,bin_no);
ERP_all.wake_m_con_alpha_bins{state} = NaN(length(sub_Folderpath),8,bin_no,2*dt*fs);
ERP_all.wake_m_con_theta_bins{state} = NaN(length(sub_Folderpath),8,bin_no,2*dt*fs);
ERP_all.wake_m_con_alpha_bins_alphafilt{state} = NaN(length(sub_Folderpath),8,bin_no,2*dt*fs);
ERP_all.wake_m_con_theta_bins_thetafilt{state} = NaN(length(sub_Folderpath),8,bin_no,2*dt*fs);
ERP_all.wake_m_con_alpha_bins_alphafilt_hilb{state} = NaN(length(sub_Folderpath),8,bin_no,2*dt*fs);
ERP_all.wake_m_con_theta_bins_thetafilt_hilb{state} = NaN(length(sub_Folderpath),8,bin_no,2*dt*fs);
ERP_all.wake_m_con_alpha_bins_alphafilt_hilb_r{state} = NaN(length(sub_Folderpath),8,bin_no,2*dt*fs);
ERP_all.wake_m_con_theta_bins_thetafilt_hilb_r{state} = NaN(length(sub_Folderpath),8,bin_no,2*dt*fs);

end

%%

for s = 1:length(sub_Folderpath)
    
    display(s); 

    nm_good_file_wake_e = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_wake_e_nm_good.mat']);
    goodREM_file_wake_e = dir([Folderpath,sub_Folderpath(s).name,filesep,'*wake_e_fil_czref_goodwake.mat']);
    
    nm_good_file_wake_m = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_wake_m_nm_good.mat']);
    goodREM_file_wake_m = dir([Folderpath,sub_Folderpath(s).name,filesep,'*wake_m_fil_czref_goodwake.mat']);


%% Wake evening
    
    load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file_wake_e(1).name]);
    load([Folderpath,sub_Folderpath(s).name,filesep,goodREM_file_wake_e(1).name]);
    load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file_wake_e(1).name(1:16),'_erp.mat'],'ERP');
    
    ERP_all.wake_e_channels{s} = ERP.channels;
    
    
    for state = 1:length(nm.trigs_StimTrak_ERP)
        
        trigs = nm.trigs_StimTrak_ERP{state};
        vol = nm.vol_trigs_StimTrak_ERP{state};
        
        if length(trigs) ~= length(ERP.trigs{state})
           error('ERP and nm trigs file length not the same'); 
        end
    
        
        if ~isempty(trigs)
        
        for t = 1:length(trigs)
         
            if ismember(trigs(t),wake_goodsamp2)
         
                trial_samps = trigs(t)-dt*fs:trigs(t)+dt*fs-1;

                if length(intersect(trial_samps,wake_goodsamp2)) == 2*dt*fs
                    wake_good_trial{state}(t) = 1;
                else
                    wake_good_trial{state}(t) = 0;
                end
                        
            end
          
        end
                
        good_trial_ndx = find(wake_good_trial{state} == 1);
        ERP_all.ntrials_wake_e{state} = length(good_trial_ndx);
        ERP.good_trial_ndx{state} = good_trial_ndx;
        
        
        for cond = 1:8
            
            trigs_state = ERP.trigs_con(state,cond);
            trigs_state_good{state,cond} = intersect(cell2mat(trigs_state),good_trial_ndx);
            trigs_state_good_vol{state,cond} = vol(trigs_state_good{state,cond});

        end
        
        ERP.trigs_state_good = trigs_state_good;
        ERP.trigs_state_good_vol = trigs_state_good_vol;
        
        trial_data = ERP.trial_data{state};
        trial_data_alphafilt_phase = ERP.trial_data_alphafilt_phase{state};
        trial_data_alphafilt_real = ERP.trial_data_alphafilt_real{state};
        trial_data_thetafilt_phase = ERP.trial_data_alphafilt_phase{state};
        trial_data_thetafilt_real = ERP.trial_data_alphafilt_real{state};
              
        if ~isempty(good_trial_ndx)
            ERP_all.wake_e_ERP{state}(s,:) = nanmean(trial_data(good_trial_ndx,:),1);
            ERP_all.wake_e_ERP_vol{state}(s) = nanmean(vol(good_trial_ndx));       
       
            rand_ndx = randi([1 length(good_trial_ndx)],1,ntrials_phasic(s));
            wake_e_rand_ndx = good_trial_ndx(rand_ndx);
        
            ERP_all.wake_e_ERP_rand{state}(s,:) = nanmean(trial_data(wake_e_rand_ndx,:),1);
            ERP_all.wake_e_ERP_rand_vol{state}(s) = nanmean(vol(wake_e_rand_ndx));   
            clear wake_e_rand_ndx
        end

        vol80_ndx = intersect(good_trial_ndx,find(vol == 80));
        vol85_ndx = intersect(good_trial_ndx,find(vol == 85));
        vol90_ndx = intersect(good_trial_ndx,find(vol == 90));
        
        if ~isempty(vol80_ndx)
            ERP_all.wake_e_vol80{state}(s,:) = nanmean(trial_data(vol80_ndx,:),1);
        end
        
        if ~isempty(vol85_ndx)
            ERP_all.wake_e_vol85{state}(s,:) = nanmean(trial_data(vol85_ndx,:),1);
        end
        
        if ~isempty(vol90_ndx)
            ERP_all.wake_e_vol90{state}(s,:) = nanmean(trial_data(vol90_ndx,:),1);
        end
        
        

        for cond = 1:8

            if ~isempty(trigs_state_good{state,cond}) 
                
             ERP_all.wake_e_con{state}(s,cond,:) = nanmean(trial_data(trigs_state_good{state,cond},:),1);
             ERP_all.wake_e_con_alphafilt{state}(s,cond,:) = nanmean(trial_data_alphafilt_real(trigs_state_good{state,cond},:),1);
             ERP_all.wake_e_con_thetafilt{state}(s,cond,:) = nanmean(trial_data_thetafilt_real(trigs_state_good{state,cond},:),1);
             ERP_all.wake_e_con_alphafilt_hilb{state}(s,cond,:) = circ_mean(trial_data_alphafilt_phase(trigs_state_good{state,cond},:));
             ERP_all.wake_e_con_thetafilt_hilb{state}(s,cond,:) = circ_mean(trial_data_thetafilt_phase(trigs_state_good{state,cond},:));
             ERP_all.wake_e_con_alphafilt_hilb_r{state}(s,cond,:) = circ_r(trial_data_alphafilt_phase(trigs_state_good{state,cond},:));
             ERP_all.wake_e_con_thetafilt_hilb_r{state}(s,cond,:) = circ_r(trial_data_thetafilt_phase(trigs_state_good{state,cond},:));
             ERP_all.wake_e_con_vol{state}(s,cond) = nanmean(trigs_state_good_vol{cond});
             ERP_all.wake_e_con_ntrials{state}(s,cond) = length(trigs_state_good{state,cond});
             
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
             
                for bin = 1:bin_no
                 bin_ndx_alpha = alpha_pre_sorted_ndx((bin-1)*no_elements+1:bin*no_elements);
                 bin_ndx_theta = theta_pre_sorted_ndx((bin-1)*no_elements+1:bin*no_elements);
                 ERP_all.wake_e_con_alpha_pre{state}(s,cond,bin) = nanmean(alpha_pre(bin_ndx_alpha));
                 ERP_all.wake_e_con_theta_pre{state}(s,cond,bin) = nanmean(theta_pre(bin_ndx_theta));
                 ERP_all.wake_e_con_alpha_bins{state}(s,cond,bin,:) = nanmean(trial_data(trigs_state_good{state,cond}(bin_ndx_alpha),:),1);
                 ERP_all.wake_e_con_theta_bins{state}(s,cond,bin,:) = nanmean(trial_data(trigs_state_good{state,cond}(bin_ndx_theta),:),1);
                 ERP_all.wake_e_con_alpha_bins_alphafilt{state}(s,cond,bin,:) = nanmean(trial_data_alphafilt_real(trigs_state_good{state,cond}(bin_ndx_alpha),:),1);
                 ERP_all.wake_e_con_theta_bins_thetafilt{state}(s,cond,bin,:) = nanmean(trial_data_thetafilt_real(trigs_state_good{state,cond}(bin_ndx_theta),:),1);
                 ERP_all.wake_e_con_alpha_bins_alphafilt_hilb{state}(s,cond,bin,:) = circ_mean(trial_data_alphafilt_phase(trigs_state_good{state,cond}(bin_ndx_alpha),:));
                 ERP_all.wake_e_con_theta_bins_thetafilt_hilb{state}(s,cond,bin,:) = circ_mean(trial_data_thetafilt_phase(trigs_state_good{state,cond}(bin_ndx_theta),:));
                 ERP_all.wake_e_con_alpha_bins_alphafilt_hilb_r{state}(s,cond,bin,:) = circ_r(trial_data_alphafilt_phase(trigs_state_good{state,cond}(bin_ndx_alpha),:));
                 ERP_all.wake_e_con_theta_bins_thetafilt_hilb_r{state}(s,cond,bin,:) = circ_r(trial_data_thetafilt_phase(trigs_state_good{state,cond}(bin_ndx_theta),:));
                end
                
             clear trial_data_alphafilt_real_good trial_data_alphafilt_trials_envelope alpha_pre alpha_pre_sorted_ndx no_elements bin_ndx*
             clear trial_data_thetafilt_real_good trial_data_thetafilt_trials_envelope theta_pre theta_pre_sorted_ndx
             
            end
        
        end    
              
        end
    
    end
    
    save([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file_wake_e(1).name(1:16),'_erp_good.mat'],'ERP');
 
    clear nm trigs vol* trial_data* wake_goodsamp2 wake_good_trial ERP

  %% Wake morning
    
    load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file_wake_m(1).name]);
    load([Folderpath,sub_Folderpath(s).name,filesep,goodREM_file_wake_m(1).name]);
    load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file_wake_m(1).name(1:16),'_erp.mat'],'ERP');
    
    ERP_all.wake_m_channels{s} = ERP.channels;
    
    
    for state = 1:length(nm.trigs_StimTrak_ERP)
        
        trigs = nm.trigs_StimTrak_ERP{state};
        vol = nm.vol_trigs_StimTrak_ERP{state};
        
        if length(trigs) ~= length(ERP.trigs{state})
           error('ERP and nm trigs file length not the same'); 
        end
    
        
        if ~isempty(trigs)
        
        for t = 1:length(trigs)
         
            if ismember(trigs(t),wake_goodsamp2)
         
                trial_samps = trigs(t)-dt*fs:trigs(t)+dt*fs-1;

                if length(intersect(trial_samps,wake_goodsamp2)) == 2*dt*fs
                    wake_good_trial{state}(t) = 1;
                else
                    wake_good_trial{state}(t) = 0;
                end
                        
            end
          
        end
                
        good_trial_ndx = find(wake_good_trial{state} == 1);
        ERP_all.ntrials_wake_m{state} = length(good_trial_ndx);
        ERP.good_trial_ndx{state} = good_trial_ndx;
        
        
        for cond = 1:8
            
            trigs_state = ERP.trigs_con(state,cond);
            trigs_state_good{state,cond} = intersect(cell2mat(trigs_state),good_trial_ndx);
            trigs_state_good_vol{state,cond} = vol(trigs_state_good{state,cond});

        end
        
        ERP.trigs_state_good = trigs_state_good;
        ERP.trigs_state_good_vol = trigs_state_good_vol;
        
        trial_data = ERP.trial_data{state};
        trial_data_alphafilt_phase = ERP.trial_data_alphafilt_phase{state};
        trial_data_alphafilt_real = ERP.trial_data_alphafilt_real{state};
        trial_data_thetafilt_phase = ERP.trial_data_alphafilt_phase{state};
        trial_data_thetafilt_real = ERP.trial_data_alphafilt_real{state};
              
        if ~isempty(good_trial_ndx)
            ERP_all.wake_m_ERP{state}(s,:) = nanmean(trial_data(good_trial_ndx,:),1);
            ERP_all.wake_m_ERP_vol{state}(s) = nanmean(vol(good_trial_ndx));       
       
            rand_ndx = randi([1 length(good_trial_ndx)],1,ntrials_phasic(s));
            wake_m_rand_ndx = good_trial_ndx(rand_ndx);
        
            ERP_all.wake_m_ERP_rand{state}(s,:) = nanmean(trial_data(wake_m_rand_ndx,:),1);
            ERP_all.wake_m_ERP_rand_vol{state}(s) = nanmean(vol(wake_m_rand_ndx));   
            clear wake_m_rand_ndx
        end

        vol80_ndx = intersect(good_trial_ndx,find(vol == 80));
        vol85_ndx = intersect(good_trial_ndx,find(vol == 85));
        vol90_ndx = intersect(good_trial_ndx,find(vol == 90));
        
        if ~isempty(vol80_ndx)
            ERP_all.wake_m_vol80{state}(s,:) = nanmean(trial_data(vol80_ndx,:),1);
        end
        
        if ~isempty(vol85_ndx)
            ERP_all.wake_m_vol85{state}(s,:) = nanmean(trial_data(vol85_ndx,:),1);
        end
        
        if ~isempty(vol90_ndx)
            ERP_all.wake_m_vol90{state}(s,:) = nanmean(trial_data(vol90_ndx,:),1);
        end
        
        

        for cond = 1:8

            if ~isempty(trigs_state_good{state,cond}) 
                
             ERP_all.wake_m_con{state}(s,cond,:) = nanmean(trial_data(trigs_state_good{state,cond},:),1);
             ERP_all.wake_m_con_alphafilt{state}(s,cond,:) = nanmean(trial_data_alphafilt_real(trigs_state_good{state,cond},:),1);
             ERP_all.wake_m_con_thetafilt{state}(s,cond,:) = nanmean(trial_data_thetafilt_real(trigs_state_good{state,cond},:),1);
             ERP_all.wake_m_con_alphafilt_hilb{state}(s,cond,:) = circ_mean(trial_data_alphafilt_phase(trigs_state_good{state,cond},:));
             ERP_all.wake_m_con_thetafilt_hilb{state}(s,cond,:) = circ_mean(trial_data_thetafilt_phase(trigs_state_good{state,cond},:));
             ERP_all.wake_m_con_alphafilt_hilb_r{state}(s,cond,:) = circ_r(trial_data_alphafilt_phase(trigs_state_good{state,cond},:));
             ERP_all.wake_m_con_thetafilt_hilb_r{state}(s,cond,:) = circ_r(trial_data_thetafilt_phase(trigs_state_good{state,cond},:));
             ERP_all.wake_m_con_vol{state}(s,cond) = nanmean(trigs_state_good_vol{cond});
             ERP_all.wake_m_con_ntrials{state}(s,cond) = length(trigs_state_good{state,cond});
             
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
             
                for bin = 1:bin_no
                 bin_ndx_alpha = alpha_pre_sorted_ndx((bin-1)*no_elements+1:bin*no_elements);
                 bin_ndx_theta = theta_pre_sorted_ndx((bin-1)*no_elements+1:bin*no_elements);
                 ERP_all.wake_m_con_alpha_pre{state}(s,cond,bin) = nanmean(alpha_pre(bin_ndx_alpha));
                 ERP_all.wake_m_con_theta_pre{state}(s,cond,bin) = nanmean(theta_pre(bin_ndx_theta));
                 ERP_all.wake_m_con_alpha_bins{state}(s,cond,bin,:) = nanmean(trial_data(trigs_state_good{state,cond}(bin_ndx_alpha),:),1);
                 ERP_all.wake_m_con_theta_bins{state}(s,cond,bin,:) = nanmean(trial_data(trigs_state_good{state,cond}(bin_ndx_theta),:),1);
                 ERP_all.wake_m_con_alpha_bins_alphafilt{state}(s,cond,bin,:) = nanmean(trial_data_alphafilt_real(trigs_state_good{state,cond}(bin_ndx_alpha),:),1);
                 ERP_all.wake_m_con_theta_bins_thetafilt{state}(s,cond,bin,:) = nanmean(trial_data_thetafilt_real(trigs_state_good{state,cond}(bin_ndx_theta),:),1);
                 ERP_all.wake_m_con_alpha_bins_alphafilt_hilb{state}(s,cond,bin,:) = circ_mean(trial_data_alphafilt_phase(trigs_state_good{state,cond}(bin_ndx_alpha),:));
                 ERP_all.wake_m_con_theta_bins_thetafilt_hilb{state}(s,cond,bin,:) = circ_mean(trial_data_thetafilt_phase(trigs_state_good{state,cond}(bin_ndx_theta),:));
                 ERP_all.wake_m_con_alpha_bins_alphafilt_hilb_r{state}(s,cond,bin,:) = circ_r(trial_data_alphafilt_phase(trigs_state_good{state,cond}(bin_ndx_alpha),:));
                 ERP_all.wake_m_con_theta_bins_thetafilt_hilb_r{state}(s,cond,bin,:) = circ_r(trial_data_thetafilt_phase(trigs_state_good{state,cond}(bin_ndx_theta),:));
                end
                
             clear trial_data_alphafilt_real_good trial_data_alphafilt_trials_envelope alpha_pre alpha_pre_sorted_ndx no_elements bin_ndx*
             clear trial_data_thetafilt_real_good trial_data_thetafilt_trials_envelope theta_pre theta_pre_sorted_ndx
             
            end
        
        end    
              
        end
    
    end
    
    save([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file_wake_m(1).name(1:16),'_erp_good.mat'],'ERP'); 
 
    clear nm trigs vol* trial_data* wake_goodsamp2 wake_good_trial ERP

end

%%

save([erpfolder,'ERP_allsub_wake_mICA_avref',date,'.mat'],'ERP_all','dt','fs');
