%% Importing Data by its file name
data = importdata('test1.tsv');

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

%% plot raw data
figure()
plot(tt,az, t2, ax, t2, ay)

%% Spectrum Analysis
ww = round(fs*30); % window length
[pp, ff] = pwelch(az,hann(ww),ww/2,ww,fs); % power density spectrum of data
loglog(ff, sqrt(pp))
xlabel('Frequency (Hz)')
ylabel('PSD (?)')
