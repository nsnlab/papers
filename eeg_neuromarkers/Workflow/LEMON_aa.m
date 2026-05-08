% Automatic analysis
% User master script example (aa version 5.*.*)
%
% This script demonstrates a basic EEG pipeline.

% addpath /users/psychology01/software/automaticanalysis
aa_ver5

DATADIR = '/users/psychology01/datasets/LEMON';
FOOOFDIR = fullfile(DATADIR,'EEG-IPF');

GROUPS = {'Y' 'E'};

FOI = [1:0.5:32 33:11:121]; % higher resolution below 32 Hz to allow shifting individual bands
% band boundaries at the 0.5 Hz resolution
BANDS = {...
    'delta', [1 3.5];...
    'theta', [4 7.5];...
    'alpha', [8 13.5];...
    'beta', [14 32.5];...
    'low gamma', [33 80.5];...
    'high gamma', [81 120];...
    };

tab = readtable(fullfile(DATADIR,'Behavioural','LEMON_Behavioural_Data.csv'),'FileType','text');
tab(cellfun(@(x) ~isempty(x),tab.Excl_),:) = []; % excluded due to various reasons (see LEMON_Behavioural_Data.csv
tab(cellfun(@(x) ~exist(fullfile(DATADIR,'EEG',x),'dir') | ~exist(fullfile(DATADIR,'MRI',x),'dir'),tab.ID),:) = []; % excluded due to completely missing data
tab(isnan(tab.As_FA2) | isnan(tab.Ep_FA1) | isnan(tab.WM_Accuracy),:) = []; % exclude missing memory data
tab.Age_2 = (tab.Age_1 >= 57.5)+1; % Y -> 1, E -> 2

nModel = 4; % age, AM, EM, WM

%% RECIPE
aap = aarecipe('LEMON_tasklist.xml');
SPM = aas_inittoolbox(aap,'spm');
SPM.load;

EL = aas_inittoolbox(aap,'eeglab');
EL.load;
CHANNELFILE = fullfile(EL.dipfitPath,'standard_BESA','standard-10-5-cap385.elp');
EL.close;

% SITE-SPECIFIC CONFIGURATION:
aap.options.wheretoprocess = 'batch'; % queuing system			% typical value localsingle or qsub_nonDCS
aap.directory_conventions.poolprofile = 'high_mem';
aap.options.aaparallel.numberofworkers = 175;
aap.options.aaparallel.memory = 16;
aap.options.aaparallel.walltime = 7*24;%7*24;
aap.options.aaworkermaximumretry = 0; % do not retry; it would remove files
aap.options.aaworkerGUI = 0;
aap.options.garbagecollection = 1;
aap.options.diagnostic_videos = 0;

%% PIPELINE
% Directory & sub-directory for analysed data:
aap.acq_details.root = '/vol/research/nemo/projects/LEMON/aa';
aap.directory_conventions.analysisid = 'eeg'; 

% Pipeline customisation
aap = aas_addinitialstream(aap,'channellayout',{CHANNELFILE});
aap = aas_addinitialstream(aap,'MNI_1mm',{'/vol/research/nemo/software/standard/MNI152_T1_1mm.nii'});

aap.tasksettings.aamod_structuralfromnifti.sfxformodality = 'T1w'; % suffix for structural
aap.tasksettings.aamod_segment8.combine = [0.05 0.05 0.05 0.05 0.5 0];
aap.tasksettings.aamod_segment8.writenormimg = 0; % write normialised structural
aap = aas_renamestream(aap,'aamod_coreg_general_00001','reference','MNI_1mm','input');
aap = aas_renamestream(aap,'aamod_coreg_general_00001','input','structural','input');
aap = aas_renamestream(aap,'aamod_coreg_general_00001','output','structural','output');
aap.tasksettings.aamod_meeg_prepareheadmodel.method = 'simbio';
aap.tasksettings.aamod_meeg_prepareheadmodel.options.simbio.downsample = 2;
aap.tasksettings.aamod_meeg_prepareheadmodel.options.simbio.meshshift = 0.1;
aap.tasksettings.aamod_meeg_preparesourcemodel.method = 'corticalsheet';
aap.tasksettings.aamod_meeg_preparesourcemodel.options.corticalsheet.resolution = '4k';
aap.tasksettings.aamod_meeg_preparesourcemodel.options.corticalsheet.annotation = 'DKTatlas';
aap = aas_renamestream(aap,'aamod_norm_write_00001','structural','MNI_1mm','input');
aap = aas_renamestream(aap,'aamod_norm_write_00001','epi','aamod_structuralfromnifti_00001.structural','input');
aap = aas_renamestream(aap,'aamod_norm_write_00001','epi','structural','output');
aap.tasksettings.aamod_norm_write.bb = [-90 90 -126 91 -72 109];
aap.tasksettings.aamod_norm_write.vox = [1 1 1];

aap.tasksettings.aamod_meeg_converttoeeglab.removechannel = 'VEOG';
aap.tasksettings.aamod_meeg_converttoeeglab.downsample = 250;
aap.tasksettings.aamod_meeg_converttoeeglab.diagnostics.freqrange = [1 120];
aap.tasksettings.aamod_meeg_converttoeeglab.diagnostics.freq = [6 10 50];
% - correct/harmonise events
aap.tasksettings.aamod_meeg_converttoeeglab.toEdit(1).subject = {'sub-010078'};
aap.tasksettings.aamod_meeg_converttoeeglab.toEdit(1).session = '*';
aap.tasksettings.aamod_meeg_converttoeeglab.toEdit(1).event(1) = struct('type','S208','operation','rename:S  1'); % keep only events starting with 'S'
aap.tasksettings.aamod_meeg_converttoeeglab.toEdit(2).subject = {'sub-010155' 'sub-010157' 'sub-010162' 'sub-010163' 'sub-010164' 'sub-010165' 'sub-010166'...
    'sub-010168' 'sub-010228' 'sub-010233' 'sub-010239' 'sub-010255' 'sub-010257' 'sub-010258' 'sub-010260'...
    'sub-010261' 'sub-010262' 'sub-010263' 'sub-010267' 'sub-010268' 'sub-010269' 'sub-010270' 'sub-010271'...
    'sub-010272' 'sub-010273' 'sub-010274' 'sub-010275' 'sub-010284' 'sub-010311' 'sub-010315' 'sub-010318'};
aap.tasksettings.aamod_meeg_converttoeeglab.toEdit(2).session = '*';
aap.tasksettings.aamod_meeg_converttoeeglab.toEdit(2).event(1) = struct('type','S  1','operation',['insert:[ ' sprintf('%d ',3:30:480) ']']);
aap.tasksettings.aamod_meeg_converttoeeglab.toEdit(3).subject = {'sub-010264'};
aap.tasksettings.aamod_meeg_converttoeeglab.toEdit(3).session = '*';
aap.tasksettings.aamod_meeg_converttoeeglab.toEdit(3).event(1) = struct('type','S  1','operation','insert:[ 3 ]');
aap.tasksettings.aamod_meeg_converttoeeglab.toEdit(4).subject = {'sub-010059'};
aap.tasksettings.aamod_meeg_converttoeeglab.toEdit(4).session = '*';
aap.tasksettings.aamod_meeg_converttoeeglab.toEdit(4).event(1) = struct('type',1:18,'operation','remove');
aap.tasksettings.aamod_meeg_converttoeeglab.toEdit(5).subject = {'sub-010081' 'sub-010100'};
aap.tasksettings.aamod_meeg_converttoeeglab.toEdit(5).session = '*';
aap.tasksettings.aamod_meeg_converttoeeglab.toEdit(5).event(1) = struct('type',1:10,'operation','remove');
aap.tasksettings.aamod_meeg_converttoeeglab.toEdit(6).subject = '*';
aap.tasksettings.aamod_meeg_converttoeeglab.toEdit(6).session = '*';
aap.tasksettings.aamod_meeg_converttoeeglab.toEdit(6).event(1) = struct('type','^S.*','operation','keep'); % keep only events starting with 'S'
aap.tasksettings.aamod_meeg_converttoeeglab.toEdit(6).event(2) = struct('type','S  1','operation','unique:last'); % remove duplicates of 'S  1'
aap.tasksettings.aamod_meeg_converttoeeglab.toEdit(6).event(3) = struct('type','S  1','operation','iterate'); % 'S  1' -> 'S  101', 'S  102', 'S  103',...
aap.tasksettings.aamod_meeg_converttoeeglab.toEdit(7).subject = '*';
aap.tasksettings.aamod_meeg_converttoeeglab.toEdit(7).session = '*';
aap.tasksettings.aamod_meeg_converttoeeglab.toEdit(7).event(1) = struct('type','S  101','operation','ignorebefore'); % remove heading samples

aap.tasksettings.aamod_meeg_filter.hpfreq = 1;
aap.tasksettings.aamod_meeg_filter.bsfreq = cell2mat(arrayfun(@(x) [x-5 x+5]', [50 100], 'UniformOutput', false))';
aap.tasksettings.aamod_meeg_filter.diagnostics = aap.tasksettings.aamod_meeg_converttoeeglab.diagnostics;

aap.tasksettings.aamod_meeg_cleanartifacts.criteria.Highpass = 'off';
aap.tasksettings.aamod_meeg_cleanartifacts.criteria.LineNoiseCriterion = 'off';
aap.tasksettings.aamod_meeg_cleanartifacts.criteria.FlatlineCriterion = 5; % maximum tolerated flatline duration in seconds
aap.tasksettings.aamod_meeg_cleanartifacts.criteria.ChannelCriterion = 0.8; % minimum channel correlation
aap.tasksettings.aamod_meeg_cleanartifacts.criteria.BurstCriterion = 20; % 5 (recommended by Makoto's pres) is too agressive; 10 to *20* (according to the evaluation paper)
aap.tasksettings.aamod_meeg_cleanartifacts.criteria.Distance = 'riemannian'; % Riemann adapted processing is a newer method to estimate covariance matrices
aap.tasksettings.aamod_meeg_cleanartifacts.criteria.BurstRejection = 'off'; % correcting data using ASR instead of removing
aap.tasksettings.aamod_meeg_cleanartifacts.criteria.WindowCriterion = 0.25; % if more than this % of channels still show above-threshold amplitudes, reject this window (0.05 - 0.3)
aap.tasksettings.aamod_meeg_cleanartifacts.interpolate = 'spherical';

aap.tasksettings.aamod_meeg_rereference.reference = 'average';
aap.tasksettings.aamod_meeg_rereference.diagnostics = aap.tasksettings.aamod_meeg_converttoeeglab.diagnostics;

aap.tasksettings.aamod_meeg_ica.PCA = 'rank';
aap.tasksettings.aamod_meeg_ica.iterations = 2000;
aap.tasksettings.aamod_meeg_ica.method = 'AMICA';
aap.tasksettings.aamod_meeg_ica.options.AMICA.num_models = 1; % learn 1 model
% reject outliers (>3 SD) for the first 15 iterations 
aap.tasksettings.aamod_meeg_ica.options.AMICA.numrej = 15; 
aap.tasksettings.aamod_meeg_ica.options.AMICA.rejint = 1;
aap.tasksettings.aamod_meeg_ica.options.AMICA.rejsig = 3;

aap.tasksettings.aamod_meeg_dipfit.transformation = CHANNELFILE;
aap.tasksettings.aamod_meeg_dipfit.volumeCondutionModel = fullfile('standard_BESA','standard_BESA.mat');
aap.tasksettings.aamod_meeg_dipfit.rejectionThreshold = 100; % keep all
aap.tasksettings.aamod_meeg_dipfit.constrainSymmetrical = 1;

% Automatic IC rejection using ICLabel label probability (brain > 0.7) and and residual variance (< 0.15) from dipole fitting (if performed).
aap.tasksettings.aamod_meeg_icclassification.method = 'ICLabel';
aap.tasksettings.aamod_meeg_icclassification.criteria.prob = 'Brain>0.7'; % Eye<0.8:*Muscle<0.8
aap.tasksettings.aamod_meeg_icclassification.criteria.rv = 0.15;

aap.tasksettings.aamod_meeg_epochs.rejectionevent = 'boundary'; % datasection rejected by aamod_meeg_cleanartifacts is marked

aap = aas_renamestream(aap,'aamod_meeg_preparesourcereconstruction_00001','input','meeg');
aap.tasksettings.aamod_meeg_preparesourcereconstruction.realignelectrodes.target = 'scalp';
aap.tasksettings.aamod_meeg_preparesourcereconstruction.realignelectrodes.method = 'spherefit';
aap = aas_renamestream(aap,'aamod_meeg_sourcecreate_00001','input','meeg');
aap.tasksettings.aamod_meeg_sourcecreate.parameter = 'trial';
aap = aas_renamestream(aap,'aamod_meeg_sourceatlasing_00001','input','meeg');
aap.tasksettings.aamod_meeg_sourceatlasing.parameter = 'trial';

% TFA
aap = aas_renamestream(aap,'aamod_meeg_timefrequencyanalysis_00001','ipf',[],'input');
aap = aas_renamestream(aap,'aamod_meeg_sourcereconstruction_00001','ipf',[],'input');
aap = aas_renamestream(aap,'aamod_meeg_connectivityanalysis_00001','ipf',[],'input');
aap = aas_renamestream(aap,'aamod_meeg_crossfrequencyanalysis_00001','ipf',[],'input');
for b = 1:2 % banding
    aap = aas_renamestream(aap,sprintf('aamod_meeg_timefrequencyanalysis_%05d',b),'meeg','aamod_meeg_epochs_00001.meeg');
    
    aap.tasksettings.aamod_meeg_timefrequencyanalysis(b).ignorebefore = -6; % ignore the first 5 trials for each trialtype
    aap.tasksettings.aamod_meeg_timefrequencyanalysis(b).timefrequencyanalysis.method = 'mtmfft';
    aap.tasksettings.aamod_meeg_timefrequencyanalysis(b).timefrequencyanalysis.taper = 'hanning';
    aap.tasksettings.aamod_meeg_timefrequencyanalysis(b).timefrequencyanalysis.foi = FOI;
    aap.tasksettings.aamod_meeg_timefrequencyanalysis(b).bandspecification.band = BANDS(:,1);
    aap.tasksettings.aamod_meeg_timefrequencyanalysis(b).bandspecification.bandbound = BANDS(:,2);
    aap.tasksettings.aamod_meeg_timefrequencyanalysis(b).diagnostics.snapshotfwoi = BANDS(:,1);
    aap.tasksettings.aamod_meeg_timefrequencyanalysis(b).contrastoperation = 'ratio';
    aap.tasksettings.aamod_meeg_timefrequencyanalysis(b).weightedaveraging = 1;
    
    aap = aas_renamestream(aap,sprintf('aamod_meeg_timefrequencystatistics_%05d',(b-1)*(1+nModel)+1),'timefreq','timeband'); % sensor + nModel
    aap.tasksettings.aamod_meeg_timefrequencystatistics((b-1)*(1+nModel)+1).numberofworkers = 10;
    aap.tasksettings.aamod_meeg_timefrequencystatistics((b-1)*(1+nModel)+1).threshold.iteration = 1000;
    aap.tasksettings.aamod_meeg_timefrequencystatistics((b-1)*(1+nModel)+1).threshold.correction = 'tfce';
    aap.tasksettings.aamod_meeg_timefrequencystatistics((b-1)*(1+nModel)+1).threshold.p = 0.025; % two-tailed
    aap.tasksettings.aamod_meeg_timefrequencystatistics((b-1)*(1+nModel)+1).diagnostics = struct_update(aap.tasksettings.aamod_meeg_timefrequencystatistics((b-1)*(1+nModel)+1).diagnostics,...
        aap.tasksettings.aamod_meeg_timefrequencyanalysis(b).diagnostics,'Mode','update');
    aap.tasksettings.aamod_meeg_timefrequencystatistics((b-1)*(1+nModel)+1).diagnostics.topohighlight = 'any';
    
    aap = aas_renamestream(aap,sprintf('aamod_meeg_sourcereconstruction_%05d',b),'input','timefreq');
    aap.tasksettings.aamod_meeg_sourcereconstruction(b).bandspecification = aap.tasksettings.aamod_meeg_timefrequencyanalysis(b).bandspecification;
    aap.tasksettings.aamod_meeg_sourcereconstruction(b).diagnostics = struct_update(aap.tasksettings.aamod_meeg_sourcereconstruction(b).diagnostics,...
        aap.tasksettings.aamod_meeg_timefrequencyanalysis(b).diagnostics,'Mode','update');
    
    for m = 2:5 % modelling
        aap = aas_renamestream(aap,sprintf('aamod_meeg_timefrequencystatistics_%05d',(b-1)*(1+nModel)+m),'timefreq','timeband');
        aap.tasksettings.aamod_meeg_timefrequencystatistics((b-1)*(1+nModel)+m).numberofworkers = 10;
        aap.tasksettings.aamod_meeg_timefrequencystatistics((b-1)*(1+nModel)+m).threshold.iteration = 1000;
        aap.tasksettings.aamod_meeg_timefrequencystatistics((b-1)*(1+nModel)+m).threshold.correction = 'tfce';
        aap.tasksettings.aamod_meeg_timefrequencystatistics((b-1)*(1+nModel)+m).threshold.p = 0.025; % two-tailed
        aap.tasksettings.aamod_meeg_timefrequencystatistics((b-1)*(1+nModel)+m).diagnostics = struct_update(aap.tasksettings.aamod_meeg_timefrequencystatistics((b-1)*(1+nModel)+m).diagnostics,...
            aap.tasksettings.aamod_meeg_sourcereconstruction(b).diagnostics,'Mode','update'); % from aamod_meeg_sourcereconstruction 1
        aap.tasksettings.aamod_meeg_timefrequencystatistics((b-1)*(1+nModel)+m).diagnostics.background = 'inflated';
        aap.tasksettings.aamod_meeg_timefrequencystatistics((b-1)*(1+nModel)+m).diagnostics.view = 'RPS';
    end
    
    % CFA
    aap = aas_renamestream(aap,sprintf('aamod_meeg_crossfrequencyanalysis_%05d',b),'crossfreq',[],'output');
    aap.tasksettings.aamod_meeg_crossfrequencyanalysis(b).timefrequencyanalysis.twoicps = 5;
    aap.tasksettings.aamod_meeg_crossfrequencyanalysis(b).crossfrequencyanalysis.method = 'plv';
    aap.tasksettings.aamod_meeg_crossfrequencyanalysis(b).crossfrequencyanalysis.foiphase = FOI;
    aap.tasksettings.aamod_meeg_crossfrequencyanalysis(b).crossfrequencyanalysis.foiamp = FOI;
    % aap.tasksettings.aamod_meeg_crossfrequencyanalysis(b).crossfrequencyanalysis.nphasebins = 13; % 0,+-30,+-60,+-90,+-120,+-150,+-180
    aap.tasksettings.aamod_meeg_crossfrequencyanalysis(b).contrastoperation = 'ratio';
    aap.tasksettings.aamod_meeg_crossfrequencyanalysis(b).crossfrequencyanalysis.chanphase = 'all';
    aap.tasksettings.aamod_meeg_crossfrequencyanalysis(b).crossfrequencyanalysis.chanamp = 'all';
    aap.tasksettings.aamod_meeg_crossfrequencyanalysis(b).bandspecification = aap.tasksettings.aamod_meeg_timefrequencyanalysis(b).bandspecification;
    % - stat
    for m = 1:4 % modelling
        aap = aas_renamestream(aap,sprintf('aamod_meeg_crossfrequencystatistics_%05d',(b-1)*nModel+m),'crossfreq','crossband');
        aap.tasksettings.aamod_meeg_crossfrequencystatistics((b-1)*nModel+m).numberofworkers = 10;
        aap.tasksettings.aamod_meeg_crossfrequencystatistics((b-1)*nModel+m).threshold.iteration = 1000;
        aap.tasksettings.aamod_meeg_crossfrequencystatistics((b-1)*nModel+m).threshold.correction = 'tfce';
        aap.tasksettings.aamod_meeg_crossfrequencystatistics((b-1)*nModel+m).threshold.p = 0.025; % two-tailed
        % aap.tasksettings.aamod_meeg_crossfrequencystatistics((b-1)*nModel+m).threshold.combinationneighbours = 0;
        aap.tasksettings.aamod_meeg_crossfrequencystatistics((b-1)*nModel+m).diagnostics.snapshotfwoiphase = BANDS(1:5,1); % no high gamma for phase
        aap.tasksettings.aamod_meeg_crossfrequencystatistics((b-1)*nModel+m).diagnostics.snapshotfwoiamplitude = BANDS(:,1);
    end
    
    % Conn
    aap = aas_renamestream(aap,sprintf('aamod_meeg_connectivityanalysis_%05d',b),'connfreq',[],'output');   
    aap.tasksettings.aamod_meeg_connectivityanalysis(b).timefrequencyanalysis.spectralsmoothing = 2;
    aap.tasksettings.aamod_meeg_connectivityanalysis(b).connectivityanalysis.method = 'wpli_debiased';
    aap.tasksettings.aamod_meeg_connectivityanalysis(b).connectivityanalysis.channels = []; % all
    aap.tasksettings.aamod_meeg_connectivityanalysis(b).connectivityanalysis.foi = FOI;
    aap.tasksettings.aamod_meeg_connectivityanalysis(b).contrastoperation = 'ratio';
    aap.tasksettings.aamod_meeg_connectivityanalysis(b).bandspecification = aap.tasksettings.aamod_meeg_timefrequencyanalysis(b).bandspecification;
    % - stat
    for m = 1:4 % modelling
        aap = aas_renamestream(aap,sprintf('aamod_meeg_connectivitystatistics_%05d',(b-1)*nModel+m),'connfreq','connband');
        aap.tasksettings.aamod_meeg_connectivitystatistics((b-1)*nModel+m).numberofworkers = 10;
        aap.tasksettings.aamod_meeg_connectivitystatistics((b-1)*nModel+m).threshold.iteration = 1000;
        aap.tasksettings.aamod_meeg_connectivitystatistics((b-1)*nModel+m).threshold.correction = 'tfce';
        aap.tasksettings.aamod_meeg_connectivitystatistics((b-1)*nModel+m).threshold.p = 0.025; % two-tailed
        % aap.tasksettings.aamod_meeg_connectivitystatistics((b-1)*nModel+m).threshold.combinationneighbours = 0;
        aap.tasksettings.aamod_meeg_connectivitystatistics((b-1)*nModel+m).diagnostics.snapshotfwoi = BANDS(:,1); % no high gamma
    end
end
%% DATA
% Directory for raw data:
aap.directory_conventions.rawdatadir = fullfile(DATADIR,'MRI');
aap.directory_conventions.rawmeegdatadir = fullfile(DATADIR,'EEG');
aap.directory_conventions.subjectoutputformat = 'sub-%06d';
aap.directory_conventions.meegsubjectoutputformat = 'sub-%06d';
aap.directory_conventions.subject_directory_format = 1;

% Add subject (full):
aap = aas_add_meeg_session(aap,'run1');
for subj = cellfun(@(x) sscanf(x,'sub-%d'),tab.ID)'
    if isempty(meeg_findvol(aap,subj,'probe',1)) ||... % no EEG folder
            isempty(mri_findvol(aap,subj,0,1)) ||... % no MRI folder
            ~exist(fullfile(mri_findvol(aap,subj,1),'anat',[aas_mriname2subjname(aap,subj) '_ses-01_acq-mp2rage_T1w.nii.gz']),'file') % no processed T1
        continue;
    end
    
    eegacq = cellstr(spm_file(spm_select('FPListRec',meeg_findvol(aap,subj,'fullpath',true),'.*vhdr'),'filename'));
    if isempty(eegacq{1})
        aas_log(aap,false,'No EEG acquisition found'); 
        continue;
    end
    if numel(eegacq) ~= numel(aap.acq_details.meeg_sessions)
        aas_log(aap,false,'The numbers of EEG sessions and EEG acquisitions do not match'); 
        continue;
    end
    aap = aas_addsubject(aap,{subj subj},...
        'structural',{fullfile('anat',[aas_mriname2subjname(aap,subj) '_ses-01_acq-mp2rage_T1w.nii.gz'])},...
        'functional',fullfile('RSEEG',eegacq));
    
    % IPF
    fnList = spm_select('FPList',fullfile(FOOOFDIR,sprintf(aap.directory_conventions.meegsubjectoutputformat,subj)),'^ipf_.*');
    if ~isempty(fnList), aap = aas_addinitialstream(aap,'ipf',aas_getN_bydomain(aap,'subject'),cellstr(fnList)); end
    
    fnList = spm_select('FPList',fullfile(FOOOFDIR,sprintf(aap.directory_conventions.meegsubjectoutputformat,subj)),'^source_ipf_.*');
    if ~isempty(fnList), aap = aas_addinitialstream(aap,'source_ipf',aas_getN_bydomain(aap,'subject'),cellstr(fnList)); end    
end
% final selection
[~,i1] = intersect(tab.ID,{aap.acq_details.subjects.subjname});
tab = tab(i1,:);

%% Epoching
aap = aas_add_meeg_event(aap,'aamod_meeg_epochs','*','run1','segment-1','S  101:S  103',0);
aap = aas_add_meeg_event(aap,'aamod_meeg_epochs','*','run1','segment-2','S  103:S  105',0);
aap = aas_add_meeg_event(aap,'aamod_meeg_epochs','*','run1','segment-3','S  105:S  107',0);
aap = aas_add_meeg_event(aap,'aamod_meeg_epochs','*','run1','segment-4','S  107:S  109',0);
aap = aas_add_meeg_event(aap,'aamod_meeg_epochs','*','run1','segment-5','S  109:S  111',0);
aap = aas_add_meeg_event(aap,'aamod_meeg_epochs','*','run1','segment-6','S  111:S  113',0);
aap = aas_add_meeg_event(aap,'aamod_meeg_epochs','*','run1','segment-7','S  113:S  115',0);
aap = aas_add_meeg_event(aap,'aamod_meeg_epochs','*','run1','segment-8','S  115:end',0);

aap = aas_add_meeg_event(aap,'aamod_meeg_epochs','*','run1','EC','S210',0);
aap = aas_add_meeg_event(aap,'aamod_meeg_epochs','*','run1','EO','S200',0);

aap.tasksettings.aamod_meeg_epochs.timewindow = [0 2000];

for b = 1:2 % banding
    %% TFR
    aap = aas_add_meeg_trialmodel(aap,sprintf('aamod_meeg_timefrequencyanalysis_%05d',b),'*','singlesession:run1','+1xEC','avg','ECAVG');
    aap = aas_add_meeg_trialmodel(aap,sprintf('aamod_meeg_timefrequencyanalysis_%05d',b),'*','singlesession:run1','+1xEO','avg','EOAVG');
    aap = aas_add_meeg_trialmodel(aap,sprintf('aamod_meeg_timefrequencyanalysis_%05d',b),'*','singlesession:run1','+1xEC|-1xEO','avg','ECAVGvsEOAVG');
    aap = aas_add_meeg_trialmodel(aap,sprintf('aamod_meeg_timefrequencyanalysis_%05d',b),'*','singlesession:run1','+0.5xEC|+0.5xEO','avg','ECAVGandEOAVG');
    
    %% CF
    aap = aas_add_meeg_trialmodel(aap,sprintf('aamod_meeg_crossfrequencyanalysis_%05d',b),'*','singlesession:run1','+1xEC','avg','ECAVG');
    aap = aas_add_meeg_trialmodel(aap,sprintf('aamod_meeg_crossfrequencyanalysis_%05d',b),'*','singlesession:run1','+1xEO','avg','EOAVG');
    aap = aas_add_meeg_trialmodel(aap,sprintf('aamod_meeg_crossfrequencyanalysis_%05d',b),'*','singlesession:run1','+1xEC|-1xEO','avg','ECAVGvsEOAVG');
    aap = aas_add_meeg_trialmodel(aap,sprintf('aamod_meeg_crossfrequencyanalysis_%05d',b),'*','singlesession:run1','+0.5xEC|+0.5xEO','avg','ECAVGandEOAVG');
    
    %% Conn
    aap = aas_add_meeg_trialmodel(aap,sprintf('aamod_meeg_connectivityanalysis_%05d',b),'*','singlesession:run1','+1xEC','avg','ECAVG');
    aap = aas_add_meeg_trialmodel(aap,sprintf('aamod_meeg_connectivityanalysis_%05d',b),'*','singlesession:run1','+1xEO','avg','EOAVG');
    aap = aas_add_meeg_trialmodel(aap,sprintf('aamod_meeg_connectivityanalysis_%05d',b),'*','singlesession:run1','+1xEC|-1xEO','avg','ECAVGvsEOAVG');
    aap = aas_add_meeg_trialmodel(aap,sprintf('aamod_meeg_connectivityanalysis_%05d',b),'*','singlesession:run1','+0.5xEC|+0.5xEO','avg','ECAVGandEOAVG');
    
    %% Stats
    for stage = {{'aamod_meeg_timefrequencystatistics_%05d/%05d' [(b-1)*(1+nModel)+1 (b-1)*(1+nModel)+2]} {'aamod_meeg_crossfrequencystatistics_%05d' [(b-1)*nModel+1]} {'aamod_meeg_connectivitystatistics_%05d' [(b-1)*nModel+1]}}
        stagef = stage{1}{1};
        latencies = '';
        
        for c = {'ECAVG' 'EOAVG' 'ECAVGvsEOAVG' 'ECAVGandEOAVG'}
            stagei = stage{1}{2};
            
            modelnameprefix = strjoin(regexp(c{1},'E[CO]{1}','match'),regexp(c{1},'[a-z]*','match'));
            
            aap = aas_add_meeg_groupmodel(aap,sprintf(stagef,stagei),'*',c{1},'all',tab.Age_2',latencies,[modelnameprefix '-YvsE']);
            aap = aas_add_meeg_groupmodel(aap,sprintf(stagef,stagei),'*',c{1},'all',tab.Age_1',latencies,[modelnameprefix '-AGE']);
            
            stagei(end) = stagei(end)+1;
            behav = spm_orth([tab.Age_1(tab.Age_2==1) tab.As_FA2(tab.Age_2==1)]);
            aap = aas_add_meeg_groupmodel(aap,sprintf(stagef,stagei),...
                tab.ID(tab.Age_2==1),...
                c{1},'all',...
                behav(:,2)',...
                latencies,[modelnameprefix '-AM-Y']);
            behav = spm_orth([tab.Age_1(tab.Age_2==2) tab.As_FA2(tab.Age_2==2)]);
            aap = aas_add_meeg_groupmodel(aap,sprintf(stagef,stagei),...
                tab.ID(tab.Age_2==2),...
                c{1},'all',...
                behav(:,2)',...
                latencies,[modelnameprefix '-AM-E']);
            
            stagei(end) = stagei(end)+1;
            behav = spm_orth([tab.Age_1(tab.Age_2==1) tab.Ep_FA1(tab.Age_2==1)]);
            aap = aas_add_meeg_groupmodel(aap,sprintf(stagef,stagei),...
                tab.ID(tab.Age_2==1),...
                c{1},'all',...
                behav(:,2)',...
                latencies,[modelnameprefix '-EM-Y']);
            behav = spm_orth([tab.Age_1(tab.Age_2==2) tab.Ep_FA1(tab.Age_2==2)]);
            aap = aas_add_meeg_groupmodel(aap,sprintf(stagef,stagei),...
                tab.ID(tab.Age_2==2),...
                c{1},'all',...
                behav(:,2)',...
                latencies,[modelnameprefix '-EM-E']);
            
            stagei(end) = stagei(end)+1;
            behav = spm_orth([tab.Age_1(tab.Age_2==1) tab.WM_Accuracy(tab.Age_2==1)]);
            aap = aas_add_meeg_groupmodel(aap,sprintf(stagef,stagei),...
                tab.ID(tab.Age_2==1),...
                c{1},'all',...
                behav(:,2)',...
                latencies,[modelnameprefix '-WM-Y']);
            behav = spm_orth([tab.Age_1(tab.Age_2==2) tab.WM_Accuracy(tab.Age_2==2)]);
            aap = aas_add_meeg_groupmodel(aap,sprintf(stagef,stagei),...
                tab.ID(tab.Age_2==2),...
                c{1},'all',...
                behav(:,2)',...
                latencies,[modelnameprefix '-WM-E']);
        end
    end
end
%% RUN
aa_doprocessing(aap);
aa_report(fullfile(aas_getstudypath(aap),aap.directory_conventions.analysisid));
