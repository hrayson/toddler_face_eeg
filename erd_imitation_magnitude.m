function erd_imitation_magnitude(subj_ids, condition, movement_type, cluster_idx, mu_range, freq_range, baseline, time_window, subj_dir_ext, max_latency)

clusters(1).name='C3';
clusters(1).channels={'E30', 'E31', 'E36', 'E37', 'E41', 'E42', 'E53', 'E54'};
clusters(2).name='C4';
clusters(2).channels={'E79', 'E80', 'E86', 'E87', 'E93', 'E103', 'E104', 'E105'};
clusters(3).name='O1';
clusters(3).channels={'E69', 'E70', 'E73', 'E74'};
clusters(4).name='O2';
clusters(4).channels={'E83', 'E82', 'E89', 'E88'};
clusters(5).name='T9';
clusters(5).channels={'E49', 'E45', 'E44', 'E39', 'E43', 'E38'};
clusters(6).name='T10';
clusters(6).channels={'E108', 'E113', 'E115', 'E114', 'E120', 'E121'};
clusters(7).name='P3';
clusters(7).channels={'E59', 'E60', 'E52', 'E51', 'E47'};
clusters(8).name='P4';
clusters(8).channels={'E85', 'E91', 'E92', 'E97', 'E98'};
clusters(9).name='F3';
clusters(9).channels={'E19', 'E23', 'E24', 'E27', 'E28'};
clusters(10).name='F4';
clusters(10).channels={'E3', 'E4', 'E117', 'E123', 'E124'};
clusters(11).name='C';
clusters(11).channels={'E79', 'E80', 'E86', 'E87', 'E93', 'E103', 'E104', 'E105', 'E30', 'E31', 'E36', 'E37', 'E41', 'E42', 'E53', 'E54'};

[included_subjects excluded_subjects]=exclude_subjects(subj_ids, {condition}, subj_dir_ext, '')

movement_magnitude_num_trials=dict;
imitation_magnitude_num_trials=dict;
subj_movement_magnitude_trials={};
subj_imitation_magnitude_trials={};
for i=1:3
    movement_magnitude_num_trials(i)=[];
    imitation_magnitude_num_trials(i)=[];
    subj_movement_magnitude_trials{end+1}=dict();
    subj_imitation_magnitude_trials{end+1}=dict();
end

