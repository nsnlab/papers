clear all;
close all;

addpath(genpath('/users/psychology01/software/fieldtrip'));
addpath(genpath('/users/psychology01/software/eeglab'));
addpath(genpath('/mnt/beegfs/users/psychology01/useful_functions'));

Savefolder = '/users/m17462/psychology01/parallel_scratch/projects/RSN/analysis/';

        %% Cluster

cluster = parcluster('eureka'); % to add cluster go to home - parallel - create and manage clusters -import -go to config folder in software folder in psychology01 -open eureka .mlsettings file
% cluster.SubmitArguments = compose("--partition=high_mem --mem=%dG
% --time=%d", 16, 24*60); % for high memory job (max. memory that can be
% allocated in normal job is 8 or 12 GB, max. time is 7 days)
cluster.SubmitArguments = compose("--mem=%dG --time=%d", 64, 72*60); % for normal job, mem: memory in GB, time: time in min that is allocated to this job
cluster.NumWorkers = 1;
% cluster.NumThreads = 4;
cluster.JobStorageLocation = '/users/psychology01/Valeria/jobfiles'; % wdir: directory where job file is put

for band = 1:15
    
    batch(cluster,@cluster_analysis_power,0,{Savefolder, band},'AutoAttachFiles', false, ...
    'AutoAddClientPath', true, ...
    'CaptureDiary', true);

end

%%

function cluster_analysis_power(Savefolder, band)


%% Average across on and off blocks and calculate change

% load('/vol/research/nemo/datasets/RSN/data/analysis/psd_allsub/psd_allsub_mICA_avref_26-Feb-2023.mat','mpsd_con_ch','ntrials');
load('/users/m17462/psychology01/parallel_scratch/projects/RSN/analysis/psd_allsub_mICA_avref_12-Mar-2023.mat');

on_block = 7:12;
off_block = 1:6;

% f = [2:.1:30];%was [2:.25:30]

psd_ON = squeeze(nanmean(mpsd_con_ch(:,:,:,:,on_block),5)); % psd_ON: sub x ch x con x bins
psd_OFF = squeeze(nanmean(mpsd_con_ch(:,:,:,:,off_block),5));

psd_ON_phasic = squeeze(nanmean(mpsd_con_ch_phasic(:,:,:,:,on_block),5)); % psd_ON: sub x ch x con x bins
psd_OFF_phasic = squeeze(nanmean(mpsd_con_ch_phasic(:,:,:,:,off_block),5));

psd_ON_tonic = squeeze(nanmean(mpsd_con_ch_tonic(:,:,:,:,on_block),5)); % psd_ON: sub x ch x con x bins
psd_OFF_tonic = squeeze(nanmean(mpsd_con_ch_tonic(:,:,:,:,off_block),5));

band_freq = [1 2;2 3;3 4;4 5; 5 6; 6 7; 7 8; ...
             8 9; 9 10; 10 11; 11 12; 12 13; 13 14; 14 15; 15 16];

band_name = {'1-2 Hz' '2-3 Hz' '3-4 Hz' '4-5 Hz' '5-6 Hz' '6-7 Hz' '7-8 Hz'...
              '8-9 Hz' '9-10 Hz' '10-11 Hz' '11-12 Hz' '12-13 Hz' '13-14 Hz'...
              '14-15 Hz' '15-16 Hz'};


% band_freq = [1 3;3 6;6 9;9 12; 12 15];
% 
% band_name = {'1-3 Hz' '3-6 Hz' '6-9 Hz' '9-12 Hz' '12-15 Hz'};
          
conditions = {'Alpha Phase 0'; 'Alpha Phase 90'; 'Alpha Phase 180'; 'Alpha Phase 270';...
            'Theta Phase 0'; 'Theta Phase 90'; 'Theta Phase 180'; 'Theta Phase 270';}

       
%% topoplot layout 

close all

% Computes electrode locations 

cfg = []; 
cfg.layout = 'EEG1005.lay';
   
layout = ft_prepare_layout(cfg);

figure
hold on
ylim([min(layout.pos(:,2)) max(layout.pos(:,2))])
xlim([min(layout.pos(:,1)) max(layout.pos(:,1))])

load('/mnt/beegfs/users/psychology01/projects/RSN/analysis/chans.mat');

for i = 1:128

%scatter(layout.pos(i,1),layout.pos(i,2))

