%% Example of batch code to preprocess multiple subjects
 
% Step 1: Change the option to use double precision.

clear all;
close all;

%% Define folders

Folderpath = '/vol/research/nemo/datasets/RSN/data/hdEEG/RSN_024/'; % with \ at the end
Folderpath_dir = dir([Folderpath,'*_wake_m_fil.set']);

%%
filename = Folderpath_dir(1).name;
dataName = filename(1:end-4);
        
%% add relevant toolboxes and functions to path

% addpath /users/hh00720/parallel_scratch/
% addpath /users/psychology01/henry/
% addpath('/users/psychology01/software/automaticanalysis/');

addpath(genpath('/user/HS301/m17462/matlab/eeglab'));
addpath(genpath('/user/HS301/m17462/matlab/csc-eeg-tools-develop'));

%% Load filtered data, and scoring data

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename', filename, 'filepath', Folderpath);

% save whole night aux channels
EEG_aux_all = pop_select(EEG,'channel',{'Echt' 'EMG' 'lEOG' 'rEOG' 'ECG'}); % remove FCz for RSN_001 and RSN_002 because it was placed on Iz
EEG_aux_all = pop_saveset(EEG_aux_all, 'filename', [dataName,'_auxch_all'], 'filepath', Folderpath);

fs = EEG.srate;
epochl = 30; % [s], epoch length
nepochs = floor(size(EEG.data,2)/(fs*epochl));

%% Plot good REM data, write down bad channels in excel


%     EEG2 = EEG;
%     EEG2.data = EEG2.data(:,rem_goodsamp);
%     pop_eegplot(EEG2); % enter bad channels in badchans excel    
%     clear EEG2

%% load bad channels

badchans_dir = dir([Folderpath,'*badchans*']);

badchans_channels = xlsread([Folderpath,badchans_dir(1).name],'Sheet1','A2:A129');
[badchans_names badchans_names] = xlsread([Folderpath,badchans_dir(1).name],'Sheet1','B2:B129');
badchans_mask = xlsread([Folderpath,badchans_dir(1).name],'Sheet1','C2:C129');
badchans_ndx = find(badchans_mask == 1);
badchans_labels = badchans_names(badchans_ndx);
 
    %% Remove aux channels, interpolate bad channels
    
    EEG.chanlocs(76).labels = 'I1';
    EEG.chanlocs(83).labels = 'I2';
    
    EEG = pop_chanedit(EEG, 'lookup','/user/HS301/m17462/matlab/eeglab/plugins/dipfit4.3/standard_BEM/elec/standard_1005.elc','eval','chans = pop_chancenter( chans, [],[]);');
%     eeg = pop_chanedit(eeg, 'lookup','/users/psychology01/software/eeglab/plugins/dipfit4.3/standard_BEM/elec/standard_1005.elc','eval','chans = pop_chancenter( chans, [],[]);');

    originaleeg = EEG;
    
    for b = 1:length(badchans_labels)
      
        EEG = pop_select(EEG,'nochannel',{badchans_labels{b}});
      
    end

     EEG = pop_interp(EEG, originaleeg.chanlocs, 'spherical');   
     
     EEG = pop_saveset(EEG, 'filename', [dataName,'_czref'], 'filepath', Folderpath);
     
     originaleeg2 = EEG;
     
     
     % Step 9: Re-reference the data to average, put Cz back, check Cz
%   don't re-reference before running the ICA so that 'clean' data can be
%   re-referenced to any ref
%     EEG.nbchan = EEG.nbchan+1;
%     EEG.data(end+1,:) = zeros(1, EEG.pnts);
%     EEG.chanlocs(1,EEG.nbchan).labels = 'Cz';
%     EEG = pop_chanedit(EEG, 'lookup','/user/HS301/m17462/matlab/Scripts/RSN/standard_1005.elc','eval','chans = pop_chancenter( chans, [],[]);');
%     EEG = pop_reref(EEG, []); % average referencing
%     EEG2 = EEG;
%     EEG2.data = EEG2.data(:,rem_goodsamp);
%     pop_eegplot(EEG2, 1, 0, 1); % check Cz, if bad, adapt excel
%     badchans_channels = xlsread([Folderpath,badchans_dir(1).name],'Sheet1','A2:A129');
%     [badchans_names badchans_names] = xlsread([Folderpath,badchans_dir(1).name],'Sheet1','B2:B129');
%     badchans_mask = xlsread([Folderpath,badchans_dir(1).name],'Sheet1','C2:C129');
%     badchans_ndx = find(badchans_mask == 1);
%     badchans_labels = badchans_names(badchans_ndx);
% %     interpolate Cz
%     if badchans_mask(128)==1
%     EEG = pop_interp(EEG, 128, 'spherical');  
%     EEG2 = EEG;
%     EEG2.data = EEG2.data(:,rem_goodsamp);
%     pop_eegplot(EEG2); % check if Cz is good now
%     clear EEG2
%     end

    %% Check if there are some remaining artefacts
     
