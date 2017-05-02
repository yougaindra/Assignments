
disp('a = 7, b = 8, c = 6, k1 = 8, k2 = 6');
disp('Question-1');
del = zeros(7,1);
del(1) = 1;
y_coeff = [1];
x_coeff = [1,0,7,8,6,0,1];

%1(a)
h = circshift(del,0) + 7*circshift(del,2) + 8*circshift(del,3) + 6*circshift(del,4) + circshift(del,6);
h = h';
disp('The impusle repsonse of given system is:');
disp(h);

pause;

%1(b)
stem(h);
xlabel('n');
ylabel('h[n]');
title('Impulse responce');

pause;

%1(c)
zplane(y_coeff,x_coeff);
title('Pole-Zero Map');

pause;

%1(d)
disp('There is Pole outside Unit Circle, Hence System is unstable');

pause;

%1(e)
x = [1,-1,1,-1]
y = conv(h,x)

subplot(2,1,1)
stem(x);
title('Plot of x[n]');
xlabel('n');
ylabel('x[n]');

subplot(2,1,2)
stem(y);
title('Plot of y[n]');
xlabel('n');
ylabel('y[n]');

pause;

%1(f)
freqz(x,[1],'whole');
title('Magnitude Plot and Frequency Plot of x[n]');

pause;
freqz(y,[1],'whole');
title('Magnitude Plot and Frequency Plot of y[n]');

pause;

freqz(h,[1],'whole');
title('Magnitude Plot and Frequency Plot of h[n]');

pause;

%=======================PART-II================================%
disp('Question-2:');
y_c = [5,8,5];
x_c = [1];
h = impz(x_c,y_c,21);
disp('impulse response for given system is:');
disp(h')

pause;

%2(b)
stem(h);
title('Plot Of h[n]');
xlabel('n');
ylabel('h[n]');

pause;



%2(c)

zplane(y_c,x_c);
title('Pole-Zero map for system');
pause;

%2(d)

disp('since all pole lie inside unit circle, System is Stable');
pause;

%2(e)
x = [1,-1,1,-1];
y = conv(h,x);

subplot(2,1,1);
stem(x);
title('Plot of x[n]');
xlabel('n');
ylabel('x[n]');

subplot(2,1,2);
stem(y);
title('Plot of y[n]');
xlabel('n');
ylabel('y[n]');

pause;

freqz(x,[1],'whole');
title('Magnitude Plot and Frequency Plot of x[n]');

pause;
freqz(y,[1],'whole');
title('Magnitude Plot and Frequency Plot of y[n]');

pause;

freqz(h,[1],'whole');
title('Magnitude Plot and Frequency Plot of h[n]');

pause;

%============question3===========%

%3(a)
x = [1,7,-8,6];
stem(x);
title('Plot of x[n]');
xlabel('n');
ylabel('x[n]');

pause;

%3(b)
four_p = fft(x,4);
subplot(2,1,1);
stem(abs(four_p));
title('Magnitude Plot of Four point fft');
xlabel('k');
ylabel('magnitude of fft,X(k)');

subplot(2,1,2);
stem(angle(four_p));
title('phase Plot of Four point fft');
xlabel('k');
ylabel('phase of fft,X(k)');

pause;

%3(c)
eht_p = fft(x,8);
subplot(2,1,1);
stem(abs(eht_p));
title('Magnitude Plot of eight point fft');
xlabel('k');
ylabel('magnitude of fft,X(k)');

subplot(2,1,2);
stem(angle(eht_p));
title('phase Plot of eight point fft');
xlabel('k');
ylabel('phase of fft,X(k)');