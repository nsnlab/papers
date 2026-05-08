function statsresult = SnPM_lmer_clus_def(u,table_allch,type,nch,neighbours)

% works for lmer, either for behavior or other EEG data
% u=num per
% table = contains all variables you want to incluse in lmer
% type= 'lmer'
% nch= num chan
% path= where plots will be safed
% CompName= name of plots/computation
% 
% adapted Angelina Maric 30.11.2015
% adapted Angelina Maric 27.6.16: permutation matrix for t-tests created the
% same way as for correlations (only 0-1 values for each subject)
% adapted Valeria Jaramillo 26.03.2021 for lmer

% to test function (vj)
% u = 10;
% type = 'categorical'; % categorical or continuous
% nch = 128;    
% path = 'I:\Data\EGI\files\statistics\SnPM\';
% CompName = 'test';

table_el1 = table_allch(table_allch.electrode == '1',:);
[uni_subject ndx_subject] = unique(table_el1.sub);
uni_table_el1 = table_el1(ndx_subject,:);
x1 = table_el1(find(table_el1.substage == '1'),:);
x2 = table_el1(find(table_el1.substage == '2'),:);

xx1 = table_el1(find(table_el1.condition == '1'),:);
xx2 = table_el1(find(table_el1.condition == '2'),:);
xx3 = table_el1(find(table_el1.condition == '3'),:);
xx4 = table_el1(find(table_el1.condition == '4'),:);

numsubjects=size(x1,1)+size(x2,1);
% Make a total data set
% total_data = vertcat(x1,x2); % changed Sas 201215
group_index = horzcat(ones(size(x1,1),1)', ones(size(x2,1),1)'*2);
condition_index = horzcat(ones(size(xx1,1),1)',ones(size(xx1,1),1)'*2, ones(size(xx1,1),1)'*3, ones(size(xx1,1),1)'*4);

rng('shuffle')

%% create Permutation Matrix for categorical variable 1 (substage)

% if strcmp(type,'categorical')==1
%    
%     if u > 2^(numsubjects)
%      u=2^(numsubjects); %maximal number of unique permutations
%     end
%  temp = zeros(u,numsubjects);
%  i = 1;
%  tic;
%  if u <= 2^(numsubjects)
%      while i<=u
%          foo = group_index(randperm(length(group_index))); % shuffle the group randomly changed SaS 201215
%          C = intersect(temp,foo,'rows');% check if this permutation is unique
%          if isempty(C)
%              temp(i,:) = foo;
%              i = i+1
%          end
%      end
%   toc;    
% %   temp(find(temp==2))=0;%replace 2 by 0
% % beta_stroke_max(1:length(u))=NaN;
% % beta_stroke_min(1:length(u))=NaN;
% % clus_max_size(1:length(u))=NaN;
% % clus_min_size(1:length(u))=NaN;
% %  
% end
% 
% end
% 
% temp_substage = temp;

if strcmp(type,'categorical')==1

    sub_table = table_el1(table_el1.sub == '1',:);
    numrows = size(sub_table,1);
    temp = NaN(size(uni_table_el1,1),u,numrows);

    for s = 1:size(uni_table_el1,1)
    sub_table = table_el1(table_el1.sub == num2str(s),:);
    numrows = size(sub_table,1);
    group_index = double(sub_table.substage)';
   
    i = 1;
    tic;
     while i<=u
         foo = group_index(randperm(length(group_index))); % shuffle the group randomly changed SaS 201215
%          C = intersect(temp,foo,'rows');% check if this permutation is unique
%          if isempty(C)
             temp(s,i,:) = foo;
             i = i+1;
%          end
     end
  toc;      

    end
 
end

temp_substage = temp;
clear temp

i = 1;
temp2 = NaN(u,numsubjects);

