function [stimTimes, stim, duration] = constructStimulus(chargeTime)
% function [stimTimes, stim, duration] = constructStimulus
%
% Currently only supports a single pair of odors.
%
%   To do:
%   1. Add capability for >1 odor pair or concentration
%   2. Convert to GUI for easier setup of complicated exp protocols
%
%   Revised July 21, 2013
%   Kyle Honegger, Harvard & CSHL

if nargin < 1
    chargeTime = 5;
end

% odors = {'Apple' 'Grape'};
% conc = [0.05 0.1];                  % proportion saturated vapor

% odors = {'MCH' 'Air'};
% conc = [0.15 0.03];%  -aMW ctrl               % proportion saturated vapor          % 150119 - balancing concs:
% odors = {'MCH' 'OCT'};
% conc = [0.16 0.13];%  -aMW ctrl               % proportion saturated vapor          % 150119 - balancing concs:


odors = {'Air' 'MCH'};
conc = [0.03 0.15];%  -aMW ctrl               % proportion saturated vapor          % 150119 - balancing concs:
odors = {'OCT' 'Air'};
conc = [.5 0.03];%  -aMW ctrl   
odors = {'Air' 'OCT'}; %SK, this is the line you want to swap to
conc = [0.03 .5];%  -aMW ctrl  
% odors = {'OCT' 'OCT'}; %SK, this is the line you want to swap to
% conc = [0.5 0.5];%  -aMW ctrl  
% 15 11
%conc = [0.09 0.15];
% OLD --------
%conc = [0.15 0.15]; % +aMW exp
%conc = [0.13 0.17];%  -aMW ctrl   
%conc = [0.15 0.15];
% conc = [0.13 0.17];
% conc = [0.05 0.08];
%conc = [0.12 0.18];
%conc = [0.08 0.15];
% 2U = [0.14 0.15]
% MB010B/shi[ts1] = [0.18 0.08]
% R46E11/shi[tsJFRC] = [0.15 0.10]

% R14H04/shi[tsJFRC] = [<0.15 >0.13] or [0.17 0.10]
% R14C11/TNT = [0.14 0.15]
% VT046560/shi[tsJFRC] = [0.1 0.1]
%180
% odorDur = 180;                        % in sec
% isi = 10;                            % in sec
% nBlocks = 1;                         % number of odor blocks
% %180
% preTime = 180;                       % wait time before first odor block
% postTime = 30;                      % wait time after last odor block

%Adjust the duration for odors
odorDur = 30;                        % in sec
isi = 10;                            % in sec
nBlocks = 1;                         % number of odor blocks
%180
preTime = 30;                       % wait time before first odor block
postTime = 10;                      % wait time after last odor block
% odorDur = 180;                        % in sec
% isi = 10;                            % in sec
% nBlocks = 1;                         % number of odor blocks
%
% preTime = 180;                       % wait time before first odor block
% postTime = 30;                      % wait time after last odor block

% Read valve assignments from csv file
fid = fopen('.\TunnelSoftware\Acquisition\odors.csv');
v = textscan(fid, '%s %d %d', 'delimiter', ','); % Format: {Odor, SideA, SideB}
fclose(fid);

% Alternate sides, with random starting side
%OdorAonTop = repmat(randperm(2)-1, [1, ceil(nBlocks/2)]); % Logical vector
% indicating
% blocks with
% odors{1} on top
% (Side B)
OdorAonTop = false;                                                        % KH141217 - hardcode this for consistency

%Odor matrix: [top/bottom concentration; top/bottom valves]
for qq = 1:nBlocks
    
    if OdorAonTop(qq)
        valve(1) = v{3}(strmatch(odors{1}, v{1}));
        valve(2) = v{2}(strmatch(odors{2}, v{1}));
    else
        valve(1) = v{2}(strmatch(odors{1}, v{1}));
        valve(2) = v{3}(strmatch(odors{2}, v{1}));
    end
    
    stim(qq).odor = [conc(1), conc(2); double(valve)];
    
    % Sort odor labels [Side A, Side B]
    if sum((v{2}==valve(1)))
        stim(qq).labels = [v{1}(v{2}==valve(1)) v{1}(v{3}==valve(2))];
    else
        stim(qq).labels = [v{1}(v{2}==valve(2)) v{1}(v{3}==valve(1))];
    end
    
end

if v{1}{find(v{2} == valve(1))} == odors{1}
    conc(1) = conc(1);
else
    conc(1) = conc(2);
end
if v{1}{find(v{3} == valve(2))} == odors{1}
    conc(2) = conc(1);
else
    conc(2) = conc(2);
end


%Build stimulus epochs
if nBlocks > 1
    lastTime = preTime - isi;                 % Runs on first block only
    
    for i=1:nBlocks
        startTime = lastTime + isi;
        stim(i).times = startTime:(startTime + chargeTime + odorDur);
        lastTime = max(stim(i).times) - chargeTime;
    end
    
else
    
    startTime = preTime;
    stim.times = startTime:(startTime + chargeTime + odorDur);
    lastTime = max(stim.times) - chargeTime;
end

duration = lastTime + postTime + chargeTime;

stimTimes = zeros(1,duration + 1);

for qqq=1:nBlocks
    stimTimes(stim(qqq).times) = qqq;
end