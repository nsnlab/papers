close all
clear 
clc

% addpath('/users/psychology01/software/automaticanalysis/');

% clear;
% aa_ver5

addpath(genpath('/user/HS301/m17462/matlab/eeglab/'));
addpath(genpath('/user/HS301/m17462/matlab/fieldtrip/'));    

%%

Folderpath = '/vol/research/nemo/datasets/RSN/data/hdEEG/RSN_006/ICA_RSN_006_1_wake_m_fil_czref_goodwake/';
Folderpath_dir = dir([Folderpath,'*ICA.set']);
% Folderpath_dir = dir([Folderpath,'*ICs_removed.set']);
filename = Folderpath_dir(1).name;

Folderpath_auxch = '/vol/research/nemo/datasets/RSN/data/hdEEG/RSN_006/';
Folderpath_auxch_dir = dir([Folderpath_auxch,'*wake_m_fil_auxch_all.set']);
matfile = dir([Folderpath_auxch,'*wake_m_fil_czref_goodwake.mat']);

%%

% cd('/mnt/beegfs/users/psychology01/Henry')
% aap = aarecipe('aap_tasklist_meeg.xml');
% SPM = aas_inittoolbox(aap,'spm');
% SPM.load;

% EL = aas_inittoolbox(aap,'eeglab');
% EL.load;


%% 

% cond_name = {'sham';'sham2';'sham3';'stim';'stim2';'stim3'};

%%

close all

% sub = 12;
% cond = 1;


%% View IC's

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename',[filename],'filepath',[Folderpath]);
% EEG = pop_loadset('filename',['IV_',dataName,'ICA.set'],'filepath',[Folderpath,filesep,dataName]);

[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 0, 1, 1);

pop_viewprops(EEG, 0, 1:30, {}, {}, 0);%,1,[],1:3);%,{},{},0,{},{});

EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:); % get component data

% EEG = pop_saveset(EEG, 'filename', [filename(1:end-4),'_autoartcorr_reref_components'], 'filepath', Folderpath);

%%

EEG.manualrejcomp = [1 13 18 22]; % define eye movement components

%% Plot eye movements and eye components

eeg_aux = pop_loadset('filename', [Folderpath_auxch_dir(1).name], 'filepath', Folderpath_auxch);

load([Folderpath_auxch,matfile(1).name],'wake_goodsamp2');
eeg_aux.data = eeg_aux.data(:,wake_goodsamp2);

if ~isequal(size(EEG.data,2),size(eeg_aux.data,2))
    error('Not same data length of EOG and component data');
end

EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:); % get component data

c1 = EEG.icaact(EEG.manualrejcomp(1),:);
c2 = EEG.icaact(EEG.manualrejcomp(2),:);

lEOG = eeg_aux.data(3,:);
rEOG = eeg_aux.data(4,:);
% lEOG = eeg_aux.data(4,:);
% rEOG = eeg_aux.data(5,:);

epochl = 10;

for ep = 30:40

figure

subplot(2,1,1)
plot(lEOG((ep-1)*epochl*EEG.srate+1:ep*epochl*EEG.srate),'Color',[1 0 0])
hold on
plot(rEOG((ep-1)*epochl*EEG.srate+1:ep*epochl*EEG.srate),'Color',[0 0.4470 0.7410])
ylim([-100 100])
title('EOG')
legend({'lEOG' 'rEOG'})
    
subplot(2,1,2)
plot(c1((ep-1)*epochl*EEG.srate+1:ep*epochl*EEG.srate),'Color',[0.3010 0.7450 0.9330])
hold on
plot(c2((ep-1)*epochl*EEG.srate+1:ep*epochl*EEG.srate),'Color',[0.8500 0.3250 0.0980])
ylim([-20 20])
title('Components')
legend({['IC',num2str(EEG.manualrejcomp(1))] ['IC',num2str(EEG.manualrejcomp(2))]})

end

    %% Reject IC's

% close all
EEG = eeg_checkset(EEG);
EEG = pop_subcomp(EEG, EEG.manualrejcomp, 1); % define manually which components to reject

pop_newset(ALLEEG, EEG, 1,'savenew',[Folderpath,filename(1:end-4),'_manual_ICA'],'gui','off'); 

pop_eegplot(EEG);

%% Make topoplot

