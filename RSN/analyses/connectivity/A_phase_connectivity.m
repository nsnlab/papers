clear all;
close all;

addpath(genpath('/users/psychology01/software/fieldtrip'))
addpath(genpath('/users/psychology01/software/eeglab'))
addpath(genpath('/mnt/beegfs/users/psychology01/useful_functions'))

%% Folderpath

Folderpath = '/users/m17462/psychology01/parallel_scratch/projects/RSN/'; % wihtout / at the end
sub_Folderpath = dir([Folderpath,'RSN*']);

%% Cluster

cluster = parcluster('eureka'); % to add cluster go to home - parallel - create and manage clusters -import -go to config folder in software folder in psychology01 -open eureka .mlsettings file
% cluster.SubmitArguments = compose("--partition=high_mem --mem=%dG
% --time=%d", 16, 24*60); % for high memory job (max. memory that can be
% allocated in normal job is 8 or 12 GB, max. time is 7 days)
cluster.SubmitArguments = compose("--mem=%dG --time=%d", 64, 72*60); % for normal job, mem: memory in GB, time: time in min that is allocated to this job
cluster.NumWorkers = 1;
% cluster.NumThreads = 4;
cluster.JobStorageLocation = '/users/psychology01/Valeria/jobfiles'; % wdir: directory where job file is put

for sub = 1:length(sub_Folderpath)
    
    batch(cluster,@phase_connectivity,0,{Folderpath,sub_Folderpath,sub},'AutoAttachFiles', false, ...
    'AutoAddClientPath', true, ...
    'CaptureDiary', true);

end

%%

function phase_connectivity(Folderpath,sub_Folderpath,sub)

try


display(sub_Folderpath(sub).name);
    
mICA_file = dir([Folderpath,sub_Folderpath(sub).name,filesep,'*sleep*_mICA_avref.set']);
nm_good_file = dir([Folderpath,sub_Folderpath(sub).name,filesep,'*sleep*_nm_good.mat']);
goodREM_file = dir([Folderpath,sub_Folderpath(sub).name,filesep,'*_czref_goodREM.mat']);

Savefolder = [Folderpath,sub_Folderpath(sub).name];

EEG = pop_loadset('filename',[mICA_file(1).name],'filepath',[Folderpath,sub_Folderpath(sub).name]);
load([Folderpath,sub_Folderpath(sub).name,filesep,nm_good_file(1).name]);
load([Folderpath,sub_Folderpath(sub).name,filesep,goodREM_file(1).name]);

data = double(EEG.data);
clear EEG.data

%% phase analysis

dt = 6;
on_block = 7:12;
off_block = 1:6;

window = 1;
epochlength = 1;

bandf = [1 4;4 7;7 12;12 30];

for b = 1:4
    
    display(['band ',num2str(b)])

    [ba,a] = butter(2, [bandf(b,1) bandf(b,2)]/(500/2)); 
        
    for con = 1:8
        
        display(['condition ',num2str(con)])
 
        ON_start_all = nm.ON_start_good{con};
        
        if length(ON_start_all) > 0       

        
            for ch = 1:size(data,1)
                
                display(['channel ',num2str(ch)])
                
                               
                    for t = 1:length(ON_start_all)

                        trial_eeg = data(ch,ON_start_all(t)-dt*fs:ON_start_all(t)+dt*fs-1);                             
           
                        for ep = 1:length(trial_eeg)/fs
                    
                            trial_eeg_ep = trial_eeg(epochlength*(ep-1)*fs+1:epochlength*ep*fs);
                            trial_eeg_ep_hilb(:,ep,t) = angle(hilbert(filtfilt(ba,a,trial_eeg_ep)));           

                        end
                                         
                    end
                
                phase.band{b}.cond{con}.chan{ch} = trial_eeg_ep_hilb;
            
            end
            
        else
            
            for ch = 1:size(data,1)
            
             phase.band{b}.cond{con}.chan{ch} = NaN;
             
            end
                    
        end 
            
        
        clear trial_eeg_ep_hilb
                
     end    
       

end

save([Savefolder,filesep,mICA_file(1).name(1:end-4),'_phase_connectivity.mat'],'phase','-v7.3')

display('phase saved');
        
display('the end');

catch exception
    display(exception.message)
    display(exception.identifier)
    error()
end

end

