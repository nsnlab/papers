clear all;
close all;

addpath(genpath('/user/HS301/m17462/matlab/eeglab'));
addpath(genpath('/user/HS301/m17462/matlab/Scripts/RSN'));

addpath /user/HS301/m17462/matlab/Henry/useful_functions

%% Load data

Folderpath = '/vol/research/nemo/datasets/RSN/data/hdEEG/';
sub_Folderpath = dir([Folderpath,'RSN*']);

Folderpath_phase = '/vol/research/nemo/datasets/RSN/data/analysis/phase_allsub/';

Savefolder = Folderpath_phase;

%%

on_block = 7:12;
off_block = 1:6;


for s = 1:length(sub_Folderpath)

    
    phase_file = dir([Folderpath_phase,sub_Folderpath(s).name,'*_phase_connectivity.mat']);
    nm_good_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_nm_good_psd_allch.mat']);
   
    load([Folderpath_phase,phase_file(1).name]);

    load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name]);


%% PLV - all channel pairs

% cd(Connectivitysave)

comps = NaN(127,127);
comps(:,1) = [1:127];


for i = 2:127
    
    comps(i:127,i) = i:127;
    
end

for band1 = 1:4
    
    display(['Band1 = ', num2str(band1)]);
    
    for band2 = 1:4
        
    display(['Band2 = ', num2str(band2)]);

    for cond = 1:8
        
        display(['Cond = ', num2str(cond)]);
    
        phase_difference.on.band1{band1}.band2{band2}.cond{cond} =  NaN(127,127);
        phase_difference_phasic.on.band1{band1}.band2{band2}.cond{cond} =  NaN(127,127);
        phase_difference_tonic.on.band1{band1}.band2{band2}.cond{cond} =  NaN(127,127);

        PLV.on.band1{band1}.band2{band2}.cond{cond} =  NaN(127,127);
        PLV_phasic.on.band1{band1}.band2{band2}.cond{cond} =  NaN(127,127);
        PLV_tonic.on.band1{band1}.band2{band2}.cond{cond} =  NaN(127,127);
        
        PLI.on.band1{band1}.band2{band2}.cond{cond} =  NaN(127,127);
        PLI_phasic.on.band1{band1}.band2{band2}.cond{cond} =  NaN(127,127);
        PLI_tonic.on.band1{band1}.band2{band2}.cond{cond} =  NaN(127,127);

        phase_difference.off.band1{band1}.band2{band2}.cond{cond} =  NaN(127,127);
        phase_difference_phasic.off.band1{band1}.band2{band2}.cond{cond} =  NaN(127,127);
        phase_difference_tonic.off.band1{band1}.band2{band2}.cond{cond} =  NaN(127,127);
        
        PLV.off.band1{band1}.band2{band2}.cond{cond} =  NaN(127,127);
        PLV_phasic.off.band1{band1}.band2{band2}.cond{cond} =  NaN(127,127);
        PLV_tonic.off.band1{band1}.band2{band2}.cond{cond} =  NaN(127,127);
        
        PLI.off.band1{band1}.band2{band2}.cond{cond} =  NaN(127,127);
        PLI_phasic.off.band1{band1}.band2{band2}.cond{cond} =  NaN(127,127);
        PLI_tonic.off.band1{band1}.band2{band2}.cond{cond} =  NaN(127,127);

        for seed = 1:127
            
            display(seed)
               
            tmp_comps = comps(~isnan(comps(:,seed)),seed);
        
            for chan = 1:length(tmp_comps)
            
                tmp_phase_diff = phase.band{band1}.cond{cond}.chan{seed}-phase.band{band2}.cond{cond}.chan{tmp_comps(chan)};
   
                tmp_phase_diff(tmp_phase_diff>pi) = tmp_phase_diff(tmp_phase_diff>pi)-2*pi;
                tmp_phase_diff(tmp_phase_diff<-pi) = tmp_phase_diff(tmp_phase_diff<-pi)+2*pi;           
            
                tmp_resultant = NaN(size(tmp_phase_diff,3),12);
                tmp_phase = NaN(size(tmp_phase_diff,3),12);
                tmp_pli = NaN(size(tmp_phase_diff,3),12);

            
                for t = 1:size(tmp_phase_diff,3)
      
                    tmp = tmp_phase_diff(:,:,t);
                    tmp_phase_diff2 = tmp_phase_diff;
                    tmp2 = tmp_phase_diff2(:,:,t);
                    tmp2(rem(tmp2./pi,1)==0) = 0; % change phase differences that are divisible by pi to 0 (does this really do anything? I don't think it will ever be exactly divisible by pi?)
       
                    for ep = 1:size(tmp,2)
          
                        if ~isnan(tmp(:,ep))
               
                            tmp_resultant(t,ep) = circ_r(tmp(:,ep)); % resultant across all samples of one second
                            tmp_phase(t,ep) = circ_mean(tmp(:,ep)); % circular mean across all samples of one second
                            tmp_pli(t,ep) = abs(mean(sign(sin(tmp2(:,ep))))); % for each sample covert phase difference to 1 if it is positive and -1 if it is negative (sin should not change sign, so not really necessary?), average across all samples and take absolute value            
          
                        end       
                    end       
                end  
                
                %%
                
                good_trialndx = nm.good_trialndx;
                phasic_goodtrialndx = nm.phasic_goodtrialndx;
                tonic_goodtrialndx = nm.tonic_goodtrialndx;
              
                phase_on = tmp_phase(good_trialndx{cond},on_block);
                phase_on_long = phase_on(:);
                phase_on_long_nonan = phase_on_long(~isnan(phase_on_long));
                phase_difference.on.band1{band1}.band2{band2}.cond{cond}(tmp_comps(chan),seed) = circ_mean(phase_on_long_nonan); % circular mean across all seconds of on trials                    
                
                phase_on_phasic = tmp_phase(phasic_goodtrialndx{cond},on_block);
                phase_on_long_phasic = phase_on_phasic(:);
                phase_on_long_nonan_phasic = phase_on_long_phasic(~isnan(phase_on_long_phasic));
                phase_difference_phasic.on.band1{band1}.band2{band2}.cond{cond}(tmp_comps(chan),seed) = circ_mean(phase_on_long_nonan_phasic); % circular mean across all seconds of on trials                    
                
                phase_on_tonic = tmp_phase(tonic_goodtrialndx{cond},on_block);
                phase_on_long_tonic = phase_on_tonic(:);
                phase_on_long_nonan_tonic = phase_on_long_tonic(~isnan(phase_on_long_tonic));
                phase_difference_tonic.on.band1{band1}.band2{band2}.cond{cond}(tmp_comps(chan),seed) = circ_mean(phase_on_long_nonan_tonic); % circular mean across all seconds of on trials                    
   
               %% 
                
                phase_off = tmp_phase(good_trialndx{cond},off_block);
                phase_off_long = phase_off(:);
                phase_off_long_nonan = phase_off_long(~isnan(phase_off_long));
                phase_difference.off.band1{band1}.band2{band2}.cond{cond}(tmp_comps(chan),seed) = circ_mean(phase_off_long_nonan); % circular mean across all seconds of off trials
                
                phase_off_phasic = tmp_phase(phasic_goodtrialndx{cond},off_block);
                phase_off_long_phasic = phase_off_phasic(:);
                phase_off_long_nonan_phasic = phase_off_long_phasic(~isnan(phase_off_long_phasic));
                phase_difference_phasic.off.band1{band1}.band2{band2}.cond{cond}(tmp_comps(chan),seed) = circ_mean(phase_off_long_nonan_phasic); % circular mean across all seconds of off trials
                
                phase_off_tonic = tmp_phase(tonic_goodtrialndx{cond},off_block);
                phase_off_long_tonic = phase_off_tonic(:);
                phase_off_long_nonan_tonic = phase_off_long_tonic(~isnan(phase_off_long_tonic));
                phase_difference_tonic.off.band1{band1}.band2{band2}.cond{cond}(tmp_comps(chan),seed) = circ_mean(phase_off_long_nonan_tonic); % circular mean across all seconds of off trials
                
                %%
                resultant_on = tmp_resultant(good_trialndx{cond},on_block);
                resultant_on_long = resultant_on(:);
                resultant_on_long_nonan = resultant_on_long(~isnan(resultant_on_long));
                PLV.on.band1{band1}.band2{band2}.cond{cond}(tmp_comps(chan),seed) = mean(resultant_on_long_nonan); % mean across all seconds of on trials
                
                resultant_on_phasic = tmp_resultant(phasic_goodtrialndx{cond},on_block);
                resultant_on_long_phasic = resultant_on_phasic(:);
                resultant_on_long_nonan_phasic = resultant_on_long_phasic(~isnan(resultant_on_long_phasic));
                PLV_phasic.on.band1{band1}.band2{band2}.cond{cond}(tmp_comps(chan),seed) = mean(resultant_on_long_nonan_phasic); % mean across all seconds of on trials

                resultant_on_tonic = tmp_resultant(tonic_goodtrialndx{cond},on_block);
                resultant_on_long_tonic = resultant_on_tonic(:);
                resultant_on_long_nonan_tonic = resultant_on_long_tonic(~isnan(resultant_on_long_tonic));
                PLV_tonic.on.band1{band1}.band2{band2}.cond{cond}(tmp_comps(chan),seed) = mean(resultant_on_long_nonan_tonic); % mean across all seconds of on trials

                %%
                resultant_off = tmp_resultant(good_trialndx{cond},off_block);
                resultant_off_long = resultant_off(:);
                resultant_off_long_nonan = resultant_off_long(~isnan(resultant_off_long));
                PLV.off.band1{band1}.band2{band2}.cond{cond}(tmp_comps(chan),seed) = mean(resultant_off_long_nonan);  % mean across all seconds of off trials

                resultant_off_phasic = tmp_resultant(phasic_goodtrialndx{cond},off_block);
                resultant_off_long_phasic = resultant_off_phasic(:);
                resultant_off_long_nonan_phasic = resultant_off_long_phasic(~isnan(resultant_off_long_phasic));
                PLV_phasic.off.band1{band1}.band2{band2}.cond{cond}(tmp_comps(chan),seed) = mean(resultant_off_long_nonan_phasic);  % mean across all seconds of off trials
  
                resultant_off_tonic = tmp_resultant(tonic_goodtrialndx{cond},off_block);
                resultant_off_long_tonic = resultant_off_tonic(:);
                resultant_off_long_nonan_tonic = resultant_off_long_tonic(~isnan(resultant_off_long_tonic));
                PLV_tonic.off.band1{band1}.band2{band2}.cond{cond}(tmp_comps(chan),seed) = mean(resultant_off_long_nonan_tonic);  % mean across all seconds of off trials

                
                %%
                pli_on = tmp_pli(good_trialndx{cond},on_block);
                pli_on_long = pli_on(:);
                pli_on_long_nonan = pli_on_long(~isnan(pli_on_long));
                PLI.on.band1{band1}.band2{band2}.cond{cond}(tmp_comps(chan),seed) = mean(pli_on_long_nonan);
                
                pli_on_phasic = tmp_pli(phasic_goodtrialndx{cond},on_block);
                pli_on_long_phasic = pli_on_phasic(:);
                pli_on_long_nonan_phasic = pli_on_long_phasic(~isnan(pli_on_long_phasic));
                PLI_phasic.on.band1{band1}.band2{band2}.cond{cond}(tmp_comps(chan),seed) = mean(pli_on_long_nonan_phasic);
                
                pli_on_tonic = tmp_pli(tonic_goodtrialndx{cond},on_block);
                pli_on_long_tonic = pli_on_tonic(:);
                pli_on_long_nonan_tonic = pli_on_long_tonic(~isnan(pli_on_long_tonic));
                PLI_tonic.on.band1{band1}.band2{band2}.cond{cond}(tmp_comps(chan),seed) = mean(pli_on_long_nonan_tonic);
                
                %%
                
                pli_off = tmp_pli(good_trialndx{cond},off_block);
                pli_off_long = pli_off(:);
                pli_off_long_nonan = pli_off_long(~isnan(pli_off_long));
                PLI.off.band1{band1}.band2{band2}.cond{cond}(tmp_comps(chan),seed) = mean(pli_off_long_nonan);
                
                pli_off_phasic = tmp_pli(phasic_goodtrialndx{cond},off_block);
                pli_off_long_phasic = pli_off_phasic(:);
                pli_off_long_nonan_phasic = pli_off_long_phasic(~isnan(pli_off_long_phasic));
                PLI_phasic.off.band1{band1}.band2{band2}.cond{cond}(tmp_comps(chan),seed) = mean(pli_off_long_nonan_phasic);
                
                pli_off_tonic = tmp_pli(tonic_goodtrialndx{cond},off_block);
                pli_off_long_tonic = pli_off_tonic(:);
                pli_off_long_nonan_tonic = pli_off_long_tonic(~isnan(pli_off_long_tonic));
                PLI_tonic.off.band1{band1}.band2{band2}.cond{cond}(tmp_comps(chan),seed) = mean(pli_off_long_nonan_tonic);
                
                
            end
        
        end       
        
    end
    
    end

end


save([Savefolder,phase_file(1).name(1:end-22),'connectivity.mat'],'PLV*','PLI*','phase_difference*','-v7.3');

end