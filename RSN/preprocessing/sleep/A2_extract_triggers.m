clear all;
close all;

addpath(genpath('/user/HS301/m17462/matlab/eeglab'));
addpath(genpath('/user/HS301/m17462/matlab/Scripts/RSN'));

addpath /mnt/beegfs/users/psychology01/useful_functions

%% Load and filter hdEEG data

Folderpath = '/vol/research/nemo/datasets/RSN/data/hdEEG/RSN_024/';
filename = 'RSN_024_1_sleep.eeg'; % .eeg file / combined .set file for RSN_022
Savefolder = Folderpath;

EEG = pop_fileio([Folderpath,filesep,filename]);
% pop_eegplot(EEG)
% EEG = pop_loadset('filename', filename, 'filepath', Folderpath); % RSN_022 combined file


% define butterworth filter
low = 0.5;
high = 40;
fs = EEG.srate;
order = 2;
[ba,a] = butter(order, [low high]/(fs/2), 'bandpass');

% filter data
for ch = [2 128] %1:size(EEG.data,1)

data_filt(ch,:) = filtfilt(ba,a,EEG.data(ch,:));

end

% EEG = pop_eegfiltnew(EEG,0.5,40);

%%
marker = EEG.event;
samp = cell2mat({marker.latency});
labels = {marker.type};

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

% Manual correction of labels (if necessary)
% startmarkers{59} = 'Theta_Vol85_Phase270'; % RSN_001
% startmarkers{25} = 'Theta_Vol85_Phase270'; % RSN_001
% startmarkers{21} = 'Alpha_Vol85_Phase180'; % RSN_004
% startmarkers{8} = 'ERP_Vol85';             % RSN_009
% startmarkers{21} = 'Theta_Vol80_Phase270'; % RSN_010
% startmarkers{46} = 'Alpha_Vol85_Phase90'; % RSN_011
% startmarkers{15} = 'Alpha_Vol75_Phase90'; % RSN_015
% startmarkers{33} = 'Theta_Vol70_Phase270'; % RSN_015
% startmarkers{10} = 'Theta_Vol90_Phase0'; % RSN_021

% cond = unique(startmarkers);
alpha_ndx = find(contains(startmarkers,'Alpha') == 1);
theta_ndx = find(contains(startmarkers,'Theta') == 1);
ERP_ndx = find(contains(startmarkers,'ERP') == 1);

Phase0_ndx = find(contains(startmarkers,'Phase0') == 1);
Phase90_ndx = find(contains(startmarkers,'Phase90') == 1);
Phase180_ndx = find(contains(startmarkers,'Phase180') == 1);
Phase270_ndx = find(contains(startmarkers,'Phase270') == 1);

Vol80_ndx = find(contains(startmarkers,'Vol80') == 1);
Vol85_ndx = find(contains(startmarkers,'Vol85') == 1);
Vol90_ndx = find(contains(startmarkers,'Vol90') == 1);

Alpha_Phase0 = intersect(alpha_ndx,Phase0_ndx);
Alpha_Phase90 = intersect(alpha_ndx,Phase90_ndx);
Alpha_Phase180 = intersect(alpha_ndx,Phase180_ndx);
Alpha_Phase270 = intersect(alpha_ndx,Phase270_ndx);

Theta_Phase0 = intersect(theta_ndx,Phase0_ndx);
Theta_Phase90 = intersect(theta_ndx,Phase90_ndx);
Theta_Phase180 = intersect(theta_ndx,Phase180_ndx);
Theta_Phase270 = intersect(theta_ndx,Phase270_ndx);

cond_allndx{1} = Alpha_Phase0;
cond_allndx{2} = Alpha_Phase90;
cond_allndx{3} = Alpha_Phase180;
cond_allndx{4} = Alpha_Phase270;
cond_allndx{5} = Theta_Phase0;
cond_allndx{6} = Theta_Phase90;
cond_allndx{7} = Theta_Phase180;
cond_allndx{8} = Theta_Phase270;

conditions = {'Alpha_Phase0' 'Alpha_Phase90' 'Alpha_Phase180' 'Alpha_Phase270' 'Theta_Phase0' 'Theta_Phase90' 'Theta_Phase180' 'Theta_Phase270'};

%% Extract ERP triggers

startsamp = samp(startmarkers_ndx(ERP_ndx));
endsamp = samp(startmarkers_ndx(ERP_ndx+1));

ECHT_trig_all = [];
StimTrak_trig_all = [];

vol_trigs_ECHT_all = [];
vol_trigs_StimTrak_all = [];


