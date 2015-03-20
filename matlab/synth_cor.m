function data = synth_cor( ddim )
% ddim: scale-rate-time-frequency

data = zeros(ddim);

s = floor(ddim(1)/2);
r = floor(ddim(2)/2);
f = floor(ddim(4)/2);

%data(1,1,50,128) = 1;
%data(:,1,100,128) = ones(1, ddim(1))/ddim(1);
%data(1,:,150,128) = ones(1, ddim(2))/ddim(2);
%data(:,:,200,128) = ones(ddim(1:2))/ddim(1)/ddim(2);

% data(1,8,:,192) = ones(1, ddim(3));
% data(6,9,:,128) = ones(1, ddim(3));
% data(5,1,:,64) = ones(1, ddim(3));

% data(11,1,:,204) = ones(1, ddim(3));
% data(11,4,:,153) = ones(1, ddim(3));
% data(11,7,:,102) = ones(1, ddim(3));
% data(11,10,:,51) = ones(1, ddim(3));

% data(1,1,50,128) = 1;
% data(4,1,100,128) = 1;
% data(7,1,150,128) = 1;
% data(10,1,200,128) = 1;

% data(1, 10, 50, 128) = 1;
% data(4, 10, 100, 128) = 1;
% data(7, 10, 150, 128) = 1;
% data(10, 10, 200, 128) = 1;

% for t= 1:ddim(3)
%     s = ceil(rand()*ddim(1));
%     r = ceil(rand()*ddim(2));
%     f = ceil(rand()*ddim(4));
%     data(s,r,t,f) = 1;
% end

     function y = clamp(x,lo,hi)
         y = min(max(x,lo),hi);
     end
 for t= 1:ddim(3)
      s = clamp(s+floor(rand()*3)-1, 1, ddim(1));
      r = clamp(r+floor(rand()*3)-1, 1, ddim(2));
      f = clamp(f+floor(rand()*3)-1, 1, ddim(4));
      data(s,r,t,f) = 1;
 end


%data = data .* exp(pi*2i*rand(ddim));


end