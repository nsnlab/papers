clear all;
close all;

addpath(genpath('/user/HS301/m17462/matlab/eeglab'));
addpath(genpath('/user/HS301/m17462/matlab/Scripts/RSN'));
addpath(genpath('/user/HS301/m17462/matlab/Henry/'));

Folderpath = '/vol/research/nemo/datasets/RSN/data/hdEEG/';
sub_Folderpath = dir([Folderpath,'RSN*']);

Savefolder = '/vol/research/nemo/datasets/RSN/data/analysis/ISI_allsub/';

%% Load nm data

fs = 500;

for s = 1:length(sub_Folderpath)
    
    display(sub_Folderpath(s).name);

    nm_good_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_nm_good_psd_allch.mat']);
    load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name]);

%     figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
%     suptitle(sub_Folderpath(s).name(1:7));
    
    for con = 1:length(nm.psd_ON)
        
        trigs_good_con = nm.ON_trigs_StimTrak_good{con}; % psd: bins x ep x trials x ch
        diff_trigs = diff(trigs_good_con);
        diff_trigs_exclndx = find(diff_trigs > 2.5 * fs | diff_trigs < 0.05*fs); % find differences longer than OFF period (6 s) or shorter than 50 ms (faster than 20 Hz)
        diff_trigs(diff_trigs_exclndx) = [];
        ISI = diff_trigs/fs;
%         freq_ISI = 1./ISI;
        
%         subplot(2,4,con)
%         histogram(freq_ISI);
%         ylabel('Counts');
%         xlabel('Freq ISI (Hz)');
%         title(nm.condition(con));
% %         xlim([0 20])
        
       ISI_allsub(s).con{con} = ISI;
       
       psd_echt = nm.psd_echt{con};
       art_trialndx = nm.art_trialndx{con};
       good_trialndx = find(art_trialndx == 0);

       echt_psd_allsub(s,:,:,:).con{con} = psd_echt(:,:,good_trialndx); 
        
      clear stimphase_good_con freq_ISI ISI
                
    end
    
%     print([Savefolder,sub_Folderpath(s).name(1:7),'_ISI'],'-dpng');
%     close
    
    
end

%%

save([Savefolder,'ISI_echt_psd_allsub_',date,'.mat'],'ISI_allsub','echt_psd_allsub');