for r = 1:length(ERP_ndx)

    if ismember(ERP_ndx(r),Vol80_ndx)   
       vol = 80;
    elseif ismember(ERP_ndx(r),Vol85_ndx) 
       vol = 85;
    elseif ismember(ERP_ndx(r),Vol90_ndx) 
       vol = 90;
    end
    
    ECHT_trig = ECHT_trigsamp(find(ECHT_trigsamp > startsamp(r) & ECHT_trigsamp < endsamp(r)));
    StimTrak_trig = StimTrak_trigsamp(find(StimTrak_trigsamp > startsamp(r) & StimTrak_trigsamp < endsamp(r)));  
    
    vol_trigs_ECHT = repmat(vol,1,length(ECHT_trig));
    vol_trigs_StimTrak = repmat(vol,1,length(StimTrak_trig));
    
    ECHT_trig_all = [ECHT_trig_all ECHT_trig];
    StimTrak_trig_all = [StimTrak_trig_all StimTrak_trig];
    
    vol_trigs_ECHT_all = [vol_trigs_ECHT_all vol_trigs_ECHT];
    vol_trigs_StimTrak_all = [vol_trigs_StimTrak_all vol_trigs_StimTrak];

    clear ECHT_trig StimTrak_trig  vol_trigs_ECHT vol_trigs_StimTrak
end

nm.ntrigs_ERP = length(ECHT_trig_all);

nm.trigs_ECHT_ERP = ECHT_trig_all;
nm.trigs_StimTrak_ERP = StimTrak_trig_all;

nm.vol_trigs_ECHT_ERP = vol_trigs_ECHT_all;
nm.vol_trigs_StimTrak_ERP = vol_trigs_StimTrak_all;
   
nm.startsamp_ERP = startsamp;
nm.endsamp_ERP = endsamp;

clear startsamp endsamp

%% Extract ON & OFF windows and triggers for Alpha/Theta neuromodulation


for con = 1:length(conditions)

    condition = conditions{con};
    cond_ndx = cond_allndx{con};
    
    startsamp = samp(startmarkers_ndx(cond_ndx));
    endsamp = samp(startmarkers_ndx(cond_ndx+1));
   
    OFF_start_all = [];
    OFF_end_all = [];
    ON_start_all = [];
    ON_end_all = [];

    ON_trigs_ECHT_all = [];
    OFF_trigs_ECHT_all = [];

    ON_trigs_StimTrak_all = [];
    OFF_trigs_StimTrak_all = [];
    
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
    StimTrak_trig = StimTrak_trigsamp(find(StimTrak_trigsamp > startsamp(r) & StimTrak_trigsamp < endsamp(r)));  
        
    OFF_diff = find(diff(ECHT_trig)>= 3000);
    OFF_start_ndx = OFF_diff;
    OFF_end_ndx = OFF_diff + 1;
    
    OFF_start = ECHT_trig(OFF_start_ndx);
    OFF_end = ECHT_trig(OFF_end_ndx);
    ON_start = OFF_end(1:length(OFF_end)-1);
    ON_end = OFF_start(2:length(OFF_start));
    
    if length(ON_start) > 20
       warning([condition,' Run: ',num2str(r), ' , Too many trials, check what happened']);