for s=1:length(included_subjects)
    subj_id=included_subjects(s);

    data=pop_loadset(['/data/infant_face_eeg/preprocessed/' num2str(subj_id) subj_dir_ext '/' num2str(subj_id) '.' condition  '.set']);

    behavior_fid=fopen(['/data/infant_face_eeg/raw/' num2str(subj_id) '/' num2str(subj_id) 'JH.csv']);
    lines=textscan(behavior_fid,'%s','Delimiter','\n','CollectOutput',true);
    for i=3:length(lines{1})
        cols=strsplit(lines{1}{i},',');
        movement=cols{2};

        init_onset=cols{3};
        init_onset_min=str2num(init_onset(1:2));
        init_onset_sec=str2num(init_onset(4:5));
        init_onset_ms=str2num(init_onset(7:end));
        init_onset_level=str2num(cols{4});

        init_offset=cols{5};
        init_offset_min=str2num(init_offset(1:2));
        init_offset_sec=str2num(init_offset(4:5));
        init_offset_ms=str2num(init_offset(7:end));    
        init_offset_level=str2num(cols{6});

        init_latency=init_onset_min*60.0+init_onset_sec+0.001*init_onset_ms;
        init_duration=(init_offset_min*60.0+init_offset_sec+0.001*init_offset_ms)-init_latency;
        init_magnitude=init_offset_level-init_onset_level
        data = pop_editeventvals(data,'append',{1 [] [] [] [] [] [] []},'changefield',{2 'type' 'artifact'},'changefield',{2 'latency' init_latency},'changefield',{2 'duration' init_duration},'changefield',{2 'actor' 'None'},'changefield',{2 'code' num2str(init_magnitude)},'changefield',{2 'movement' movement});

        ret_onset=cols{7};
        ret_onset_min=str2num(ret_onset(1:2));
        ret_onset_sec=str2num(ret_onset(4:5));
        ret_onset_ms=str2num(ret_onset(7:end));
        ret_onset_level=str2num(cols{8});

        ret_offset=cols{9};
        ret_offset_min=str2num(ret_offset(1:2));
        ret_offset_sec=str2num(ret_offset(4:5));
        ret_offset_ms=str2num(ret_offset(7:end));    
        ret_offset_level=str2num(cols{10});

        ret_latency=ret_onset_min*60.0+ret_onset_sec+0.001*ret_onset_ms;
        ret_duration=(ret_offset_min*60.0+ret_offset_sec+0.001*ret_offset_ms)-ret_latency;
        ret_magnitude=ret_onset_level-ret_offset_level
        data = pop_editeventvals(data,'append',{1 [] [] [] [] [] [] []},'changefield',{2 'type' 'artifact'},'changefield',{2 'latency' ret_latency},'changefield',{2 'duration' ret_duration},'changefield',{2 'actor' 'None'},'changefield',{2 'code' num2str(ret_magnitude)},'changefield',{2 'movement' movement});
    end

    code='';
    mvmt='';
    movement_mag_trials=zeros(length(data.epoch),1);
    imitation_mag_trials=zeros(length(data.epoch),1);
    for i=1:length(data.epoch)
        movement_magnitude=0;
        imitation_magnitude=0;
        if iscell(data.epoch(i).eventtype)
            for j=1:length(data.epoch(i).eventtype)
                if strcmp(data.epoch(i).eventtype{j},'mov1')
                    code=data.epoch(i).eventcode{j};
                    mvmt=data.epoch(i).eventmovement{j};
                elseif strcmp(data.epoch(i).eventtype{j},'artifact') && strcmp(data.epoch(i).eventcode{j},'noat')==0
                    if strcmp(movement_type,'all')
                        if str2num(data.epoch(i).eventcode{j})>movement_magnitude
                            movement_magnitude=str2num(data.epoch(i).eventcode{j});
                        end
                        if (strcmp(code,'joy') && strcmp(data.epoch(i).eventmovement{j},'J')) || (strcmp(code,'move') && strcmp(data.epoch(i).eventmovement{j},'MO')) || (strcmp(code,'sad') && strcmp(data.epoch(i).eventmovement{j},'S'))
                            if str2num(data.epoch(i).eventcode{j})>imitation_magnitude
                                imitation_magnitude=str2num(data.epoch(i).eventcode{j});
                            end
                        end
                    elseif strcmp(movement_type,'emotion') && (strcmp(data.epoch(i).eventmovement{j},'J') || strcmp(data.epoch(i).eventmovement{j},'S'))
                        if str2num(data.epoch(i).eventcode{j})>movement_magnitude
                            movement_magnitude=str2num(data.epoch(i).eventcode{j});
                        end
                        if (strcmp(code,'joy') && strcmp(data.epoch(i).eventmovement{j},'J')) || (strcmp(code,'sad') && strcmp(data.epoch(i).eventmovement{j},'S'))
                            if str2num(data.epoch(i).eventcode{j})>imitation_magnitude
                                imitation_magnitude=str2num(data.epoch(i).eventcode{j});
                            end
                        end                    
                    elseif strcmp(movement_type,'happy') && strcmp(data.epoch(i).eventmovement{j},'J')
                        if str2num(data.epoch(i).eventcode{j})>movement_magnitude
                            movement_magnitude=str2num(data.epoch(i).eventcode{j});
                        end
                        if strcmp(code,'joy')
                            if str2num(data.epoch(i).eventcode{j})>imitation_magnitude
                                imitation_magnitude=str2num(data.epoch(i).eventcode{j});
                            end
                        end
                    elseif strcmp(movement_type,'move') && strcmp(data.epoch(i).eventmovement{j},'MO')
                        if str2num(data.epoch(i).eventcode{j})>movement_magnitude
                            movement_magnitude=str2num(data.epoch(i).eventcode{j});
                        end
                        if strcmp(code,'move')
                            if str2num(data.epoch(i).eventcode{j})>imitation_magnitude
                                imitation_magnitude=str2num(data.epoch(i).eventcode{j});
                            end
                        end
                    elseif strcmp(movement_type,'sad') && strcmp(data.epoch(i).eventmovement{j},'S')
                        if str2num(data.epoch(i).eventcode{j})>movement_magnitude
                            movement_magnitude=str2num(data.epoch(i).eventcode{j});
                        end
                        if strcmp(code,'sad')
                            if str2num(data.epoch(i).eventcode{j})>imitation_magnitude
                                imitation_magnitude=str2num(data.epoch(i).eventcode{j});
                            end
                        end
                    end
                end
            end
        end
        imitation_mag_trials(i)=imitation_magnitude;
        movement_mag_trials(i)=movement_magnitude;
    end
    
    dict_array=movement_magnitude_num_trials(1);
    dict_array(end+1)=length(find(movement_mag_trials==0));
    movement_magnitude_num_trials(1)=dict_array;
        
    subj_dict=subj_movement_magnitude_trials{1};
    subj_dict(subj_id)=find(movement_mag_trials==0);
    subj_movement_magnitude_trials{1}=subj_dict;

    dict_array=imitation_magnitude_num_trials(1);
    dict_array(end+1)=length(find(imitation_mag_trials==0));
    imitation_magnitude_num_trials(1)=dict_array;
        
    subj_dict=subj_imitation_magnitude_trials{1};
    subj_dict(subj_id)=find(imitation_mag_trials==0);
    subj_imitation_magnitude_trials{1}=subj_dict;


    dict_array=movement_magnitude_num_trials(2);
    dict_array(end+1)=length(union(find(movement_mag_trials==1),find(movement_mag_trials==2)));
    movement_magnitude_num_trials(2)=dict_array;
        
    subj_dict=subj_movement_magnitude_trials{2};
    subj_dict(subj_id)=union(find(movement_mag_trials==1),find(movement_mag_trials==2));
    subj_movement_magnitude_trials{2}=subj_dict;

    dict_array=imitation_magnitude_num_trials(2);
    dict_array(end+1)=length(union(find(imitation_mag_trials==1),find(imitation_mag_trials==2)));
    imitation_magnitude_num_trials(2)=dict_array;
        
    subj_dict=subj_imitation_magnitude_trials{2};
    subj_dict(subj_id)=union(find(imitation_mag_trials==1),find(imitation_mag_trials==2));
    subj_imitation_magnitude_trials{2}=subj_dict;


    dict_array=movement_magnitude_num_trials(3);
    dict_array(end+1)=length(union(find(movement_mag_trials==3),find(movement_mag_trials==4)));
    movement_magnitude_num_trials(3)=dict_array;
        
    subj_dict=subj_movement_magnitude_trials{3};
    subj_dict(subj_id)=union(find(movement_mag_trials==3),find(movement_mag_trials==4));
    subj_movement_magnitude_trials{3}=subj_dict;

    dict_array=imitation_magnitude_num_trials(3);
    dict_array(end+1)=length(union(find(imitation_mag_trials==3),find(imitation_mag_trials==4)));
    imitation_magnitude_num_trials(3)=dict_array;
        
    subj_dict=subj_imitation_magnitude_trials{3};
    subj_dict(subj_id)=union(find(imitation_mag_trials==3),find(imitation_mag_trials==4));
    subj_imitation_magnitude_trials{3}=subj_dict;
    
