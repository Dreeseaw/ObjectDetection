%makes an array of folder names for each image set
projectFolder = '.\Project3-DataSets';
imageSetsFolder = fullfile(projectFolder, 'DataSets');
dirs = dir(imageSetsFolder);
isub = [dirs(:).isdir];
imageSets = {dirs(isub).name};
imageSets(ismember(imageSets, {'.','..'})) = [];

%Makes a new folder for the image set output subfolders
mkdir(projectFolder, 'Outputs');
outputFolder = fullfile(projectFolder, 'Outputs');

%iterates the motion detection algorithm over each image set
for set = 1:length(imageSets)
    %makes a structure containing the information for all the jpegs in the
    %image set
    thisSet = imageSets{set};
    imFolder = fullfile(imageSetsFolder, thisSet);
    filePattern = fullfile(imFolder, '*.jpg');
    jpegFiles = dir(filePattern);
    
    %makes a new folder to store the output images
    saveFolderName = strcat(thisSet, '_output');
    mkdir(outputFolder, saveFolderName);
    
    %algorithm parameters
    sfdLambda = 0.001;
    pfdLambda = 0.1;
    pfdGamma = 7;
    absAlpha = 0.1;
    
    permIm = imread(fullfile(imFolder, jpegFiles(1).name));
    permIm = im2double(permIm);
    permIm = rgb2gray(permIm);
    
    pfdPrevTemp = permIm;
    absPrevIm = permIm;
    
    %iterates over each image in the set
    for im = 1:length(jpegFiles)-1
        %loads in the current frame and the previous frame
        currentFileName = fullfile(imFolder, jpegFiles(im+1).name);
        lastFileName = fullfile(imFolder, jpegFiles(im).name);
        currentIm = imread(currentFileName);
        lastIm = imread(lastFileName);
        
        %converts the frames to grayscale, double precision
        currentIm = im2double(currentIm);
        currentIm = rgb2gray(currentIm);
        lastIm = im2double(lastIm);
        lastIm = rgb2gray(lastIm);
        
        %simple frame differencing algorithm
        simpleFD = abs(currentIm - lastIm);
        simpleFD(find(simpleFD < sfdLambda)) = 0;
        
        %persistant frame differencing algorithm
        pfdTemp = currentIm - lastIm;
        pfdTemp(find(pfdTemp < pfdLambda)) = 0;
        
        pfdPrevTemp = pfdPrevTemp - pfdGamma;
        pfdPrevTemp(find(pfdPrevTemp < 0)) = 0;
        pfdNewTemp = pfdPrevTemp;
        pfdTemp = 255*pfdTemp;
        pfdTemp(pfdTemp < pfdNewTemp) = pfdNewTemp(pfdTemp < pfdNewTemp);
        pfdPrevTemp = pfdTemp;
        
        persistentFD = pfdTemp;
        persistentFD = persistentFD/255;
        
        %simple background subtraction algorithm
        sbsDiff = abs(currentIm - permIm);
        sbsDiff(find(sbsDiff < sfdLambda)) = 0;
        
        %adaptive backgound subtraction algorithm
        adaptiveBG = abs(absPrevIm - currentIm);
        adaptiveBG(find(adaptiveBG < sfdLambda)) = 0;
        
        absTempAlpha = immultiply(currentIm, absAlpha);
        absTemp_B_Alpha = immultiply(absPrevIm, (1- absAlpha));
        absPrevIm = imadd(absTempAlpha, absTemp_B_Alpha);
        
        %generate side by side image
        compIm = [sbsDiff, simpleFD; adaptiveBG, persistentFD];
        
        %overlays what algorithm was run over its output
        [y_dim, x_dim] = size(compIm);
        textArray = {'Simple BG Subtract', 'Simple Frame Diff', 'Adaptive BG', 'Persistent Frame Diff'};
        posArray = [(0.01*y_dim) (0.2*x_dim);(0.01*y_dim) (0.7*x_dim);(0.51*y_dim) (0.2*x_dim);(0.51*y_dim) (0.7*x_dim)];
        imText = insertText(compIm, posArray, textArray,'FontSize', 18, 'TextColor', 'white');
        
        
        %saves the composite image to the image set's output folder
        saveImageName = strcat(imageSets{set}, num2str(im, '%04d'), '.jpg');
        saveFileName = fullfile(outputFolder, saveFolderName, saveImageName);
        imwrite(compIm, saveFileName);
    end
end


