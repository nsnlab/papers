clear all;
close all;

addpath(genpath('/user/HS301/m17462/matlab/eeglab'));
addpath(genpath('//user/HS301/m17462/matlab/Scripts/RSN'));

addpath /mnt/beegfs/users/psychology01/useful_functions

%% Load and filter hdEEG data

Folderpath = '/vol/research/nemo/datasets/RSN/data/hdEEG/RSN_001/';
filename = 'RSN_001_1_wake_e.eeg';
Savefolder = Folderpath;

EEG = pop_fileio([Folderpath,filesep,filename]);
% pop_eegplot(EEG)

%%
marker = EEG.event;
samp = cell2mat({marker.latency});
labels = {marker.type};

% Manual correction of startmarkers (if necessary)
% labels{1} = 'ERP_EO_Vol80'; % RSN_005_1_wake_m
% labels{2} = 'ERP_EO_Vol80'; % RSN_006_1_wake_e
% labels{2} = 'neuromodulation'; % RSN_007_1_wake_m

ECHT_trig = find(strcmp(labels, 'E  1')==1);
StimTrak_trig = find(strcmp(labels, 'S  1')==1);

ECHT_trigsamp = samp(ECHT_trig);
StimTrak_trigsamp = samp(StimTrak_trig);

startmarkers_ndx = setdiff([1:length(labels)],[ECHT_trig, StimTrak_trig]);
startmarkers = labels(startmarkers_ndx);

startmarkers{end+1} = 'end'; % add marker at the end (to know where last run ends)
samp(end+1) = samp(end)+1;
startmarkers_ndx(end+1) = length(samp); % add one sample so that end is after last trigger

% save([Savefolder,filename(1:end-4),'_filt.mat'],'a','ba','data_filt','ECHT_trig','ECHT_trigsamp','fs','high','low','labels','marker','order','samp','startmarkers','startmarkers_ndx','StimTrak_trig','StimTrak_trigsamp','-v7.3');

%% Find conditions

cond = unique(startmarkers);

ERP_ndx = find(contains(startmarkers,'ERP') == 1);

EO_ndx = find(contains(startmarkers,'EO') == 1);
EC_ndx = find(contains(startmarkers,'EC') == 1);

Vol80_ndx = find(contains(startmarkers,'Vol80') == 1);
Vol85_ndx = find(contains(startmarkers,'Vol85') == 1);
Vol90_ndx = find(contains(startmarkers,'Vol90') == 1);

cond_allndx_ERP{1} = EO_ndx;
cond_allndx_ERP{2} = EC_ndx;

conditions_ERP = {'EO','EC'};

%% Extract ERP triggers

for con = 1:length(conditions_ERP)

    condition = conditions_ERP{con};
    cond_ndx = cond_allndx_ERP{con};
    
    startsamp = samp(startmarkers_ndx(cond_ndx));
    endsamp = samp(startmarkers_ndx(cond_ndx+1));

    ECHT_trig_all = [];
    StimTrak_trig_all = [];

    vol_trigs_ECHT_all = [];
    vol_trigs_StimTrak_all = [];


    for r = 1:length(cond_ndx)

        if ismember(cond_ndx(r),Vol80_ndx)   
            vol = 80;
        elseif ismember(cond_ndx(r),Vol85_ndx) 
            vol = 85;
        elseif ismember(cond_ndx(r),Vol90_ndx) 
            vol = 90;
        end
    
    ECHT_trig = ECHT_trigsamp(find(ECHT_trigsamp > startsamp(r) & ECHT_trigsamp < endsamp(r)));
    ECHT_trig = ECHT_trig(2:end-1);
    StimTrak_trig = StimTrak_trigsamp(find(StimTrak_trigsamp > startsamp(r) & StimTrak_trigsamp < endsamp(r)));  
    
    vol_trigs_ECHT = repmat(vol,1,length(ECHT_trig));
    vol_trigs_StimTrak = repmat(vol,1,length(StimTrak_trig));
    
    ECHT_trig_all = [ECHT_trig_all ECHT_trig];
    StimTrak_trig_all = [StimTrak_trig_all StimTrak_trig];
    
    vol_trigs_ECHT_all = [vol_trigs_ECHT_all vol_trigs_ECHT];
    vol_trigs_StimTrak_all = [vol_trigs_StimTrak_all vol_trigs_StimTrak];

    clear ECHT_trig StimTrak_trig  vol_trigs_ECHT vol_trigs_StimTrak
    end

nm.ntrigs_ERP{con} = length(ECHT_trig_all);

nm.trigs_ECHT_ERP{con} = ECHT_trig_all;
nm.trigs_StimTrak_ERP{con} = StimTrak_trig_all;

nm.vol_trigs_ECHT_ERP{con} = vol_trigs_ECHT_all;
nm.vol_trigs_StimTrak_ERP{con} = vol_trigs_StimTrak_all;
   
nm.startsamp_ERP{con} = startsamp;
nm.endsamp_ERP{con} = endsamp;

clear startsamp endsamp

end

nm.conditions_ERP = conditions_ERP;

%%

save([Savefolder,filename(1:end-4),'_nm.mat'],'nm');



