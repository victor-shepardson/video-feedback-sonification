function write_cor( data, fname, paras, bpo, bounds )
% write a synthetic .cor file for use with the NSL toolbox
% data: 4D scale-rate-time-frequency analysis
% fname: save file name

%	PARAS	= [frmlen, tc, fac, shft];
%	frmlen	: frame length, typically, 8, 16 or 2^[natural #] ms.
%	tc	: time const., typically, 4, 16, or 64 ms, etc.
%		  if tc == 0, the leaky integration turns to short-term avg.
%	fac	: nonlinear factor (critical level ratio), typically, .1 for
%		  a unit sequence, e.g., X -- N(0, 1);
%		  The less the value, the more the compression.
%		  fac = 0,  y = (x > 0),   full compression, booleaner.
%		  fac = -1, y = max(x, 0), half-wave rectifier
%		  fac = -2, y = x,         linear function
%	shft	: shifted by # of octave, e.g., 0 for 16k, -1 for 8k,
%		  etc. SF = 16K * 2^[shft].%	
%	 FULLT (FULLX): fullness of temporal (spectral) margin. The value can
%		be any real number within [0, 1].
%	 BP	: pure bandpass indicator
%	 rv	: rate vector in Hz, e.g., 2.^(1:.5:5).
%	 sv	: scale vector in cyc/oct, e.g., 2.^(-2:.5:3).

FULLT = 0; % do not change
FULLX = 0; % do not change
BP = 0;

min_rate = bounds(1);
max_rate = bounds(2);
min_scale = bounds(3);
max_scale = bounds(4);

% dimensions
[K2, K1, N, M]	= size(data)	% dimensions of auditory spectrogram: s, r, t, f
K1 = K1/2;
rv = 2.^((0:K1-1)*(max_rate-min_rate)/(K1-1)+min_rate);
sv = 2.^((0:K2-1)*(max_scale-min_scale)/(K2-1)+min_scale);

%because of the way NSL handles +- rate filters, we may want to rearrange
%dimension 2
data = [fliplr(data(:,1:2:2*K1,:,:)) data(:,2:2:2*K1,:,:)];

fout = fopen(fname, 'w');
fwrite(fout, [paras(:); K1; K2; rv(:); sv(:); N; M; FULLT; FULLX], ...
    'float');  

for rdx = 1:K1
    for sgn = [1 -1]
        rdx2 = 2*rdx-1+(sgn<0);
        for sdx = 1:K2
            % z is complex valued time-frequency signal after rate-scale filter
            % identified by (sdx, rdx)
            z = squeeze(data(sdx, rdx2, :, :));
            phi_f = repmat((sv(sdx)/bpo)*(1:M), N, 1);
            phi_t = repmat((rv(rdx)*sgn*paras(1)/1000)*(1:N)', 1, M);
            phi = phi_f+phi_t;
            z = z.*exp(pi*2i*phi);
            corcplxw(z, fout);
        end
    end
end
fclose(fout);

end

