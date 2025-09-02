function [p,tbl,stats]=subjects_movement_erd(subj_ids, conditions, mu_range, freq_range, baseline, time_window, subj_dir_ext, file_ext)

clusters(1).name='C3';
clusters(1).channels={'E30', 'E31', 'E36', 'E37', 'E41', 'E42', 'E53', 'E54'};
clusters(2).name='C4';
clusters(2).channels={'E79', 'E80', 'E86', 'E87', 'E93', 'E103', 'E104', 'E105'};
clusters(3).name='O1';
clusters(3).channels={'E69', 'E70', 'E73', 'E74'};
clusters(4).name='O2';
clusters(4).channels={'E83', 'E82', 'E89', 'E88'};

trials_per_condition=zeros(length(conditions),length(subj_ids));

for i=1:length(clusters)
    clusters(i).mu_erds=dict;
    clusters(i).mu_mean_erds=dict;
    for k=1:length(conditions)
        mu_erds=[];
        mu_mean_erds=[];
        for j=1:length(subj_ids)
            subj_id=subj_ids(j);
            file_name=fullfile('/data/infant_face_eeg/preprocessed/', [num2str(subj_id) subj_dir_ext], [num2str(subj_id) '.' conditions{k}  file_ext '.set']);
            if exist(file_name,'file')
                data=pop_loadset(file_name);
                trials_per_condition(k,j)=data.trials;   
                if data.trials>=3
                    [times mu_erds(end+1,:) mu_mean_erds(end+1)]=cluster_erd(data, clusters(i).channels, mu_range, freq_range, baseline, time_window);
                end
            end
        end
        clusters(i).times=times;
        clusters(i).mu_erds(conditions{k})=mu_erds;
        clusters(i).mu_mean_erds(conditions{k})=mu_mean_erds;
    end
end

for condition_idx=1:length(conditions)
    condition=conditions{condition_idx};
    disp([condition ': ' num2str(min(trials_per_condition(condition_idx,:))) '-' num2str(max(trials_per_condition(condition_idx,:))) ', M=' num2str(mean(trials_per_condition(condition_idx,:))) ', SD=' num2str(std(trials_per_condition(condition_idx,:)))]);
end

figure();
cluster_means=[];
cluster_stderrs=[];
for i=1:length(clusters)
    condition_means=[];
    condition_stderrs=[];
    for j=1:length(conditions)
        condition_means(end+1)=mean(clusters(i).mu_mean_erds(conditions{j}));
        condition_stderrs(end+1)=std(clusters(i).mu_mean_erds(conditions{j}))/sqrt(length(clusters(i).mu_mean_erds(conditions{j})));
    end
    cluster_means(end+1,:)=condition_means;
    cluster_stderrs(end+1,:)=condition_stderrs;
end
[h herr]=barwitherr(cluster_stderrs, cluster_means);
hold on;
for i=1:length(conditions)
    xdata=get(get(herr(i),'children'),'xdata');
    ydata=get(get(herr(i),'children'),'ydata');
    clusterx=cell2mat(xdata(1));
    clustery=cell2mat(ydata(2));
    for j=1:length(clusters)
        disp([clusters(j).name ' - ' conditions{i} '(N=' num2str(length(clusters(j).mu_mean_erds(conditions{i}))) ')']);
        [h,p]=ttest(clusters(j).mu_mean_erds(conditions{i}))
        if p<=0.05
            x=clusterx(j)-.035;
            y1=clustery((j-1)*9+1);
            y2=clustery((j-1)*9+2);
            y=y1+1;
            if y1<0 && y2<0
                y=y2-1;
            end
            text(x, y, '*', 'VerticalAlignment', 'top', 'FontSize', 18);
        end
    end
end
hold off;
set(gca,'XTickLabel',{'C3','C4','O1','O2'});
title([num2str(mu_range(1)) '-' num2str(mu_range(2)) 'Hz']);
legend(conditions);


