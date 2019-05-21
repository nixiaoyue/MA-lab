%% Importing Data by its file name
data = importdata('test3.tsv');

%%Data Extraction/ Conversion/ Parameters

convv = 4/(2^16);                %bit to acceleration: +/-2g with 16bit res.

tt = data.data(:,1)/1000;       %Time stamp (Unit: ms/1000 = s)
ax = data.data(:,2)*convv;       %X-axis acceleration (Unit: g, Sampling Rate: 200Hz)    
ay = -data.data(:,3)*convv;      %Y-axis acceleration (Unit: g, Sampling Rate: 200Hz  
az = -data.data(:,4)*convv;      %Z-axis acceleration (Unit: g, Sampling Rate: 1600Hz   

fs = round(1/mean(diff(tt)));   %Z-axis sampling frequency

%%%% get rid of NaN values
% look into the data structure to see why NaN values are there
idx = ~isnan(ax);
t2 = tt(idx);
ax = ax(idx);
ay = ay(idx);

fs_xy = round(1/mean(diff(t2))); %X, Y-axis sampling frequency

%% Band-pass
az_h = myfilt(az, fs, [20, 50], 'bandpass');

% plot raw vs. Band-passed signals
figure(4)
ax(1)=subplot(211);
plot(tt, az, 'k')
ylabel('Raw Signal (g)')
ax(2)=subplot(212);
plot(tt, az_h, 'k')
linkaxes(ax, 'x')
xlim([tt(1), tt(end)])
xlabel('Time (s)')
ylabel('20-50Hz BP Signal (g)')

%% Peak finding algorithm for an overview
[qrspeaks,locs] = findpeaks(az_h,tt,'MinPeakProminence',0.005, 'MinPeakHeight', 0.005,...
'MinPeakDistance', 0.15);
hold all
plot(locs, qrspeaks, '.', 'MarkerSize', 10)

%% HR analysis in 5-s moving window
Win = 5;
TT = tt(end);          % total time of the test
LWin = Win*fs;         % time window in data length
tvec = Win/2:Win:TT;   % center time vector
is = round(tvec * fs - LWin/2) + 1; % center time index

% loop over each time window for HR analysis
HR = nan(length(is), 1);
HR_amp = nan(length(is), 1);

span = (60/400)*fs; % assuming 200BPM max HR
if mod(span, 2)~=1
    span = span-1;
end
for ii = 1:length(is)
    dd0 = GetData(az_h, is(ii), LWin);
    tt0 = (0:LWin)'/fs;

    % peak detection algorithm
    [qrspeaks,locs] = findpeaks(dd0,tt0,'MinPeakProminence',0.005, 'MinPeakHeight', 0.005,...
    'MinPeakDistance', 0.15);
    interv1 = diff(locs);

    % remove time intervals that are beyond physiological limits
    idx = interv1>1.2 | interv1<0.1;
    interv1(idx) = []; % period --> bpm: 1/1.2*60
    if length(interv1)>=5
        HR(ii) = 1./mean(interv1)*60/2;
        HR_amp(ii) = mean(qrspeaks(qrspeaks<0.5));
    end
end

%% Plot HR vs. Cardiac Force Amplitude
figure(5)
yyaxis left
plot(tvec, HR)
ylabel('HR (BPM)')
yyaxis right
plot(tvec, HR_amp)
ylabel('Amplitude (g)')
xlabel('Time (s)')

