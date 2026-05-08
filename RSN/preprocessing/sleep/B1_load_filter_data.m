clear all;
close all;

addpath(genpath('/user/HS301/m17462/matlab/eeglab/'));
addpath(genpath('/user/HS301/m17462/matlab/Matlab'));

%% Define folder

Folderpath = '/vol/research/nemo/datasets/RSN/data/hdEEG/RSN_015';
filename = 'RSN_015_1_sleep.eeg'; % .eeg file / combined .set file for RSN_022
dataName = filename(1:end-4);

%% Filter and resample data

% fs = 256;
EEG = pop_fileio([Folderpath,filesep,filename]);
% EEG = pop_loadset('filename', filename, 'filepath', Folderpath); % RSN_022 combined file

% using fieldtrip filters
% in fieldtrip default is to apply a two-pass filter (forward and reverse),
% which results in a zero-phase shift of your ERP components.

data = eeglab2fieldtrip(EEG, 'raw', 'none');      

addpath(genpath('/user/HS301/m17462/matlab/fieldtrip/'));    
     
% high-pass filter to remove slow drifts in data
cfg.hpfiltord = 5;
cfg.hpfilter = 'yes';
cfg.hpfreq = 0.1;
data = ft_preprocessing(cfg,data);                  
EEG.data = data.trial{1};
data = eeglab2fieldtrip(EEG, 'raw', 'none');       

% high-pass filter and band-stop filter to remove line noise
cfg = [];
cfg.hpfilter = 'yes';
cfg.hpfreq = 0.7;
cfg.bsfilter = 'yes';
cfg.bsfreq = [45 55;95 105];
% cfg.lpfilter = 'yes';
% cfg.lpfreq = 40;
     
data = ft_preprocessing(cfg,data);                  
EEG.data = data.trial{1};

% EEG = pop_resample(EEG,fs);


%%
EEG = pop_saveset(EEG, 'filename', [dataName,'_fil'], 'filepath', Folderpath);


