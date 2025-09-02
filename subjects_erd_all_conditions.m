function [p,tbl,stats]=subjects_erd_all_conditions(subj_ids, conditions, mu_range, freq_range, baseline, time_window, ylimits, subj_dir_ext, file_ext)

if nargin<8
    subj_dir_ext='';
end
if nargin<9
    file_ext='';
end

clusters(1).name='C3';
clusters(1).channels={'E30', 'E31', 'E36', 'E37', 'E41', 'E42', 'E53', 'E54'};
clusters(2).name='C4';
clusters(2).channels={'E79', 'E80', 'E86', 'E87', 'E93', 'E103', 'E104', 'E105'};
clusters(3).name='O1';
clusters(3).channels={'E69', 'E70', 'E73', 'E74'};
clusters(4).name='O2';
clusters(4).channels={'E83', 'E82', 'E89', 'E88'};
%clusters(5).name='T9';
%clusters(5).channels={'E49', 'E45', 'E44', 'E39', 'E43', 'E38'};
%clusters(6).name='T10';
%clusters(6).channels={'E108', 'E113', 'E115', 'E114', 'E120', 'E121'};
%clusters(7).name='P3';
%clusters(7).channels={'E59', 'E60', 'E52', 'E51', 'E47'};
%clusters(8).name='P4';
%clusters(8).channels={'E85', 'E91', 'E92', 'E97', 'E98'};
%clusters(9).name='F3';
%clusters(9).channels={'E19', 'E23', 'E24', 'E27', 'E28'};
%clusters(10).name='F4';
%clusters(10).channels={'E3', 'E4', 'E117', 'E123', 'E124'};
%clusters(11).name='C';
%clusters(11).channels={'E30', 'E31', 'E36', 'E37', 'E41', 'E42', 'E53', 'E54', 'E79', 'E80', 'E86', 'E87', 'E93', 'E103', 'E104', 'E105'};

[included_subjects excluded_subjects]=exclude_subjects(subj_ids, conditions, subj_dir_ext, file_ext)

for i=1:length(clusters)
    clusters(i).mu_erds=dict;
    clusters(i).mu_mean_erds=dict;
    for k=1:length(conditions)
        mu_erds=[];
        mu_mean_erds=[];
        for j=1:length(included_subjects)
            subj_id=included_subjects(j);
            data=pop_loadset(['/data/infant_face_eeg/preprocessed/' num2str(subj_id) subj_dir_ext '/' num2str(subj_id) '.' conditions{k}  file_ext '.set']);
            [times mu_erds(end+1,:) mu_mean_erds(end+1)]=cluster_erd(data, clusters(i).channels, mu_range, freq_range, baseline, time_window);
        end
        clusters(i).times=times;
        clusters(i).mu_erds(conditions{k})=mu_erds;
        clusters(i).mu_mean_erds(conditions{k})=mu_mean_erds;
    end
end

figure();
cluster_means=[];
cluster_stderrs=[];
for i=1:length(clusters)
    condition_means=[];
    condition_stderrs=[];
    for j=1:length(conditions)
        condition_means(end+1)=mean(clusters(i).mu_mean_erds(conditions{j}));
        condition_stderrs(end+1)=std(clusters(i).mu_mean_erds(conditions{j}))/sqrt(length(included_subjects));
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
        disp([clusters(j).name ' - ' conditions{i}]);
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
if length(ylimits)>0
    ylim(ylimits);
end
set(gca,'XTickLabel',{'C3','C4','O1','O2','T9','T10','P3','P4','F3','F4','C'});
title([num2str(mu_range(1)) '-' num2str(mu_range(2)) 'Hz']);
legend(conditions);

disp(['Using ' num2str(length(included_subjects)) ' subjects, excluded ' num2str(length(excluded_subjects)) ' subjects'])