%        ON_start = ON_start(1:20);
%        ON_end = ON_end(1:20);
%        OFF_start = OFF_start(1:21);
%        OFF_end = OFF_end(1:21);     
    end
    
        for t = 1:length(ON_start)
        
            ON_trigs_ndx_ECHT = find(ECHT_trig > ON_start(t) & ECHT_trig < ON_end(t));
            OFF_trigs_ndx_ECHT = find(ECHT_trig > OFF_start(t) & ECHT_trig < OFF_end(t));
       
            ON_trigs_ndx_StimTrak = find(StimTrak_trig > ON_start(t) & StimTrak_trig < ON_end(t));
            OFF_trigs_ndx_StimTrak = find(StimTrak_trig > OFF_start(t) & StimTrak_trig < OFF_end(t));
       
            ntrigs_ON{r}(t) = length(ON_trigs_ndx_ECHT);
            ntrigs_OFF{r}(t) = length(OFF_trigs_ndx_ECHT);
       
            dur_ON{r}(t) = length(ON_start:ON_end)/fs;
            dur_OFF{r}(t) = length(OFF_start:OFF_end)/fs;
            
            vol_trigs_ECHT = repmat(vol,1,length(ON_trigs_ndx_ECHT));
            vol_trigs_StimTrak = repmat(vol,1,length(ON_trigs_ndx_StimTrak));
            
            ON_trigs_ECHT = ECHT_trig(ON_trigs_ndx_ECHT);
            OFF_trigs_ECHT = ECHT_trig(OFF_trigs_ndx_ECHT);
       
            ON_trigs_StimTrak = StimTrak_trig(ON_trigs_ndx_StimTrak);
            OFF_trigs_StimTrak = StimTrak_trig(OFF_trigs_ndx_StimTrak);
       
            ON_trigs_ECHT_all = [ON_trigs_ECHT_all ON_trigs_ECHT];
            OFF_trigs_ECHT_all = [OFF_trigs_ECHT_all OFF_trigs_ECHT];
       
            ON_trigs_StimTrak_all = [ON_trigs_StimTrak_all ON_trigs_StimTrak];
            OFF_trigs_StimTrak_all = [OFF_trigs_ECHT_all OFF_trigs_StimTrak];
            
            vol_trigs_ECHT_all = [vol_trigs_ECHT_all vol_trigs_ECHT];
            vol_trigs_StimTrak_all = [vol_trigs_StimTrak_all vol_trigs_ECHT];
           

            clear ON_trigs_ndx OFF_trigs_ndx ON_trigs OFF_trigs
       
        end
    
    OFF_start_all = [OFF_start_all OFF_start];
    OFF_end_all = [OFF_end_all OFF_end];
    ON_start_all = [ON_start_all ON_start];
    ON_end_all = [ON_end_all ON_end];

    clear OFF_start OFF_end ON_start ON_end    
      
    end

   nm.condition{con} = condition; 
    
   nm.OFF_start{con} = OFF_start_all;
   nm.OFF_end{con} = OFF_end_all;
   nm.ON_start{con} = ON_start_all;
   nm.ON_end{con} = ON_end_all;
   
   nm.ON_trigs_ECHT{con} = ON_trigs_ECHT_all;
   nm.OFF_trigs_ECHT{con} = OFF_trigs_ECHT_all;
   nm.ON_trigs_StimTrak{con} = ON_trigs_StimTrak_all;
   nm.OFF_trigs_StimTrak{con} = OFF_trigs_StimTrak_all;
   
   nm.ntrigs_ON{con} = ntrigs_ON;
   nm.ntrigs_OFF{con} = ntrigs_OFF;
   
   nm.dur_ON{con} = dur_ON;
   nm.dur_OFF{con} = dur_OFF;
   
   nm.vol_trigs_ECHT{con} = vol_trigs_ECHT_all;
   nm.vol_trigs_StimTrak{con} = vol_trigs_StimTrak_all;
   
   nm.startsamp{con} = startsamp;
   nm.endsamp{con} = endsamp;

   clear OFF_start_all OFF_end_all ON_start_all ON_end_all ON_trigs_ECHT_all OFF_trigs_ECHT_all ON_trigs_StimTrak_all OFF_trigs_StimTrak_all ntrigs_ON ntrigs_OFF dur_ON dur_OFF
  
    
end

nm.cond_allndx = cond_allndx;
nm.startmarkers = startmarkers;
nm.startmarkers_ndx = startmarkers_ndx;

%% Alpha - Phase analysis

echt_ch = 128;
fz = 2; %17;

data_echt = double(data_filt(echt_ch,:));
data_fz = double(data_filt(fz,:));

filt_lf = 7.5;
filt_hf = 12.5;

colors = linspecer(4);

for con = 1:4

% based on ECHT data
    ON_trigs_StimTrak_all = nm.ON_trigs_StimTrak{con};

    for trig = 1:length(ON_trigs_StimTrak_all)
       
        hilb_echt = echt(data_echt(ON_trigs_StimTrak_all(trig)-fs:ON_trigs_StimTrak_all(trig)), filt_lf, filt_hf, fs);    
        stim_phase_echt(trig) = angle(hilb_echt(end)); 
       
       clear hilb_ECHT
    end
 
% based on Fz of hdEEG
    for trig = 1:length(ON_trigs_StimTrak_all)
       
        hilb_fz = echt(data_fz(ON_trigs_StimTrak_all(trig)-fs:ON_trigs_StimTrak_all(trig)), filt_lf, filt_hf, fs);    
        stim_phase_fz(trig) = angle(hilb_fz(end)); 
       
        clear hilb_fz
    end  
    
 
    nm.stimphase_echt{con} = stim_phase_echt;
    nm.stimphase_fz{con} = stim_phase_fz;
  
    clear stim_phase_echt stim_phase_fz

end


%% Alpha - Make polar plot 

% Make polar plot based on echt data
figure 

