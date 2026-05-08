clear all;
close all;

addpath(genpath('/user/HS301/m17462/matlab/eeglab'));
addpath(genpath('/user/HS301/m17462/matlab/Scripts/RSN'));

addpath /mnt/beegfs/users/psychology01/useful_functions

Folderpath = '/vol/research/nemo/datasets/RSN/data/hdEEG/';
sub_Folderpath = dir([Folderpath,'RSN*']);

%%

for s = 5 %1:length(sub_Folderpath)
    
    display(sub_Folderpath(s).name);
    Savefolder = [Folderpath,sub_Folderpath(s).name];
   
    %% sleep
    mICA_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_sleep*_fil_czref_mICA_avref.set']);
    EEG = pop_loadset('filename',[mICA_file(1).name],'filepath',[Folderpath,sub_Folderpath(s).name]);

    epochl = 1; % [s], epoch length
    fs = EEG.srate;
    nepochs = floor(size(EEG.data,2)/(fs*epochl));
    windowl = 1; % [s], window length (segmentation window, Tukey)
    overlap = 0.5; % [samples], overlap of adjacent windows
    f = [0:.1:40];%was [2:.25:30]

%     fs = EEG.srate;
%     epochl = 30; % [s], epoch length
%     windowl = 10; % [s], window length (segmentation window, Tukey)
%     overlap = 1; % [s], overlap of adjacent windows
%     ratio = 0.5; % ratio taper to constant sector of window
%     nepochs = floor(size(EEG.data,2)/(fs*epochl));
         
    for ch = 1:size(EEG.data,1)
        display(['ch',num2str(ch)]);

        for epo = 1:nepochs

            startEp = (epo-1)*epochl*fs+1;
            endEp = epo*epochl*fs;
              [pow,ff] = pwelch(EEG.data(ch,startEp:endEp),windowl*fs,overlap,f,fs); 
              %FFT pwelch(data,window,overlap,nFFT,sampling freq) 
%             [pow,ff] = pwelch(EEG.data(ch,startEp:endEp),tukeywin(windowl*fs,ratio),...
%                            fs*overlap,windowl*fs,fs);    
            ffttot(ch,:,epo) = pow;


        end
            
    end
    
    save([Savefolder,filesep,mICA_file(1).name(1:end-4),'_ffttot.mat'],'ffttot','ff','epochl','nepochs','windowl','overlap','fs','-v7.3');

    clear ffttot 
end