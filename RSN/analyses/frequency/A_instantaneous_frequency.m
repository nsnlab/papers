clear all;
close all;

addpath(genpath('/users/psychology01/software/fieldtrip'));
addpath(genpath('/users/psychology01/software/eeglab'));
addpath(genpath('/mnt/beegfs/users/psychology01/useful_functions'));

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

for s = 1:length(sub_Folderpath)
    
    batch(cluster,@instantaneous_frequency,0,{Folderpath,sub_Folderpath,s},'AutoAttachFiles', false, ...
    'AutoAddClientPath', true, ...
    'CaptureDiary', true);

end

%%

function instantaneous_frequency(Folderpath,sub_Folderpath,s)

 display(sub_Folderpath(s).name);
    
    Savefolder = [Folderpath,sub_Folderpath(s).name];
    
    % Filter parameters
    fs = 500;
    lower_freq_alpha = 7;
    higher_freq_alpha = 12;
    lower_freq_theta = 4;
    higher_freq_theta = 7;
    
    n_order = 10;
    orders = linspace(10,400,n_order)/2;
    orders = round( orders/(1000/fs) );
    trans_width    = .15;
    idealresponse  = [ 0 0 1 1 0 0 ];

   %% rem - all
   
    mICA_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_sleep*_fil_czref_mICA_avref.set']);
    EEG = pop_loadset('filename',[mICA_file(1).name],'filepath',[Folderpath,sub_Folderpath(s).name]);
    
    goodREM_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_sleep*_fil_czref_goodREM.mat']);
    load([Folderpath,sub_Folderpath(s).name,filesep,goodREM_file(1).name]);
    
    nm_good_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_sleep*_nm_good.mat']);
    load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name]); 
    
    
    rem_data = EEG.data(:,rem_goodsamp2);
    
    %use Cohen's median filter method
    % https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6608248/

    filtfreqbounds_alpha = [ 0 (1-trans_width)*lower_freq_alpha lower_freq_alpha higher_freq_alpha higher_freq_alpha*(1+trans_width) fs/2 ]/(fs/2);
    filt_order_alpha     = round(3*(fs/lower_freq_alpha));
    filterweights_alpha  = firls(filt_order_alpha,filtfreqbounds_alpha,idealresponse);
    
    filtfreqbounds_theta = [ 0 (1-trans_width)*lower_freq_theta lower_freq_theta higher_freq_theta higher_freq_theta*(1+trans_width) fs/2 ]/(fs/2);
    filt_order_theta     = round(3*(fs/lower_freq_theta));
    filterweights_theta  = firls(filt_order_theta,filtfreqbounds_theta,idealresponse);
    
%     for cond = 1:8
    
    % this part does the actual filtering