%fid = fopen(['/data/infant_face_eeg/analysis/subject_' num2str(mu_range(1)) '-' num2str(mu_range(2)) 'Hz_erd' file_ext '.csv'], 'w');
%title_col=['Subject'];
%for i=1:length(clusters)
%    for j=1:length(conditions)
%        title_col=[title_col ', ' clusters(i).name uplow(conditions{j})];
%    end
%end
%fprintf(fid, [title_col '\n']);
%fprintf(fid, 'Subject, CentralShuffled, CentralUnshuffled, CentralEmotion, CentralMovement, CentralHappy, CentralSad, LeftCentralShuffled, LeftCentralUnshuffled, LeftCentralEmotion, LeftCentralMovement, LeftCentralHappy, LeftCentralSad, RightCentralShuffled, RightCentralUnshuffled, RightCentralEmotion, RightCentralMovement, RightCentralHappy, RightCentralSad, LeftOccipitalShuffled, LeftOccipitalUnshuffled, LeftOccipitalEmotion, LeftOccipitalMovement, LeftOccipitalHappy, LeftOccipitalSad, RightOccipitalShuffled, RightOccipitalUnshuffled, RightOccipitalEmotion, RightOccipitalMovement, RightOccipitalHappy, RightOccipitalSad, LeftTemporalShuffled, LeftTemporalUnshuffled, LeftTemporalEmotion, LeftTemporalMovement, LeftTemporalHappy, LeftTemporalSad, RightTemporalShuffled, RightTemporalUnshuffled, RightTemporalEmotion, RightTemporalMovement, RightTemporalHappy, RightTemporalSad, LeftParietalShuffled, LeftParietalUnshuffled, LeftParietalEmotion, LeftParietalMovement, LeftParietalHappy, LeftParietalSad, RightParietalShuffled, RightParietalUnshuffled, RightParietalEmotion, RightParietalMovement, RightParietalHappy, RightParietalSad, LeftFrontalShuffled, LeftFrontalUnshuffled, LeftFrontalEmotion, LeftFrontalMovement, LeftFrontalHappy, LeftFrontalSad, RightFrontalShuffled, RightFrontalUnshuffled, RightFrontalEmotion, RightFrontalMovement, RightFrontalHappy, RightFrontalSad\n');
c3_shuf_erds=clusters(1).mu_mean_erds('shuffled');
c3_unshuf_erds=clusters(1).mu_mean_erds('unshuffled');
c3_emotion_erds=clusters(1).mu_mean_erds('emotion');
c3_move_erds=clusters(1).mu_mean_erds('movement');
c3_happy_erds=clusters(1).mu_mean_erds('happy');
c3_sad_erds=clusters(1).mu_mean_erds('sad');
c4_shuf_erds=clusters(2).mu_mean_erds('shuffled');
c4_unshuf_erds=clusters(2).mu_mean_erds('unshuffled');
c4_emotion_erds=clusters(2).mu_mean_erds('emotion');
c4_move_erds=clusters(2).mu_mean_erds('movement');
c4_happy_erds=clusters(2).mu_mean_erds('happy');
c4_sad_erds=clusters(2).mu_mean_erds('sad');
o1_shuf_erds=clusters(3).mu_mean_erds('shuffled');
o1_unshuf_erds=clusters(3).mu_mean_erds('unshuffled');
o1_emotion_erds=clusters(3).mu_mean_erds('emotion');
o1_move_erds=clusters(3).mu_mean_erds('movement');
o1_happy_erds=clusters(3).mu_mean_erds('happy');
o1_sad_erds=clusters(3).mu_mean_erds('sad');
o2_shuf_erds=clusters(4).mu_mean_erds('shuffled');
o2_unshuf_erds=clusters(4).mu_mean_erds('unshuffled');
o2_emotion_erds=clusters(4).mu_mean_erds('emotion');
o2_move_erds=clusters(4).mu_mean_erds('movement');
o2_happy_erds=clusters(4).mu_mean_erds('happy');
o2_sad_erds=clusters(4).mu_mean_erds('sad');
%t9_shuf_erds=clusters(5).mu_mean_erds('shuffled');
%t9_unshuf_erds=clusters(5).mu_mean_erds('unshuffled');
%t9_emotion_erds=clusters(5).mu_mean_erds('emotion');
%t9_move_erds=clusters(5).mu_mean_erds('movement');
%t9_happy_erds=clusters(5).mu_mean_erds('happy');
%t9_sad_erds=clusters(5).mu_mean_erds('sad');
%t10_shuf_erds=clusters(6).mu_mean_erds('shuffled');
%t10_unshuf_erds=clusters(6).mu_mean_erds('unshuffled');
%t10_emotion_erds=clusters(6).mu_mean_erds('emotion');
%t10_move_erds=clusters(6).mu_mean_erds('movement');
%t10_happy_erds=clusters(6).mu_mean_erds('happy');
%t10_sad_erds=clusters(6).mu_mean_erds('sad');
%p3_shuf_erds=clusters(7).mu_mean_erds('shuffled');
%p3_unshuf_erds=clusters(7).mu_mean_erds('unshuffled');
%p3_emotion_erds=clusters(7).mu_mean_erds('emotion');
%p3_move_erds=clusters(7).mu_mean_erds('movement');
%p3_happy_erds=clusters(7).mu_mean_erds('happy');
%p3_sad_erds=clusters(7).mu_mean_erds('sad');
%p4_shuf_erds=clusters(8).mu_mean_erds('shuffled');
%p4_unshuf_erds=clusters(8).mu_mean_erds('unshuffled');
%p4_emotion_erds=clusters(8).mu_mean_erds('emotion');
%p4_move_erds=clusters(8).mu_mean_erds('movement');
%p4_happy_erds=clusters(8).mu_mean_erds('happy');
%p4_sad_erds=clusters(8).mu_mean_erds('sad');
%f3_shuf_erds=clusters(9).mu_mean_erds('shuffled');
%f3_unshuf_erds=clusters(9).mu_mean_erds('unshuffled');
%f3_emotion_erds=clusters(9).mu_mean_erds('emotion');
%f3_move_erds=clusters(9).mu_mean_erds('movement');
%f3_happy_erds=clusters(9).mu_mean_erds('happy');
%f3_sad_erds=clusters(9).mu_mean_erds('sad');
%f4_shuf_erds=clusters(10).mu_mean_erds('shuffled');
%f4_unshuf_erds=clusters(10).mu_mean_erds('unshuffled');
%f4_emotion_erds=clusters(10).mu_mean_erds('emotion');
%f4_move_erds=clusters(10).mu_mean_erds('movement');
%f4_happy_erds=clusters(10).mu_mean_erds('happy');
%f4_sad_erds=clusters(10).mu_mean_erds('sad');
%c_shuf_erds=clusters(11).mu_mean_erds('shuffled');
%c_unshuf_erds=clusters(11).mu_mean_erds('unshuffled');
%c_emotion_erds=clusters(11).mu_mean_erds('emotion');
%c_move_erds=clusters(11).mu_mean_erds('movement');
%c_happy_erds=clusters(11).mu_mean_erds('happy');
%c_sad_erds=clusters(11).mu_mean_erds('sad');

