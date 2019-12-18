clear all
clc
close all

%% Sample

fs = 8000; % ������� �������������
dt = 1/fs; % �������� �������������
fmain = 10; % ������� ��������� ������
ferr = 15; % ������� ��������� ������
f3 = 50; % ������� ��������� ������
f4 = 45; % ������� ��������� ������
Amain = 10; % ��������� ��������� ������
Aerr = 5; % ��������� ��������� ������
A3 = 20; % ��������� ��������� ������
A4 = 15; % ��������� ��������� ������
n = (0:8000); % ����� ������� (������ ��������)
t = n*dt; % ����� ������� (� ��������)
ns = length(n); % ���������� �������� �������

sig_main = Amain*sin(2*pi*fmain*n/fs); % �������� �����
sig_err = Aerr*sin(2*pi*ferr*n/fs);
sig_3 = A3*sin(2*pi*f3*n/fs);
sig_4 = A4*sin(2*pi*f4*n/fs);
sig_full = sig_main + sig_err + sig_3 + sig_4;
spektr = abs(fft(sig_full));

figure(1)
hold all
grid on
plot(t, sig_full, 'r')
figure(2)
hold all
grid on
stem(spektr/ns*2,'-o g')

%% Sample max_hold

fs = 8000; % ������� �������������
dt = 1/fs; % �������� �������������
n = (1:8000); % ����� ������� (������ ��������)
t = n*dt; % ����� ������� (� ��������)
ns = length(n); % ���������� �������� �������

f = 1 : 2 : 40;
A = 1 : 2 : 40;

sig = zeros(20, 8000);
for i = 1 : 20
    sig(i, :) = A(i)*sin(2*pi*f(i)*n/fs);
end

sig_full = sum(sig);
spektr = abs(fft(sig_full));

max_hold_spktr = (1:2000);
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
figure(2)
hold all
grid on
stem(spektr/ns*2,'-o g')

figure(3)
hold all
grid on
stem(max_hold_spktr/(ns/4)*2,'-o g')

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