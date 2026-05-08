clear all;
close all;

addpath(genpath('/users/nemo/software/eeglab'));


Folderpath = '/parallel_scratch/nemo/RSN/hdEEG/RSN_001/';

czref_file = dir([Folderpath,'*sleep*czref.set']);
manual_ICA_file = dir([Folderpath,'ICA2/','*czref_goodREM_ICA_manual_ICA.set']);
goodrem_mat_file = dir([Folderpath,'*czref_goodREM.mat']);

%%

EEG = pop_loadset('filename',[czref_file(1).name],'filepath',[Folderpath]);
EEG = pop_select(EEG,'nochannel',{'Echt' 'EMG' 'lEOG' 'rEOG' 'ECG'});

EEG_mICA = pop_loadset('filename',[manual_ICA_file(1).name],'filepath',[Folderpath,'ICA2']);

load([Folderpath,goodrem_mat_file(1).name]);

EEG.data(:,rem_goodsamp2)= EEG_mICA.data;

EEG = pop_saveset(EEG, 'filename', [czref_file(1).name(1:end-4),'_mICA'], 'filepath', Folderpath);


% put back Cz
EEG.nbchan = EEG.nbchan+1;
EEG.data(end+1,:) = zeros(1, EEG.pnts);
EEG.chanlocs(1,EEG.nbchan).labels = 'Cz';
EEG = pop_chanedit(EEG, 'lookup','/users/nemo/software/eeglab/plugins/Fieldtrip-lite20210601/template/electrode/standard_1005.elc','eval','chans = pop_chancenter( chans, [],[]);');

originaleeg = EEG;

%% Average referencing

EEG = pop_reref(EEG, []); % average referencing
EEG = pop_saveset(EEG, 'filename', [czref_file(1).name(1:end-4),'_mICA_avref'], 'filepath', Folderpath);
clear EEG


% %% Laplacian referencing
% 
% EEG = originaleeg;
% 
% % Scalp Current Density - create electrode positions
% 
% [~,ftpath] = ft_version; 
% elec = ft_read_sens(strcat(ftpath, '/template/electrode/standard_1005.elc' )); 
% 
% clear elec2
% 
% chans = {EEG.chanlocs.labels};
% chans{76} = 'I1';
% chans{83} = 'I2';
% save('chans.mat','chans');
% 
%     for i = 1:128
% 
%         %scatter(layout.pos(i,1),layout.pos(i,2))
% 
%         clear indx
% 
%         indx = strcmp(chans(i),elec.label);
% 
%         %text(layout.pos(indx,1),layout.pos(indx,2),chans(i))
% 
%         elec2.chanpos(i,:) = elec.chanpos(indx,:);
%         elec2.elecpos(i,:) = elec.elecpos(indx,:);
%         elec2.label(i,:) = elec.label(indx,:);
% 
%     end
% 
% elec2.chantype = elec.chantype;
% elec2.unit = elec.unit;
% elec2.chanunit = elec.chanunit;
% elec2.type = elec.type;
% 
% % Re-reference
% 
% data = eeglab2fieldtrip(EEG, 'raw', 'none' );      
% data.elec = elec2;
% data.label = elec2.label;
% 
% cfg = [];
% cfg.method       = 'spline';    
% 
% cfg.elec = elec2;
% data2 = ft_scalpcurrentdensity(cfg, data);            
% EEG_reref = data2.trial{1};  
% 
% EEG.data = EEG_reref;
% EEG = pop_saveset(EEG, 'filename', [czref_file(1).name(1:end-4),'_mICA_lapref'], 'filepath', Folderpath);
