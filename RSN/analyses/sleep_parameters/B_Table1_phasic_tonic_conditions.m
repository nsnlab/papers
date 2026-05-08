clear all;
close all;

addpath(genpath('/user/HS301/m17462/matlab/eeglab'));
addpath(genpath('/user/HS301/m17462/matlab/Scripts/RSN'));

addpath(genpath('/user/HS301/m17462/matlab/Henry/useful_functions'));

Folderpath = '/vol/research/nemo/datasets/RSN/data/hdEEG/';
sub_Folderpath = dir([Folderpath,'RSN*']);

conditions = {'Peak'; 'Falling'; 'Trough'; 'Rising';
    'Peak'; 'Falling'; 'Trough'; 'Rising';}

colors = linspecer(4);

Savefolder = '/vol/research/nemo/datasets/RSN/data/analysis/sleep_parameters/';

%%

for s = 1:length(sub_Folderpath)
    
nm_good_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*sleep*_nm_good.mat']);
goodREM_file = dir([Folderpath,sub_Folderpath(s).name,filesep,'*_czref_goodREM.mat']);

load([Folderpath,sub_Folderpath(s).name,filesep,nm_good_file(1).name]);
load([Folderpath,sub_Folderpath(s).name,filesep,goodREM_file(1).name]);

rem_ndx = find(hypno4 == 'R');

phasic_ndx = find(phasic_ep == 1);
tonic_ndx = find(tonic_ep == 1);

phasic_n = length(phasic_ndx);
tonic_n = length(tonic_ndx);

rem_n = length(rem_ndx);
per_phasic(s) = phasic_n/(phasic_n+tonic_n)*100;
per_tonic(s) = tonic_n/(phasic_n+tonic_n)*100;

art_ndx = find(art_ep == 1);
art_n = length(art_ndx);

per_art(s) = art_n/rem_n*100;

% total_per = per_art + per_phasic + per_tonic

ON_start = nm.ON_start_good;

phasic_tonic = zeros(1,length(hypno4));
phasic_tonic(phasic_ndx) = 1;
phasic_tonic(tonic_ndx) = 2;

for c = 1:8

    trials = ON_start{c};
    trials_sec = floor(trials/fs);
    
%     off_phasic_all = NaN(1,length(trials_sec));
%     off_tonic_all = NaN(1,length(trials_sec));
%     on_phasic_all = NaN(1,length(trials_sec));
%     on_tonic_all = NaN(1,length(trials_sec));
    
    off_all = NaN(1,length(trials_sec));
    on_all = NaN(1,length(trials_sec));
         
    
    if ~isempty(trials_sec)

        for t = 1:length(trials_sec)
            
            offon_art = find(phasic_tonic(trials_sec(t)-5:trials_sec(t)+5)==0);
            
            if isempty(offon_art)
            
            off = phasic_tonic(trials_sec(t)-5:trials_sec(t)-1);
            off_phasic_n = length(find(off == 1));
            off_tonic_n = length(find(off == 2));
            off_perc_phasic = off_phasic_n/(off_phasic_n+ off_tonic_n)*100;
%             off_phasic_all(t) = off_phasic_n;
%             off_tonic_all(t) = off_tonic_n;
            
            on = phasic_tonic(trials_sec(t)+1:trials_sec(t)+5);
            on_phasic_n = length(find(on == 1));
            on_tonic_n = length(find(on == 2));
            on_perc_phasic = on_phasic_n/(on_phasic_n+ on_tonic_n)*100;
%             on_phasic_all(t) = on_phasic_n;
%             on_tonic_all(t) = on_tonic_n;
            
            off_all(t) = off_perc_phasic;
            on_all(t) = on_perc_phasic;
            
            end
            
            clear off_perc_phasic on_perc_phasic
            
        end
        
    end
    
        
