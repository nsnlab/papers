clear all;
close all;

addpath(genpath('/user/HS301/m17462/matlab/eeglab'));

Folderpath = '/vol/research/nemo/datasets/RSN/data/hdEEG/RSN_024/';
ICA_folder = dir([Folderpath,'ICA_RSN_024_1_wake_m*']);

czref_file = dir([Folderpath,'*wake_m_fil_czref.set']);
manual_ICA_file = dir([Folderpath,ICA_folder(1).name,filesep,'*wake_m_fil_czref_goodwake_ICA_manual_ICA.set']);
goodrem_mat_file = dir([Folderpath,'*wake_m_fil_czref_goodwake.mat']);

%%
EEG = pop_loadset('filename',[czref_file(1).name],'filepath',[Folderpath]);
EEG = pop_select(EEG,'nochannel',{'Echt' 'EMG' 'lEOG' 'rEOG' 'ECG'});

EEG_mICA = pop_loadset('filename',[manual_ICA_file(1).name],'filepath',[manual_ICA_file(1).folder]);

load([Folderpath,goodrem_mat_file(1).name]);


if length(wake_goodsamp2) == size(EEG_mICA.data,2)
    EEG.data(:,wake_goodsamp2)= EEG_mICA.data;
else
    error('Not same size of goodsamp and ICA data');
end

EEG = pop_saveset(EEG, 'filename', [czref_file(1).name(1:end-4),'_mICA'], 'filepath', Folderpath);


% put back Cz
EEG.nbchan = EEG.nbchan+1;
EEG.data(end+1,:) = zeros(1, EEG.pnts);
EEG.chanlocs(1,EEG.nbchan).labels = 'Cz';
EEG = pop_chanedit(EEG, 'lookup','/user/HS301/m17462/matlab/eeglab/plugins/dipfit4.3/standard_BEM/elec/standard_1005.elc','eval','chans = pop_chancenter( chans, [],[]);');

originaleeg = EEG;

%% Average referencing

EEG = pop_reref(EEG, []); % average referencing
EEG = pop_saveset(EEG, 'filename', [czref_file(1).name(1:end-4),'_mICA_avref'], 'filepath', Folderpath);
clear EEG

% %% Laplacian referencing

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
% 
% 
% 
