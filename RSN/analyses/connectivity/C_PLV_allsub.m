clear all;
close all;

addpath(genpath('/user/HS301/m17462/matlab/eeglab'));
addpath(genpath('/user/HS301/m17462/matlab/Scripts/RSN'));
addpath(genpath('/user/HS301/m17462/matlab/Henry/useful_functions'));

Folderpath = '/vol/research/nemo/datasets/RSN/data/hdEEG/';
sub_Folderpath = dir([Folderpath,'RSN*']);

Savefolder = '/vol/research/nemo/datasets/RSN/data/analysis/connectivity/';

%%

for s = 1:length(sub_Folderpath)
    
    display(sub_Folderpath(s).name);

    connectivity_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*avref_connectivity.mat']);
    load([Folderpath,sub_Folderpath(s).name,filesep,connectivity_file(1).name]);
       
    for cond = 1:8
       
       for band1 = 1:4
           
           for band2 = 1:4
               
           %% PLV
           
           PLV_on_tmp = PLV.on.band1{band1}.band2{band2}.cond{cond};
           PLV_off_tmp = PLV.off.band1{band1}.band2{band2}.cond{cond};
           
           PLV_on_tmp(isnan(PLV_on_tmp)) = 0;
           PLV_on_tmp_mirrored = PLV_on_tmp + PLV_on_tmp';
           for i = 1:size(PLV_on_tmp_mirrored,1)
               PLV_on_tmp_mirrored(i,i) = 1;
           end
           
           PLV_off_tmp(isnan(PLV_off_tmp)) = 0;
           PLV_off_tmp_mirrored = PLV_off_tmp + PLV_off_tmp';
           for i = 1:size(PLV_off_tmp_mirrored,1)
               PLV_off_tmp_mirrored(i,i) = 1;
           end
                    
           PLV_on.band1{band1}.band2{band2}.cond{cond}(:,:,s) = PLV_on_tmp_mirrored;
           PLV_off.band1{band1}.band2{band2}.cond{cond}(:,:,s) = PLV_off_tmp_mirrored;
           
           clear PLV_on_tmp PLV_on_tmp_mirrored PLV_off_tmp PLV_off_tmp_mirrored
           
           %%   PLV phasic         
           PLV_on_tmp = PLV_phasic.on.band1{band1}.band2{band2}.cond{cond};
           PLV_off_tmp = PLV_phasic.off.band1{band1}.band2{band2}.cond{cond};
           
           PLV_on_tmp(isnan(PLV_on_tmp)) = 0;
           PLV_on_tmp_mirrored = PLV_on_tmp + PLV_on_tmp';
           for i = 1:size(PLV_on_tmp_mirrored,1)
               PLV_on_tmp_mirrored(i,i) = 1;
           end
           
           PLV_off_tmp(isnan(PLV_off_tmp)) = 0;
           PLV_off_tmp_mirrored = PLV_off_tmp + PLV_off_tmp';
           for i = 1:size(PLV_off_tmp_mirrored,1)
               PLV_off_tmp_mirrored(i,i) = 1;
           end
                    
           PLV_on_phasic.band1{band1}.band2{band2}.cond{cond}(:,:,s) = PLV_on_tmp_mirrored;
           PLV_off_phasic.band1{band1}.band2{band2}.cond{cond}(:,:,s) = PLV_off_tmp_mirrored;
           
           clear PLV_on_tmp PLV_on_tmp_mirrored PLV_off_tmp PLV_off_tmp_mirrored
           
           
           %%   PLV tonic       
           PLV_on_tmp = PLV_tonic.on.band1{band1}.band2{band2}.cond{cond};
           PLV_off_tmp = PLV_tonic.off.band1{band1}.band2{band2}.cond{cond};
           
           PLV_on_tmp(isnan(PLV_on_tmp)) = 0;
           PLV_on_tmp_mirrored = PLV_on_tmp + PLV_on_tmp';
           for i = 1:size(PLV_on_tmp_mirrored,1)
               PLV_on_tmp_mirrored(i,i) = 1;
           end
           
           PLV_off_tmp(isnan(PLV_off_tmp)) = 0;
           PLV_off_tmp_mirrored = PLV_off_tmp + PLV_off_tmp';
           for i = 1:size(PLV_off_tmp_mirrored,1)
               PLV_off_tmp_mirrored(i,i) = 1;
           end
                    
           PLV_on_tonic.band1{band1}.band2{band2}.cond{cond}(:,:,s) = PLV_on_tmp_mirrored;
           PLV_off_tonic.band1{band1}.band2{band2}.cond{cond}(:,:,s) = PLV_off_tmp_mirrored;
           
           clear PLV_on_tmp PLV_on_tmp_mirrored PLV_off_tmp PLV_off_tmp_mirrored
           
           
            %% PLI
           
           PLI_on_tmp = PLI.on.band1{band1}.band2{band2}.cond{cond};
           PLI_off_tmp = PLI.off.band1{band1}.band2{band2}.cond{cond};
           
           PLI_on_tmp(isnan(PLI_on_tmp)) = 0;
           PLI_on_tmp_mirrored = PLI_on_tmp + PLI_on_tmp';
           for i = 1:size(PLI_on_tmp_mirrored,1)
               PLI_on_tmp_mirrored(i,i) = 1;
           end
           
           PLI_off_tmp(isnan(PLI_off_tmp)) = 0;
           PLI_off_tmp_mirrored = PLI_off_tmp + PLI_off_tmp';
           for i = 1:size(PLI_off_tmp_mirrored,1)
               PLI_off_tmp_mirrored(i,i) = 1;
           end
                    
           PLI_on.band1{band1}.band2{band2}.cond{cond}(:,:,s) = PLI_on_tmp_mirrored;
           PLI_off.band1{band1}.band2{band2}.cond{cond}(:,:,s) = PLI_off_tmp_mirrored;
           
           clear PLI_on_tmp PLI_on_tmp_mirrored PLI_off_tmp PLI_off_tmp_mirrored
           
            %% PLI phasic
           
           PLI_on_tmp = PLI_phasic.on.band1{band1}.band2{band2}.cond{cond};
           PLI_off_tmp = PLI_phasic.off.band1{band1}.band2{band2}.cond{cond};
           
           PLI_on_tmp(isnan(PLI_on_tmp)) = 0;
           PLI_on_tmp_mirrored = PLI_on_tmp + PLI_on_tmp';
           for i = 1:size(PLI_on_tmp_mirrored,1)
               PLI_on_tmp_mirrored(i,i) = 1;
           end
           
           PLI_off_tmp(isnan(PLI_off_tmp)) = 0;
           PLI_off_tmp_mirrored = PLI_off_tmp + PLI_off_tmp';
           for i = 1:size(PLI_off_tmp_mirrored,1)
               PLI_off_tmp_mirrored(i,i) = 1;
           end
                    
           PLI_on_phasic.band1{band1}.band2{band2}.cond{cond}(:,:,s) = PLI_on_tmp_mirrored;
           PLI_off_phasic.band1{band1}.band2{band2}.cond{cond}(:,:,s) = PLI_off_tmp_mirrored;
           
           clear PLI_on_tmp PLI_on_tmp_mirrored PLI_off_tmp PLI_off_tmp_mirrored
           
             %% PLI tonic
           
           PLI_on_tmp = PLI_tonic.on.band1{band1}.band2{band2}.cond{cond};
           PLI_off_tmp = PLI_tonic.off.band1{band1}.band2{band2}.cond{cond};
           
           PLI_on_tmp(isnan(PLI_on_tmp)) = 0;
           PLI_on_tmp_mirrored = PLI_on_tmp + PLI_on_tmp';
           for i = 1:size(PLI_on_tmp_mirrored,1)
               PLI_on_tmp_mirrored(i,i) = 1;
           end
           
           PLI_off_tmp(isnan(PLI_off_tmp)) = 0;
           PLI_off_tmp_mirrored = PLI_off_tmp + PLI_off_tmp';
           for i = 1:size(PLI_off_tmp_mirrored,1)
               PLI_off_tmp_mirrored(i,i) = 1;
           end
                    
           PLI_on_tonic.band1{band1}.band2{band2}.cond{cond}(:,:,s) = PLI_on_tmp_mirrored;
           PLI_off_tonic.band1{band1}.band2{band2}.cond{cond}(:,:,s) = PLI_off_tmp_mirrored;
           
           clear PLI_on_tmp PLI_on_tmp_mirrored PLI_off_tmp PLI_off_tmp_mirrored
           
           
           %%
           end

           
                      
       end
   
    end
   
   clear PLV PLI PLV_phasic PLV_tonic PLI_phasic PLI_tonic
        
end

%%

save([Savefolder,'connectivity_allsub_',date,'.mat']);

