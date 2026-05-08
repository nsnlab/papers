clear all;
close all;

addpath(genpath('/users/nemo/software/eeglab'));
addpath(genpath('/users/nemo/projects/RSN'));
addpath(genpath('/users/nemo/software/Henry/useful_functions'));

% addpath /user/HS301/m17462/matlab/colorGradient

% addpath('/user/HS301/m17462/matlab/eBOSC/external/BOSC/')

erpfolder = '/parallel_scratch/nemo/RSN/analysis/analysis/erp_allsub/';

%% Load data

Folderpath = '/parallel_scratch/nemo/RSN/hdEEG/';
sub_Folderpath = dir([Folderpath,'RSN*']);

dt = 1;
dt2 = 6;
% dt_phasictonic = 6;

fs = 500;

trial_data = NaN(19,8,100,1000);
trial_data_alphafilt_phase = NaN(19,8,100,1000);
trial_data_alphafilt_real = NaN(19,8,100,1000);
trial_data_thetafilt_phase = NaN(19,8,100,1000);
trial_data_thetafilt_real = NaN(19,8,100,1000);

%%
for s = 1:length(sub_Folderpath)
    
    display(s); 
    
    nm_good_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_sleep*_nm_good.mat']);
    goodREM_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_czref_goodREM.mat']);
 
    %% REM - phasic and tonic

    load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name]);
    load([Folderpath,sub_Folderpath(s).name,filesep,goodREM_file(1).name]);
%     load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name(1:15),'_erp_nm.mat'],'ERP_nm'); 
    load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name(1:15),'_erp_nm_broadband.mat'],'ERP_nm'); 
    
%     ERP_nm_all.channels = ERP_nm.channels;
    
     
     %% all

              
     for con = 1:8
         
         if sum(isnan(ERP_nm.trial_data{con}(1,1,:))) == 0
         
         trial_data(s,con,:,:) = squeeze(nanmean(ERP_nm.trial_data{con},1));
         for w = 1:100
         trial_data_alphafilt_phase(s,con,:,:) = squeeze(ERP_nm.trial_data_alphafilt_phase{con}(w,:,:));
         trial_data_alphafilt_phase_r(s,con,:,:) = squeeze(circ_r(ERP_nm.trial_data_alphafilt_phase{con}));
         trial_data_alphafilt_real(s,con,:,:) = squeeze(nanmean(ERP_nm.trial_data_alphafilt_real{con},1));
         trial_data_thetafilt_phase(s,con,:,:) = squeeze(circ_mean(ERP_nm.trial_data_thetafilt_phase{con}));
         trial_data_thetafilt_phase_r(s,con,:,:) = squeeze(circ_r(ERP_nm.trial_data_thetafilt_phase{con}));
         trial_data_thetafilt_real(s,con,:,:) = squeeze(nanmean(ERP_nm.trial_data_thetafilt_real{con},1));
         end
                      
         end
         
     end
            
     ERP_nm_all.trial_data = trial_data;
     ERP_nm_all.trial_data_alphafilt_phase = trial_data_alphafilt_phase;
     ERP_nm_all.trial_data_alphafilt_phase_r = trial_data_alphafilt_phase_r;
     ERP_nm_all.trial_data_alphafilt_real = trial_data_alphafilt_real;
     ERP_nm_all.trial_data_thetafilt_phase = trial_data_thetafilt_phase;
     ERP_nm_all.trial_data_thetafilt_phase_r = trial_data_thetafilt_phase_r;
     ERP_nm_all.trial_data_thetafilt_real = trial_data_thetafilt_real;
    
       
     clear ERP_nm
    
end



%%

save([erpfolder,'ERP_nm_broadband_allsub_REM_mICA_avref',date,'.mat'],'ERP_nm_all','dt','fs');


