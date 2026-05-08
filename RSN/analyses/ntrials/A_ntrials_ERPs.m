clear all;
close all;

Folderpath = 'S:\datasets\RSN\data\hdEEG\';
sub_Folderpath = dir([Folderpath,'RSN*']);

nbins = 3;
fs = 500;

Savefolder = 'S:\datasets\RSN\data\analysis\ntrials\';


%% Load erp data

for s = 1:length(sub_Folderpath)
    
    display(sub_Folderpath(s).name);

    erp_good_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_erp_good.mat']);
    load([Folderpath,sub_Folderpath(s).name,filesep,erp_good_file(1).name],'ERP');

 %% ERPs
 
    for con = 1:size(ERP.trigs_con,2)
 
        ERP_trigs = ERP.trigs;
        ERP_trigs_good = ERP_trigs(ERP.trigs_state_good_all{con});
            
        ERPs_ntrials_all(s,con) = length(ERP.trigs_state_good_all{con});
        ERPs_ntrials_tonic(s,con) = length(ERP.trigs_state_good{1,con});
        ERPs_ntrials_phasic(s,con) = length(ERP.trigs_state_good{2,con});
        

      for b = 1:nbins
          bin_duration = 10/nbins;
          bin_samps = (b-1)*bin_duration*60*60*fs+1:b*bin_duration*60*60*fs;
          ERPs_ntrials_bins(s,con,b) = length(intersect(ERP_trigs_good,bin_samps));
          ERPs_perc_trials_bins(s,con,b) = ERPs_ntrials_bins(s,con,b)/length(ERP_trigs_good)*100;
      end

    clear ERP_trigs_good 
    
    end
    
end  

save([Savefolder,'ERP_ntrials_allsub.mat'],'ERPs*')