%     filterdata = zeros(size(EEG.data,2));
    for chan = 1:128
        filterdata_alpha(chan,:) = filtfilt(filterweights_alpha,1,rem_data(chan,:));
        filterdata_theta(chan,:) = filtfilt(filterweights_theta,1,rem_data(chan,:));
    end
  
    temphilbert_alpha = hilbert(filterdata_alpha')';
    freqslide_prefilt_alpha = diff(fs*unwrap(angle(temphilbert_alpha'),[],1)',1,2)/(2*pi);
    
    temphilbert_theta = hilbert(filterdata_theta')';
    freqslide_prefilt_theta = diff(fs*unwrap(angle(temphilbert_theta'),[],1)',1,2)/(2*pi);
    
%     figure
%     a = angle(temphilbert');
%     a2 = unwrap(angle(temphilbert'),[],1)';
%     a3 = diff(fs*unwrap(angle(temphilbert'),[],1)',1,2)/(2*pi);
%     plot(a(1:1000,1));
%     hold on
%     plot(a2(1,1:1000));
%     hold on
%     plot(a3(1,1:1000));
        
    clear tmp_alpha tmp_theta
    tmp_alpha = movmedian(freqslide_prefilt_alpha,orders(2),2);
    tmp_theta = movmedian(freqslide_prefilt_theta,orders(2),2);
    
    for window = orders(3:end-1)
        tmp_alpha = cat(3,tmp_alpha,movmedian(freqslide_prefilt_alpha,window,2));
        tmp_theta = cat(3,tmp_theta,movmedian(freqslide_prefilt_theta,window,2));
    end

    for ch = 1:128
        ifq_alpha(ch,:) = nanmean(tmp_alpha(ch,:,:),3);
        ifq_theta(ch,:) = nanmean(tmp_theta(ch,:,:),3);
    end
    
%     ifq2 = nanmean(tmp,3);
    
%     hold on
%     plot(ifq(1,1:1000));
    
%     ifq_alpha(:,end) = NaN(128,1);
%     ifq_theta(:,end) = NaN(128,1);
% %     end
% 
%     for ch = 1:128  
%         ifq_alpha_range_ndx = find(ifq_alpha(ch,:) >= lower_freq_alpha & ifq_alpha(ch,:) <= higher_freq_alpha);
%         ifq_alpha_range_ndx_good = intersect(ifq_alpha_range_ndx,1:length(rem_goodsamp2));
%         mifq_alpha(ch) = nanmean(ifq_alpha(ch,ifq_alpha_range_ndx_good));
%         
%         ifq_theta_range_ndx = find(ifq_theta(ch,:) >= lower_freq_theta & ifq_theta(ch,:) <= higher_freq_theta);
%         ifq_theta_range_ndx_good = intersect(ifq_theta_range_ndx,1:length(rem_goodsamp2));
%         mifq_theta(ch) = nanmean(ifq_theta(ch,ifq_theta_range_ndx_good));
%     end
    
    freq.ifq_rem_alpha = ifq_alpha;
    freq.ifq_rem_theta = ifq_theta;
    clear mifq_alpha mifq_theta filterdata_alpha filterdata_theta tmp_alpha tmp_theta ifq_alpha ifq_theta
    
       
    %% wake evening
    
    display(sub_Folderpath(s).name);

    mICA_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_wake_e_fil_czref_mICA_avref.set']);
    EEG = pop_loadset('filename',[mICA_file(1).name],'filepath',[Folderpath,sub_Folderpath(s).name]);
    
    goodwake_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_wake_e_fil_czref_goodwake.mat']);
    load([Folderpath,sub_Folderpath(s).name,filesep,goodwake_file(1).name]);
    
    nm_good_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_wake_e*_nm_good.mat']);
    load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name]); 
   
    %
    %use Cohen's median filter method
    % https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6608248/

    filtfreqbounds_alpha = [ 0 (1-trans_width)*lower_freq_alpha lower_freq_alpha higher_freq_alpha higher_freq_alpha*(1+trans_width) fs/2 ]/(fs/2);
    filt_order_alpha     = round(3*(fs/lower_freq_alpha));
    filterweights_alpha  = firls(filt_order_alpha,filtfreqbounds_alpha,idealresponse);
    
    filtfreqbounds_theta = [ 0 (1-trans_width)*lower_freq_theta lower_freq_theta higher_freq_theta higher_freq_theta*(1+trans_width) fs/2 ]/(fs/2);
    filt_order_theta     = round(3*(fs/lower_freq_theta));
    filterweights_theta  = firls(filt_order_theta,filtfreqbounds_theta,idealresponse);

    
%     for cond = 1:8
    
    % this part does the actual filtering
%     filterdata = zeros(size(EEG.data,2));
    for chan = 1:128
        filterdata_alpha(chan,:) = filtfilt(filterweights_alpha,1,EEG.data(chan,:));
        filterdata_theta(chan,:) = filtfilt(filterweights_theta,1,EEG.data(chan,:));
    end
  
    temphilbert_alpha = hilbert(filterdata_alpha')';
    freqslide_prefilt_alpha = diff(fs*unwrap(angle(temphilbert_alpha'),[],1)',1,2)/(2*pi);
    
    temphilbert_theta = hilbert(filterdata_theta')';
    freqslide_prefilt_theta = diff(fs*unwrap(angle(temphilbert_theta'),[],1)',1,2)/(2*pi);
 
    
%     figure
%     a = angle(temphilbert');
%     a2 = unwrap(angle(temphilbert'),[],1)';
%     a3 = diff(fs*unwrap(angle(temphilbert'),[],1)',1,2)/(2*pi);
%     plot(a(1:1000,1));
%     hold on
%     plot(a2(1,1:1000));
%     hold on
%     plot(a3(1,1:1000));
        
    clear tmp_alpha tmp_theta
    tmp_alpha = movmedian(freqslide_prefilt_alpha,orders(2),2);
    tmp_theta = movmedian(freqslide_prefilt_theta,orders(2),2);
    
    for window = orders(3:end-1)
        tmp_alpha = cat(3,tmp_alpha,movmedian(freqslide_prefilt_alpha,window,2));
        tmp_theta = cat(3,tmp_theta,movmedian(freqslide_prefilt_theta,window,2));
    end

    for ch = 1:128
        ifq_alpha(ch,:) = nanmean(tmp_alpha(ch,:,:),3);
        ifq_theta(ch,:) = nanmean(tmp_theta(ch,:,:),3);
    end
    
%     ifq2 = nanmean(tmp,3);
    
%     hold on
%     plot(ifq(1,1:1000));
    
%     ifq_alpha(:,end) = NaN(128,1);
%     ifq_theta(:,end) = NaN(128,1);
%     end

%     for ch = 1:128  
%         ifq_alpha_range_ndx = find(ifq_alpha(ch,:) >= lower_freq_alpha & ifq_alpha(ch,:) <= higher_freq_alpha);
%         ifq_alpha_range_ndx_good = intersect(ifq_alpha_range_ndx,1:length(wake_goodsamp2));
%         mifq_alpha(ch) = nanmean(ifq_alpha(ch,ifq_alpha_range_ndx_good));
%         
%         ifq_theta_range_ndx = find(ifq_theta(ch,:) >= lower_freq_theta & ifq_theta(ch,:) <= higher_freq_theta);
%         ifq_theta_range_ndx_good = intersect(ifq_theta_range_ndx,1:length(wake_goodsamp2));
%         mifq_theta(ch) = nanmean(ifq_theta(ch,ifq_theta_range_ndx_good));
%     end
    
    freq.ifq_wake_e_alpha = ifq_alpha;
    freq.ifq_wake_e_theta = ifq_theta;
    clear mifq_alpha mifq_theta
    
    clear wake_goodsamp2 EEG filterdata_alpha filterdata_theta tmp_alpha tmp_theta ifq_alpha ifq_theta
    
 %% wake morning
    
    display(sub_Folderpath(s).name);

    mICA_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_wake_m_fil_czref_mICA_avref.set']);
    EEG = pop_loadset('filename',[mICA_file(1).name],'filepath',[Folderpath,sub_Folderpath(s).name]);
    
    goodwake_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_wake_m_fil_czref_goodwake.mat']);
    load([Folderpath,sub_Folderpath(s).name,filesep,goodwake_file(1).name]);
    
    nm_good_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_wake_m*_nm_good.mat']);
    load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name]); 
    
    
    %use Cohen's median filter method
    % https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6608248/
    
    filtfreqbounds_alpha = [ 0 (1-trans_width)*lower_freq_alpha lower_freq_alpha higher_freq_alpha higher_freq_alpha*(1+trans_width) fs/2 ]/(fs/2);
    filt_order_alpha     = round(3*(fs/lower_freq_alpha));
    filterweights_alpha  = firls(filt_order_alpha,filtfreqbounds_alpha,idealresponse);
    
    filtfreqbounds_theta = [ 0 (1-trans_width)*lower_freq_theta lower_freq_theta higher_freq_theta higher_freq_theta*(1+trans_width) fs/2 ]/(fs/2);
    filt_order_theta     = round(3*(fs/lower_freq_theta));
    filterweights_theta  = firls(filt_order_theta,filtfreqbounds_theta,idealresponse);

    
%     for cond = 1:8
    
    % this part does the actual filtering
%     filterdata = zeros(size(EEG.data,2));
    for chan = 1:128
        filterdata_alpha(chan,:) = filtfilt(filterweights_alpha,1,EEG.data(chan,:));
        filterdata_theta(chan,:) = filtfilt(filterweights_theta,1,EEG.data(chan,:));
    end
  
    temphilbert_alpha = hilbert(filterdata_alpha')';
    freqslide_prefilt_alpha = diff(fs*unwrap(angle(temphilbert_alpha'),[],1)',1,2)/(2*pi);
    
    temphilbert_theta = hilbert(filterdata_theta')';
    freqslide_prefilt_theta = diff(fs*unwrap(angle(temphilbert_theta'),[],1)',1,2)/(2*pi);
 
    
%     figure
%     a = angle(temphilbert');
%     a2 = unwrap(angle(temphilbert'),[],1)';
%     a3 = diff(fs*unwrap(angle(temphilbert'),[],1)',1,2)/(2*pi);
%     plot(a(1:1000,1));
%     hold on
%     plot(a2(1,1:1000));
%     hold on
%     plot(a3(1,1:1000));
        
    clear tmp_alpha tmp_theta
    tmp_alpha = movmedian(freqslide_prefilt_alpha,orders(2),2);
    tmp_theta = movmedian(freqslide_prefilt_theta,orders(2),2);
    
    for window = orders(3:end-1)
        tmp_alpha = cat(3,tmp_alpha,movmedian(freqslide_prefilt_alpha,window,2));
        tmp_theta = cat(3,tmp_theta,movmedian(freqslide_prefilt_theta,window,2));
    end

    for ch = 1:128
        ifq_alpha(ch,:) = nanmean(tmp_alpha(ch,:,:),3);
        ifq_theta(ch,:) = nanmean(tmp_theta(ch,:,:),3);
    end
    
%     ifq2 = nanmean(tmp,3);
    
%     hold on
%     plot(ifq(1,1:1000));
    
%     ifq_alpha(:,end) = NaN(128,1);
%     ifq_theta(:,end) = NaN(128,1);
%     end

%     for ch = 1:128  
%         ifq_alpha_range_ndx = find(ifq_alpha(ch,:) >= lower_freq_alpha & ifq_alpha(ch,:) <= higher_freq_alpha);
%         ifq_alpha_range_ndx_good = intersect(ifq_alpha_range_ndx,1:length(wake_goodsamp2));
%         mifq_alpha(ch) = nanmean(ifq_alpha(ch,ifq_alpha_range_ndx_good));
%         
%         ifq_theta_range_ndx = find(ifq_theta(ch,:) >= lower_freq_theta & ifq_theta(ch,:) <= higher_freq_theta);
%         ifq_theta_range_ndx_good = intersect(ifq_theta_range_ndx,1:length(wake_goodsamp2));
%         mifq_theta(ch) = nanmean(ifq_theta(ch,ifq_theta_range_ndx_good));
%     end
    
    freq.ifq_wake_m_alpha = ifq_alpha;
    freq.ifq_wake_m_theta = ifq_theta;
    clear mifq_alpha mifq_theta
    
    clear wake_goodsamp2 EEG filterdata_alpha filterdata_theta tmp_alpha tmp_theta ifq_alpha ifq_theta  

    %%

    save([Savefolder,filesep,sub_Folderpath(s).name,'_freq.mat'],'freq','-v7.3');
   
    clear freq
    
end



