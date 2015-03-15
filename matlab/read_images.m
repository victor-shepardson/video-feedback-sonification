function [ data, video ] = read_images( path, frames, slice, resamp )
% read a series of images into a 4d [scale rate time frequency] matrix
% path: directory containing images
% frames = [first:last]: indeces of images to read
% slice = [slicex, slicey]: number of cells wide/high each image is; each
% cell is a slice in the vertical dimension, numbered in row major order
% resamp: factor by which to downsample each scale-rate surface e.g. resamp=2
% means 4 pixels per filter
vdim = [];
data = [];

%window = .5-.5*cos(2*pi*(0:(length(frames)-1))/(length(frames)-1));
%plot(window)
for frame = frames
    % construct file name
    fname = sprintf('%s/%05d.png', path, frame)
    t = frame-frames(1)+1

    % read image
    color_img = imread(fname);
    img = rgb2hsv(color_img);
    
    % reduce color data: hue -> angle, value*saturation -> log magnitude
    angle = double(img(:,:,1)')*2*pi;
    %mag = window(t) * double(img(:,:,3)')/255;
    %mag = double(img(:,:,3)')/255;
    mag = 2.^(10*double(img(:,:,2)').*double(img(:,:,3)')/255-10);
    
    [img_real img_cplx] = pol2cart(angle, mag);
    img = img_real;%+1i*img_cplx;
    dim = size(img)./resamp;
    
    %allocate on first frame
    if frame == frames(1)
        ddim = [dim./slice length(frames) slice(1)*slice(2)]; %[scale rate time freq]
        data = zeros(ddim);
        vdim = [size(color_img) length(frames)];
        video = zeros(vdim, 'uint8');
    end
    
    %store color image in video volume
    %size(video)
    %size(color_img)
    video(:,:,:,t) = color_img; %double(color_img)/255;
    
    % slice and stack cortical image
    for cy=1:slice(2)
        for cx=1:slice(1)
            xs = ddim(1)*resamp;
            ys = ddim(2)*resamp;
            xr = ((cx-1)*xs+1):(cx*xs);
            yr = ((cy-1)*ys+1):(cy*ys);
            f = cx + (cy-1)*slice(1);
            plane = img(xr, yr);
            if(resamp > 1)
                plane = resample(plane, 1, resamp, resamp);
                plane = resample(plane', 1, resamp, resamp)';
            end
            data(:, :, t, f) = plane;
        end
    end
    %sum(sum(sum(sum(data(:,:,max(t-1,1),:)))))
end

size(data)

end

