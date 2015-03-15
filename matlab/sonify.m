function [xh, yh] = sonify( path, frames )

use_3d = 0; %map three spatial dimensions to rate-scale-freq, else map two+color
use_cor2aud = 1; %use cortical rep, else flatten and use as auditory spectrogram
use_aud2wav = 0; %use convex projection, else use oscillator bank

sr = 44100; %audio samplerate, forced to 16kHz if use_aud2wav
bpo = 29; %bands per octave, forced to 24 if use_aud2wav
filts = 256; %total bands, forced to 128 if use_aud2wav

frmlen = 32; %frame length in ms
tc = 64; %integration time constant in ms (only matters if use_aud2wav)
fac = .1; %compression type (only matters if use_aud2wav)
shft = 0; %octave shift, do not change (only matters if use_aud2wav)
paras = [frmlen tc fac shft];

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
    write_cor(data, corname, paras, bpo);

    [yh, para1, rv, sv, HH] = cor2aud(corname);
    %imagesc(HH); figure;
    %para1
    %yh = max(0, real(yh)+imag(yh));
    %yh = abs(yh);
    yh = aud_fix(yh);
else
    yh = squeeze(mean(mean(data)));
end

if resamp_post > 1
    yh = resample(yh,1,resamp_post,resamp_post);
    yh = resample(yh',1,resamp_post,resamp_post)';
end

imagesc(yh'); %figure;

%synthesize audio
if use_aud2wav
    xh = aud2wav(yh, [], [paras 10 1 0]);
else
    xh = osc_bank(yh', 20, bpo, frmlen, sr);
end

%write audio and video files
fr = resamp_post*1000/frmlen;

writer = VideoWriter(sprintf('%s-frames-%d-%d.avi', path, frames(1), frames(length(frames))));
writer.FrameRate = fr;
open(writer);
writeVideo(writer, video);
close(writer);

audio = xh/max(abs(xh));
audiowrite(sprintf('%s-frames-%d-%d.wav', path, frames(1), frames(length(frames))), audio, sr);

%savefig(sprintf('%s-frames-%d-%d.fig', path, frames(1), frames(length(frames))));


end

