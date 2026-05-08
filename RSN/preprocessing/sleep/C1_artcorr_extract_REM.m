clear all;
close all;

%% Define folders

Folderpath = '/parallel_scratch/nemo/RSN/hdEEG/RSN_001/';

%%
Folderpath_dir = dir([Folderpath,'*_sleep_fil.set']);
filename = Folderpath_dir(1).name;
dataName = filename(1:end-4);

hypnofile_dir = dir([Folderpath,'*profile*.txt']);
REM_file_dir = dir([Folderpath,'*scoredREMlabels_2023*']);
        
%% add relevant toolboxes and functions to path

addpath(genpath('/user/HS301/m17462/matlab/eeglab'));

%% Load filtered data, and scoring data

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename', filename, 'filepath', Folderpath);

% save whole night aux channels
EEG_aux_all = pop_select(EEG,'channel',{'Echt' 'EMG' 'lEOG' 'rEOG' 'ECG'}); % remove FCz for RSN_001 and RSN_002 because it was placed on Iz
% EEG_aux_all = pop_saveset(EEG_aux_all, 'filename', [dataName,'_auxch_all'], 'filepath', Folderpath);

fs = EEG.srate;
epochl = 30; % [s], epoch length
nepochs = floor(size(EEG.data,2)/(fs*epochl));

fid1 = fopen([Folderpath,hypnofile_dir(1).name]);
hypno = fscanf(fid1,'%s');
if hypno(1) ~= 'W' && hypno(1) ~= '1' && hypno(1) ~= '2' && hypno(1) ~= '3' && hypno(1) ~= 'R'
    hypno = hypno(2:end);
end

hypno2 = hypno(1:nepochs);


load([Folderpath,REM_file_dir(1).name]);

%% find good rem windows and phasic and tonic segments

windowl = 1;

EOG_L = squeeze(Labels(1,:,:));
EOG_R = squeeze(Labels(2,:,:));
            
EOG_L_exp = reshape(EOG_L,windowl,[]);
EOG_R_exp = reshape(EOG_R,windowl,[]);

EOG_L_exp2 = EOG_L_exp(2:end); 
EOG_R_exp2 = EOG_R_exp(2:end);


for ep = 1:size(EOG_L_exp2,2)
    
    if isempty(find(EOG_L_exp2(:,ep)== 2))
       phasic_ep(ep) = 0; 
    else
       phasic_ep(ep) = 1;  
    end
  
    if isempty(find(EOG_L_exp2(:,ep)== 3))  
       tonic_ep(ep) = 0; 
    else
       tonic_ep(ep) = 1;  
    end
  
    if isempty(find(EOG_L_exp2(:,ep)== 1))  
       art_ep(ep) = 0; 
    else
       art_ep(ep) = 1;  
    end
    
    if isempty(find(EOG_L_exp2(:,ep)== 0))  
       scored_ep(ep) = 1; 
    else
       scored_ep(ep) = 0;  
    end

end

phasic_ndx = find(phasic_ep == 1); % phasic epoch (epoch that has at least 1 phasic segment)
tonic_phasic_ndx = find(tonic_ep == 1);   % epoch that has at least 1 tonic segment 
tonic_ndx = setdiff(tonic_phasic_ndx,phasic_ndx); % tonic epoch (epoch that has at least 1 tonic and no phasic segment)

good_ndx = find(art_ep == 0);
scored_ndx = find(scored_ep == 1);
good_scored_ndx = intersect(good_ndx,scored_ndx);

hypno3 = repelem(hypno2,epochl/windowl);
hypno4 = hypno3(2:end); % take out first second to align with REM scoring
rem_ndx = find(hypno4 == 'R');
nrem_ndx = find(hypno4 == '2' | hypno4 == '3');

rem_goodndx = intersect(rem_ndx,good_ndx);
rem_goodscored_ndx = intersect(rem_ndx,good_ndx);

unscored_rem = setdiff(rem_goodndx,good_scored_ndx);
if ~isempty(unscored_rem)
    warning('unscored rem epochs');
end

%% Find good REM samples, phasic and tonic good REM samples

   rem_goodsamp = [];
    
    for ep = 1:length(rem_goodndx)
        
        ep_ndx = rem_goodndx(ep);
        ep_samp = ((ep_ndx-1)*fs*windowl+1):(ep_ndx*fs*windowl);
        rem_goodsamp = [rem_goodsamp ep_samp];
        
        clear ep_samp
        
    end
    
       rem_samp = [];
    
    for ep = 1:length(rem_ndx)
        
        ep_ndx = rem_ndx(ep);
        ep_samp = ((ep_ndx-1)*fs*windowl+1):(ep_ndx*fs*windowl);
        rem_samp = [rem_samp ep_samp];
        
        clear ep_samp
        
    end
    
    
