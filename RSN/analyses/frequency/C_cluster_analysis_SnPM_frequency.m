clear all;
close all;

addpath(genpath('/users/psychology01/software/fieldtrip'));
addpath(genpath('/users/psychology01/software/eeglab'));
addpath(genpath('/mnt/beegfs/users/psychology01/useful_functions'));

Savefolder = '/users/m17462/psychology01/parallel_scratch/projects/RSN/analysis/';
% Savefolder = '/vol/research/nemo/datasets/RSN/data/analysis/topo_allsub_lapref/';

        %% Cluster

cluster = parcluster('eureka'); % to add cluster go to home - parallel - create and manage clusters -import -go to config folder in software folder in psychology01 -open eureka .mlsettings file
% cluster.SubmitArguments = compose("--partition=high_mem --mem=%dG
% --time=%d", 16, 24*60); % for high memory job (max. memory that can be
% allocated in normal job is 8 or 12 GB, max. time is 7 days)
cluster.SubmitArguments = compose("--mem=%dG --time=%d", 64, 72*60); % for normal job, mem: memory in GB, time: time in min that is allocated to this job
cluster.NumWorkers = 1;
% cluster.NumThreads = 4;
cluster.JobStorageLocation = '/users/psychology01/Valeria/jobfiles'; % wdir: directory where job file is put

% for band = 1:2
    
    batch(cluster,@cluster_analysis_frequency,0,{Savefolder},'AutoAttachFiles', false, ...
    'AutoAddClientPath', true, ...
    'CaptureDiary', true);

% end

%%

function cluster_analysis_frequency(Savefolder)


load('/users/m17462/psychology01/parallel_scratch/projects/RSN/analysis/freqalphatheta_allsub_23-Jun-2023.mat');

%% Average across on and off blocks and calculate change

on_block = 7:12;
off_block = 1:6;
          
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
band = 1;
display(num2str(band));

table_allch = [];

    for ch = 1:128
    
     dat = [];        
     perc_change_freq_alphaband_allcon = [];

     for con = 1:4
         
%         band_ndx = find(f >= band_freq(band,1) & f <= band_freq(band,2));

        ifq_alphaband_ON = squeeze(ifq.on_ifq_alpha(incl_sub,con,:));
        ifq_alphaband_OFF = squeeze(ifq.off_ifq_alpha(incl_sub,con,:));
        
        ifq_alphaband_ON_phasic = squeeze(ifq.on_ifq_alpha_phasic(incl_sub,con,:));
        ifq_alphaband_OFF_phasic = squeeze(ifq.off_ifq_alpha_phasic(incl_sub,con,:));
        
        ifq_alphaband_ON_tonic = squeeze(ifq.on_ifq_alpha_tonic(incl_sub,con,:));
        ifq_alphaband_OFF_tonic = squeeze(ifq.off_ifq_alpha_tonic(incl_sub,con,:));
        
        perc_change_freq_alphaband = log10(ifq_alphaband_ON./ifq_alphaband_OFF); %ifq_alphaband_ON - ifq_alphaband_OFF;
        perc_change_alphaband_phasic = log10(ifq_alphaband_ON_phasic./ifq_alphaband_OFF_phasic); %ifq_alphaband_ON_phasic - ifq_alphaband_OFF_phasic;
        perc_change_alphaband_tonic = log10(ifq_alphaband_ON_tonic./ifq_alphaband_OFF_tonic); %ifq_alphaband_ON_tonic - ifq_alphaband_OFF_tonic;
       
