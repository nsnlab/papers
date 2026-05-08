% clear all;
% close all;

function A_Phase_sub_allch(s)

try

addpath(genpath('/users/nemo/software/eeglab')); % eeglab toolbox, see README on where to find this
addpath(genpath('/users/nemo/software/Henry/useful_functions')); % contains linspecer function, circular statistics toolbox functions, echt function, shadedErrorBar function, see README on where to find this

%% Load data

Folderpath = '/parallel_scratch/nemo/RSN/hdEEG/';
sub_Folderpath = dir([Folderpath,'RSN*']);

% for s = 1 %:length(sub_Folderpath)
    
mICA_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*sleep*_mICA_avref.set']);
nm_good_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*sleep*_nm_good.mat']);
goodREM_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_czref_goodREM.mat']);

Savefolder = [Folderpath,sub_Folderpath(s).name];

EEG = pop_loadset('filename',[mICA_file(1).name],'filepath',[Folderpath,sub_Folderpath(s).name]);
load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name]);
load([Folderpath,sub_Folderpath(s).name,filesep,goodREM_file(1).name]);

data = double(EEG.data);

clear EEG.data

%% Alpha - Phase analysis

filt_lf = 7.5;
filt_hf = 12.5;
fs = 500;

% Compute filter's frequency response
filt_order = 2;
[b_alphafilt,a_alphafilt] = butter(filt_order, [filt_lf filt_hf]/(fs/2), 'bandpass');
fvtool(b_alphafilt,a_alphafilt);

for ch = 1:size(data,1)
    data_alpha_fil(ch,:) = filtfilt(b_alphafilt,a_alphafilt,data(ch,:));
end

colors = linspecer(4);


for con = 1:8
    
    for ch = 1:size(data,1)
        
        % based on echt
        for trig = 1:length(nm.ON_trigs_StimTrak_good{con})
       
            hilb_fz = echt(data(ch,nm.ON_trigs_StimTrak_good{con}(trig)-fs:nm.ON_trigs_StimTrak_good{con}(trig)), filt_lf, filt_hf, fs);    
            stim_phase_good(ch,trig) = angle(hilb_fz(end)); 
       
            clear hilb_fz
        end  

        if length(nm.ON_trigs_StimTrak_good{con})==0
           stim_phase_good = [];
        end
        
        % based on acausal filter
%         hilb_fz_notecht  = hilbert(data_alpha_fil(ch,:));  % extract phase in rad from whole signal with Hilbert
%         stim_phase_good_notecht(ch,:) = angle(hilb_fz_notecht(nm.ON_trigs_StimTrak_good{con}));
%         
%         if length(nm.ON_trigs_StimTrak_good{con})==0
%            stim_phase_good_notecht = [];
%         end
%         
%         clear hilb_fz_notecht
    end
    
    nm.stimphase_good_alphafilt{con} = stim_phase_good;
%     nm.stimphase_good_alphafilt_notecht{con} = stim_phase_good_notecht;
  
    clear stim_phase_echt stim_phase_good
%     clear stim_phase_good_notecht

end


%% Alpha - Make polar plot 

% Make polar plot based on echt data
figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])

ch = 2;

for con = 1:4

    stim_phase_good = nm.stimphase_good{con};
%     stim_phase_good = nm.stimphase_good_alphafilt_notecht{con};
    
    if ~isempty(stim_phase_good)
    
    polarhistogram(stim_phase_good(ch,:),100,'FaceColor',colors(con,:),'LineWidth',.75)  % Polar Histogram   
    hold on
%     title({['RSN ',mICA_file(1).name(5:7)] ['Alpha (Fz data)']});
    
    end

    clear stim_phase_good
    
end

if ~exist([Savefolder,filesep,'QC_Plots'])
    mkdir([Savefolder,filesep,'QC_Plots']);   
end
% print([Savefolder,filesep,'QC_Plots/Alpha_phase_plot_fz_good'],'-dpng');

set(gca,'Fontsize',35);

saveas(gcf,[Savefolder,filesep,'QC_Plots/Alpha_phase_plot_fz_good.svg']);
% saveas(gcf,[Savefolder,filesep,'QC_Plots/Alpha_phase_plot_fz_good_notecht.svg']);

%% Theta - Phase analysis

filt_lf = 4.5;
filt_hf = 7.5;

% Compute filter's frequency response
filt_order = 2;
[b_thetafilt,a_thetafilt] = butter(filt_order, [filt_lf filt_hf]/(fs/2), 'bandpass');
fvtool(b_thetafilt,a_thetafilt);

for ch = 1:size(data,1)
    data_theta_fil(ch,:) = filtfilt(b_thetafilt,a_thetafilt,data(ch,:));
end

colors = linspecer(4);

for con = 1:8
    
    for ch = 1:size(data,1)

        % based on echt
        for trig = 1:length(nm.ON_trigs_StimTrak_good{con})
       
            hilb_fz = echt(data(ch,nm.ON_trigs_StimTrak_good{con}(trig)-fs:nm.ON_trigs_StimTrak_good{con}(trig)), filt_lf, filt_hf, fs);    
            stim_phase_good(ch,trig) = angle(hilb_fz(end)); 
       
            clear hilb_fz
        end  
    
        if length(nm.ON_trigs_StimTrak_good{con})==0
        stim_phase_good = [];
        end

        % based on acausal filter
%         hilb_fz_notecht  = hilbert(data_theta_fil(ch,:));  % extract phase in rad from whole signal with Hilbert
%         stim_phase_good_notecht(ch,:) = angle(hilb_fz_notecht(nm.ON_trigs_StimTrak_good{con}));
%         
%         if length(nm.ON_trigs_StimTrak_good{con})==0
%            stim_phase_good_notecht = [];
%         end
%         
%         clear hilb_fz_notecht

    end
    
    nm.stimphase_good_thetafilt{con} = stim_phase_good;
%     nm.stimphase_good_thetafilt_notecht{con} = stim_phase_good_notecht;
  
    clear stim_phase_echt stim_phase_good
%     clear stim_phase_good_notecht

end


%% Theta - Make polar plot 

% Make polar plot based on hdEEG Fz data
figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])

ch = 2;

for con = 5:8

    stim_phase_good = nm.stimphase_good{con};
%     stim_phase_good = nm.stimphase_good_thetafilt_notecht{con};
    
    if ~isempty(stim_phase_good)
    
    polarhistogram(stim_phase_good(ch,:),100,'FaceColor',colors(con-4,:),'LineWidth',.75)  % Polar Histogram   
    hold on
%     title({['RSN ',mICA_file(1).name(5:7)] ['Theta (Fz data)']});
    
    end

    clear stim_phase_good
    
end

if ~exist([Savefolder,filesep,'QC_Plots'])
    mkdir([Savefolder,filesep,'QC_Plots']);   
end
% print([Savefolder,filesep,'QC_Plots/Theta_phase_plot_fz_good'],'-dpng');

set(gca,'Fontsize',35);

saveas(gcf,[Savefolder,filesep,'QC_Plots/Theta_phase_plot_fz_good.svg']);
% saveas(gcf,[Savefolder,filesep,'QC_Plots/Theta_phase_plot_fz_good_notecht.svg']);


%%

save([Savefolder,filesep,mICA_file(1).name(1:end-4),'_nm_good_phase_allch.mat'],'nm','-append','-v7.3');

clear nm

% end


       
display('the end');

catch exception
    display(exception.message)
    display(exception.identifier)
    error()
end
    
    
end




