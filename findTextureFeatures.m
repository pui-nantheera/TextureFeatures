function features = findTextureFeatures(cubeImg, lowcoef, highcoef, bitsperpixel, listfeature, mask, withphase)
% features = findTextureFeatures(cubeImg, lowcoef, highcoef, bitsperpixel, listfeature, mask, withphase)
%           extract texture features
%
% INPUTS:   cubeImg is a 2D or 3D array of 2D or 3D gray image
%           lowcoef is lowpass coefficients of DT-CWT, which can be left as empty array ([])
%           highcoef is highpass coefficients of DT-CWT, which can be left as empty array ([])
%           bitsperpixel is number of bits of grayscale level (default = 8)
%           listfeature is index telling what features are included,
%                       1 = Intensity level distribution
%                       2 = Run length measures
%                       3 = Co-occurrence matrix
%                       4 = Wavelet transform
%                       5 = Local binary pattern histogram
%                       6 = Granulometry histogram
%                       e.g. listfeature = [1 4 5], intensity level
%                            distribution, wavelet and LBP are extracted
%           mask is a 2D array with same size as cubeImg and region to extract texture features is 1, elsewhere 0. 
%                       If empty ([]), the whole image is used.
%           withphase is to indicate whether the phases of DT-CWT is used (default = 0 no use).
%
% OUTPUTS:  features is a column array of all features concatenated. 
%
% v1.0 by Pui Anantrasirichai, Univerysity of Bristol 20/03/12
% v1.1 by Pui Anantrasirichai, Univerysity of Bristol 25/05/12 choices of features added
% v1.2 by Pui Anantrasirichai, Univerysity of Bristol 05/11/13 choices phase usage added

% -------------------------------------------------------------------------
% default parameters
% -------------------------------------------------------------------------
if (nargin<6) || (isempty(mask))
    mask = ones(size(cubeImg));
end

if nargin<4 || isempty(bitsperpixel)
    bitsperpixel = 8;
end

if nargin<5 || isempty(listfeature)
    listfeature = 1:6;
end

if isempty(lowcoef) || isempty(highcoef) 
    % wavelet transform
    [lowcoef,highcoef] = dtwavexfm2(cubeImg,4,'antonini','qshift_06');
end

if sum(size(cubeImg)==1)>0
    addMat = (size(cubeImg)==1)*2 + 1;
    cubeImg = repmat(cubeImg, addMat);
end

if max(cubeImg(:))>1
    cubeImg = cubeImg/255;
    cubeImg(cubeImg>1) = 1;
end
if nargin < 7
    withphase = 0;
end
% -------------------------------------------------------------------------
% I. Intensity level distribution
% -------------------------------------------------------------------------
if sum(listfeature==1)
    
    % 1) mean
    meanCube = mean(cubeImg(mask(:)>0));
    % 2) variance
    varCube = var(cubeImg(mask(:)>0));
    % 3) skewness
    skewCube = skewness(cubeImg(mask(:)>0));
    % 4) kurtosis
    kurtCube = kurtosis(cubeImg(mask(:)>0));
    % 5) entropy
    entropyCube = entropy(cubeImg(mask(:)>0));
    % concatenated all intensity features
    intensityFeatures = [meanCube varCube skewCube kurtCube entropyCube];
   
else
    meanCube = [];
    varCube = [];
    skewCube = [];
    kurtCube = [];
    entropyCube = [];
end

% -------------------------------------------------------------------------
% II. Run length measures
% -------------------------------------------------------------------------
if sum(listfeature==2)
    
    %  1) Short Run Emphasis (SRE)
    %  2) Long Run Emphasis (LRE)
    %  3) Gray-Level Nonuniformity (GLN)
    %  4) Run Length Nonuniformity (RLN)
    %  5) Run Percentage (RP)
    %  6) Low Gray-Level Run Emphasis (LGRE)
    %  7) High Gray-Level Run Emphasis (HGRE)
    %  8) Short Run Low Gray-Level Emphasis (SRLGE)
    %  9) Short Run High Gray-Level Emphasis (SRHGE)
    %  10) Long Run Low Gray-Level Emphasis (LRLGE)
    %  11) Long Run High Gray-Level Emphasis (LRHGE)
    runLengthStat = findRunLengthProp(cubeImg, bitsperpixel, mask);
else
    runLengthStat = [];
end

% -------------------------------------------------------------------------
% III. Co-occurrence matrix
% -------------------------------------------------------------------------
if sum(listfeature==3)
    
    % 1) angular second moment or energy
    % 2) correlation
    % 3) contrast or inertia
    % 4) entropy
    % 5) Cluster Shade
    % 6) inverse difference moment
    % 7) Homogeneity
    glcmStat = findGLCMProp(cubeImg, mask);
else
    glcmStat = [];
end

% -------------------------------------------------------------------------
% IV. Wavelet transform
% -------------------------------------------------------------------------
if sum(listfeature==4)

% 1) mean and variance 
% 2) kurtosis measures
% 3) fractal dimension
    [cwtParameters,cwtglcmStat,cwtrunLengthStat] = findCWTProp(lowcoef, highcoef, sum(listfeature==2), bitsperpixel, mask, withphase);
else
    cwtParameters = [];
    cwtglcmStat = [];
    cwtrunLengthStat = [];
end


% -------------------------------------------------------------------------
% V. Local Binary Pattern Histogram
% -------------------------------------------------------------------------
if sum(listfeature==5)
    LBPhist = findLBPhist(cubeImg, mask);
else
    LBPhist = [];
end

% -------------------------------------------------------------------------
% VI. Granulometry
% -------------------------------------------------------------------------
if sum(listfeature==6)
    Granhist = findGranulometry(cubeImg);
else
    Granhist = [];
end

% -------------------------------------------------------------------------
% All features;
% -------------------------------------------------------------------------
features = [intensityFeatures runLengthStat glcmStat cwtParameters cwtglcmStat cwtrunLengthStat LBPhist Granhist];