fs = EEG.srate;
epochl = 30; % [s], epoch length
windowl = 4; % [s], window length (segmentation window, Tukey)
overlap = 1; % [s], overlap of adjacent windows
ratio = 0.5; % ratio taper to constant sector of window
nepochs = floor(size(EEG.data,2)/(fs*epochl));
        
for ch = 1:size(EEG.data,1)

    for epo = 1:nepochs

        startEp = (epo-1)*epochl*fs+1;
        endEp = epo*epochl*fs;
        %FFT pwelch(data,window,overlap,nFFT,sampling freq)
        [pow,ff] = pwelch(EEG.data(ch,startEp:endEp),tukeywin(windowl*fs,ratio),...
                           fs*overlap,windowl*fs,fs);        
        ffttot(ch,:,epo) = pow;

    end
            
end

mpsd = nanmean(ffttot,3);

figure
for ch = 1:30

plot(ff,mpsd(ch,:));
xlim([1,30]);
hold on

end
a = 1:30;
legend(num2str(a'))

figure
for ch = 31:60

plot(ff,mpsd(ch,:));
xlim([1,30]);
hold on

end
a = 31:60;
legend(num2str(a'))

figure
for ch = 61:90

plot(ff,mpsd(ch,:));
xlim([1,30]);
hold on

end
a = 61:90;
legend(num2str(a'))

figure
for ch = 91:127

plot(ff,mpsd(ch,:));
xlim([1,30]);
hold on

end
a = 91:127;
legend(num2str(a'))


delta_freq = [1 8];
delta_freqndx = find(ff >= delta_freq(1) & ff <= delta_freq(2));
delta_power = nanmean(squeeze(sum(ffttot(:,delta_freqndx,:),2)),2);

alpha_freq = [8 12];
alpha_freqndx = find(ff >= alpha_freq(1) & ff <= alpha_freq(2));
alpha_power = nanmean(squeeze(sum(ffttot(:,alpha_freqndx,:),2)),2);

beta_freq = [12 30];
beta_freqndx = find(ff >= beta_freq(1) & ff <= beta_freq(2));
beta_power = nanmean(squeeze(sum(ffttot(:,beta_freqndx,:),2)),2);

% topoplot layout 

% close all

% Computes electrode locations 

cfg = []; 
cfg.layout = 'EEG1005.lay';
   
layout = ft_prepare_layout(cfg);

figure
hold on
ylim([min(layout.pos(:,2)) max(layout.pos(:,2))])
xlim([min(layout.pos(:,1)) max(layout.pos(:,1))])

load('/user/HS301/m17462/matlab/Scripts/RSN/preprocessing/sleep/chans.mat');

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

% Plot

clc

cfg = [];
cfg.layout = layout2;
cfg.method = 'triangulation';
cfg.compress = 'yes';
cfg.feedback = 'yes';%'yes';
neighbours = ft_prepare_neighbours(cfg);

figure
ft_plot_topo(layout2.pos(1:127,1),layout2.pos(1:127,2),delta_power','mask',layout2.mask,'outline',layout2.outline, ...
'interplim','mask','gridscale',300); 
ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
colormap(flipud(brewermap(64,'RdBu')))
cb = colorbar;
axis off
axis square
title('Delta');

figure
ft_plot_topo(layout2.pos(1:127,1),layout2.pos(1:127,2),alpha_power','mask',layout2.mask,'outline',layout2.outline, ...
'interplim','mask','gridscale',300); 
ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
colormap(flipud(brewermap(64,'RdBu')))
cb = colorbar;
axis off
axis square
title('Alpha');

figure
ft_plot_topo(layout2.pos(1:127,1),layout2.pos(1:127,2),beta_power','mask',layout2.mask,'outline',layout2.outline, ...
'interplim','mask','gridscale',300); 
ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
colormap(flipud(brewermap(64,'RdBu')))
cb = colorbar;
axis off
axis square
title('Beta');

%%
labels = {EEG.chanlocs.labels};

delta_outlier_ndx = find(delta_power > 400)
delta_oulier_label = labels(delta_outlier_ndx)

alpha_outlier_ndx = find(alpha_power > 250)
alpha_oulier_label = labels(alpha_outlier_ndx)

beta_outlier_ndx = find(beta_power > 80)
beta_oulier_label = labels(beta_outlier_ndx)



