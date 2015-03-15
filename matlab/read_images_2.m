function [ data, video ] = read_images_2( path, frames, filts, resamp )
% read a series of images into a 4d [scale rate time frequency] matrix
% path: directory containing images
% frames = [first:last]: indeces of images to read
% cell is a slice in the vertical dimension, numbered in row major order
% resamp: factor by which to downsample each scale-rate surface e.g. resamp=2
% means 4 pixels per filter
vdim = [];
data = [];

window = 0;

twindow = .5-.5*cos(2*pi*(0:(length(frames)-1))/(length(frames)-1));
fwindow = .5-.5*cos(2*pi*(0:(filts-1))/(filts-1));

%plot(window)
for frame = frames
    % construct file name
    fname = sprintf('%s/%05d.png', path, frame)
    t = frame-frames(1)+1

    % read image
    color_img = imread(fname);
    img = permute(double(color_img)/255, [2 1 3]);
    if window
        img = img*twindow(t);
    end
    dim = size(img);
    if resamp > 1
        img = resample(img, 1, resamp, resamp);
        img = permute(img, [2 1 3]);
        img = resample(img, 1, resamp, resamp);
        img = permute(img, [2 1 3]);
        img = reshape(img, [dim(1:2)/resamp dim(3)]); 
    end    
    img = rgb2hsv(img);
    dim = size(img);
    
    %allocate on first frame
    if frame == frames(1)
        ddim = [dim(1:2) length(frames) filts]; %[scale rate time freq]
        data = zeros(ddim);
        vdim = [size(color_img) length(frames)];
        video = zeros(vdim, 'uint8');
    end
    
    %store color image in video volume
    video(:,:,:,t) = color_img;
    
    %for each (scale, rate) determine frequency activation from color
    for s = 1:dim(1)
        for r = 1:dim(2)
            color = squeeze(img(s,r,:))./[1 1 255]';
            % hue -> frequency
            % saturation-> bandwidth
            % value -> magnitude
            activs = (1:filts)/filts - color(1); %distance from center
            sigma = 1-color(2) + color(2)/(filts*2);
            activs = exp(-activs.*activs/(sigma*sigma)); %gaussianfft
            activs = 2.^(10-10*color(3))*activs./((activs==0)+sum(abs(activs))); %normalize and scale
            if window
                activs = activs.*fwindow;
            end
            %activs = abs(activs).*exp(rand(size(activs))*pi*2i); %random
            %phase
            data(s,r,t,:) = activs;
        end
    end
end

size(data)

end