%     EEG2 = EEG;
%     EEG2.data = EEG2.data(:,rem_goodsamp);
%     EEG2.times = EEG2.times(:,rem_goodsamp);
%     EEG2.pnts = length(EEG2.times);
%     EEG2.event = [];
%     EEG2.urevent = [];
%     EEG2 = csc_eeg_plotter(EEG2);
%     event_marker = EEG2.csc_event_data;
%     event_type = cell2mat(event_marker(:,3));
%     event_start = cell2mat(event_marker(:,2));
%     art_startndx = find(event_type == 1);
%     art_endndx = find(event_type == 2);
%     art_start = floor(event_start(art_startndx)*fs); % artefact start in samples
%     art_end = floor(event_start(art_endndx)*fs); % artefact end in samples
%     
%     badsamps_all = [];
%     for a = 1:length(art_start)
%         
%         badsamps = art_start(a):1:art_end(a);
%         figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
%         plot(EEG2.data(1,badsamps(1)-15*fs:badsamps(end)+15*fs));
%         ylim([-200 200]);
%         badsamps_all = vertcat(badsamps_all,badsamps');
%         
%     end

EEG2 = EEG;
% EEG2 = pop_select(EEG2,'nochannel',{'lEOG'});
pop_eegplot(EEG2,1,1,1); 

%% find samples of remaining artefacts

marker = EEG.event;
samp = cell2mat({marker.latency});
duration = {marker.duration};
labels = {marker.type};
art_marker = find(strcmp(labels, 'boundary')==1);
art_start = floor(samp(art_marker)); % sample of artefact start
art_duration = duration(art_marker);

badsamps_all = [];
art_duration2 = 0;

    for a = 1:length(art_start)
        
        if a == 1
           art_start2 = art_start(a); 
        else
            art_start2 = art_start(a) + art_duration2;
        end
        
        art_end2 = art_start2 + art_duration{a};   
        
        if art_end2 > size(EEG.data,2) & art_start2 < size(EEG.data,2)
           art_end2 = size(EEG.data,2);
        end
        
        ch = 5;
        badsamps = art_start2:1:art_end2;
        
%         figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
%         plot(EEG2.data(ch,badsamps(1):badsamps(end)));
%         hold on
%         plot([15*fs 15*fs],[-200 200]);
%         hold on
%         plot([15*fs+length(badsamps) 15*fs+length(badsamps)],[-200 200]);        
%         ylim([-200 200]);
        
        badsamps_all = vertcat(badsamps_all,badsamps');
        
        art_duration2 = art_duration2 + art_duration{a};
        
        clear art_start2 art_end2
        
    end


% clear EEG2
    
    %% Extract good REM data
        
    EEG = originaleeg2;
    % save and remove aux channels
%     EEG_aux = pop_select(EEG,'channel',{'Echt' 'EMG' 'lEOG' 'rEOG' 'ECG'}); 
%     EEG_aux = pop_saveset(EEG_aux, 'filename', [dataName,'_auxch'], 'filepath', Folderpath);
    EEG = pop_select(EEG,'nochannel',{'Echt' 'EMG' 'lEOG' 'rEOG' 'ECG'});
    % extract good REM data
    wake_goodsamp = 1:size(EEG.data,2);
    wake_goodsamp2 = wake_goodsamp;
    wake_goodsamp2(badsamps_all)=[];
    EEG.data = EEG.data(:,wake_goodsamp2);
    EEG.times = EEG.times(:,wake_goodsamp2);
    EEG.event = [];
    EEG.urevent = [];
%     EEG = csc_eeg_plotter(EEG);
    pop_eegplot(EEG,1,1,1); 
    
    %%
  
    EEG = pop_saveset(EEG, 'filename', [dataName,'_czref_goodwake'], 'filepath', Folderpath);

%     EEG.data = EEG.data(:,rem_goodsamp);
%     EEG.times = EEG.times(rem_goodsamp);
%     EEG = pop_saveset(EEG, 'filename', [dataName,'_avref_goodREM'], 'filepath', Folderpath);

  
    %

    save([Folderpath,dataName,'_czref_goodwake.mat'],'badchans_mask','badchans_labels','fs','wake_goodsamp2');
   


    
  