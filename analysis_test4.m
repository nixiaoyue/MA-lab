%% Importing Data by its file name
data = importdata('test4.tsv');

%%Data Extraction/ Conversion/ Parameters

convv = 4/(2^16);                %bit to acceleration: +/-2g with 16bit res.

tt = data.data(:,1)/1000;       %Time stamp (Unit: ms/1000 = s)
ax = data.data(:,2)*convv;       %X-axis acceleration (Unit: g, Sampling Rate: 200Hz)    
ay = -data.data(:,3)*convv;      %Y-axis acceleration (Unit: g, Sampling Rate: 200Hz  
az = -data.data(:,4)*convv;      %Z-axis acceleration (Unit: g, Sampling Rate: 1600Hz   

fs = round(1/mean(diff(tt)));   %Z-axis sampling frequency
tt = (1:length(az))/fs;         %reconstruct time vector to correct for time-stamp bug

%%%% get rid of NaN values
% look into the data structure to see why NaN values are there
idx = ~isnan(ax);
t2 = tt(idx);
ax = ax(idx);
ay = ay(idx);

fs_xy = round(1/mean(diff(t2))); %X, Y-axis sampling frequency

%% Filter Design
% Respiration
az_r = myfilt(az, fs, [0.1, 0.8], 'bandpass');

% Other high frequency, transient signals, focus on swallow in this case
% give it a minute to think about why [90, 150] or so.
az_t = myfilt(az, fs, [90, 150], 'bandpass');

% Let's try something more interesting:
az_bp = myfilt(az, fs, [0.1, 150], 'bandpass'); % bandpass first
az_bp_bs = myfilt(az_bp, fs, [0.8, 90], 'stop'); % then bandstop

%% 
figure(5)
ax(1)=subplot(211);
plot(tt, az, 'k')
ylabel('Raw Signal (g)')
ax(2)=subplot(212);
plot(tt, az_bp_bs, 'k')
ylabel('Bandpassed + Bandstoped Signal (g)')
xlabel('Time (s)')
linkaxes(ax, 'x')
xlim([tt(1), tt(end)])
