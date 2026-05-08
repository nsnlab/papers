clear all;
close all;

addpath(genpath('/user/HS301/m17462/matlab/eeglab'));
addpath(genpath('//user/HS301/m17462/matlab/Scripts/RSN'));

addpath /mnt/beegfs/users/psychology01/useful_functions

Folderpath = '/vol/research/nemo/datasets/RSN/data/hdEEG/RSN_024/';
goodrem_mat_file = dir([Folderpath,'*wake_m_fil_czref_goodwake.mat']);
nm_mat_file = dir([Folderpath,'*wake_m_nm.mat']);

%% Load artefact info

load([Folderpath,goodrem_mat_file(1).name]);

%% Load nm file

load([Folderpath,nm_mat_file(1).name]);

%% Exclude bad ERP triggers

for con = 1:length(nm.trigs_ECHT_ERP)
    
[nm.trigs_ECHT_ERP_good{con} nm.trigs_ECHT_ERP_goodndx{con}] = intersect(nm.trigs_ECHT_ERP{con},wake_goodsamp2);
[nm.trigs_StimTrak_ERP_good{con} nm.trigs_StimTrak_ERP_goodndx{con}] = intersect(nm.trigs_StimTrak_ERP{con},wake_goodsamp2);

end

%%

save([Folderpath,nm_mat_file(1).name(1:end-4),'_good.mat'],'nm');




