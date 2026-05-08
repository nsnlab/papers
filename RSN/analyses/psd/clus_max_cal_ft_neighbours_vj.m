
function [clus_max_size q WhichCh_1 WhichCh_2 WhichCh_3 WhichCh_4 WhichCh_5]=clus_max_cal_ft_neighbours_vj(EventCh,neighbours)
%clear all;close all;
%% Nachbarelektroden einlesen
% to test function vj
%    EventCh = EventChmax2;

WhichCh_1 = [];
WhichCh_2 = [];
WhichCh_3 = [];
WhichCh_4 = [];
WhichCh_5 = [];

% load('D:\Matlab\toolboxen\SnPM_Scripts\NEIGHBOURS_256_egiTEMPLATE.mat');

% neighbours = neighbours(4:259); 

allch_labels = {neighbours.label};

for ch=1:128
    q=neighbours(ch).neighblabel;

    for el=1:length(q)
        k=cell2mat(neighbours(ch).neighblabel(el));
        el_number = find(strcmp(k,allch_labels)==1);
        
        if ~isempty(el_number)
        NeighbourEl(ch,el) = el_number;
        end
        clear k
    end
    clear q
end

NeighbourEl(NeighbourEl==0)=NaN;
clear ch el neighbours

%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    q = [];
    
             if ~isempty(EventCh)

             %% Einzelelektroden rausnehmen
             AllNeighbours = NeighbourEl(EventCh,:);
             EventCh(sum(ismember(AllNeighbours,EventCh),2)==0)=[];
             if ~isempty(EventCh)       
             %% Klustergrösse bestimmen
             RestEl=EventCh; %Eventchan=channels with r value bigger than xy
             q=0;

             while ~isempty(RestEl)
                 Ch_Kluster=[];
                 k=[];
                 q=1+q;
                 clear RestEl;
                 nrCh=0;
                 ch=1;
                     k=[k,NeighbourEl(EventCh(ch),:)];
                     while sum(ismember(EventCh,k))>0
                         [c,ik,iEventCh]=intersect(k,EventCh);
                         nrCh=nrCh+length(c);
                         Ch_Kluster=horzcat(Ch_Kluster,EventCh(iEventCh));
                         EventCh(iEventCh)=[];
                         for ii=1:length(c)
                             k=[k,NeighbourEl(c(ii),:)];
                         end
                         k=unique(k); 
                         clear c ik iEventCh
                     end

                     RestEl=EventCh;
                     eval(['nrCh_',num2str(q),'=nrCh',';'])
                     eval(['WhichCh_',num2str(q),'=Ch_Kluster',';'])
                     clear nrCh k Ch_Kluster;
             end

             

         
             clear size_tot
             for n=1:q
                 eval(['MaxKluster(n,:)=nrCh_',num2str(n),';'])
              end

             KlusterSize_max=max(MaxKluster);
             KlusterSize_mean=nanmean(MaxKluster);
             %KlusterSize(g)=sum(MaxKluster);

   
      

             
             clear MaxKluster nrCh_* findgood EventCh RestEl AmpKluster AmpKluster_max_ndx ChAmpKluster_max nrAmp*  

             else KlusterSize_max=1;
                  KlusterSize_mean=1;
               
                 clear findgood EventCh
             end
             else KlusterSize_max=0;
                 KlusterSize_mean=0;
                 clear findgood EventCh
             end
             
             clus_max_size=KlusterSize_max;
end
 