%% Plot good REM data, write down bad channels in excel

    EEG2 = EEG;
    EEG2.data = EEG2.data(:,rem_goodsamp);
    pop_eegplot(EEG2); % enter bad channels in badchans excel    
    clear EEG2

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
    
    % load standard channel locations, this can be found in eeglab/plugins/dipfit4.3/standard_BEM/elec/standard_1005.elc'
    EEG = pop_chanedit(EEG, 'lookup','/user/HS301/m17462/matlab/Scripts/RSN/preprocessing/sleep/standard_1005.elc','eval','chans = pop_chancenter( chans, [],[]);');

    originaleeg = EEG;
    
    for b = 1:length(badchans_labels)
      
        EEG = pop_select(EEG,'nochannel',{badchans_labels{b}});
      
    end

     EEG = pop_interp(EEG, originaleeg.chanlocs, 'spherical');   
     EEG = pop_saveset(EEG, 'filename', [dataName,'_czref'], 'filepath', Folderpath);
     
     originaleeg2 = EEG;
     
     
    %% Check if there are some remaining artefacts
     
EEG2 = EEG;
EEG2.data = EEG2.data(:,rem_goodsamp);
EEG2.times = EEG2.times(:,rem_goodsamp);
EEG2.pnts = length(EEG2.times);
EEG2.xmax = 1/EEG.srate * EEG2.pnts;
EEG2.event = [];
EEG2.urevent = [];

pop_eegplot(EEG2,1,1,1); % mark artefacts in eeglab interface

%% find samples of remaining artefacts

marker = EEG.event;
samp = cell2mat({marker.latency});
duration = {marker.duration};
labels = {marker.type};
art_marker = find(strcmp(labels, 'boundary')==1);
n_art = length(art_marker);
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
        
        art_start2_sec(a) = art_start2/fs;
        
        art_end2 = art_start2 + art_duration{a};   
        
        ch = 2;
        badsamps = art_start2:1:art_end2;
%         to check if badsamps really are the artefacts you marked
%         figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
%         plot(EEG2.data(ch,badsamps(1)-15*fs:badsamps(end)+15*fs));
%         hold on
%         plot([15*fs 15*fs],[-200 200]);
%         hold on
%         plot([15*fs+length(badsamps) 15*fs+length(badsamps)],[-200 200]);        
%         ylim([-200 200]);
%         title(num2str(art_start2_sec(a)));
        badsamps_all = vertcat(badsamps_all,badsamps');
        
        art_duration2 = art_duration2 + art_duration{a};
        
        clear art_start2 art_end2
        
    end


clear EEG2
    
    %% Extract good REM data
        
    EEG = originaleeg2;
    EEG = pop_select(EEG,'nochannel',{'Echt' 'EMG' 'lEOG' 'rEOG' 'ECG'});
    % extract good REM data
    rem_goodsamp2 = rem_goodsamp;
    rem_goodsamp2(badsamps_all)=[];
    EEG.data = EEG.data(:,rem_goodsamp2);
    EEG.times = EEG.times(:,rem_goodsamp2);
    EEG.event = [];
    EEG.urevent = [];
    pop_eegplot(EEG,1,1,1); 
    
    %% save food REM data
  
    EEG = pop_saveset(EEG, 'filename', [dataName,'_czref_goodREM'], 'filepath', Folderpath);

    %% save good REM samples (rem_goodsamp2), good phasic (phasic_goodsamp2) and good tonic (tonic_goodsamp2) samples info
    
       phasic_samp = [];
    
    for ep = 1:length(phasic_ndx)
        
        ep_ndx = phasic_ndx(ep);
        ep_samp = ((ep_ndx-1)*fs*windowl+1):(ep_ndx*fs*windowl);
        phasic_samp = [phasic_samp ep_samp];
        
        clear ep_samp
        
    end
    
    phasic_goodsamp2 = intersect(phasic_samp,rem_goodsamp2);
    
    tonic_samp = [];
    
    for ep = 1:length(tonic_ndx)
        
        ep_ndx = tonic_ndx(ep);
        ep_samp = ((ep_ndx-1)*fs*windowl+1):(ep_ndx*fs*windowl);
        tonic_samp = [tonic_samp ep_samp];
        
        clear ep_samp
        
    end
    
    tonic_goodsamp2 = intersect(tonic_samp,rem_goodsamp2);

    save([Folderpath,dataName,'_czref_goodREM.mat'],'badchans_mask','badchans_labels','fs','epochl','windowl','nepochs','hypno2','hypno4','phasic_ep','tonic_ep','art_ep','rem_goodsamp','rem_goodsamp2','phasic_goodsamp2','tonic_goodsamp2');
   


    
  