for j=1:u 

    substage_perm_allsub = [];
    
    for s = 1:size(uni_table_el1,1) 
        
         substage_perm = squeeze(temp_substage(s,j,:));
         substage_perm_allsub = vertcat(substage_perm_allsub,substage_perm);
          
    end   
    
     C = intersect(temp2, substage_perm_allsub','rows');% check if this permutation is unique
         if isempty(C)
             temp2(i,:) = substage_perm_allsub';
             i = i+1;
         end
    
end

temp2_substage = temp2;
clear temp2

%% create Permutation Matrix for categorical variable 2 (condition)

% if strcmp(type,'categorical')==1
%    
%     if u > 2^(numsubjects)
%      u=2^(numsubjects); %maximal number of unique permutations
%     end
%  temp = zeros(u,numsubjects);
%  i = 1;
%  tic;
%  if u <= 2^(numsubjects)
%      while i<=u
%          foo = condition_index(randperm(length(condition_index))); % shuffle the group randomly changed SaS 201215
%          C = intersect(temp,foo,'rows');% check if this permutation is unique
%          if isempty(C)
%              temp(i,:) = foo;
%              i = i+1
%          end
%      end
%   toc;    
% %   temp(find(temp==2))=0;%replace 2 by 0
% % beta_stroke_max(1:length(u))=NaN;
% % beta_stroke_min(1:length(u))=NaN;
% % clus_max_size(1:length(u))=NaN;
% % clus_min_size(1:length(u))=NaN;
% %  
% end
% 
% end
% 
% temp_condition = temp;

if strcmp(type,'categorical')==1

    sub_table = table_el1(table_el1.sub == '1',:);
    numrows = size(sub_table,1);
    temp = NaN(size(uni_table_el1,1),u,numrows);

    for s = 1:size(uni_table_el1,1)
    sub_table = table_el1(table_el1.sub == num2str(s),:);
    numrows = size(sub_table,1);
    group_index = double(sub_table.condition)';
   
    i = 1;
    tic;
     while i<=u
         foo = group_index(randperm(length(group_index))); % shuffle the group randomly changed SaS 201215
%          C = intersect(temp,foo,'rows');% check if this permutation is unique
%          if isempty(C)
             temp(s,i,:) = foo;
             i = i+1;
%          end
     end
  toc;      

    end
 
end

temp_condition = temp;
clear temp


i = 1;
temp2 = NaN(u,numsubjects);

for j=1:u 

    condition_perm_allsub = [];
    
    for s = 1:size(uni_table_el1,1) 
        
         condition_perm = squeeze(temp_condition(s,j,:));
         condition_perm_allsub = vertcat(condition_perm_allsub,condition_perm);
          
    end   
    
     C = intersect(temp2, condition_perm_allsub','rows');% check if this permutation is unique
         if isempty(C)
             temp2(i,:) = condition_perm_allsub';
             i = i+1;
         end
    
end

temp2_condition = temp2;
clear temp2


%% Make permutation tests across random samples

for j=1:u %size(temp_substage,1)%number of permutations
    
    display(['You are at permutation ', num2str(j)]);
    
%     if rem(j,10) == 0 
%         
%         text=['You are at permutation ', num2str(j)];
%         disp(text)
%    
%     end
    

% take Permutation Vector for t-test/u-test/lmer
%         a =logical(temp_substage(j,:));
%         b =logical(abs(temp_substage(j,:)-1));

    for ch=1:nch

%         if strcmp(type,'categorical')
            
%           table_el_perm = table_allch(table_allch.electrode == num2str(ch),:);
%           table_el_perm.substage = temp_substage(j,:)';
%           table_el_perm.condition = temp_condition(j,:)';
            

          table_el_perm_allsub = [];  
            
          for s = 1:size(uni_table_el1,1) 
              
             table_el_perm = table_allch(table_allch.electrode == num2str(ch),:);
             table_el_perm_sub =  table_el_perm(table_el_perm.sub == num2str(s),:);
             table_el_perm_allsub = vertcat(table_el_perm_allsub,table_el_perm_sub);
         
          end
          

          table_el_perm_allsub.substage = temp2_substage(j,:)';
          table_el_perm_allsub.condition = temp2_condition(j,:)';
          
%         end
        
        
%     end
     
    
%     allsub_table_substage(j,:) = table_el_perm_allsub.substage;
    
         
          table_el_perm_allsub.substage = categorical(table_el_perm_allsub.substage);
          table_el_perm_allsub.condition = categorical(table_el_perm_allsub.condition);
        
          lme = fitlme(table_el_perm_allsub,'power_change ~ substage * condition +(1|sub)','FitMethod','REML','DummyVarCoding','effects');

%           [beta,betanames,stats] = fixedEffects(lme);
%           
%            beta_stroke(ch) = beta(2); 
%            pvalue_stroke(ch) = stats.pValue(2); 

          stats = anova(lme);
          
          Fvalue_substage(ch) = stats.FStat(2); 
          Fvalue_condition(ch) = stats.FStat(3); 
          Fvalue_substage_condition(ch) = stats.FStat(4);
          
          pvalue_substage(ch) = stats.pValue(2); 
          pvalue_condition(ch) = stats.pValue(3); 
          pvalue_substage_condition(ch) = stats.pValue(4);
    
           
%            clear beta betanames stats
        clear stats
        end

            
%         else
%           disp('error testtype')
%               
%         end
        

    F_substage_max(j)=max(Fvalue_substage);
    F_substage_min(j)=min(Fvalue_substage);
    
    F_condition_max(j)=max(Fvalue_condition);
    F_condition_min(j)=min(Fvalue_condition);
    
    F_substage_condition_max(j)=max(Fvalue_substage_condition);
    F_substage_condition_min(j)=min(Fvalue_substage_condition);
    
    ndxokt=isfinite(Fvalue_substage);
    
%     excludech = [247 251 256 91 102 111 120 133 145 165 174 187 199 208 216 229 233 237 ...
%     243 246 250 255 82 92 103 112 121 134 146 156 166 175 188 200 209 217 228 232 236 240 ...
%     242 245 249 254 73 93 104 113 122 135 147 157 167 176 189 201 218 227 231 235 239];

    EventChmax2=find(pvalue_substage < 0.05);
%     EventChmax2=setdiff(EventChmax,excludech);
    max_Ch = find(Fvalue_substage > 0);
    EventChmax3 = intersect(EventChmax2,max_Ch);
    clus_max_size_substage(j) = clus_max_cal_ft_neighbours_vj(EventChmax3,neighbours);
    
    EventChmax2=find(pvalue_condition < 0.05);
%     EventChmax2=setdiff(EventChmax,excludech);
    max_Ch = find(Fvalue_condition > 0);
    EventChmax3 = intersect(EventChmax2,max_Ch);
    clus_max_size_condition(j) = clus_max_cal_ft_neighbours_vj(EventChmax3,neighbours);
    
    EventChmax2=find(pvalue_substage_condition < 0.05);
%     EventChmax2=setdiff(EventChmax,excludech);
    max_Ch = find(Fvalue_substage_condition > 0);
    EventChmax3 = intersect(EventChmax2,max_Ch);
    clus_max_size_substage_condition(j) = clus_max_cal_ft_neighbours_vj(EventChmax3,neighbours);

    EventChmin2=find(pvalue_substage < 0.05);
%     EventChmin2=setdiff(EventChmax,excludech);   
    min_Ch = find(Fvalue_substage < 0);
    EventChmin3 = intersect(EventChmin2,min_Ch);
    clus_min_size_substage(j)= clus_max_cal_ft_neighbours_vj(EventChmin3,neighbours);
    
    
    EventChmin2=find(pvalue_condition < 0.05);
%     EventChmin2=setdiff(EventChmax,excludech);   
    min_Ch = find(Fvalue_condition < 0);
    EventChmin3 = intersect(EventChmin2,min_Ch);
    clus_min_size_condition(j)= clus_max_cal_ft_neighbours_vj(EventChmin3,neighbours);
    
    EventChmin2=find(pvalue_substage_condition < 0.05);
%     EventChmin2=setdiff(EventChmax,excludech);   
    min_Ch = find(Fvalue_substage_condition < 0);
    EventChmin3 = intersect(EventChmin2,min_Ch);
    clus_min_size_substage_condition(j)= clus_max_cal_ft_neighbours_vj(EventChmin3,neighbours);
    

    clear EventChmax* EventChmin* beta_stroke pvalue_stroke a b
    %%%%plot this to get an impression of the data or do the cluster test, i.e. count neighbouring electrodes
%     if t(j)>3 
%        tch(tch<3)=0;
%        figure
%        matnetneu(ndxokt);
%        topoplot(tch(ndxokt),'e:\wispic\human\matlab\test.txt','electrodes','labels','maplimits',[-7,7]);
%        colorbar
%        title(num2str(j))
%        pause
%     end
        
end

%% Calculate thresholds

p95_substage = prctile(F_substage_max,95);
p97_5_substage = prctile(F_substage_max,97.5);
p90_substage = prctile(F_substage_max,90);

p95_condition = prctile(F_condition_max,95);
p97_5_condition = prctile(F_condition_max,97.5);
p90_condition = prctile(F_condition_max,90);

p95_substage_condition = prctile(F_substage_condition_max,95);
p97_5_substage_condition = prctile(F_substage_condition_max,97.5);
p90_substage_condition = prctile(F_substage_condition_max,90);

p97_5_clus_substage = prctile(clus_max_size_substage,97.5);
p95_clus_substage = prctile(clus_max_size_substage,95);
p90_clus_substage = prctile(clus_max_size_substage,90);

p97_5_clus_condition = prctile(clus_max_size_condition,97.5);
p95_clus_condition = prctile(clus_max_size_condition,95);
p90_clus_condition = prctile(clus_max_size_condition,90);

p97_5_clus_substage_condition = prctile(clus_max_size_substage_condition,97.5);
p95_clus_substage_condition = prctile(clus_max_size_substage_condition,95);
p90_clus_substage_condition = prctile(clus_max_size_substage_condition,90);

p2_5_substage = prctile(F_substage_min,2.5);
p5_substage = prctile(F_substage_min,5);
p10_substage = prctile(F_substage_min,10);

p2_5_condition = prctile(F_condition_min,2.5);
p5_condition = prctile(F_condition_min,5);
p10_condition = prctile(F_condition_min,10);

p2_5_substage_condition = prctile(F_substage_condition_min,2.5);
p5_substage_condition = prctile(F_substage_condition_min,5);
p10_substage_condition = prctile(F_substage_condition_min,10);

p97_5_clus_min_substage = prctile(clus_min_size_substage,97.5);
p95_clus_min_substage = prctile(clus_min_size_substage,95);
p90_clus_min_substage = prctile(clus_min_size_substage,90);

p97_5_clus_min_condition = prctile(clus_min_size_condition,97.5);
p95_clus_min_condition = prctile(clus_min_size_condition,95);
p90_clus_min_condition = prctile(clus_min_size_condition,90);

p97_5_clus_min_substage_condition = prctile(clus_min_size_substage_condition,97.5);
p95_clus_min_substage_condition = prctile(clus_min_size_substage_condition,95);
p90_clus_min_substage_condition = prctile(clus_min_size_substage_condition,90);

%% Real sample
% au=logical(ones(1,numsubjects));
% bu=logical(zeros(1,numsubjects));
for ch=1:nch
    
    if strcmp(type,'categorical')
        
       table_el = table_allch(table_allch.electrode == num2str(ch),:);
%        table_el_perm.stroke = au';
        
        lme = fitlme(table_el,'power_change ~ substage * condition +(1|sub)','FitMethod','REML','DummyVarCoding','effects');

%        [beta,betanames,stats] = fixedEffects(lme);
%           
%         beta_stroke(ch) = beta(2); 
%         pvalue_stroke(ch) = stats.pValue(2); 

          stats = anova(lme);
          
          Fvalue_substage(ch) = stats.FStat(2); 
          Fvalue_condition(ch) = stats.FStat(3); 
          Fvalue_substage_condition(ch) = stats.FStat(4);
          
          pvalue_substage(ch) = stats.pValue(2); 
          pvalue_condition(ch) = stats.pValue(3); 
          pvalue_substage_condition(ch) = stats.pValue(4);
           
    else
      disp('error testtype')
    end
end

%% Calculate beta and clus size for real sample

% excludech = [247 251 256 91 102 111 120 133 145 165 174 187 199 208 216 229 233 237 ...
% 243 246 250 255 82 92 103 112 121 134 146 156 166 175 188 200 209 217 228 232 236 240 ...
% 242 245 249 254 73 93 104 113 122 135 147 157 167 176 189 201 218 227 231 235 239];

[F_substage_max_real x]=max(Fvalue_substage);
[F_substage_min_real x]=min(Fvalue_substage);

[F_condition_max_real x]=max(Fvalue_condition);
[F_condition_min_real x]=min(Fvalue_condition);

[F_substage_condition_max_real x]=max(Fvalue_substage_condition);
[F_substage_condition_min_real x]=min(Fvalue_substage_condition);

clear EventChmax EventChmin

EventChmax2=find(pvalue_substage < 0.05);
%     EventChmax2=setdiff(EventChmax,excludech);
max_Ch = find(Fvalue_substage > 0);
EventChmax3 = intersect(EventChmax2,max_Ch);
[clus_max_substage q WhichCh_1_max_substage WhichCh_2_max_substage WhichCh_3_max_substage WhichCh_4_max_substage WhichCh_5_max_substage]= clus_max_cal_ft_neighbours_vj(EventChmax3,neighbours);

EventChmax2=find(pvalue_condition < 0.05);
%     EventChmax2=setdiff(EventChmax,excludech);
max_Ch = find(Fvalue_condition > 0);
EventChmax3 = intersect(EventChmax2,max_Ch);
[clus_max_condition q WhichCh_1_max_condition WhichCh_2_max_condition WhichCh_3_max_condition WhichCh_4_max_condition WhichCh_5_max_condition]= clus_max_cal_ft_neighbours_vj(EventChmax3,neighbours);

EventChmax2=find(pvalue_substage_condition < 0.05);
%     EventChmax2=setdiff(EventChmax,excludech);
max_Ch = find(Fvalue_substage_condition > 0);
EventChmax3 = intersect(EventChmax2,max_Ch);
[clus_max_substage_condition q WhichCh_1_max_substage_condition WhichCh_2_max_substage_condition WhichCh_3_max_substage_condition WhichCh_4_max_substage_condition WhichCh_5_max_substage_condition]= clus_max_cal_ft_neighbours_vj(EventChmax3,neighbours);


EventChmin2=find(pvalue_substage < 0.05);
%     EventChmin2=setdiff(EventChmax,excludech);   
min_Ch = find(Fvalue_substage < 0);
EventChmin3 = intersect(EventChmin2,min_Ch);
[clus_min_substage q WhichCh_1_min_substage WhichCh_2_min_substage WhichCh_3_min_substage WhichCh_4_min_substage WhichCh_5_min_substage] = clus_max_cal_ft_neighbours_vj(EventChmin3,neighbours);


EventChmin2=find(pvalue_condition < 0.05);
%     EventChmin2=setdiff(EventChmax,excludech);   
min_Ch = find(Fvalue_condition < 0);
EventChmin3 = intersect(EventChmin2,min_Ch);
[clus_min_condition q WhichCh_1_min_condition WhichCh_2_min_condition WhichCh_3_min_condition WhichCh_4_min_condition WhichCh_5_min_condition] = clus_max_cal_ft_neighbours_vj(EventChmin3,neighbours);


EventChmin2=find(pvalue_substage_condition < 0.05);
%     EventChmin2=setdiff(EventChmax,excludech);   
min_Ch = find(Fvalue_substage_condition < 0);
EventChmin3 = intersect(EventChmin2,min_Ch);
[clus_min_substage_condition q WhichCh_1_min_substage_condition WhichCh_2_min_substage_condition WhichCh_3_min_substage_condition WhichCh_4_min_substage_condition WhichCh_5_min_substage_condition] = clus_max_cal_ft_neighbours_vj(EventChmin3,neighbours);

%% Figures
% figure
% hist(beta_stroke_max,256)
% hold on
% plot([p90 p90],[0 25],'m') %threshold
% hold on
% plot([p95 p95],[0 25],'r') %threshold
% hold on
% plot([p97_5 p97_5],[0 25],'c') %threshold
% hold on
% plot([beta_stroke_max_real beta_stroke_max_real],[0 25],'g') %real sample
% cd(path);
% outname1=[CompName,'_beta_max'];
% set(gcf, 'Position', get(0,'Screensize')); % Maximize figure. 
%     img = getframe(gcf);
%     imwrite(img.cdata, [outname1, '.png']);
% close all;
% 
% 
% figure
% hist(beta_stroke_min,256)
% hold on
% plot([p10 p10],[0 25],'m') %threshold
% hold on
% plot([p5 p5],[0 25],'r') %threshold
% hold on
% plot([p2_5 p2_5],[0 25],'c') %threshold
% hold on
% plot([beta_stroke_min_real beta_stroke_min_real],[0 25],'g') %real sample
% cd(path);
% outname2=[CompName,'_beta_min'];
% set(gcf, 'Position', get(0,'Screensize')); % Maximize figure. 
%     img = getframe(gcf);
%     imwrite(img.cdata, [outname2, '.png']);
% close all;
% 
% 
% 
% figure
% hist(clus_max_size,256)
% hold on
% plot([p90_clus p90_clus],[0 25],'m') %threshold
% hold on
% plot([p95_clus p95_clus],[0 25],'r') %threshold
% hold on
% plot([p97_5_clus p97_5_clus],[0 25],'c') %threshold
% hold on
% plot([clus_max clus_max],[0 25],'g') %real sample
% cd(path);
% outname3=[CompName,'_clus_max_size'];
% set(gcf, 'Position', get(0,'Screensize')); % Maximize figure. 
%     img = getframe(gcf);
%     imwrite(img.cdata, [outname3, '.png']);
% close all;
% 
% 
% figure
% hist(clus_min_size,256)
% hold on
% plot([p97_5_clus_min p97_5_clus_min],[0 25],'c') %threshold
% hold on
% plot([p95_clus_min p95_clus_min],[0 25],'m') %threshold
% hold on
% plot([p90_clus_min p90_clus_min],[0 25],'r') %threshold
% hold on
% plot([clus_min clus_min],[0 25],'g') %real sample
% cd(path);
% outname4=[CompName,'_clus_min_size'];
% set(gcf, 'Position', get(0,'Screensize')); % Maximize figure. 
%     img = getframe(gcf);
%     imwrite(img.cdata, [outname4, '.png']);
% close all;
 
 %% Statsresults
statsresult.Fvalue_substage = Fvalue_substage;
statsresult.pvalue_substage = pvalue_substage;
statsresult.Fvalue_substage_min = F_substage_min;

statsresult.Fvalue_condition = Fvalue_condition;
statsresult.pvalue_condition = pvalue_condition;
statsresult.Fvalue_condition_min = F_condition_min;

statsresult.Fvalue_substage_condition = Fvalue_substage_condition;
statsresult.pvalue_substage_condition = pvalue_substage_condition;
statsresult.Fvalue_substage_condition_min = F_substage_condition_min;

statsresult.cv = NaN;
statsresult.type = type;

statsresult.Fvalue_substage_max = F_substage_max;
statsresult.Fvalue_condition_max = F_condition_max;
statsresult.Fvalue_substage_condition_max = F_substage_condition_max;

statsresult.table_allch = table_allch;
statsresult.temp2_substage = temp2_substage;
statsresult.temp2_condition = temp2_condition;
statsresult.u = u;

statsresult.F_substage_min_real = F_substage_min_real;
statsresult.F_substage_max_real = F_substage_max_real;
statsresult.F_condition_min_real = F_condition_min_real;
statsresult.F_condition_max_real = F_condition_max_real;
statsresult.F_substage_condition_min_real = F_substage_condition_min_real;
statsresult.F_substage_condition_max_real = F_substage_condition_max_real;

statsresult.p97_5_substage = p97_5_substage;
statsresult.p95_substage = p95_substage;
statsresult.p90_substage = p90_substage;

statsresult.p97_5_condition = p97_5_condition;
statsresult.p95_condition = p95_condition;
statsresult.p90_condition = p90_condition;

statsresult.p97_5_substage_condition = p97_5_substage_condition;
statsresult.p95_substage_condition = p95_substage_condition;
statsresult.p90_substage_condition = p90_substage_condition;

statsresult.p2_5_substage = p2_5_substage;
statsresult.p5_substage = p5_substage;
statsresult.p10_substage = p10_substage;

statsresult.p2_5_condition = p2_5_condition;
statsresult.p5_condition = p5_condition;
statsresult.p10_condition = p10_condition;

statsresult.p2_5_substage_condition = p2_5_substage_condition;
statsresult.p5_substage_condition = p5_substage_condition;
statsresult.p10_substage_condition = p10_substage_condition;


statsresult.clus_min_size_substage = clus_min_size_substage;
statsresult.clus_max_size_substage = clus_max_size_substage;
statsresult.clus_min_substage = clus_min_substage;
statsresult.clus_max_substage = clus_max_substage;

statsresult.clus_min_size_condition = clus_min_size_condition;
statsresult.clus_max_size_condition = clus_max_size_condition;
statsresult.clus_min_condition = clus_min_condition;
statsresult.clus_max_condition = clus_max_condition;

statsresult.clus_min_size_substage_condition = clus_min_size_substage_condition;
statsresult.clus_max_size_substage_condition = clus_max_size_substage_condition;
statsresult.clus_min_substage_condition = clus_min_substage_condition;
statsresult.clus_max_substage_condition = clus_max_substage_condition;

statsresult.p90_clus_min_substage = p90_clus_min_substage;
statsresult.p95_clus_min_substage = p95_clus_min_substage;
statsresult.p97_5_clus_min_substage = p97_5_clus_min_substage;

statsresult.p90_clus_min_condition = p90_clus_min_condition;
statsresult.p95_clus_min_condition = p95_clus_min_condition;
statsresult.p97_5_clus_min_condition = p97_5_clus_min_condition;

statsresult.p90_clus_min_substage_condition = p90_clus_min_substage_condition;
statsresult.p95_clus_min_substage_condition = p95_clus_min_substage_condition;
statsresult.p97_5_clus_min_substage_condition = p97_5_clus_min_substage_condition;

statsresult.p90_clus_substage = p90_clus_substage;
statsresult.p95_clus_substage = p95_clus_substage;
statsresult.p97_5_clus_substage = p97_5_clus_substage;

statsresult.p90_clus_condition = p90_clus_condition;
statsresult.p95_clus_condition = p95_clus_condition;
statsresult.p97_5_clus_condition = p97_5_clus_condition;

statsresult.p90_clus_substage_condition = p90_clus_substage_condition;
statsresult.p95_clus_substage_condition = p95_clus_substage_condition;
statsresult.p97_5_clus_substage_condition = p97_5_clus_substage_condition;

statsresult.WhichCh_1_max_substage = WhichCh_1_max_substage;
statsresult.WhichCh_2_max_substage = WhichCh_2_max_substage;
statsresult.WhichCh_3_max_substage = WhichCh_3_max_substage;
statsresult.WhichCh_4_max_substage = WhichCh_4_max_substage;
statsresult.WhichCh_5_max_substage = WhichCh_5_max_substage;
statsresult.WhichCh_1_min_substage = WhichCh_1_min_substage;
statsresult.WhichCh_2_min_substage = WhichCh_2_min_substage;
statsresult.WhichCh_3_min_substage = WhichCh_3_min_substage;
statsresult.WhichCh_4_min_substage = WhichCh_4_min_substage;
statsresult.WhichCh_5_min_substage = WhichCh_5_min_substage;

statsresult.WhichCh_1_max_condition = WhichCh_1_max_condition;
statsresult.WhichCh_2_max_condition = WhichCh_2_max_condition;
statsresult.WhichCh_3_max_condition = WhichCh_3_max_condition;
statsresult.WhichCh_4_max_condition = WhichCh_4_max_condition;
statsresult.WhichCh_5_max_condition = WhichCh_5_max_condition;
statsresult.WhichCh_1_min_condition = WhichCh_1_min_condition;
statsresult.WhichCh_2_min_condition = WhichCh_2_min_condition;
statsresult.WhichCh_3_min_condition = WhichCh_3_min_condition;
statsresult.WhichCh_4_min_condition = WhichCh_4_min_condition;
statsresult.WhichCh_5_min_condition = WhichCh_5_min_condition;

statsresult.WhichCh_1_max_substage_condition = WhichCh_1_max_substage_condition;
statsresult.WhichCh_2_max_substage_condition = WhichCh_2_max_substage_condition;
statsresult.WhichCh_3_max_substage_condition = WhichCh_3_max_substage_condition;
statsresult.WhichCh_4_max_substage_condition = WhichCh_4_max_substage_condition;
statsresult.WhichCh_5_max_substage_condition = WhichCh_5_max_substage_condition;
statsresult.WhichCh_1_min_substage_condition = WhichCh_1_min_substage_condition;
statsresult.WhichCh_2_min_substage_condition = WhichCh_2_min_substage_condition;
statsresult.WhichCh_3_min_substage_condition = WhichCh_3_min_substage_condition;
statsresult.WhichCh_4_min_substage_condition = WhichCh_4_min_substage_condition;
statsresult.WhichCh_5_min_substage_condition = WhichCh_5_min_substage_condition;



end 