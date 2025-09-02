function subjects_erd(subj_ids, condition, mu_range, baseline, time_window, subj_dir_ext)

if nargin<6
    subj_dir_ext='';
end

clusters(1).name='C3';
clusters(1).channels={'E30', 'E31', 'E36', 'E37', 'E41', 'E42', 'E53', 'E54'};
clusters(2).name='C4';
clusters(2).channels={'E79', 'E80', 'E86', 'E87', 'E93', 'E103', 'E104', 'E105'};
clusters(3).name='O1';
clusters(3).channels={'E69', 'E70', 'E73', 'E74'};
clusters(4).name='O2';
clusters(4).channels={'E83', 'E82', 'E89', 'E88'};

Y=[];
S=[];
F1=[];
F2=[];

for i=1:length(clusters)
    clusters(i).mu_erds=[];
    clusters(i).mu_mean_erds=[];
    for j=1:length(subj_ids)
        subj_id=subj_ids(j);
        data=pop_loadset(['/data/infant_face_eeg/preprocessed/' num2str(subj_id) subj_dir_ext '/' num2str(subj_id) '.' condition '.set']);
        [x times logfreqs]=std_ersp(data,'type','ersp','trialindices',[1:data.trials],'freqs', mu_range, 'nfreqs',10,'freqscale','linear','channels',clusters(i).channels,'baseline',baseline,'savefile','off');
        clusters(i).times=times;
        erd=(10.^(mean(x)/10)-1)*100;
        time_idx=intersect(find(times>=time_window(1)),find(times<=time_window(2)));        
        mean_erd=mean(erd(time_idx));
        Y(1,end+1)=mean_erd;
        S(1,end+1)=j;
        if strcmp(clusters(i).name,'C3') || strcmp(clusters(i).name,'C4')
            F1(1,end+1)=1;
        else
            F1(1,end+1)=2;
        end
        if strcmp(clusters(i).name,'C3') || strcmp(clusters(i).name,'O1')
            F2(1,end+1)=1;
        else
            F2(1,end+1)=2;
        end
        clusters(i).mu_erds(end+1,:)=erd;
        clusters(i).mu_mean_erds(j)=mean_erd;
    end
end

figure();
for i=1:length(clusters)
    idx=find(clusters(i).times>baseline(2));
    subplot(length(clusters)/2,2,i);
    shadedErrorBar(clusters(i).times(idx),mean(clusters(i).mu_erds(:,idx)),std(clusters(i).mu_erds(:,idx))/sqrt(length(subj_ids)),'b');
    xlim([baseline(2), clusters(i).times(end)]);
    xlabel('Time (ms)');
    ylabel(['Power - ' num2str(mu_range(1)) '-' num2str(mu_range(2)) 'Hz']);
    title(clusters(i).name);
end

figure();
for i=1:length(clusters)
    idx=find(clusters(i).times>baseline(2));
    legend_info={};
    subplot(length(clusters)/2,2,i);
    hold all;
    for j=1:length(subj_ids)
        plot(clusters(i).times(idx),clusters(i).mu_erds(j,idx));
        legend_info{j}=['subj ' num2str(subj_ids(j))];
    end
    legend(legend_info);
    hold off;
    xlim([baseline(2), clusters(i).times(end)]);
    xlabel('Time (ms)');
    ylabel(['Power - ' num2str(mu_range(1)) '-' num2str(mu_range(2)) 'Hz']);
    title(clusters(i).name);
end

figure();
cluster_means=[mean(clusters(1).mu_mean_erds) mean(clusters(2).mu_mean_erds); mean(clusters(3).mu_mean_erds) mean(clusters(4).mu_mean_erds)];
bar(cluster_means);
hold on;
means=[mean(clusters(1).mu_mean_erds) mean(clusters(2).mu_mean_erds) mean(clusters(3).mu_mean_erds) mean(clusters(4).mu_mean_erds)];
stderrs=[std(clusters(1).mu_mean_erds)/sqrt(length(subj_ids)) std(clusters(2).mu_mean_erds)/sqrt(length(subj_ids)) std(clusters(3).mu_mean_erds)/sqrt(length(subj_ids)) std(clusters(4).mu_mean_erds)/sqrt(length(subj_ids))];
errorbar([.86 1.14 1.86 2.14],means,stderrs,'ok');
hold off;
set(gca,'XTickLabel',{'central','occipital'})
legend('left','right');
title(condition);

rm_anova2(Y,S,F1,F2,{'region','hemisphere'})

for i=1:length(clusters)
    clusters(i).name
    [h,p]=ttest(clusters(i).mu_mean_erds)
end