end

movement_magnitudes=[];
imitation_magnitudes=[];
for i=1:length(cluster_idx)
    clusters(cluster_idx(i)).movement_magnitude_mean_mu_erds=[];
    clusters(cluster_idx(i)).movement_magnitude_std_mu_erds=[];
    clusters(cluster_idx(i)).imitation_magnitude_mean_mu_erds=[];
    clusters(cluster_idx(i)).imitation_magnitude_std_mu_erds=[];
end
for i=1:3
    dict_array=movement_magnitude_num_trials(i);
    subj_dict=subj_movement_magnitude_trials{i};
    % If at least five subjects have two trials of this magnitude
    if length(find(dict_array>=2))>=3
        movement_magnitudes(end+1)=i;
        mean_mu_erds=[];
        subj_idx=1;
        for s=1:length(included_subjects)
            subj_id=included_subjects(s);
            subj_trials=subj_dict(subj_id);
            % If this subject has at least three trials of this magnitude
            if length(subj_trials)>=2
                data=pop_loadset(['/data/infant_face_eeg/preprocessed/' num2str(subj_id) subj_dir_ext '/' num2str(subj_id) '.' condition  '.set']);
                for j=1:length(cluster_idx)
                    [times mu_erd mean_mu_erds(j,subj_idx)]=cluster_erd(data, clusters(cluster_idx(j)).channels, mu_range, freq_range, baseline, time_window, subj_trials); 
                end
                subj_idx=subj_idx+1;
            end
        end
        for j=1:length(cluster_idx)
            clusters(cluster_idx(j)).movement_magnitude_mean_mu_erds(end+1)=mean(mean_mu_erds(j,:));
            clusters(cluster_idx(j)).movement_magnitude_std_mu_erds(end+1)=std(mean_mu_erds(j,:))/sqrt(size(mean_mu_erds,2));
        end
    end

    dict_array=imitation_magnitude_num_trials(i);
    subj_dict=subj_imitation_magnitude_trials{i};
    % If at least five subjects have three trials of this magnitude
    if length(find(dict_array>=2))>=3
        imitation_magnitudes(end+1)=i;
        mean_mu_erds=[];
        subj_idx=1;
        for s=1:length(included_subjects)
            subj_id=included_subjects(s);
            subj_trials=subj_dict(subj_id);
            % If this subject has at least three trials of this magnitude
            if length(subj_trials)>=2
                data=pop_loadset(['/data/infant_face_eeg/preprocessed/' num2str(subj_id) subj_dir_ext '/' num2str(subj_id) '.' condition  '.set']);
                for j=1:length(cluster_idx)
                    [times mu_erd mean_mu_erds(j,subj_idx)]=cluster_erd(data, clusters(cluster_idx(j)).channels, mu_range, freq_range, baseline, time_window, subj_trials); 
                end
                subj_idx=subj_idx+1;
            end
        end
        for j=1:length(cluster_idx)
            clusters(cluster_idx(j)).imitation_magnitude_mean_mu_erds(end+1)=mean(mean_mu_erds(j,:));
            clusters(cluster_idx(j)).imitation_magnitude_std_mu_erds(end+1)=std(mean_mu_erds(j,:))/sqrt(size(mean_mu_erds,2));
        end
    end