%         dat = vertcat(dat,perc_change_freq_alphaband(:,ch));
        perc_change_freq_alphaband_phasictonic = vertcat(perc_change_alphaband_phasic(:,ch),perc_change_alphaband_tonic(:,ch));

        
        perc_change_freq_alphaband_allcon = vertcat(perc_change_freq_alphaband_allcon,perc_change_freq_alphaband_phasictonic);
        
        clear perc_change_freq_alphaband perc_change_freq_alphaband_phasic perc_change_freq_alphaband_tonic perc_change_freq_alphaband_phasictonic
        
     end
        
        substage_all = [1.*ones(1,length(incl_sub)) 2.*ones(1,length(incl_sub)) 1.*ones(1,length(incl_sub)) 2.*ones(1,length(incl_sub)) 1.*ones(1,length(incl_sub)) 2.*ones(1,length(incl_sub)) 1.*ones(1,length(incl_sub)) 2.*ones(1,length(incl_sub))];
        cond_all =  [ones(1,length(incl_sub)*2)  2.*ones(1,length(incl_sub)*2) 3.*ones(1,length(incl_sub)*2) 4.*ones(1,length(incl_sub)*2)];
        sub_all = [1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub)];
        electrode = repmat(ch,length(incl_sub)*4*2,1);
        
        
        table_all = table(perc_change_freq_alphaband_allcon,substage_all',cond_all',electrode,sub_all','VariableNames',{'freq_change','substage','condition','electrode','sub'});
        
        
        table_all.substage = categorical(table_all.substage);
        table_all.condition = categorical(table_all.condition);
        table_all.sub = categorical(table_all.sub);
        table_all.electrode = categorical(table_all.electrode);

        table_allch = vertcat(table_allch,table_all);
        
        
    end
    
    
    u = 1000;
    type = 'categorical';
    nch = 128;
    statsresult = SnPM_lmer_clus_def_freq(u,table_allch,type,nch,neighbours);
    save([Savefolder,'statsresult_alphastim_alphafreq.mat'],'statsresult');
        
    clear table_allch statsresult
    
    
    band = 2;
   display(num2str(band));

table_allch = [];

    for ch = 1:128
    
     dat = [];        
     perc_change_freq_thetaband_allcon = [];

     for con = 1:4
         
%         band_ndx = find(f >= band_freq(band,1) & f <= band_freq(band,2));

        ifq_thetaband_ON = squeeze(ifq.on_ifq_theta(incl_sub,con,:));
        ifq_thetaband_OFF = squeeze(ifq.off_ifq_theta(incl_sub,con,:));
        
        ifq_thetaband_ON_phasic = squeeze(ifq.on_ifq_theta_phasic(incl_sub,con,:));
        ifq_thetaband_OFF_phasic = squeeze(ifq.off_ifq_theta_phasic(incl_sub,con,:));
        
        ifq_thetaband_ON_tonic = squeeze(ifq.on_ifq_theta_tonic(incl_sub,con,:));
        ifq_thetaband_OFF_tonic = squeeze(ifq.off_ifq_theta_tonic(incl_sub,con,:));
        
        perc_change_freq_thetaband = log10(ifq_thetaband_ON./ifq_thetaband_OFF); %ifq_thetaband_ON - ifq_thetaband_OFF;
        perc_change_thetaband_phasic = log10(ifq_thetaband_ON_phasic./ifq_thetaband_OFF_phasic); %ifq_thetaband_ON_phasic - ifq_thetaband_OFF_phasic;
        perc_change_thetaband_tonic = log10(ifq_thetaband_ON_tonic./ifq_thetaband_OFF_tonic); %ifq_thetaband_ON_tonic - ifq_thetaband_OFF_tonic;
       
%         dat = vertcat(dat,perc_change_freq_thetaband(:,ch));
        perc_change_freq_thetaband_phasictonic = vertcat(perc_change_thetaband_phasic(:,ch),perc_change_thetaband_tonic(:,ch));

        
        perc_change_freq_thetaband_allcon = vertcat(perc_change_freq_thetaband_allcon,perc_change_freq_thetaband_phasictonic);
        
        clear perc_change_freq_thetaband perc_change_freq_thetaband_phasic perc_change_freq_thetaband_tonic perc_change_freq_thetaband_phasictonic
        
     end
        
        substage_all = [1.*ones(1,length(incl_sub)) 2.*ones(1,length(incl_sub)) 1.*ones(1,length(incl_sub)) 2.*ones(1,length(incl_sub)) 1.*ones(1,length(incl_sub)) 2.*ones(1,length(incl_sub)) 1.*ones(1,length(incl_sub)) 2.*ones(1,length(incl_sub))];
        cond_all =  [ones(1,length(incl_sub)*2)  2.*ones(1,length(incl_sub)*2) 3.*ones(1,length(incl_sub)*2) 4.*ones(1,length(incl_sub)*2)];
        sub_all = [1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub)];
        electrode = repmat(ch,length(incl_sub)*4*2,1);
        
        
        table_all = table(perc_change_freq_thetaband_allcon,substage_all',cond_all',electrode,sub_all','VariableNames',{'freq_change','substage','condition','electrode','sub'});
        
        
        table_all.substage = categorical(table_all.substage);
        table_all.condition = categorical(table_all.condition);
        table_all.sub = categorical(table_all.sub);
        table_all.electrode = categorical(table_all.electrode);

        table_allch = vertcat(table_allch,table_all);
        
        
    end
    
    
    u = 1000;
    type = 'categorical';
    nch = 128;
    statsresult = SnPM_lmer_clus_def_freq(u,table_allch,type,nch,neighbours);
    save([Savefolder,'statsresult_alphastim_thetafreq.mat'],'statsresult');
        
    clear table_allch statsresult
    

    
end

