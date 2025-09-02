function explore_erd(subj_ids, base_condition, exp_condition, freq_range, paired)

duration=1000;
incr=50;
num_iter=(2500-duration)/incr;
mu_ranges=[5 9; 5 10; 6 9; 6 10];
for i=1:num_iter
    time_lim=[(i-1)*incr (i-1)*incr+duration];
    for j=1:size(mu_ranges,1)
        subjects_erd(subj_ids, base_condition, exp_condition, time_lim, time_lim, freq_range, squeeze(mu_ranges(j,:)), paired);
        saveas(gcf, ['/data/infant_face_eeg/analysis/erd_param_explore/end-t' num2str(time_lim(1)) '-' num2str(time_lim(2)) '_mu' num2str(mu_ranges(j,1)) '-' num2str(mu_ranges(j,2)) '.png'], 'png');
        close(gcf);
    end
end