%for s = 1:length(included_subjects)
%    row=num2str(included_subjects(s));
%    for i=1:length(clusters)
%        for j=1:length(conditions)
%            erds=clusters(i).mu_mean_erds(conditions{j});
%            row=[row sprintf(', %1.6f', erds(s))];
%        end
%    end
%    fprintf(fid, [row '\n']);
    %fprintf(fid, sprintf('%d, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f, %1.6f\n', included_subjects(i), c_shuf_erds(i), c_unshuf_erds(i), c_emotion_erds(i), c_move_erds(i), c_happy_erds(i), c_sad_erds(i), c3_shuf_erds(i), c3_unshuf_erds(i), c3_emotion_erds(i), c3_move_erds(i), c3_happy_erds(i), c3_sad_erds(i), c4_shuf_erds(i), c4_unshuf_erds(i), c4_emotion_erds(i), c4_move_erds(i), c4_happy_erds(i), c4_sad_erds(i), o1_shuf_erds(i), o1_unshuf_erds(i), o1_emotion_erds(i), o1_move_erds(i), o1_happy_erds(i), o1_sad_erds(i), o2_shuf_erds(i), o2_unshuf_erds(i), o2_emotion_erds(i), o2_move_erds(i), o2_happy_erds(i), o2_sad_erds(i), t9_shuf_erds(i), t9_unshuf_erds(i), t9_emotion_erds(i), t9_move_erds(i), t9_happy_erds(i), t9_sad_erds(i), t10_shuf_erds(i), t10_unshuf_erds(i), t10_emotion_erds(i), t10_move_erds(i), t10_happy_erds(i), t10_sad_erds(i), p3_shuf_erds(i), p3_unshuf_erds(i), p3_emotion_erds(i), p3_move_erds(i), p3_happy_erds(i), p3_sad_erds(i), p4_shuf_erds(i), p4_unshuf_erds(i), p4_emotion_erds(i), p4_move_erds(i), p4_happy_erds(i), p4_sad_erds(i), f3_shuf_erds(i), f3_unshuf_erds(i), f3_emotion_erds(i), f3_move_erds(i), f3_happy_erds(i), f3_sad_erds(i), f4_shuf_erds(i), f4_unshuf_erds(i), f4_emotion_erds(i), f4_move_erds(i), f4_happy_erds(i), f4_sad_erds(i)));
%end
%fclose(fid);