%        if ~isequal(round(nansum(off_phasic_all)/(nansum(off_phasic_all)+nansum(off_tonic_all))*100,2),round(nanmean(off_all),2))
%           keyboard
%        end
    
        
%         per_all_off_phasic(s,c) = nansum(off_phasic_all)/(nansum(off_phasic_all)+nansum(off_tonic_all))*100;
%         per_all_on_phasic(s,c) = nansum(on_phasic_all)/(nansum(on_phasic_all)+nansum(on_tonic_all))*100;
        
        m_off_trials_cond(s,c) = nanmean(off_all);
        m_on_trials_cond(s,c) = nanmean(on_all);
        
    
        clear m_on_trials m_off_trials  off_all on_all off_phasic_all off_tonic_all trials trials_sec
        
end

clear rem_ndx phasic_ndx tonic_ndx phasic_n tonic_n rem_n phasic_tonic ON_start

end


%% ttest comparing phasic differences before and after stimulation

incl_sub = setdiff(1:19,12);
m_per_phasic = nanmean(per_phasic(incl_sub));
m_per_tonic = nanmean(per_tonic(incl_sub));

sd_per_phasic = nanstd(per_phasic(incl_sub));
sd_per_tonic = nanstd(per_tonic(incl_sub));

phasic_tonic_per_table = table(vertcat(m_per_phasic,m_per_tonic),vertcat(sd_per_phasic,sd_per_tonic),'VariableNames',{'Mean' 'SD'});
writetable(phasic_tonic_per_table,[Savefolder,'phasic_tonic_percentages.xlsx']);


clear h p ci stats

diff_on_off_trials = m_on_trials_cond - m_off_trials_cond;

m_diff_on_off_trials = nanmean(diff_on_off_trials(incl_sub,:),1);
sd_diff_on_off_trials = nanstd(diff_on_off_trials(incl_sub,:),1);


for c = 1:8
    
[h(c) p(c) ci{c} stats{c}] = ttest(diff_on_off_trials(incl_sub,c));
% [h(c) p(c) ci{c} stats{c}] = ttest(m_on_trials_cond(incl_sub,c),m_off_trials_cond(incl_sub,c));

end


% for c = 1:8
%     
% [h_all(c) p_all(c) ci_all{c} stats_all{c}] = ttest(per_all_on_phasic(incl_sub,c),per_all_off_phasic(incl_sub,c));
% 
% end


%% alpha plots - mean % phasic activity across on and off trials

% 
% fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
% violins = violinPlot(m_on_trials_cond(incl_sub,1:4));
% ylabel('on phasic (%)');
% xticklabels(conditions(1:4));
% xtickangle(45);
% set(gca,'Fontsize',35);
% box on
% axis square
% ylim([0 35])
% 
%   for cond = 1:4
%       violins(cond).ViolinColor = colors(cond,:); 
%       violins(cond).ShowMean = 1;
%       violins(cond).ShowData = 1;
%   end
%   
% saveas(fig,[Savefolder,'on_phasic_perc_alpha.svg']);


% fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
% violins = violinPlot(m_off_trials_cond(incl_sub,1:4));
% ylabel('off phasic (%)');
% xticklabels(conditions(1:4));
% xtickangle(45);
% set(gca,'Fontsize',35);
% box on
% axis square
% ylim([0 35])
% 
%   for cond = 1:4
%       violins(cond).ViolinColor = colors(cond,:); 
%       violins(cond).ShowMean = 1;
%       violins(cond).ShowData = 1;
%   end
%   
% saveas(fig,[Savefolder,'off_phasic_perc_alpha.svg']);


% fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
% violins = violinPlot(diff_on_off_trials(incl_sub,1:4));
% ylabel('% change on vs off (%)');
% xticklabels(conditions(1:4));
% xtickangle(45);
% set(gca,'Fontsize',35);
% box on
% axis square
% 
%   for cond = 1:4
%       violins(cond).ViolinColor = colors(cond,:); 
%       violins(cond).ShowMean = 1;
%       violins(cond).ShowData = 1;
%   end
% 
% saveas(fig,[Savefolder,'onoff_diff_perc_alpha.svg']);

%% theta plots - mean % phasic activity across on and off trials

% fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
% violins = violinPlot(m_on_trials_cond(incl_sub,5:8));
% ylabel('on phasic (%)');
% xticklabels(conditions(5:8));
% xtickangle(45);
% set(gca,'Fontsize',35);
% box on
% axis square
% ylim([0 35])
% 
%   for cond = 1:4
%       violins(cond).ViolinColor = colors(cond,:); 
%       violins(cond).ShowMean = 1;
%       violins(cond).ShowData = 1;
%   end
%   
% saveas(fig,[Savefolder,'on_phasic_perc_theta.svg']);
% 
% 
% fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
% violins = violinPlot(m_off_trials_cond(incl_sub,5:8));
% ylabel('off phasic (%)');
% xticklabels(conditions(5:8));
% xtickangle(45);
% set(gca,'Fontsize',35);
% box on
% axis square
% ylim([0 35])
% 
%   for cond = 1:4
%       violins(cond).ViolinColor = colors(cond,:); 
%       violins(cond).ShowMean = 1;
%       violins(cond).ShowData = 1;
%   end
%   
% saveas(fig,[Savefolder,'off_phasic_perc_theta.svg']);
% 
% 
% diff_on_off_trials = m_on_trials_cond-m_off_trials_cond;
% 
% fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])
% violins = violinPlot(diff_on_off_trials(:,5:8));
% ylabel('% change on vs off (%)');
% xticklabels(conditions(5:8));
% xtickangle(45);
% set(gca,'Fontsize',35);
% box on
% axis square
% ylim([-15 20])
% 
%   for cond = 1:4
%       violins(cond).ViolinColor = colors(cond,:); 
%       violins(cond).ShowMean = 1;
%       violins(cond).ShowData = 1;
%   end
% 
% saveas(fig,[Savefolder,'onoff_diff_perc_theta.svg']);

%% 

% % alpha stim
% phasictonic_diff_all_alpha = vertcat(diff_on_off_trials(incl_sub,1),diff_on_off_trials(incl_sub,2),diff_on_off_trials(incl_sub,3),diff_on_off_trials(incl_sub,4));  
% cond_all = vertcat(repmat(1,length(incl_sub),1),repmat(2,length(incl_sub),1),repmat(3,length(incl_sub),1),repmat(4,length(incl_sub),1));  
% sub_all = vertcat(incl_sub',incl_sub',incl_sub',incl_sub');
% table_diff_alpha = table(phasictonic_diff_all_alpha,cond_all,sub_all,'VariableNames',{'phasictonic_diff_all','condition','sub'});
% table_diff_alpha.condition = categorical(table_diff_alpha.condition);
% table_diff_alpha.sub = categorical(table_diff_alpha.sub);
% lme_diff_alpha = fitlme(table_diff_alpha,'phasictonic_diff_all ~ condition +(1|sub)','FitMethod','REML','DummyVarCoding','effects');
% anova(lme_diff_alpha)
% 
% 
% % theta stim
% phasictonic_diff_all_theta = vertcat(diff_on_off_trials(incl_sub,5),diff_on_off_trials(incl_sub,6),diff_on_off_trials(incl_sub,7),diff_on_off_trials(incl_sub,8));  
% cond_all = vertcat(repmat(1,length(incl_sub),1),repmat(2,length(incl_sub),1),repmat(3,length(incl_sub),1),repmat(4,length(incl_sub),1));  
% sub_all = vertcat(incl_sub',incl_sub',incl_sub',incl_sub');
% table_diff_theta = table(phasictonic_diff_all_theta,cond_all,sub_all,'VariableNames',{'phasictonic_diff_all','condition','sub'});
% table_diff_theta.condition = categorical(table_diff_theta.condition);
% table_diff_theta.sub = categorical(table_diff_theta.sub);
% lme_diff_theta = fitlme(table_diff_theta,'phasictonic_diff_all ~ condition +(1|sub)','FitMethod','REML','DummyVarCoding','effects');
% anova(lme_diff_theta)
% 
% 



