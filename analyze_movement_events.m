
function [shuffled_movements mouthopen_movements happy_movements sad_movements shuffled_imitations mouthopen_imitations happy_imitations sad_imitations shuffled_trials mouthopen_trials happy_trials sad_trials]=analyze_movement_events(subj_id, behavior_file, max_latency)

if nargin<3
    max_latency=0;
end

data=pop_loadset(['/data/infant_face_eeg/raw/' num2str(subj_id) '/' num2str(subj_id) '.events.set']);
behavior_fid=fopen(['/data/infant_face_eeg/raw/' num2str(subj_id) '/' behavior_file]);
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
    data = pop_editeventvals(data,'append',{1 [] [] [] [] [] [] []},'changefield',{2 'type' 'artifact'},'changefield',{2 'latency' init_latency},'changefield',{2 'duration' init_duration},'changefield',{2 'actor' 'None'},'changefield',{2 'code' init_magnitude},'changefield',{2 'movement' movement});

    %ret_onset=cols{7};
    %ret_onset_min=str2num(ret_onset(1:2));
    %ret_onset_sec=str2num(ret_onset(4:5));
    %ret_onset_ms=str2num(ret_onset(7:end));
    %ret_onset_level=str2num(cols{8});

    %ret_offset=cols{9};
    %ret_offset_min=str2num(ret_offset(1:2));
    %ret_offset_sec=str2num(ret_offset(4:5));
    %ret_offset_ms=str2num(ret_offset(7:end));    
    %ret_offset_level=str2num(cols{10});

    %ret_latency=ret_onset_min*60.0+ret_onset_sec+0.001*ret_onset_ms;
    %ret_duration=(ret_offset_min*60.0+ret_offset_sec+0.001*ret_offset_ms)-ret_latency;
    %ret_magnitude=ret_onset_level-ret_offset_level;
    %data = pop_editeventvals(data,'append',{1 [] [] [] [] [] [] []},'changefield',{2 'type' 'artifact'},'changefield',{2 'latency' ret_latency},'changefield',{2 'duration' ret_duration},'changefield',{2 'actor' 'None'},'changefield',{2 'code' ret_magnitude},'changefield',{2 'movement' movement});
end

if subj_id==201
    new_data=pop_loadset(['/data/infant_face_eeg/raw/' num2str(subj_id) '/' num2str(subj_id) '.events.set']);
    for i=1:length(data.event)
        if strcmp(data.event(i).type,'mov1')
            new_data = pop_editeventvals(new_data,'append',{1 [] [] [] [] [] [] []},'changefield',{2 'type' 'mov2'},'changefield',{2 'latency' data.event(i).latency/data.srate+3.172},'changefield',{2 'duration' .001},'changefield',{2 'actor' data.event(i).actor},'changefield',{2 'code' data.event(i).code},'changefield',{2 'movement' data.event(i).movement});
        end
    end
    data=new_data;
end

imitations=[];
num_trials=0;
last_mov_start=-1;
last_mov_end=-1;
code='';
mvmt='';
shuffled_movements=[];
mouthopen_movements=[];
happy_movements=[];
sad_movements=[];
shuffled_imitations=[];
mouthopen_imitations=[];
happy_imitations=[];
sad_imitations=[];
shuffled_trials=0;
mouthopen_trials=0;
happy_trials=0;
sad_trials=0;

for i=1:length(data.event)
    if strcmp(data.event(i).type,'mov1')
        last_mov_start=data.event(i).latency;
        code=data.event(i).code;
        mvmt=data.event(i).movement;
    elseif strcmp(data.event(i).type,'mov2')
        last_mov_end=data.event(i).latency;
        if strcmp(code,'joy')
            happy_trials=happy_trials+1;
        elseif strcmp(code,'move')
            mouthopen_trials=mouthopen_trials+1;
        elseif strcmp(code,'sad')
            sad_trials=sad_trials+1;
        elseif strcmp(code,'shuf')
            shuffled_trials=shuffled_trials+1;
        end
    elseif strcmp(data.event(i).type,'artifact') && strcmp(data.event(i).code,'noat')==0
        if (last_mov_start>-1 && last_mov_end<0) || (last_mov_start>-1 && last_mov_end>-1 && last_mov_start<=data.event(i).latency<=last_mov_end+max_latency*data.srate)
            if strcmp(data.event(i).movement,'J')
                happy_movements(end+1)=str2num(data.event(i).code);
            elseif strcmp(data.event(i).movement,'MO')
                mouthopen_movements(end+1)=str2num(data.event(i).code);
            elseif strcmp(data.event(i).movement,'S')
                sad_movements(end+1)=str2num(data.event(i).code);
            end
            if strcmp(code,'joy') && strcmp(data.event(i).movement,'J')
                happy_imitations(end+1)=str2num(data.event(i).code);
            elseif strcmp(code,'move') && strcmp(data.event(i).movement,'MO')
                mouthopen_imitations(end+1)=str2num(data.event(i).code);
            elseif strcmp(code,'sad') && strcmp(data.event(i).movement,'S')
                sad_imitations(end+1)=str2num(data.event(i).code);
            elseif strcmp(code,'shuf')
                shuffled_movements(end+1)=str2num(data.event(i).code);
                if (strcmp(mvmt,'mopn') && strcmp(data.event(i).movement,'MO')) || (strcmp(mvmt,'frwn') && strcmp(data.event(i).movement,'S')) || (strcmp(mvmt,'smil') && strcmp(data.event(i).movement,'J'))
                    shuffled_imitations(end+1)=str2num(data.event(i).code);
                end
            end
        end
    end
end
%unshuffled_freq=(length(happy_imitations)+length(sad_imitations)+length(mouthopen_imitations))/(num_joy_trials+num_sad_trials+num_mouthopen_trials);
%emotion_freq=(length(happy_imitations)+length(sad_imitations))/(num_joy_trials+num_sad_trials);
%shuffled_freq=length(shuffled_imitations)/num_shuffled_trials;
%if length(shuffled_movements)
%    shuffled_imitations=length(shuffled_imitations)/length(shuffled_movements);
%else
%    shuffled_imitations=0.0;
%end
