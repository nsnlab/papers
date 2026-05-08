clear all;
close all;

Folderpath = '/vol/research/nemo/datasets/RSN/data/hdEEG/';
sub_Folderpath = dir([Folderpath,'RSN*']);

Savefolder = '/vol/research/nemo/datasets/RSN/data/analysis/power_allsub/';

%%

for s = 1:length(sub_Folderpath)
    
    display(sub_Folderpath(s).name)

%% sleep

sleep_ffttot_dir = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_sleep*_fil_czref_mICA_avref_ffttot.mat']);

% nm_good_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_sleep_nm_good.mat']);
goodREM_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_sleep*_fil_czref_goodREM.mat']);

load([Folderpath,sub_Folderpath(s).name,filesep,sleep_ffttot_dir(1).name]);
load([Folderpath,sub_Folderpath(s).name,filesep,goodREM_file(1).name]);

% rem_ndx = find(hypno4 == 'R');
% rem_goodndx = intersect(rem_ndx,good_ndx);

good_rem_epo = zeros(size(ffttot,3),1);

for epo = 1:size(ffttot,3)
    
    ep_samp = ((epo-1)*fs*windowl+1):(epo*fs*windowl);
    
    if length(intersect(ep_samp,rem_goodsamp2)) == windowl*fs
       good_rem_epo(epo) = 1;
    end
    
end

rem_goodndx2  = find(good_rem_epo == 1);

phasic_ndx = find(phasic_ep == 1); % phasic epoch (epoch that has at least 1 phasic segment)
tonic_phasic_ndx = find(tonic_ep == 1);   % epoch that has at least 1 tonic segment 
tonic_ndx = setdiff(tonic_phasic_ndx,phasic_ndx); % tonic epoch (epoch that has at least 1 tonic and no phasic segment)

phasic_goodndx2 = intersect(phasic_ndx,rem_goodndx2);
tonic_goodndx2 = intersect(tonic_ndx,rem_goodndx2);

ffttot_sleep = ffttot;
clear ffttot;

% f_ndx = find(ff > 7 & ff < 11);
% ffttot_freq_ch = squeeze(nanmean(ffttot_sleep(2,f_ndx,:),2));
% rem_ends = find(diff(rem_goodndx2)>30*4);
% figure
% plot(ffttot_freq_ch(1:rem_ends(1)));
% for rem_ep = 1:(length(rem_ends)-1)
% figure
% plot(ffttot_freq_ch(rem_ends(rem_ep)+1:rem_ends(rem_ep+1)));
% end

mfft_rem(s,:,:) = nanmean(ffttot_sleep(:,:,rem_goodndx2),3);
mfft_phasic(s,:,:) = nanmean(ffttot_sleep(:,:,phasic_goodndx2),3);
mfft_tonic(s,:,:) = nanmean(ffttot_sleep(:,:,tonic_goodndx2),3);

nrem_ndx = find(hypno4 == '2'|hypno4 == '3');
mfft_nrem(s,:,:) = nanmean(ffttot_sleep(:,:,nrem_ndx),3);

%% wake evening

wake_e_ffttot_dir = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_wake_e_fil_czref_mICA_avref_ffttot.mat']);

nm_good_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_wake_e_nm_good.mat']);
goodwake_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_wake_e_fil_czref_goodwake.mat']);

load([Folderpath,sub_Folderpath(s).name,filesep,wake_e_ffttot_dir(1).name]);
load([Folderpath,sub_Folderpath(s).name,filesep,goodwake_file(1).name]);
load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name]);

good_wake_e_epo = zeros(size(ffttot,3),1);

for epo = 1:size(ffttot,3)
    
    ep_samp = ((epo-1)*fs*windowl+1):(epo*fs*windowl);
    
    if length(intersect(ep_samp,wake_goodsamp2)) == windowl*fs
       good_wake_e_epo(epo) = 1;
    end
    
end

wake_e_goodndx2  = find(good_wake_e_epo == 1);

eye_closure_ep = ceil(nm.startsamp_ERP{2}(1)/fs);
EO_ndx = 1:eye_closure_ep-1;
EC_ndx = eye_closure_ep:length(good_wake_e_epo);
EO_e_goodndx2 = intersect(EO_ndx,wake_e_goodndx2);
EC_e_goodndx2 = intersect(EC_ndx,wake_e_goodndx2);

ffttot_wake_e = ffttot;
clear ffttot nm EO_ndx EC_ndx EO_m_goodndx2 EC_m_goodndx2

mfft_wake_e(s,:,:) = nanmean(ffttot_wake_e(:,:,wake_e_goodndx2),3);
mfft_wake_EO_e(s,:,:) = nanmean(ffttot_wake_e(:,:,EO_e_goodndx2),3);
mfft_wake_EC_e(s,:,:) = nanmean(ffttot_wake_e(:,:,EC_e_goodndx2),3);

%% wake morning

wake_m_ffttot_dir = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_wake_m_fil_czref_mICA_avref_ffttot.mat']);

nm_good_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_wake_m_nm_good.mat']);
goodwake_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_wake_m_fil_czref_goodwake.mat']);

load([Folderpath,sub_Folderpath(s).name,filesep,wake_m_ffttot_dir(1).name]);
load([Folderpath,sub_Folderpath(s).name,filesep,goodwake_file(1).name]);
load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name]);

good_wake_m_epo = zeros(size(ffttot,3),1);

for epo = 1:size(ffttot,3)
    
    ep_samp = ((epo-1)*fs*windowl+1):(epo*fs*windowl);
    
    if length(intersect(ep_samp,wake_goodsamp2)) == windowl*fs
       good_wake_m_epo(epo) = 1;
    end
    
end

wake_m_goodndx2  = find(good_wake_m_epo == 1);

eye_closure_ep = ceil(nm.startsamp_ERP{2}(1)/fs);
EO_ndx = 1:eye_closure_ep-1;
EC_ndx = eye_closure_ep:length(good_wake_m_epo);
EO_m_goodndx2 = intersect(EO_ndx,wake_m_goodndx2);
EC_m_goodndx2 = intersect(EC_ndx,wake_m_goodndx2);

ffttot_wake_m = ffttot;
clear ffttot nm EO_ndx EC_ndx

mfft_wake_m(s,:,:) = nanmean(ffttot_wake_m(:,:,wake_m_goodndx2),3);
mfft_wake_EO_m(s,:,:) = nanmean(ffttot_wake_m(:,:,EO_m_goodndx2),3);
mfft_wake_EC_m(s,:,:) = nanmean(ffttot_wake_m(:,:,EC_m_goodndx2),3);


clear ffttot_sleep ffttot_wake_e ffttot_wake_m rem_goodndx2 phasic_goodndx2 tonic_goodndx2 nrem_ndx wake_e_goodndx2 wake_m_goodndx2 EO_m_goodndx2 EC_m_goodndx2

end

save([Savefolder,'power_allsub_mICA_avref_',date,'.mat'],'mfft_rem','mfft_phasic','mfft_tonic','mfft_nrem','mfft_wake_e','mfft_wake_EO_e','mfft_wake_EC_e','mfft_wake_m','mfft_wake_EO_m','mfft_wake_EC_m');

