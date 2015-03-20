function [xh, yh] = synth_test( )
% path: file path to directory containing image sequence
% frames: range of frames (e.g. 1:256) to sonify
% xh: output audio signal
% yh: auditory spectrogram

use_aud2wav = 0;
use_cor2aud = 1;

sr = 44100; %audio samplerate, forced to 16kHz if use_aud2wav
bpo = 28; %bands per octave, forced to 24 if use_aud2wav
filts = 256; %total bands, forced to 128 if use_aud2wav
rates = 18;
scales = 11;
frames = 256;
lofreq = 30;

frmlen = 32; %frame length in ms
tc = 64; %integration time constant in ms (only matters if use_aud2wav)
fac = .1; %compression type (only matters if use_aud2wav)
shft = 0; %octave shift, do not change (only matters if use_aud2wav)
paras = [frmlen tc fac shft];

min_rate = -1;
max_rate = log2(1000/frmlen);
min_scale = -log2(9);
max_scale = log2(bpo)-1;
bounds = [min_rate max_rate min_scale max_scale];

resamp_pre = 1; %factor to downsample rate-scale plane
resamp_post = 1; %factor to downsample time-frequency spectrogram

corname = 'synth.cor'; %name of cor file if use_cor2aud

if use_aud2wav
    sr = 16000;
    filts = 128;
    bpo = 24;
end

data = synth_cor([scales rates frames filts]);

%obtain auditory spectrogram
if use_cor2aud
    write_cor(data, corname, paras, bpo, bounds);

    [yh, para1, rv, sv, HH] = cor2aud(corname);
    
    yh = aud_fix(yh);
    %yh = abs(yh);
else
    yh = squeeze(mean(mean(data)));
end

if resamp_post > 1
    yh = resample(yh,1,resamp_post,resamp_post);
    yh = resample(yh',1,resamp_post,resamp_post)';
end

%imagesc(flipud(yh')); %figure;

%synthesize audio
if use_aud2wav
    xh = aud2wav(yh, [], [paras 10 1 0]);
else
    xh = osc_bank(yh', lofreq, bpo, frmlen, sr);
end

aud_plot_2(log(max(.0001,yh)), [paras bpo lofreq]);

end

