%% Example of batch code to preprocess multiple subjects
 
% Step 1: Change the option to use double precision.

clear all;
close all;

%% Define folders

Folderpath = '/vol/research/nemo/datasets/RSN/data/hdEEG/'; % with \ at the end
sub_Folderpath = dir([Folderpath,'RSN*']);

savefolder = '/vol/research/nemo/datasets/RSN/data/analysis/sleep_parameters/';

%%

for s = 1:length(sub_Folderpath)

hypnofile_dir = dir([Folderpath,sub_Folderpath(s).name,filesep,'*profile*.txt']);
        
fid1 = fopen([Folderpath,sub_Folderpath(s).name,filesep,hypnofile_dir(1).name]);
hypno = fscanf(fid1,'%s');
if hypno(1) ~= 'W' && hypno(1) ~= '1' && hypno(1) ~= '2' && hypno(1) ~= '3' && hypno(1) ~= 'R'
    hypno = hypno(2:end);
end


[nr(s,:),nr1(s,:),rem(s,:),tots(s,:),tot(s,:),waso(s,:),seff(s,:),sl(s,:),n2(s,:),n3(s,:),n1(s,:),nrwaso(s,:),sws(s,:)] = hypno_sleepparameters_30epochsize(hypno);

clear hypno hypno_8h

end       


%%
incl_sub = setdiff(1:19,12);

m_tot = nanmean(tot(incl_sub))/60;
sd_tot = nanstd(tot(incl_sub))/60;

m_seff = nanmean(seff(incl_sub));
sd_seff = nanstd(seff(incl_sub));

m_tots = nanmean(tots(incl_sub))/60;
sd_tots = nanstd(tots(incl_sub))/60;

m_sl = nanmean(sl(incl_sub));
sd_sl = nanstd(sl(incl_sub));

m_waso = nanmean(waso(incl_sub));
sd_waso = nanstd(waso(incl_sub));

m_nr = nanmean(nr1(incl_sub))/60;
sd_nr = nanstd(nr1(incl_sub))/60;

m_r = nanmean(rem(incl_sub))/60;
sd_r = nanstd(rem(incl_sub))/60;

m_perc_nr = (nanmean(nr1(incl_sub)./tots(incl_sub)))*100;
sd_perc_nr = (nanstd(nr1(incl_sub)./tots(incl_sub)))*100;

m_perc_r = (nanmean(rem(incl_sub)./tots(incl_sub)))*100;
sd_perc_r = (nanstd(rem(incl_sub)./tots(incl_sub)))*100;

sleep_parameters_table = table(vertcat(m_tots,m_sl,m_waso,m_seff,m_perc_nr,m_perc_r),...
    vertcat(sd_tots,sd_sl,sd_waso,sd_seff,sd_perc_nr,sd_perc_r));

% writetable(sleep_parameters_table,[savefolder,'sleep_parameters.xlsx']);
