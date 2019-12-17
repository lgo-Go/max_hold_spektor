clear all
clc
close all

%% Sample

fs = 8000; % ������� �������������
dt = 1/fs; % �������� �������������
fmain = 10; % ������� ��������� ������
ferr = 1000; % ������� ��������� ������
Amain = 10; % ��������� ��������� ������
Aerr = 1; % ��������� ��������� ������
n = (0:8000)'; % ����� ������� (������ ��������)
t = n*dt; % ����� ������� (� ��������)
ns = length(n); % ���������� �������� �������

sig_main = Amain*sin(2*pi*fmain*n/fs); % �������� �����
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