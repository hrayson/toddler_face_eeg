function erd_movement_magnitude(subj_ids, movement_type, mu_range, freq_range, baseline, time_window, subj_dir_ext, max_latency)

clusters(1).name='C3';
clusters(1).channels={'E30', 'E31', 'E36', 'E37', 'E41', 'E42', 'E53', 'E54'};
clusters(1).mag_erd_pairs=[];
clusters(2).name='C4';
clusters(2).channels={'E79', 'E80', 'E86', 'E87', 'E93', 'E103', 'E104', 'E105'};
clusters(2).mag_erd_pairs=[];

[included_subjects excluded_subjects]=exclude_subjects(subj_ids, {'rereferenced.interp'}, subj_dir_ext, '')

for s=1:length(included_subjects)
    subj_id=included_subjects(s);

    data=pop_loadset(['/data/infant_face_eeg/preprocessed/' num2str(subj_id) subj_dir_ext '/' num2str(subj_id) '.rereferenced.interp.set']);

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
        init_magnitude=init_offset_level-init_onset_level;
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
        ret_magnitude=ret_onset_level-ret_offset_level;
        data = pop_editeventvals(data,'append',{1 [] [] [] [] [] [] []},'changefield',{2 'type' 'artifact'},'changefield',{2 'latency' ret_latency},'changefield',{2 'duration' ret_duration},'changefield',{2 'actor' 'None'},'changefield',{2 'code' num2str(ret_magnitude)},'changefield',{2 'movement' movement});
    end

    movement_mag_trials=dict();

    last_mov_start=-1;
    last_mov_end=-1;
    code='';
    mvmt='';
    for i=1:length(data.epoch)
        movement_magnitude=0;
        if iscell(data.epoch(i).eventtype)
            for j=1:length(data.epoch(i).eventtype)
                if strcmp(data.epoch(i).eventtype{j},'mov1')
                    last_mov_start=data.epoch(i).eventlatency{j};
                    code=data.epoch(i).eventcode{j};
                    mvmt=data.epoch(i).eventmovement{j};
                elseif strcmp(data.epoch(i).eventtype{j},'mov2')
                    last_mov_end=data.epoch(i).eventlatency{j};
                elseif strcmp(data.epoch(i).eventtype{j},'artifact') && strcmp(data.epoch(i).eventcode{j},'noat')==0
                    if (last_mov_start>-1 && last_mov_end<0) || (last_mov_start>-1 && last_mov_end>-1 && last_mov_start<=data.epoch(i).eventlatency{j}<=last_mov_end+max_latency*data.srate)
                        if strcmp(movement_type,'all')
                            if str2num(data.epoch(i).eventcode{j})>movement_magnitude
                                movement_magnitude=str2num(data.epoch(i).eventcode{j});
                            end
                        elseif strcmp(movement_type,'emotion') && (strcmp(data.epoch(i).eventmovement{j},'J') || strcmp(data.epoch(i).eventmovement{j},'S'))
                            if str2num(data.epoch(i).eventcode{j})>movement_magnitude
                                movement_magnitude=str2num(data.epoch(i).eventcode{j});
                            end
                        elseif strcmp(movement_type,'sad') && strcmp(data.epoch(i).eventmovement{j},'S')
                            if str2num(data.epoch(i).eventcode{j})>movement_magnitude
                                movement_magnitude=str2num(data.epoch(i).eventcode{j});
                            end        
                        elseif strcmp(movement_type,'happy') && strcmp(data.epoch(i).eventmovement{j},'J')
                            if str2num(data.epoch(i).eventcode{j})>movement_magnitude
                                movement_magnitude=str2num(data.epoch(i).eventcode{j});
                            end    
                        elseif strcmp(movement_type,'move') && strcmp(data.epoch(i).eventmovement{j},'MO')
                            if str2num(data.epoch(i).eventcode{j})>movement_magnitude
                                movement_magnitude=str2num(data.epoch(i).eventcode{j});
                            end
                        elseif strcmp(movement_type,'emotion') && (strcmp(data.epoch(i).eventmovement{j},'J') || strcmp(data.epoch(i).eventmovement{j},'S'))
                            if str2num(data.epoch(i).eventcode{j})>movement_magnitude
                                movement_magnitude=str2num(data.epoch(i).eventcode{j});
                            end
                        end
                    end
                end
            end
        end
        movement_mag_trials(movement_magnitude)=[movement_mag_trials(movement_magnitude) i];
    end

    mag_keys=movement_mag_trials.key;
    for j=1:length(clusters)
        for k=1:length(mag_keys)
            magnitude=mag_keys{k};
            [times mu_erd mean_mu_erd]=cluster_erd(data, clusters(j).channels, mu_range, freq_range, baseline, time_window, movement_mag_trials(magnitude)); 
            clusters(j).mag_erd_pairs=[clusters(j).mag_erd_pairs; magnitude mean_mu_erd];
        end
    end
end

figure();
P=polyfit(clusters(1).mag_erd_pairs(:,1),clusters(1).mag_erd_pairs(:,2),1);
yfit=P(1)*[0:4]+P(2);
plot(clusters(1).mag_erd_pairs(:,1),clusters(1).mag_erd_pairs(:,2),'ro');
hold on;
plot([0:4],yfit,'r--');
P=polyfit(clusters(2).mag_erd_pairs(:,1),clusters(2).mag_erd_pairs(:,2),1);
yfit=P(1)*[0:4]+P(2);
plot(clusters(2).mag_erd_pairs(:,1),clusters(2).mag_erd_pairs(:,2),'bo');
plot([0:4],yfit,'b--');
hold off;
legend({clusters(1).name,clusters(2).name});
xlabel('Movement Magnitude');
ylabel('Mean ERD');

clusters(1).name
[rho pval]=corr(clusters(1).mag_erd_pairs(:,1),clusters(1).mag_erd_pairs(:,2))

clusters(2).name
[rho pval]=corr(clusters(2).mag_erd_pairs(:,1),clusters(2).mag_erd_pairs(:,2))