for con = 1:4

    stim_phase_echt = nm.stimphase_echt{con};
    
    polarhistogram(stim_phase_echt,100,'FaceColor',colors(con,:),'LineWidth',.75)  % Polar Histogram   
    hold on
    title({['RSN ',filename(5:7)] ['Alpha (echt data)']});
    
    clear stim_phase_echt
    
end

if ~exist([Savefolder,filesep,'QC_Plots'])
    mkdir([Savefolder,filesep,'QC_Plots']);   
end
print([Savefolder,filesep,'QC_Plots/Alpha_phase_plot_echt'],'-dpng');
    
% Make polar plot based on hdEEG Fz data
figure 

for con = 1:4

    stim_phase_fz = nm.stimphase_fz{con};
    
    polarhistogram(stim_phase_fz,100,'FaceColor',colors(con,:),'LineWidth',.75)  % Polar Histogram   
    hold on
    title({['RSN ',filename(5:7)] ['Alpha (Fz data)']});

    clear stim_phase_echt

    
end
% 
% if ~exist([Savefolder,filesep,'QC_Plots'])
%     mkdir([Savefolder,filesep,'QC_Plots']);   
% end
% print([Savefolder,filesep,'QC_Plots/Alpha_phase_plot_fz'],'-dpng');


%% Theta - Phase analysis

echt_ch = 128;
fz = 2; %17;

data_echt = double(data_filt(echt_ch,:));
data_fz = double(data_filt(fz,:));

filt_lf = 4.5;
filt_hf = 7.5;

colors = linspecer(4);

for con = 5:8

% based on ECHT data
    ON_trigs_StimTrak_all = nm.ON_trigs_StimTrak{con};

    for trig = 1:length(ON_trigs_StimTrak_all)
       
        hilb_echt = echt(data_echt(ON_trigs_StimTrak_all(trig)-fs:ON_trigs_StimTrak_all(trig)), filt_lf, filt_hf, fs);    
        stim_phase_echt(trig) = angle(hilb_echt(end)); 
       
       clear hilb_ECHT
    end
 
% based on Fz of hdEEG
    for trig = 1:length(ON_trigs_StimTrak_all)
       
        hilb_fz = echt(data_fz(ON_trigs_StimTrak_all(trig)-fs:ON_trigs_StimTrak_all(trig)), filt_lf, filt_hf, fs);    
        stim_phase_fz(trig) = angle(hilb_fz(end)); 
       
        clear hilb_fz
    end  
    
 
    nm.stimphase_echt{con} = stim_phase_echt;
    nm.stimphase_fz{con} = stim_phase_fz;
  
    clear ON_trigs_StimTrak_all stim_phase_echt stim_phase_fz

end


%% Theta - Make polar plot 

% Make polar plot based on echt data
figure 

for con = 5:8

    stim_phase_echt = nm.stimphase_echt{con};
    
    polarhistogram(stim_phase_echt,100,'FaceColor',colors(con-4,:),'LineWidth',.75)  % Polar Histogram   
    hold on
    title({['RSN ',filename(5:7)] ['Theta (echt data)']});
    
    clear stim_phase_echt
    
end

if ~exist([Savefolder,filesep,'QC_Plots'])
    mkdir([Savefolder,filesep,'QC_Plots']);   
end
print([Savefolder,filesep,'QC_Plots/Theta_phase_plot_echt'],'-dpng');
    
% Make polar plot based on hdEEG Fz data
% figure 
% 
% for con = 5:8
% 
%     stim_phase_fz = nm.stimphase_fz{con};
%     
%     polarhistogram(stim_phase_fz,100,'FaceColor',colors(con-4,:),'LineWidth',.75)  % Polar Histogram   
%     hold on
%     title({['RSN ',filename(5:7)] ['Theta (Fz data)']});
% 
%     clear stim_phase_fz
%     
% end
% 
% if ~exist([Savefolder,filesep,'QC_Plots'])
%     mkdir([Savefolder,filesep,'QC_Plots']);   
% end
% print([Savefolder,filesep,'QC_Plots/Theta_phase_plot_fz'],'-dpng');


%% Power analysis using echt data

echt_ch = 128;
fz = 2; %17;

data_echt = double(data_filt(echt_ch,:));
data_fz = double(data_filt(fz,:));

dt = 6;
on_block = 7:12;
off_block = 1:6;

colors = linspecer(4);

