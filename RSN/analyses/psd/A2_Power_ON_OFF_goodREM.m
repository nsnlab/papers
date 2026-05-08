clear all;
close all;

addpath(genpath('/users/nemo/software/eeglab'));
addpath(genpath('/users/nemo/projects/RSN'));

%% Load data

Folderpath = '/parallel_scratch/nemo/RSN/hdEEG/';
sub_Folderpath = dir([Folderpath,'RSN*']);

for s = 1:length(sub_Folderpath)
    
mICA_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*sleep*_mICA_avref.set']);
% nm_good_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*sleep*_nm_good.mat']);
nm_good_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*sleep*_nm_good_psd_allch.mat']);
goodREM_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_czref_goodREM.mat']);

Savefolder = [Folderpath,sub_Folderpath(s).name];

EEG = pop_loadset('filename',[mICA_file(1).name],'filepath',[Folderpath,sub_Folderpath(s).name]);
load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name]);
load([Folderpath,sub_Folderpath(s).name,filesep,goodREM_file(1).name]);

data = double(EEG.data);
clear EEG.data

%% Power analysis using hdEEG data

dt = 6;
on_block = 7:12;
off_block = 1:6;

% f = [2:.1:30];%was [2:.25:30]
f = [0:.1:40];%was [2:.25:30]
nm.f = f;
window = 1; 
epochlength = 1;
noverlap = .5;

for con = 1:8
    
    ON_start_all = nm.ON_start_good{con};
    
     % calculate artefact trial ndx
%      for t = 1:length(ON_start_all)
%          
%          trial_samps = ON_start_all(t)-dt*fs:ON_start_all(t)+2*dt*fs-1;

%           if length(intersect(trial_samps,rem_goodsamp2)) == 2*dt*fs
%                 art_trialndx(t) = 0;
%           else
%                 art_trialndx(t) = 1;
%           end
%           
%           good_trialndx = find(art_trialndx == 0);
     
%      end

    if length(ON_start_all) > 0
    
    for ch = 1:size(data,1)

        for t = 1:length(ON_start_all)
        
            trial_eeg = data(ch,ON_start_all(t)-dt*fs:ON_start_all(t)+2*dt*fs-1);
        
            for ep = 1:length(trial_eeg)/fs
       
                trial_eeg_ep = trial_eeg(epochlength*(ep-1)*fs+1:epochlength*ep*fs);
                psd_allch(:,ep,t,ch) = pwelch(trial_eeg_ep,window*fs,noverlap,f,fs); 

            end
            
            clear trial_samps trial_eeg
        end
                
    end
    
    nm.psd{con} = psd_allch;
    
%     nm.art_trialndx{con} = art_trialndx;
%     nm.ntrials_good{con} = length(good_trialndx);
    good_trialndx = nm.good_trialndx{con};
    mtrials_psd = squeeze(nanmean(psd_allch(:,:,good_trialndx,:),3)); % average psd across all trials of all runs

    ch = 2;
    psd_ON_good_fz = nanmean(mtrials_psd(:,on_block,ch),2); % average psd across on sec
    psd_OFF_good_fz = nanmean(mtrials_psd(:,off_block,ch),2); % average psd across off sec
    psd_ONOFF_change_fz = (psd_ON_good_fz - psd_OFF_good_fz)./psd_OFF_good_fz *100; 
    
    nm.mtrials_psd{con} = mtrials_psd;
    nm.psd_ON_good_fz{con} = psd_ON_good_fz;
    nm.psd_OFF_good_fz{con} = psd_OFF_good_fz;
    nm.psd_ONOFF_change_fz{con} = psd_ONOFF_change_fz;
    
    else
        
    psd_allch = NaN(length(f),18,1,size(data,1));
%     art_trialndx = NaN;
%     good_trialndx = [];
    
    nm.psd{con} = psd_allch;
    
%     nm.art_trialndx{con} = art_trialndx;
%     nm.ntrials_good{con} = length(good_trialndx);
    mtrials_psd = NaN(length(f),18,size(data,1)); % average psd across all trials of all runs

    ch = 2;
    psd_ON_good_fz = nanmean(mtrials_psd(:,on_block,ch),2); % average psd across on sec
    psd_OFF_good_fz = nanmean(mtrials_psd(:,off_block,ch),2); % average psd across off sec
    psd_ONOFF_change_fz = (psd_ON_good_fz - psd_OFF_good_fz)./psd_OFF_good_fz *100; 
    
    nm.mtrials_psd{con} = mtrials_psd;
    nm.psd_ON_good_fz{con} = psd_ON_good_fz;
    nm.psd_OFF_good_fz{con} = psd_OFF_good_fz;
    nm.psd_ONOFF_change_fz{con} = psd_ONOFF_change_fz;
    
    end
     
    clear art_trialndx good_trialndx mtrials_psd psd_ON_good_fz psd_OFF_good_fz psd_ONOFF_change_fz
    clear psd_allch