clear indx
indx = strcmp(chans(i),layout.label);
text(layout.pos(indx,1),layout.pos(indx,2),chans(i))
layout2.pos(i,:) = layout.pos(indx,:);
layout2.pos(i,:) = layout.pos(indx,:);
layout2.width(i,:) = layout.width(indx,:);
layout2.height(i,:) = layout.height(indx,:);
layout2.label{i} = chans{i};

end

layout2.mask = layout.mask;
layout2.outline = layout.outline;

% Scalp Current Density - create electrode positions

[~,ftpath] = ft_version; 
elec = ft_read_sens(strcat(ftpath, '/template/electrode/standard_1005.elc' )); 

clear elec2

for i = 1:128

%scatter(layout.pos(i,1),layout.pos(i,2))

clear indx

indx = strcmp(chans(i),elec.label);

%text(layout.pos(indx,1),layout.pos(indx,2),chans(i))

elec2.chanpos(i,:) = elec.chanpos(indx,:);
elec2.elecpos(i,:) = elec.elecpos(indx,:);
elec2.label(i,:) = elec.label(indx,:);


end

elec2.chantype = elec.chantype;
elec2.unit = elec.unit;
elec2.chanunit = elec.chanunit;
elec2.type = elec.type;

%

clc

cfg = [];
cfg.layout = layout2;
cfg.method = 'triangulation';
cfg.compress = 'yes';
cfg.feedback = 'yes';%'yes';
neighbours = ft_prepare_neighbours(cfg);

close all

%% lme: power change ~ condition * substage + 1|sub (cluster-corrected)

incl_sub = setdiff(1:19,12);

% for band = 1:15
    
    display(band_name{band});

    table_allch = [];
    
    for ch = 1:128
    
        
     perc_change_band_allcon = [];

     for con = 1:4
         
        band_ndx = find(f >= band_freq(band,1) & f <= band_freq(band,2));
        
        power_band_ON = nansum(psd_ON(incl_sub,:,con,band_ndx),4);
        power_band_OFF = nansum(psd_OFF(incl_sub,:,con,band_ndx),4);
        
        power_band_ON_phasic = nansum(psd_ON_phasic(incl_sub,:,con,band_ndx),4);
        power_band_OFF_phasic = nansum(psd_OFF_phasic(incl_sub,:,con,band_ndx),4);
        
        power_band_ON_tonic = nansum(psd_ON_tonic(incl_sub,:,con,band_ndx),4);
        power_band_OFF_tonic = nansum(psd_OFF_tonic(incl_sub,:,con,band_ndx),4);
        
        perc_change_band = log10(power_band_ON./power_band_OFF);
        perc_change_band_phasic = log10(power_band_ON_phasic./power_band_OFF_phasic);
        perc_change_band_tonic = log10(power_band_ON_tonic./power_band_OFF_tonic);
        
        perc_change_band_phasictonic = vertcat(perc_change_band_phasic(:,ch),perc_change_band_tonic(:,ch));
        
        perc_change_band_allcon = vertcat(perc_change_band_allcon,perc_change_band_phasictonic);
        
        clear perc_change_band_phasictonic
        
     end
        
        substage_all = [1.*ones(1,length(incl_sub)) 2.*ones(1,length(incl_sub)) 1.*ones(1,length(incl_sub)) 2.*ones(1,length(incl_sub)) 1.*ones(1,length(incl_sub)) 2.*ones(1,length(incl_sub)) 1.*ones(1,length(incl_sub)) 2.*ones(1,length(incl_sub))];
        cond_all =  [ones(1,length(incl_sub)*2)  2.*ones(1,length(incl_sub)*2) 3.*ones(1,length(incl_sub)*2) 4.*ones(1,length(incl_sub)*2)];
        sub_all = [1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub)];
        electrode = repmat(ch,length(incl_sub)*4*2,1);
        
        table_all = table(perc_change_band_allcon,substage_all',cond_all',electrode,sub_all','VariableNames',{'power_change','substage','condition','electrode','sub'});
   
        table_all.substage = categorical(table_all.substage);
        table_all.condition = categorical(table_all.condition);
        table_all.sub = categorical(table_all.sub);
        table_all.electrode = categorical(table_all.electrode);
       
        table_allch = vertcat(table_allch,table_all);
    end
    
    u = 1000;
    type = 'categorical';
    nch = 128;
    statsresult = SnPM_lmer_clus_def(u,table_allch,type,nch,neighbours);
    save([Savefolder,'statsresult_alpha_',band_name{band},'.mat'],'statsresult');
        
    clear table_allch statsresult
    
% end
        
% end
end