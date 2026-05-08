clear all;
close all;

addpath(genpath('/users/psychology01/software/fieldtrip'));
addpath(genpath('/users/psychology01/software/eeglab'));
addpath(genpath('/users/psychology01/Valeria/Scripts/RSN/analysis'));

Savefolder = '/users/m17462/psychology01/parallel_scratch/projects/RSN/analysis/';
% Savefolder = '/vol/research/nemo/datasets/RSN/data/analysis/topo_allsub_lapref/';

%% Cluster

cluster = parcluster('eureka'); % to add cluster go to home - parallel - create and manage clusters -import -go to config folder in software folder in psychology01 -open eureka .mlsettings file
% cluster.SubmitArguments = compose("--partition=high_mem --mem=%dG
% --time=%d", 16, 24*60); % for high memory job (max. memory that can be
% allocated in normal job is 8 or 12 GB, max. time is 7 days)
cluster.SubmitArguments = compose("--mem=%dG --time=%d", 24, 72*60); % for normal job, mem: memory in GB, time: time in min that is allocated to this job
cluster.NumWorkers = 1;
% cluster.NumThreads = 4;
cluster.JobStorageLocation = '/users/psychology01/Valeria/jobfiles'; % wdir: directory where job file is put

for band1 = 3 %1:4
    
    for band2 = 3:4 %1:4
    
    batch(cluster,@cluster_analysis_connectivity,0,{Savefolder, band1, band2},'AutoAttachFiles', false, ...
        'AutoAddClientPath', true, ...
        'CaptureDiary', true);
     
    end
end

%%

function cluster_analysis_connectivity(Savefolder, band1, band2)

try
    
%     load('/users/m17462/psychology01/parallel_scratch/projects/RSN/analysis/connectivity_allsub_25-Aug-2023.mat','PLV*','PLI*');
    load('/users/m17462/psychology01/parallel_scratch/projects/RSN/analysis/connectivity_allsub_07-Dec-2023.mat','PLV*','PLI*');
    
    band_name = {'1-4 Hz' '4-7 Hz' '7-12 Hz' '13-30 Hz' '8-12 Hz'};
    
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
    
    
    %% lme: PLV change ~ condition * substage + 1|sub (cluster-corrected)
    
