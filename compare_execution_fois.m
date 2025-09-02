function subj_cluster_foi_erds=compare_execution_fois(subj_ids, fois, freq_range, baseline, time_window, subj_dir_ext)

if nargin<6
    subj_dir_ext='';
end

%clusters(1).name='C3';
%clusters(1).channels={'E30', 'E31', 'E36', 'E37', 'E41', 'E42', 'E53', 'E54'};
%clusters(2).name='C4';
%clusters(2).channels={'E79', 'E80', 'E86', 'E87', 'E93', 'E103', 'E104', 'E105'};
clusters(1).name='C';
clusters(1).channels={'E79', 'E80', 'E86', 'E87', 'E93', 'E103', 'E104', 'E105', 'E30', 'E31', 'E36', 'E37', 'E41', 'E42', 'E53', 'E54'};

[included_subjects excluded_subjects]=exclude_subjects(subj_ids, {'all'}, subj_dir_ext, '.move');

subj_cluster_foi_erds=zeros(length(included_subjects),length(clusters),size(fois,1));

for subj_idx=1:length(included_subjects)
    subj_id=included_subjects(subj_idx);
    data=pop_loadset(['/data/infant_face_eeg/preprocessed/' num2str(subj_id) subj_dir_ext '/' num2str(subj_id) '.all.move.set']);
    for cluster_idx=1:length(clusters)
        for foi_idx=1:size(fois,1)
            [times erd foi_mean_erd]=cluster_erd(data, clusters(cluster_idx).channels, fois(foi_idx,:), freq_range, baseline, time_window);
            subj_cluster_foi_erds(subj_idx,cluster_idx,foi_idx)=foi_mean_erd;
        end
    end
end
subj_cluster_foi_erds(:,end+1,:)=mean(subj_cluster_foi_erds,2);

foi_labels={};
for foi_idx=1:size(fois,1)
    foi_labels{end+1}=[num2str(fois(foi_idx,1)) '-' num2str(fois(foi_idx,2)) 'Hz'];
end
cluster_labels={};
for cluster_idx=1:length(clusters)
    cluster_labels{end+1}=clusters(cluster_idx).name;
end
cluster_labels{end+1}='C';

figure();
erd_means=squeeze(mean(subj_cluster_foi_erds));
erd_stderrs=squeeze(std(subj_cluster_foi_erds))./sqrt(length(included_subjects));
[h herr]=barwitherr(erd_stderrs', erd_means');
hold on;
for cluster_idx=1:size(subj_cluster_foi_erds,2)
    xdata=get(get(herr(cluster_idx),'children'),'xdata');
    ydata=get(get(herr(cluster_idx),'children'),'ydata');
    clusterx=cell2mat(xdata(1));
    clustery=cell2mat(ydata(2));
    for foi_idx=1:size(fois,1)
        [h,p]=ttest(squeeze(subj_cluster_foi_erds(:,cluster_idx,foi_idx)));
        disp([cluster_labels{cluster_idx} ' - ' foi_labels{foi_idx} '=' num2str(p)]);
        if p<=0.05
            x=clusterx(foi_idx)-.035;
            y1=clustery((foi_idx-1)*9+1);
            y2=clustery((foi_idx-1)*9+2);
            y=y1+1;
            if y1<0 && y2<0
                y=y2-1;
            end
            text(x, y, '*', 'VerticalAlignment', 'top', 'FontSize', 18);
        end
    end
end
hold off;
set(gca,'XTickLabel',foi_labels);
legend(cluster_labels);

fid = fopen('/data/infant_face_eeg/analysis/subject_freq_range_exe_erd.csv', 'w');
title_col=['Subject,FOI,ERD\n'];
fprintf(fid, title_col);
for subj_idx=1:length(included_subjects)
    for foi_idx=1:size(fois,1)
        foi=fois(foi_idx,:);
        ln=[num2str(included_subjects(subj_idx)) ',' num2str(foi(1)) '-' num2str(foi(2)) 'Hz,' num2str(subj_cluster_foi_erds(subj_idx,1,foi_idx)) '\n'];
        fprintf(fid, ln);
    end
end
fclose(fid);

