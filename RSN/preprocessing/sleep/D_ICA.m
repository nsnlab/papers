clear all;
close all;

addpath /users/psychology01/software/fieldtrip
addpath /users/psychology01/software/eeglab
addpath /users/psychology01/Valeria/Scripts

Folderpath = '/users/m17462/psychology01/parallel_scratch/projects/RSN/RSN_008'; % wihtout / at the end


%% Cluster

cluster = parcluster('eureka'); % to add cluster go to home - parallel - create and manage clusters -import -go to config folder in software folder in psychology01 -open eureka .mlsettings file
% cluster.SubmitArguments = compose("--partition=high_mem --mem=%dG
% --time=%d", 16, 24*60); % for high memory job (max. memory that can be
% allocated in normal job is 8 or 12 GB, max. time is 7 days)
cluster.SubmitArguments = compose("--mem=%dG --time=%d", 16, 72*60); % for normal job, mem: memory in GB, time: time in min that is allocated to this job
cluster.NumWorkers = 1;
% cluster.NumThreads = 4;
cluster.JobStorageLocation = '/users/psychology01/Valeria/jobfiles'; % wdir: directory where job file is put

% for s = 1:size(Datafolder_dir,1)
    

    batch(cluster,@ICA,0,{Folderpath},'AutoAttachFiles', false, ...
    'AutoAddClientPath', true, ...
    'CaptureDiary', true);

% end


%% perform ICA
   
function ICA(Folderpath)

    Folderpath_dir = dir([Folderpath,filesep,'*_goodREM.set']);
    filename = Folderpath_dir(1).name;
    dataName = filename(1:end-4);

          
    eeg = pop_loadset('filename', [dataName,'.set'], 'filepath', Folderpath);
    cd(Folderpath)

    ica_dir = [Folderpath,'/ICA'];
    mkdir(ica_dir)  
    
    dataRank = sum(eig(cov(double(eeg.data'))) > 1E-6); % 1E-6 follows pop_runica() line 531, changed from 1E-7.
     
    runamica15(eeg, 'num_chans', eeg.nbchan,...
        'outdir', [Folderpath,'/ICA'],...
        'pcakeep', dataRank, 'num_models', 1,...
        'do_reject', 1, 'numrej', 15, 'rejsig', 3, 'rejint', 1, 'max_threads', 1);
        
    eeg.etc.amica  = loadmodout15([Folderpath,'/ICA']);
    eeg.etc.amica.S = eeg.etc.amica.S(1:eeg.etc.amica.num_pcs, :); % Weirdly, I saw size(S,1) be larger than rank. This process does not hurt anyway.
    eeg.icaweights = eeg.etc.amica.W;
    eeg.icasphere  = eeg.etc.amica.S;
    eeg = eeg_checkset(eeg, 'ica');
       
  [~,coordinateTransformParameters] = coregister(eeg.chanlocs, '/users/psychology01/software/eeglab/plugins/dipfit4.3/standard_BEM/elec/standard_1005.elc', 'warp', 'auto', 'manual', 'off');

  templateChannelFilePath = '/users/psychology01/software/eeglab/plugins/dipfit4.3/standard_BEM/elec/standard_1005.elc';
    hdmFilePath             = '/users/psychology01/software/eeglab/plugins/dipfit4.3/standard_BEM/standard_vol.mat';
    eeg = pop_dipfit_settings( eeg, 'hdmfile', hdmFilePath, 'coordformat', 'MNI',...
        'mrifile', '/users/psychology01/software/eeglab/plugins/dipfit4.3/standard_BEM/standard_mri.mat',...
        'chanfile', templateChannelFilePath, 'coord_transform', coordinateTransformParameters,...
        'chansel', 1:eeg.nbchan);
    eeg = pop_multifit(eeg, 1:eeg.nbchan,'threshold', 100, 'dipplot','off','plotopt',{'normlen' 'on'});
 
    % Step 12: Search for and estimate symmetrically constrained bilateral dipoles
    eeg = fitTwoDipoles(eeg, 'LRR', 35);
    
    eeg = pop_saveset(eeg, 'filename', [dataName,'_ICA'], 'filepath', [Folderpath,'/ICA']);

    % Step 13: Run ICLabel (Pion-Tonachini et al., 2019)
    eeg = iclabel(eeg, 'default');  
    
%     mkdir([Folderpath,dataName,'/IClabel'])
            
     % Perform IC rejection using ICLabel scores and r.v. from dipole fitting.
 
     %
     
    % Obtain the most dominant class label and its label probability.
    [~, mostDominantClassLabelVector] = max(eeg.etc.ic_classification.ICLabel.classifications, [], 2);
    mostDominantClassLabelProbVector = zeros(length(mostDominantClassLabelVector),1);
    for icIdx = 1:length(mostDominantClassLabelVector)
             mostDominantClassLabelProbVector(icIdx)  = eeg.etc.ic_classification.ICLabel.classifications(icIdx, mostDominantClassLabelVector(icIdx));
    end
    
        
    %brainLabelProbThresh  = .4; % [0-1]
    brainIdx = find(mostDominantClassLabelVector==1 | mostDominantClassLabelVector==7);% & mostDominantClassLabelProbVector>=brainLabelProbThresh);
    %brainIdx = logical((brainIdx-1).^2); 
         
    % Perform IC rejection using residual variance of the IC scalp maps.
    rvList    = [eeg.dipfit.model.rv];
    goodRvIdx = find(rvList < 0.35)'; % < 15% residual variance == good ICs.
 
    % Perform IC rejection using inside brain criterion.
    load(eeg.dipfit.hdmfile); % This returns 'vol'.
    dipoleXyz = zeros(length(eeg.dipfit.model),3);
    for icIdx = 1:length(eeg.dipfit.model)
        dipoleXyz(icIdx,:) = eeg.dipfit.model(icIdx).posxyz(1,:);
    end
    depth = ft_sourcedepth(dipoleXyz, vol);
    depthThreshold = 1;
    insideBrainIdx = find(depth<=depthThreshold);
 
    % Take AND across the three criteria.
    goodIcIdx = intersect(brainIdx, goodRvIdx);
    goodIcIdx = intersect(goodIcIdx, insideBrainIdx);
        %goodIcIdx = intersect(brainIdx, insideBrainIdx);        
         
    
    % Save the dataset
    eeg = pop_saveset(eeg, 'filename', [dataName,'_ICs_removed'], 'filepath', [Folderpath,'/ICA']);
        

end
   