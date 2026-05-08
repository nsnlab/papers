clear all;
close all;

addpath(genpath('/users/nemo/software/eeglab'));
addpath(genpath('/users/nemo/projects/RSN'));
addpath(genpath('/users/nemo/software/Henry/useful_functions'));

%% Load data

Folderpath = '/parallel_scratch/nemo/RSN/hdEEG/';
sub_Folderpath = dir([Folderpath,'RSN*']);

% erpfolder = '/vol/research/nemo/datasets/RSN/data/analysis/erp_allsub/';

%% Load data

dt = 1;
fs = 500;

%%
for s = 19 %:length(sub_Folderpath)
    
display(s); 

mICA_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_sleep*_fil_czref_mICA_avref.set']);
nm_good_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_sleep*_nm_good.mat']);
goodREM_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_czref_goodREM.mat']);

Savefolder = [Folderpath,sub_Folderpath(s).name];

ch = [2 34 65 94]; % Fz, AFz, AFF1h, AFF2h
% ERP_nm.channels = ch;

     %% REM
     
    clear EEG data data_stim trigs vol* nm rem_goodsamp2 wake_goodsamp2 wake_good_trial trial_data*
     
    EEG = pop_loadset('filename',[mICA_file(1).name],'filepath',[Folderpath,sub_Folderpath(s).name],'loadmode', ch);
    load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name]);
    load([Folderpath,sub_Folderpath(s).name,filesep,goodREM_file(1).name]);

    data = double(EEG.data);
    clear EEG.data

    data_stim = nanmean(data,1);

  %%
  for con = 1:8   
      
  display(con); 
  
  trial_data = NaN(100,100,2*fs);
  trial_data_alphafilt_phase = NaN(100,100,2*fs);
  trial_data_alphafilt_real = NaN(100,100,2*fs);
  trial_data_thetafilt_phase = NaN(100,100,2*fs);
  trial_data_thetafilt_real = NaN(100,100,2*fs);
  
  for w = 1:length(nm.ON_start_good{con})

      
   trigs = nm.ON_trigs_StimTrak_good{con}; 
      
   trigs_window_ndx = find(trigs > nm.ON_start_good{con}(w) & trigs < nm.ON_end_good{con}(w));
   trigs_window = trigs(trigs_window_ndx);
   
   ERP_nm.trigs_window{con,w} = trigs_window;
   
           
   if length(trigs_window)>= 1 

  filt_lf_alpha = 7.5;
  filt_hf_alpha = 12.5;
  filt_lf_theta = 4.5;
  filt_hf_theta = 7.5;
        
     
        for t = 1:length(trigs_window)
     
            trial_data(w,t,:) = data_stim(trigs_window(t)-dt*fs:trigs_window(t)+dt*fs-1); % 501. sample is trig sample
            
            for time = 1:2*fs %-dt*fs:dt*fs-1
                x_alpha = echt(data_stim(trigs_window(t)-dt*fs+time-1-fs:trigs_window(t)-dt*fs+time-1), filt_lf_alpha, filt_hf_alpha, fs); 
                trial_data_alphafilt_phase(w,t,time) = angle(x_alpha(end)); % 501. sample is trig sample
                trial_data_alphafilt_real(w,t,time) = real(x_alpha(end)); % get real component of hilbert-transformed signal
                x_theta = echt(data_stim(trigs_window(t)-dt*fs+time-1-fs:trigs_window(t)-dt*fs+time-1), filt_lf_theta, filt_hf_theta, fs);
                trial_data_thetafilt_phase(w,t,time) = angle(x_theta(end));
                trial_data_thetafilt_real(w,t,time) = real(x_theta(end)); % get real component of hilbert-transformed signal
                
                clear x_alpha x_theta               
            end
            
            clear trig_ndx
        end
        
        ERP_nm.trial_data{con} = trial_data;
        ERP_nm.trial_data_alphafilt_phase{con} = trial_data_alphafilt_phase;
        ERP_nm.trial_data_alphafilt_real{con} = trial_data_alphafilt_real;
        ERP_nm.trial_data_thetafilt_phase{con} = trial_data_thetafilt_phase;
        ERP_nm.trial_data_thetafilt_real{con} = trial_data_thetafilt_real;
     
   else

        ERP_nm.trigs_con{con} = [];           
%         ERP_nm.trial_data{con} = NaN(1,10,2*fs);
%         ERP_nm.trial_data_alphafilt_phase{con} = NaN(1,10,2*fs);
%         ERP_nm.trial_data_alphafilt_real{con} = NaN(1,10,2*fs);
%         ERP_nm.trial_data_thetafilt_phase{con} = NaN(1,10,2*fs);
%         ERP_nm.trial_data_thetafilt_real{con} = NaN(1,10,2*fs);
        
   end
    
        
   
   end
  
  end
  
%       save([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name(1:15),'_erp_nm.mat'],'ERP_nm');
      save([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name(1:15),'_erp_nm_broadband.mat'],'ERP_nm','-v7.3');
 
      


end

   