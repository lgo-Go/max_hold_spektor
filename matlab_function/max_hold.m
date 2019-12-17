clear all
clc
close all

%% Sample

fs = 8000; % Частота дискретизации
dt = 1/fs; % Интервал дискретизации
fmain = 10; % Частота полезного синуса
ferr = 1000; % Частота мешающего синуса
Amain = 10; % Амплитуда полезного синуса
Aerr = 1; % Амплитуда мешающего синуса
n = (0:8000)'; % Шкала времени (номера отсчетов)
t = n*dt; % Шкала времени (в секундах)
ns = length(n); % Количество отсчетов сигнала

sig_main = Amain*sin(2*pi*fmain*n/fs); % Полезный синус
spektr = fft(sig_main);

figure(1)
hold all
grid on
plot(t,sig_main,'r')
figure(2)
hold all
grid on
plot(t,spektr,'g')

%%

fid = fopen('File1_fd20_1_ofdm_only.pcm');
Num_of_samples = 140000;
data = fread(fid,Num_of_samples,'int16');
fclose(fid);
data_i = downsample(data,2);
data_q = downsample(data,2,1);
data_samples = complex(data_i,data_q);

max_hold_spktr = (1:128)';
max_hold_spktr(1) = max(fft(data(1:1024)));
for i = 2 : 128
    max_hold_spktr(i) = max(fft(data((i-1)*1024:i*1024)));
end

% figure(1)
% grid on
% hold on
% plot(data)

figure(2)
grid on
hold on
plot(data_i)

figure(3)
grid on
hold on
plot(abs(fft(data_samples)))

figure(7)
plot(abs(fftshift(fft(data_samples))))

figure(4)
grid on
hold on
plot(abs(max_hold_spktr))

% figure(3)
% grid on
% hold on
% plot(data_q)
% 
% figure(4)
% grid on
% hold on
% plot(data_samples)


%%

wr_sig_full = round(data);
dlmwrite('data.dat',wr_sig_full);