for con = 1:8
    
    ON_start_all = nm.ON_start{con};

    for t = 1:length(ON_start_all)

        trial_eeg = data_echt(ON_start_all(t)-dt*fs:ON_start_all(t)+dt*fs-1);
       
        f = [2:.1:30];%was [2:.25:30]
        epochlength = 1;
        window = 1; 
        noverlap = .5;
       
        for ep = 1:length(trial_eeg)/fs
       
        trial_eeg_ep = trial_eeg(epochlength*(ep-1)*fs+1:epochlength*ep*fs);
        psd(:,ep,t) = pwelch(trial_eeg_ep,window*fs,noverlap,f,fs); 

        end
       
    end

    mtrials_psd = nanmean(psd,3); % average psd across all trials of all runs

    psd_ON = nanmean(mtrials_psd(:,on_block),2); % average psd across on sec
    psd_OFF = nanmean(mtrials_psd(:,off_block),2); % average psd across off sec
    psd_ONOFF_change = (psd_ON - psd_OFF)./psd_OFF *100; 
    
    nm.mtrials_psd{con} = mtrials_psd;
    nm.psd_ON{con} = psd_ON;
    nm.psd_OFF{con} = psd_OFF;
    nm.psd_ONOFF_change{con} = psd_ONOFF_change;

    clear mtrials_psd psd_ON psd_OFF psd_ONOFF_change

end


%% Alpha - Plot power spectrum and change

% Plot power spectrum for on and off windows
for con = 1:4
    
    psd_ON = nm.psd_ON{con};
    psd_OFF = nm.psd_OFF{con};
        
    figure
    plot(f,psd_ON,'Color','r','LineWidth',2);
    hold on
    plot(f,psd_OFF,'Color','b','LineWidth',2);
    hold on
    xlabel('Frequency (Hz)');
    ylabel('Power spectral density (uV^2/s)');
    legend({'ON' 'OFF'})
    title({['RSN ',filename(5:7)] ['Alpha ', conditions{con}(7:end),' (echt data)']});
%     ylim([-60 120]);

    if ~exist([Savefolder,filesep,'QC_Plots'])
        mkdir([Savefolder,filesep,'QC_Plots']);   
    end
    print([Savefolder,filesep,'QC_Plots/',conditions{con},'_powerspectrum_echt'],'-dpng');
    close all
    
    clear psd_ON psd_OFF
   
end


% Plot power spectrum change
figure

for con = 1:4
    
    psd_ONOFF_change = nm.psd_ONOFF_change{con};
        
    plot(f,psd_ONOFF_change,'Color',colors(con,:),'LineWidth',2);
    hold on
    xlabel('Frequency (Hz)');
    ylabel('ON/OFF change (%)');
    title({['RSN ',filename(5:7)] ['Alpha (echt data)']});
    ylim([-60 120]);
   
    clear psd_ONOFF_change
    
end

legend(conditions{1:4});

if ~exist([Savefolder,filesep,'QC_Plots'])
   mkdir([Savefolder,filesep,'QC_Plots']);   
end
print([Savefolder,filesep,'QC_Plots/','Alpha_powerspectrum_change_echt'],'-dpng');

%% Theta - Plot power spectrum and change

% Plot power spectrum for on and off windows
for con = 5:8
    
    psd_ON = nm.psd_ON{con};
    psd_OFF = nm.psd_OFF{con};
        
    figure
    plot(f,psd_ON,'Color','r','LineWidth',2);
    hold on
    plot(f,psd_OFF,'Color','b','LineWidth',2);
    hold on
    xlabel('Frequency (Hz)');
    ylabel('Power spectral density (uV^2/s)');
    legend({'ON' 'OFF'})
    title({['RSN ',filename(5:7)] ['Theta ', conditions{con}(7:end),' (echt data)']});
%     ylim([-60 120]);

    if ~exist([Savefolder,filesep,'QC_Plots'])
        mkdir([Savefolder,filesep,'QC_Plots']);   
    end
    print([Savefolder,filesep,'QC_Plots/',conditions{con},'_powerspectrum_echt'],'-dpng');
    close all
    
    clear psd_ON psd_OFF
   
end


% Plot power spectrum change
figure

for con = 5:8
    
    psd_ONOFF_change = nm.psd_ONOFF_change{con};
        
    plot(f,psd_ONOFF_change,'Color',colors(con-4,:),'LineWidth',2);
    hold on
    xlabel('Frequency (Hz)');
    ylabel('ON/OFF change (%)');
    title({['RSN ',filename(5:7)] ['Theta (echt data)']});
    ylim([-60 120]);
    
    clear psd_ONOFF_change
   
end

legend(conditions{5:8});

if ~exist([Savefolder,filesep,'QC_Plots'])
   mkdir([Savefolder,filesep,'QC_Plots']);   
end
print([Savefolder,filesep,'QC_Plots/','Theta_powerspectrum_change_echt'],'-dpng');

%%

save([Savefolder,filesep,filename(1:end-4),'_nm.mat'],'nm');