end
                
        
figure();
for i=1:3
    subplot(1,3,i);
    hist(movement_magnitude_num_trials(i));
    xlabel(['# Trials, magnitude=' num2str(i)]);
    ylabel('# of Subjects');
    title([movement_type ' movements']);
    if i==1
        xlim([0 80]);
    else
        xlim([0 15]);
    end
end

figure();
for i=1:3
    subplot(1,3,i);
    hist(imitation_magnitude_num_trials(i));
    xlabel(['# Trials, magnitude=' num2str(i)]);
    ylabel('# of Subjects');
    title([movement_type ' imitations']);
    if i==1
        xlim([0 80]);
    else
        xlim([0 15]);
    end
end


figure();
hold all;
legend_str={};
cluster_colors={'r','b'};
for j=1:length(cluster_idx)
    errorbar(movement_magnitudes,clusters(cluster_idx(j)).movement_magnitude_mean_mu_erds,clusters(cluster_idx(j)).movement_magnitude_std_mu_erds,['o-' cluster_colors{j}]);
    errorbar(imitation_magnitudes,clusters(cluster_idx(j)).imitation_magnitude_mean_mu_erds,clusters(cluster_idx(j)).imitation_magnitude_std_mu_erds,['o--' cluster_colors{j}]);
    legend_str{end+1}=[clusters(cluster_idx(j)).name '- movement'];
    legend_str{end+1}=[clusters(cluster_idx(j)).name '- imitation'];
end
xlim([0.5 3.5]);
ylim([-70 70]);
legend(legend_str);
xlabel('Magnitude');
ylabel('Mean Mu ERD');
title(movement_type);

