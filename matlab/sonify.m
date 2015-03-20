function [xh, yh] = sonify( path, frames )
% path: file path to directory containing image sequence
% frames: range of frames (e.g. 1:256) to sonify
% xh: output audio signal
% yh: auditory spectrogram

use_3d = 1; %map three spatial dimensions to rate-scale-freq, else map two+color
use_cor2aud = 1; %use cortical rep, else flatten and use as auditory spectrogram
use_aud2wav = 0; %use convex projection, else use oscillator bank

log_plot = 0;
write_audio = 1; % write a wav file
write_video = 1; % write an mp4 file

sr = 44100; %audio samplerate, forced to 16kHz if use_aud2wav
bpo = 28; %bands per octave, forced to 24 if use_aud2wav
filts = 256; %total bands, forced to 128 if use_aud2wav
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

slice = [16 16]; %horizontal, vertical number of cells if use_3d

resamp_pre = 1; %factor to downsample rate-scale plane
resamp_post = 1; %factor to downsample time-frequency spectrogram

corname = 'fb.cor'; %name of cor file if use_cor2aud

if use_aud2wav
    sr = 16000;
    filts = 128;
    bpo = 24;
end

%interpret image sequence
if use_3d
    [data video] = read_images(path, frames, slice, resamp_pre);
else     
    [data video] = read_images_2(path, frames, filts*resamp_post, resamp_pre);
end

nans = isnan(data);
sprintf('%d nans in data',sum(nans(:)))

%obtain auditory spectrogram
if use_cor2aud
    write_cor(data, corname, paras, bpo, bounds);

    [yh, para1, rv, sv, HH] = cor2aud(corname);
    %imagesc(HH); figure;
    %para1
    %yh = max(0, real(yh)+imag(yh));
    %yh = abs(yh);
else
    yh = squeeze(mean(mean(data)));
end
yh = aud_fix(yh);


if resamp_post > 1
    yh = resample(yh,1,resamp_post,resamp_post);
    yh = resample(yh',1,resamp_post,resamp_post)';
end

imagesc(yh'); %figure;

%synthesize audio
if use_aud2wav
    xh = aud2wav(yh, [], [paras 10 1 0]);
else
    xh = osc_bank(yh', lofreq, bpo, frmlen, sr);
end

%write audio and video files
if write_video
    fr = resamp_post*1000/frmlen;
    writer = VideoWriter(sprintf('%s-frames-%d-%d.avi', path, frames(1), frames(length(frames))));
    writer.FrameRate = fr;
    open(writer);
    writeVideo(writer, video);
    close(writer);
end

if write_audio
    audio = xh/max(abs(xh));
    audiowrite(sprintf('%s-frames-%d-%d.wav', path, frames(1), frames(length(frames))), audio, sr);
end;
%savefig(sprintf('%s-frames-%d-%d.fig', path, frames(1), frames(length(frames))));

if log_plot
    aud_plot_2(log(max(.0001,yh)), [paras bpo lofreq]);
else
    aud_plot_2(yh, [paras bpo lofreq]);    
end
    
end

