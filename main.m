% Program to implement stiching of multiple images

%filename   1       2      3       4        5
datasets={'rosen','mov3','mov2','glacier4','lake'};

filename=5; %%change this based on the above dataset no

if isnumeric(filename)
    folder_no=filename;
    path='imgs';
else
    if strcmp(filename(end),'/')
        filename=filename(1:end-1);
    end
    [path,dataset_name,~]=fileparts(filename);
    disp(['path ',path,' dataset ',dataset_name])
    
    folder_no=find(strcmp(datasets,dataset_name));
end

size_bound=400.0;
f=1000;
% run('vlfeat-0.9.21/toolbox/vl_setup');
disp(['creating panorama for ',datasets{folder_no}]);
s=imageSet(fullfile(path,datasets{folder_no}));
img=read(s,1);
size_1=size(img,1);
if size_1>size_bound
    img=imresize(img,size_bound/size_1);
end
imgs=zeros(size(img,1),size(img,2),size(img,3),s.Count,'like',img);
t=cputime;

for i=1:s.Count
    new_img=read(s,i);
    if size_1>size_bound
        imgs(:,:,:,i)=imresize(new_img,size_bound/size_1);
    else
        imgs(:,:,:,i)=new_img;
    end
    % subplot(2,5,i), imshow(new_img);
end


panorama=create(imgs, f);
imwrite(panorama,['./results/',datasets{folder_no},'.jpg']);

figure();
imshow(panorama);