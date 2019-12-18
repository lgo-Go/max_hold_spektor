clear all
clc
close all

%% Sample

clear all
clc
close all

fs = 8000; % частота дискретизации
dt = 1/fs; % интервал дискретизации
fmain = 10; % частоты синусоид
ferr = 15;
f3 = 50;
f4 = 45;
Amain = 10; % амплитуды синусоид
Aerr = 5;
A3 = 20;
A4 = 15;
n = (0:8000); % Шкала времени (номера отсчетов)
t = n*dt; % Шкала времени (в секундах)
ns = length(n); % Количество отсчетов сигнала

sig_main = Amain*sin(2*pi*fmain*n/fs); % Синусоиды
sig_err = Aerr*sin(2*pi*ferr*n/fs);
sig_3 = A3*sin(2*pi*f3*n/fs);
sig_4 = A4*sin(2*pi*f4*n/fs);
sig_full = sig_main + sig_err + sig_3 + sig_4; % Суммарный сигнал (в спектре должно быть 4 гармоники)
spektr = abs(fft(sig_full)); % Спектр суммарного сигнала 

figure(1)
hold all
grid on
plot(t, sig_full, 'r')
figure(2)
hold all
grid on
stem(spektr/ns*2,'-o g')

%% Sample max_hold

clear all
clc
close all

fs = 8000; % частота дискретизации
dt = 1/fs; % интервал дискретизации
n = (1:8000); % Шкала времени (номера отсчетов)
t = n*dt; % Шкала времени (в секундах)
ns = length(n); % Количество отсчетов сигнала

f = 1 : 2 : 40; % параметры синусоид
A = 1 : 2 : 40;

sig = zeros(20, ns); % 20 будущих синусоид
for i = 1 : 20
    sig(i, :) = A(i)*sin(2*pi*f(i)*n/fs);
end

sig_full = sum(sig); % Суммарный сигнал
spektr = (abs(fft(sig_full))); % Обычный спектр

max_hold_spktr = (1:2000); % Max Hold спектр
max_hold_spktr(1) = max(abs(fft(sig_full(1:4))));
for i = 2 : 2000
    max_hold_spktr(i) = max(abs(fft(sig_full((i-1)*4 : i*4))));
end

figure(1)
hold all
grid on
plot(t, sig_full, 'r')

figure(2)
hold all
grid on
stem(spektr/ns*2,'-o g')

figure(3)
hold all
grid on
stem(max_hold_spktr/(ns/4)*2, '-o g')

%% Max-Hold spektrum

clear all; clc; close all

% fs = 22000000; % частота дискретизации
% dt = 1/fs; % интервал дискретизации
% n = (1:22000000); % Шкала времени (номера отсчетов)
% t = n*dt; % Шкала времени (в секундах)
% ns = length(n); % Количество отсчетов сигнала

fid = fopen('File1_fd20_1_ofdm_only.pcm');
Num_of_samples = 140000;
data = fread(fid,Num_of_samples,'int16');
fclose(fid);
data_i = downsample(data,2);
data_q = downsample(data,2,1);
data_samples = complex(data_i,data_q);

Ns = Num_of_samples/2;
n = 1 : Ns;
fs = Ns;
dt = 1/fs;
t = n*dt;

max_hold_spktr = (1:128);
max_hold_spktr(1) = max(abs(fft(data_samples(1:546))));
for i = 2 : 128
    max_hold_spktr(i) = max(abs(fft(data_samples((i-1)*546 : i*546))));
end

figure(1)
grid on
hold on
plot(t, data_i)

% figure(2)
% grid on
% hold on
% plot(abs(fft(data_samples)))

figure(3)
grid on
hold on
stem(max_hold_spktr/(Ns/546)*2, '-o b')

%%

wr_sig_full = round(data);
dlmwrite('data.dat',wr_sig_full);