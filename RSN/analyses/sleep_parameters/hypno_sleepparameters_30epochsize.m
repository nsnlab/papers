function [nr,nr1,rem,tots,tot,waso,seff,sl,n2,n3,n1,nrwaso,sws]= hypno_sleepparameters_30epochsize(hypno) 


        indexsleepnr=find(hypno=='2' | hypno=='3')';
        indexsleep=find(hypno=='2' | hypno=='3' | hypno=='R')';
        indexsleep1=find(hypno=='1' | hypno=='2' | hypno=='3' | hypno=='R')';
        indexnr1=find(hypno=='1' | hypno=='2' | hypno=='3')';
        indexnr=find(hypno=='2' | hypno=='3')';
        indexsws=find(hypno=='3')';
        indexrem=find(hypno=='R')';
        indexw=find(hypno=='W')';
        index1=find(hypno=='1')';
        index2=find(hypno=='2')';
        index3=find(hypno=='3')';

        indexNotScor=find(hypno== ' ');
        indexScored=setdiff([1:length(hypno)],indexNotScor);
        totScored=length(indexScored)/2; % recording length (that is scored) in min

        indexwaso=find(hypno(indexsleep(1):length(hypno))=='W');
        diffindexwaso=diff(indexwaso);
        
        nrwaso=0;k=1;     % nrwaso = number of wake ups after sleep onset
        
        while  k<length(diffindexwaso)
            if diffindexwaso(k)~=1
                nrwaso=nrwaso+1;
                k=k+1;
            else 
                nrwaso=nrwaso+1;
                w=k;
              
                while w <= length(diffindexwaso) && diffindexwaso(w)==1 
                    w=w+1;
                end
                k=w;
            end
        end
                

        sl=(indexsleep(1)-1)/2;
        if length(indexrem)>0
            rl=(indexrem(1)-1)/2; % rem latency
        else
            rl=NaN;
        end
        
        nr=length(indexnr)/2;    
        nr1=length(indexnr1)/2;
        sws=length(indexsws)/2;
        rem=length(indexrem)/2;
        tots=length(indexsleep1)/2; % min in Non_REM+REM
        tot=length(hypno)/2; %länge visfiles total
        waso=length(indexwaso)/2;
        firstsleep=indexsleep1(1)/2;
        n2=length(index2)/2;
        n3=length(index3)/2;
        n1=length(index1)/2;
       
       seff=(100/totScored)*tots;
       
       
end