%     band1 = band;
%     band2 = band;
    
    incl_sub = setdiff(1:19,12);
    
    seeds = [2 34 65 94] %1:128; %[2 34 65 94];
    
    table_allch = [];
    
    for ch = 1:128
        
        perc_change_allcon = [];
        
        for cond = 1:4
            
            
            PLV_ON_table = squeeze(nanmean(PLV_on.band1{band1}.band2{band2}.cond{cond}(ch,seeds,incl_sub),2));
            PLV_OFF_table = squeeze(nanmean(PLV_off.band1{band1}.band2{band2}.cond{cond}(ch,seeds,incl_sub),2));
            
            PLV_ON_phasic_table = squeeze(nanmean(PLV_on_phasic.band1{band1}.band2{band2}.cond{cond}(ch,seeds,incl_sub),2));
            PLV_OFF_phasic_table = squeeze(nanmean(PLV_off_phasic.band1{band1}.band2{band2}.cond{cond}(ch,seeds,incl_sub),2));
            
            PLV_ON_tonic_table = squeeze(nanmean(PLV_on_tonic.band1{band1}.band2{band2}.cond{cond}(ch,seeds,incl_sub),2));
            PLV_OFF_tonic_table = squeeze(nanmean(PLV_off_tonic.band1{band1}.band2{band2}.cond{cond}(ch,seeds,incl_sub),2));
            
            perc_change_PLV = log10(PLV_ON_table./PLV_OFF_table); %ifq_alphaband_ON - ifq_alphaband_OFF;
            perc_change_PLV_phasic = log10(PLV_ON_phasic_table./PLV_OFF_phasic_table ); %ifq_alphaband_ON_phasic - ifq_alphaband_OFF_phasic;
            perc_change_PLV_tonic = log10(PLV_ON_tonic_table./PLV_OFF_tonic_table); %ifq_alphaband_ON_tonic - ifq_alphaband_OFF_tonic;
            
            perc_change_phasictonic = vertcat(perc_change_PLV_phasic,perc_change_PLV_tonic);
            
            perc_change_allcon = vertcat(perc_change_allcon,perc_change_phasictonic);
            
            clear perc_change_PLV_phasic perc_change_PLV_tonic perc_change_phasictonic
            
        end
        
        
        substage_all = [1.*ones(1,length(incl_sub)) 2.*ones(1,length(incl_sub)) 1.*ones(1,length(incl_sub)) 2.*ones(1,length(incl_sub)) 1.*ones(1,length(incl_sub)) 2.*ones(1,length(incl_sub)) 1.*ones(1,length(incl_sub)) 2.*ones(1,length(incl_sub))];
        cond_all =  [ones(1,length(incl_sub)*2)  2.*ones(1,length(incl_sub)*2) 3.*ones(1,length(incl_sub)*2) 4.*ones(1,length(incl_sub)*2)];
        sub_all = [1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub)];
        electrode = repmat(ch,length(incl_sub)*4*2,1);
        
        table_all = table(perc_change_allcon,substage_all',cond_all',electrode,sub_all','VariableNames',{'PLV_change','substage','condition','electrode','sub'});
        
        table_all.substage = categorical(table_all.substage);
        table_all.condition = categorical(table_all.condition);
        table_all.sub = categorical(table_all.sub);
        table_all.electrode = categorical(table_all.electrode);
        
        table_allch = vertcat(table_allch,table_all);
        
    end
    
    
    u = 1000;
    type = 'categorical';
    nch = 128;
    
    statsresult = SnPM_lmer_clus_def_PLV(u,table_allch,type,nch,neighbours);
    display('saving PLV');
    save([Savefolder,'statsresult_alphastim_PLV_frontalseeds_',band_name{band1},'-',band_name{band2},'.mat'],'statsresult');
    
    clear table_allch statsresult
            
    display('PLV saved');
    
    %% lme: PLI change ~ condition * substage + 1|sub (cluster-corrected)
    
%     band1 = band;
%     band2 = band;
    
    incl_sub = setdiff(1:19,12);
    
    seeds = [2 34 65 94] %1:128; %[2 34 65 94];
    
    table_allch = [];
    
    for ch = 1:128
        
        perc_change_allcon = [];
        
        for cond = 1:4
            
            
            PLI_ON_table = squeeze(nanmean(PLI_on.band1{band1}.band2{band2}.cond{cond}(ch,seeds,incl_sub),2));
            PLI_OFF_table = squeeze(nanmean(PLI_off.band1{band1}.band2{band2}.cond{cond}(ch,seeds,incl_sub),2));
            
            PLI_ON_phasic_table = squeeze(nanmean(PLI_on_phasic.band1{band1}.band2{band2}.cond{cond}(ch,seeds,incl_sub),2));
            PLI_OFF_phasic_table = squeeze(nanmean(PLI_off_phasic.band1{band1}.band2{band2}.cond{cond}(ch,seeds,incl_sub),2));
            
            PLI_ON_tonic_table = squeeze(nanmean(PLI_on_tonic.band1{band1}.band2{band2}.cond{cond}(ch,seeds,incl_sub),2));
            PLI_OFF_tonic_table = squeeze(nanmean(PLI_off_tonic.band1{band1}.band2{band2}.cond{cond}(ch,seeds,incl_sub),2));
            
            perc_change_PLI = log10(PLI_ON_table./PLI_OFF_table); %ifq_alphaband_ON - ifq_alphaband_OFF;
            perc_change_PLI_phasic = log10(PLI_ON_phasic_table./PLI_OFF_phasic_table ); %ifq_alphaband_ON_phasic - ifq_alphaband_OFF_phasic;
            perc_change_PLI_tonic = log10(PLI_ON_tonic_table./PLI_OFF_tonic_table); %ifq_alphaband_ON_tonic - ifq_alphaband_OFF_tonic;
            
            perc_change_phasictonic = vertcat(perc_change_PLI_phasic,perc_change_PLI_tonic);
            
            perc_change_allcon = vertcat(perc_change_allcon,perc_change_phasictonic);
            
            clear perc_change_PLI_phasic perc_change_PLI_tonic perc_change_phasictonic
            
        end
        
        
        substage_all = [1.*ones(1,length(incl_sub)) 2.*ones(1,length(incl_sub)) 1.*ones(1,length(incl_sub)) 2.*ones(1,length(incl_sub)) 1.*ones(1,length(incl_sub)) 2.*ones(1,length(incl_sub)) 1.*ones(1,length(incl_sub)) 2.*ones(1,length(incl_sub))];
        cond_all =  [ones(1,length(incl_sub)*2)  2.*ones(1,length(incl_sub)*2) 3.*ones(1,length(incl_sub)*2) 4.*ones(1,length(incl_sub)*2)];
        sub_all = [1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub) 1:length(incl_sub)];
        electrode = repmat(ch,length(incl_sub)*4*2,1);
        
        table_all = table(perc_change_allcon,substage_all',cond_all',electrode,sub_all','VariableNames',{'PLI_change','substage','condition','electrode','sub'});
        
        table_all.substage = categorical(table_all.substage);
        table_all.condition = categorical(table_all.condition);
        table_all.sub = categorical(table_all.sub);
        table_all.electrode = categorical(table_all.electrode);
        
        table_allch = vertcat(table_allch,table_all);
        
    end
    
    
    u = 1000;
    type = 'categorical';
    nch = 128;
    statsresult = SnPM_lmer_clus_def_PLI(u,table_allch,type,nch,neighbours);    
    display('saving PLI');
    save([Savefolder,'statsresult_alphastim_PLI_frontalseeds_',band_name{band1},'-',band_name{band2},'.mat'],'statsresult');
    
    clear table_allch statsresult
            
    display('PLI saved');
        
    display('the end');
catch exception
    display(exception.message)
    display(exception.identifier)
    error()
end

end

