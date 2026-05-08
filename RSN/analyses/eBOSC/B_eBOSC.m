clear all;
close all;

addpath(genpath('/user/HS301/m17462/matlab/eeglab'));
addpath(genpath('/user/HS301/m17462/matlab/eBOSC'));

Folderpath = '/vol/research/nemo/datasets/RSN/data/hdEEG/';
sub_Folderpath = dir([Folderpath,'RSN*']);

Savefolder = '/vol/research/nemo/datasets/RSN/data/analysis/oscillation_detection/';

%% Average across on and off blocks and calculate change
lower_freq_alpha = 7.5;
higher_freq_alpha = 12.5;
lower_freq_theta = 4.5;
higher_freq_theta = 7.5;
%%

for s = 1:length(sub_Folderpath)
    
mICA_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_sleep*_fil_czref_mICA_avref.set']);
EEG = pop_loadset('filename',[mICA_file(1).name],'filepath',[Folderpath,sub_Folderpath(s).name]);
    
goodREM_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_sleep*_fil_czref_goodREM.mat']);
load([Folderpath,sub_Folderpath(s).name,filesep,goodREM_file(1).name]);
    
nm_good_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_nm_good_psd_allch.mat']);
load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name]); 

%% eBOSC settings
cfg = [];
cfg.eBOSC.channel = []; %[];%all channels
cfg.eBOSC.trial = 1;
cfg.eBOSC.trial_background = 1;

%cfg.eBOSC.F           = 1:.5:44;    % frequency sampling
cfg.eBOSC.F = 1:.25:30; %1:.25:30;%2.^[0:.0125:5];%1:.25:18;%
% f = cfg.eBOSC.F;
cfg.eBOSC.wavenumber  = 6;% wavelet family parameter (time-frequency tradeoff)
cfg.eBOSC.fsample     = fs;     % current sampling frequency of EEG data

cfg.eBOSC.pad.tfr_s = 1;            % padding following wavelet transform to avoid edge artifacts in seconds (bi-lateral)
cfg.eBOSC.pad.detection_s = .5;     % padding following rhythm detection in seconds (bi-lateral); 'shoulder' for BOSC eBOSC.detected matrix to account for duration threshold
cfg.eBOSC.pad.background_s = 1;     % padding of segments for BG (only avoiding edge artifacts)
cfg.eBOSC.threshold.excludePeak = [];                                   % lower and upper bound of frequencies to be excluded during background fit (Hz) (previously: LowFreqExcludeBG HighFreqExcludeBG)
cfg.eBOSC.threshold.duration	= repmat(3, 1, numel(cfg.eBOSC.F));         % vector of duration thresholds at each frequency (previously: ncyc)
cfg.eBOSC.threshold.percentile  = .95;                                      % percentile of background fit for power threshold

cfg.eBOSC.postproc.use      = 'no';         % Post-processing of rhythmic eBOSC.episodes, i.e., wavelet 'deconvolution' (default = 'no')
cfg.eBOSC.postproc.method   = 'MaxBias';	% Deconvolution method (default = 'MaxBias', FWHM: 'FWHM')
cfg.eBOSC.postproc.edgeOnly = 'yes';        % Deconvolution only at on- and offsets of eBOSC.episodes? (default = 'yes')
cfg.eBOSC.postproc.effSignal= 'PT'; 

%%

data = double(EEG.data);
waves_allepch = [];

for ep = 1:nepochs
    
    for ch = 2 %1:128

    samp_ep = (ep-1)*epochl*fs+1:ep*epochl*fs;
    
    signal.label{1} =  'Fz';
    signal.trial{1} = data(ch,samp_ep);
    signal.time{1} = (1:length(signal.trial{1}))./fs;


    [eBOSC, ~] = eBOSC_wrapper(cfg, signal);
    
    tmp_abu = squeeze(eBOSC.abundance_ep);
    f = cfg.eBOSC.F;
    abundance_alpha(ep) = sum(tmp_abu(f>= lower_freq_alpha & f<= higher_freq_alpha)); %abundance
    abundance_theta(ep) = sum(tmp_abu(f>= lower_freq_theta & f<= higher_freq_theta)); %abundance
    
    criteria_alpha = eBOSC.episodes.FrequencyMean >= lower_freq_alpha & eBOSC.episodes.FrequencyMean <= higher_freq_alpha; %& eBOSC.episodes.DurationC >= 3; %eBOSC.episodes.FrequencyMean >= bandf(band,1) & eBOSC.episodes.FrequencyMean <= bandf(band,2)
    density_alpha(ep) = sum(criteria_alpha)/epochl*60; %density (number per minute)
    
    criteria_theta = eBOSC.episodes.FrequencyMean >= lower_freq_theta & eBOSC.episodes.FrequencyMean <= higher_freq_theta; %& eBOSC.episodes.DurationC >= 3; %eBOSC.episodes.FrequencyMean >= bandf(band,1) & eBOSC.episodes.FrequencyMean <= bandf(band,2)
    density_theta(ep) = sum(criteria_theta)/epochl*60; %density (number per minute)

   channel  = repmat(ch,length(eBOSC.episodes.Channel),1);
   startsamp = (ep-1)*fs*epochl + eBOSC.episodes.Onset*fs;  
   endsamp = (ep-1)*fs*epochl + eBOSC.episodes.Offset*fs;
   duration = (endsamp-startsamp)/fs;
   cycles = eBOSC.episodes.DurationC;
   power = eBOSC.episodes.PowerMean;
   SNR = eBOSC.episodes.SNRMean;
   frequency = eBOSC.episodes.FrequencyMean;
   nep = repmat(ep,length(startsamp),1);
   stage = repelem(hypno2(ep),length(startsamp),1);
   offset = repmat(eBOSC.static.pv(:,2),length(startsamp),1);
   exponent = repmat(eBOSC.static.pv(:,1),length(startsamp),1);
   
                
   waves_ep = table(channel,startsamp,endsamp,duration,cycles,power,SNR,frequency,nep,stage,offset,exponent);
   waves_allepch= vertcat(waves_allepch,waves_ep);
   clear waves_ep channel startsamp endsamp duration cycles power SNR frequency nep stage offset exponent

    end

end

save([Savefolder,sub_Folderpath(s).name,'_eBOSC_waves.mat'],'waves_allepch','abundance_alpha','abundance_theta','density_alpha','density_theta','-v7.3')

clear abundance_alpha abundance_theta density_alpha density_theta

end

