clear all;
close all;

addpath(genpath('F:\Valeria\m17462\bigdata\matlab\Henry\useful_functions')); % contains linspecer function, circular statistics toolbox functions, echt function, shadedErrorBar function, see README on where to find this

load('F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figure3B_ISI_echt_psd_allsub_14-Mar-2023');

incl_sub = setdiff(1:19,12);

colors = linspecer(4);

Savefolder = 'F:\Valeria\RSN\data\for_sharing\data_to_make_figures\Figures\';

%%

for s = 1:length(ISI_allsub)
    
    for con = 1:8
    
        ISI_subcon = ISI_allsub(s).con{con};
        ISI_freq = 1./ISI_subcon; 
        
        if length(ISI_freq)>= 20
            acf(s,con,:) = autocorr(ISI_freq,'NumLags',19);

        end
    
    end
    
end

%% Alpha
fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])

for con = 1:4
errorbar(1:20,squeeze(nanmean(acf(incl_sub,con,:),1)),squeeze(nanstd(acf(incl_sub,con,:),1)),'Color',colors(con,:),'LineWidth',2);
hold on
xlim([0 20]);
ylim([-0.2 1]);

end

xlabel('Lags');
ylabel('Autocorrelation');
set(gca,'Fontsize',35,'TickDir','out','LineWidth',3);
box off
axis square
xticks([0:5:20]);

% saveas(fig,[Savefolder,'Suppl_Figure3_ISI_autocorr_alphastim.svg']);


%% Theta
fig = figure('Renderer','painters','units','normalized','outerposition',[0 0 1 1])

for con = 5:8
errorbar(1:20,squeeze(nanmean(acf(incl_sub,con,:),1)),squeeze(nanstd(acf(incl_sub,con,:),1)),'Color',colors(con-4,:),'LineWidth',2);
hold on
xlim([0 20]);
ylim([-0.2 1]);

end

xlabel('Lags');
ylabel('Autocorrelation');
set(gca,'Fontsize',35,'TickDir','out','LineWidth',3);
box off
axis square
xticks([0:5:20]);

% saveas(fig,[Savefolder,'Suppl_Figure3_ISI_autocorr_thetastim.svg']);


