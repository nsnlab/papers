clear all;
close all;

Folderpath = 'S:\datasets\RSN\data\hdEEG\';
sub_Folderpath = dir([Folderpath,'RSN*']);

nbins = 3;
fs = 500;

Savefolder = 'S:\datasets\RSN\data\analysis\ntrials\';

%% Load nm data

for s = 1:length(sub_Folderpath)
    
    display(sub_Folderpath(s).name);

    nm_good_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_nm_good_psd_allch.mat']);
    load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name],'nm');

      %% Neuromodulation
    
    for con = 1:size(nm.ON_start_good,2)
        
        ON_start = nm.ON_start_good{con};
        ON_start_good = ON_start(nm.good_trialndx{con});
        
        nm_ntrials_all(s,con) = nm.ntrials_good{con};
        nm_ntrials_phasic(s,con) = nm.ntrials_phasic{con};
        nm_ntrials_tonic(s,con) = nm.ntrials_tonic{con};
        

        for b = 1:nbins
            bin_duration = 10/nbins;
            bin_samps = (b-1)*bin_duration*60*60*fs+1:b*bin_duration*60*60*fs;
            nm_ntrials_bins(s,con,b) = length(intersect(ON_start_good,bin_samps));
            nm_perc_trials_bins(s,con,b) = nm_ntrials_bins(s,con,b)/length(ON_start_good)*100;
            
        end
       
   
    end
    
    clear ON_start*
        
end  

save([Savefolder,'nm_ntrials_allsub.mat'],'nm_ntrials_all','nm_ntrials_phasic','nm_ntrials_tonic','nm_ntrials_bins','nm_perc_trials_bins')
