%% Importing Data by its file name
data = importdata('test2.tsv');

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

%% Spectrogram Analysis
x = myfilt(az, fs, 5, 'high'); %analysis on high-passed z axis data (normal to the skin)

window = round(fs*0.1);         %window = 0.1 sec 
noverlap = round(fs*0.09);      %overlap = 0.09 sec

figure(1) 
subplot(2,1,1)  % generate a figure containing 2(row) x 1(column) subplots
plot(tt,az)  % plot the raw data vs. time for comparison
xlim([tt(1), tt(end)])
xlabel('Time (s)')
ylabel('Acceleration (g)')

subplot(2,1,2)
% Use Mathworks documentation for details of spectrogram function
% https://www.mathworks.com/help/signal/ref/spectrogram.html
spectrogram(x,window,noverlap,fs,fs,'yaxis')
colorbar off
% caxis([-80 -50]) % Adjust Z-axis range (Unit: dB)