end

%% Alpha - Plot power spectrum and change

% colors = linspecer(4);
% 
% % Plot power spectrum for on and off windows
% for con = 1:4
%     
%     psd_ON = nm.psd_ON_good_fz{con};
%     psd_OFF = nm.psd_OFF_good_fz{con};
%         
%     figure
%     plot(f,psd_ON,'Color','r','LineWidth',2);
%     hold on
%     plot(f,psd_OFF,'Color','b','LineWidth',2);
%     hold on
%     xlabel('Frequency (Hz)');
%     ylabel('Power spectral density (uV^2/s)');
%     legend({'ON' 'OFF'})
%     title({['RSN ',mICA_file(1).name(5:7)] ['Alpha ', nm.condition{con}(7:end),' (fz data)']});
% %     ylim([-60 120]);
% 
% %     if ~exist([Savefolder,filesep,'QC_Plots'])
% %         mkdir([Savefolder,filesep,'QC_Plots']);   
% %     end
% %     print([Savefolder,filesep,'QC_Plots/',nm.condition{con},'_powerspectrum_fz_good'],'-dpng');
%     close all
%     
%     clear psd_ON psd_OFF
%    
% end


% Plot power spectrum change
% figure
% 
% for con = 1:4
%     
%     psd_ONOFF_change = nm.psd_ONOFF_change_fz{con};
%         
%     plot(f,psd_ONOFF_change,'Color',colors(con,:),'LineWidth',2);
%     hold on
%     xlabel('Frequency (Hz)');
%     ylabel('ON/OFF change (%)');
%     title({['RSN ',mICA_file(1).name(5:7)] ['Alpha (fz data)']});
%     ylim([-60 120]);
%    
%     clear psd_ONOFF_change
%     
% end
% 
% legend(nm.condition{1:4});
% 
% % if ~exist([Savefolder,filesep,'QC_Plots'])
% %    mkdir([Savefolder,filesep,'QC_Plots']);   
% % end
% % print([Savefolder,filesep,'QC_Plots/','Alpha_powerspectrum_change_fz_good'],'-dpng');

%% Theta - Plot power spectrum and change

% Plot power spectrum for on and off windows
% for con = 5:8
%     
%     psd_ON = nm.psd_ON_good_fz{con};
%     psd_OFF = nm.psd_OFF_good_fz{con};
%         
%     figure
%     plot(f,psd_ON,'Color','r','LineWidth',2);
%     hold on
%     plot(f,psd_OFF,'Color','b','LineWidth',2);
%     hold on
%     xlabel('Frequency (Hz)');
%     ylabel('Power spectral density (uV^2/s)');
%     legend({'ON' 'OFF'})
%     title({['RSN ',mICA_file(1).name(5:7)] ['Theta ', nm.condition{con}(7:end),' (fz data)']});
% %     ylim([-60 120]);
% 
% %     if ~exist([Savefolder,filesep,'QC_Plots'])
% %         mkdir([Savefolder,filesep,'QC_Plots']);   
% %     end
% %     print([Savefolder,filesep,'QC_Plots/',nm.condition{con},'_powerspectrum_fz_good'],'-dpng');
%     close all
%     
%     clear psd_ON psd_OFF
%    
% end


% Plot power spectrum change
% figure
% 
% for con = 5:8
%     
%     psd_ONOFF_change = nm.psd_ONOFF_change_fz{con};
%         
%     plot(f,psd_ONOFF_change,'Color',colors(con-4,:),'LineWidth',2);
%     hold on
%     xlabel('Frequency (Hz)');
%     ylabel('ON/OFF change (%)');
%     title({['RSN ',mICA_file(1).name(5:7)] ['Theta (fz data)']});
%     ylim([-60 120]);
%     
%     clear psd_ONOFF_change
%    
% end
% 
% legend(nm.condition{5:8});
% 
% % if ~exist([Savefolder,filesep,'QC_Plots'])
% %    mkdir([Savefolder,filesep,'QC_Plots']);   
% % end
% % print([Savefolder,filesep,'QC_Plots/','Theta_powerspectrum_change_fz_good'],'-dpng');

%%

save([Savefolder,filesep,mICA_file(1).name(1:end-4),'_nm_good_psd_allch_OFFONOFF.mat'],'nm','-v7.3');

clear nm

end





