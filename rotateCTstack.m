%Rotate CT stack, rotate stack B with respect to stack A

%Get stack A
[fileA, pathA] = ...
    uigetfile({'*.tif';'*.*'},'Select (last) image Stack A');
if isequal(fileA,0)
    disp('User selected Cancel')
else
    %Get stack B
    [fileB, pathB] = ...
        uigetfile({'*.tif';'*.*'},'Select (first) image Stack B',pathA(1:end-2));
    if isequal(fileB,0)
        disp('User selected Cancel')
    end
end

%Open images
imA = imread(fullfile(pathA,fileA));
imB = imread(fullfile(pathB,fileB));

%Show images and indicate shell halves
hFig = figure;
imshowpair(imA,imB,'montage')
title(['Left: ',fileA,' || Right: ',fileB])

h = msgbox('Click two points between the shell halves for A and B');
uiwait(h)
[x,y]=ginput(4);
X = round(x);
Y = round(y);
line(X(1:2),Y(1:2))
line(X(3:4),Y(3:4))


% Rotate image
dA = atan2d(Y(2)-Y(1),X(2)-X(1));
dB = atan2d(Y(4)-Y(3),X(4)-X(3));
J = imrotate(imB,dB-dA,'bilinear','crop');
hFig2 = figure;
imshowpair(imA,J)
title([fileB,' rotated: ',num2str(dB-dA),' degree'])

user = questdlg('Rotate all images?', ...
	'Rotate?', ...
	'Yes','No','Yes');
if strcmp(user,'No')
    %do nothing
    close(hFig)
    close(hFig2)
else
    oldFolder =pwd;
    cd(pathB)
    Files = ls([fileB(1:end-8),'*.tif']); 
    cd(oldFolder)
    [nFiles,~]=size(Files);
    for idFile = 1:nFiles
        IM = imread(fullfile(pathB,Files(idFile,:)));
        JM = imrotate(IM,dB-dA,'bilinear','crop');
        imwrite(JM,fullfile(pathB,Files(idFile,:)));
    end
    close(hFig)
    close(hFig2)
end