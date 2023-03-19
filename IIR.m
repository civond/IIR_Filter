clear all;

[s, Fs] = audioread('clean.wav');     % speech signal
[x, Fs] = audioread('noisy.wav');     % speech signal with tonal noise

N = length(x);
t = (0:N-1)'/Fs;            % t : time axis

f_null = 500;          % frequency to null out
om_null = 2 * pi * f_null / Fs;



%% FIR notch filter

K_fir = 1/(2 - 2 * cos(om_null));
b_fir = K_fir * [1 -2*cos(om_null) 1];               % filter coefficients
a_fir = 1;

y_fir = filter(b_fir,a_fir,x);
%% IIR notch filter
r = 0.95;


b_iir1 = [1 -2*cos(om_null) 1];        % filter coefficients
a_iir1 = [1 -2*r*cos(om_null) r^2];    % filter coefficients
K_iir1 = sum(a_iir1) / sum(b_iir1);
b_iir1 = K_iir1* b_iir1;
y_iir1 = filter(b_iir1,a_iir1,x);

b_iir2 = [1 (-4*cos(om_null)) (2+4*cos(om_null)^2) (-4*cos(om_null)) 1];        % filter coefficients
a_iir2= [1 (-4*r*cos(om_null)) (2*(r^2)+4*(cos(om_null)^2)*r^2) (-4*(r^3)*cos(om_null)) ((r^4))];
K_iir2 = sum(a_iir2) / sum(b_iir2);                        % make dc gain equal to 1
b_iir2 = K_iir2* b_iir2;

y_iir2 = filter(b_iir2,a_iir2,x);

%% Pole Diagram

figure(1);
subplot(3,1,1);
zplane(b_fir,a_fir);
title('FIR Pole-Zero Diagram');

subplot(3,1,2);
zplane(b_iir1,a_iir1);
title('2nd Order IIR Pole-Zero Diagram');

subplot(3,1,3);
zplane(b_iir2,a_iir2);
title('4th Order IIR Pole-Zero Diagram');

figure(8);
subplot(1,2,1);
zplane(b_iir1,a_iir1);
title('2nd Order IIR Pole-Zero Diagram');

subplot(1,2,2);
zplane(b_iir2,a_iir2);
title('4th Order IIR Pole-Zero Diagram');

%% Impulse Response

del = @(n) double(n == 0);
n = -10:30;

h_fir = filter(b_fir,a_fir,del(n));
h_iir1 = filter(b_iir1,a_iir1,del(n));
h_iir2 = filter(b_iir2,a_iir2,del(n));

figure(2);
subplot(3,1,1);
stem(n,h_fir,MarkerSize=2);
title('FIR Impulse Response');
grid("on");

subplot(3,1,2);
stem(n,h_iir1,MarkerSize=2);
title('2nd Order IIR Impulse Response');
grid("on");

subplot(3,1,3);
stem(n,h_iir2,MarkerSize=2);
title('4th Order IIR Impulse Response');
grid("on");

%% Frequency Response

[H_fir, om_fir] = freqz(b_fir, a_fir);
[H_iir1, om_iir1] = freqz(b_iir1, a_iir1);
[H_iir2, om_iir2] = freqz(b_iir2, a_iir2);

figure(3);
subplot(3,1,1);
plot(om_fir/(2*pi)*Fs, abs(H_fir))
xlabel('Frequency (Hz)')
title('FIR Filter Frequency Response');
grid("on");

subplot(3,1,2);
plot(om_iir1/(2*pi)*Fs, abs(H_iir1))
xlabel('Frequency (Hz)')
title('2nd Order IIR Filter Frequency Response');
grid("on");

subplot(3,1,3);
plot(om_iir2/(2*pi)*Fs, abs(H_iir2))
xlabel('Frequency (Hz)')
title('4th Order IIR Filter Frequency Response');
grid("on");

%% Filter Signal!
figure(4)
subplot(2,1,1);
plot(t,x);
title('Noisy Signal');
grid("on");

subplot(2,1,2);
plot(t,s);
title('Clean Signal');
grid("on");

figure(5);
subplot(3,1,1);
plot(t,y_fir);
hold("on");
plot(t,s);
title('FIR Filter');
legend('Filtered','Clean Signal')
grid("on");

subplot(3,1,2);
plot(t,y_iir1);
hold("on");
plot(t,s);
title('FIR Filter');
legend('Filtered','Clean Signal')
grid("on");

subplot(3,1,3);
plot(t,y_iir2);
hold("on");
plot(t,s);
title('4th Order IIR Filter');
legend('Filtered','Clean Signal')
grid("on");

figure(6);
subplot(2,1,1);
plot(t,y_iir1);
hold("on");
plot(t,s);
title('2nd Order IIR Filter');
legend('Filtered','Clean Signal')
grid("on");
xlim([1.25,1.45]);

subplot(2,1,2);
plot(t,y_iir2,Color='#0E7ECB');
hold("on");
plot(t,s);
title('4th Order IIR Filter');
legend('Filtered','Clean Signal')
grid("on");
xlim([1.25,1.45]);

%% Export audoio files

%audiowrite('output_FIR.wav', y_fir, Fs);
%audiowrite('output_IIR_2nd.wav', y_iir1, Fs);
audiowrite('output_IIR_4th.wav', y_iir2, Fs);
