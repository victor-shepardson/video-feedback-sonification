function signal = osc_bank(freq_time, lo_freq, bpo, frame_ms, samplerate)

    [bands frames] = size(freq_time);
    frame_samps = floor(frame_ms/1000*samplerate);
    
    sampct = 0:(frames*frame_samps-1);
    
    freqs = 2.^((0:bands-1)/bpo)*lo_freq;
    
    signal = zeros(1, frames*frame_samps);
    for b = 1:bands    
        sprintf('synthesizing band %d',b)
        phase = sampct*freqs(b)/samplerate+rand();
        amps = resample(freq_time(b, :), frame_samps, 1, 2);
        signal = signal + sin(2*pi*phase).*amps;
    end
end