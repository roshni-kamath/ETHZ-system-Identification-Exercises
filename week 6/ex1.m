clc
clear all 
close all

%initialise the variables
gama = 5 ; %gama>0, gama is the amplitude of the signal
A = [ 1 0 0 0 0 1 ;
      1 0 0 0 0 0 ;
      0 1 0 0 0 0 ;
      0 0 1 0 0 0 ;
      0 0 0 1 0 0 ;
      0 0 0 0 1 0 ] ;
C = [0 0 0 0 0 2*gama];
x = [] ; y_signal = [] ;
x(:,1) = [0 1 0 1 0 1]' ; %initialize x0

% compute the loop for the signal generation
for j = 0:3*(2^6-1)
    i = j+1 ; %shift because matlab indices start at 1
    z = A*x(:,i) ;
    x(:,i+1) = mod(z,2) ;
    y_signal(i) = C*x(:,i) - gama ; 
end

y1 = y_signal(1:(2^6-1)) ;
y2 = y_signal(2^6:(2*2^6 -2)) + 11 ; %to plot signals one over the other and see the periodicity
y3 = y_signal((2*2^6-1):(3*2^6-3)) + 22;

%show signal
figure;
y1 = iddata([],y1',1);
y2 = iddata([],y2',1);
y3 = iddata([],y3',1);
plot(y1) ; hold on ; 
plot(y2) ;
plot(y3) ;
%this confirms the periodicity that is 2^n-1 where n is the dimension of x
%another way to do it is to find when we get back to the same configuration
%as xo
period_found = 0 ;
for i = 2:max(size(x))
    if x(:,1) == x(:,i)
        fprintf('xo configurtion found after %2d iterations \n  The period is therefore %d \n \n', i, i-1)
        period_found = 1 ;
        break
    end
end
if period_found == 0 %error message if the periodocoty was not found
   fprintf('periodicity not found \n') ;
end

%% calculation of autocorrelation
y = y_signal(1:2^6-1) ;
autocorrelation_y = 0*y ;
M = 2^6 -1 ; 

autocorrelation_y = autocorrelation_periodic( y, M, [0 M-1] ) ;
figure ;
subplot(2,2,1) ;
plot(0:(M-1), autocorrelation_y) ; hold on ;
xlabel('tao') ;
ylabel('autocorrelation') ;
title('autocorrelation of the signal') ;
%when plotting the autocorrelation, we see that the signal is not correlated
%when sifted

%% generate other signal 
% a) y(k) with 10 non zero initial conditions

%randomly generate initial conditions
% check that all initial conditions are different and non zero
not_checked = 1 ;
recompute = 0 ;
while not_checked
    xo = randi([0 1],[6,10]) ;
    for i = 1:10
        if xo(:,i) == zeros(6,1) ;
            break
        end 
        for j = (i+1):10
            if (xo(:,i) == xo(:,j))
                recompute = 1 ;
                break
            end
        end
        if recompute
            recompute = 0 ;
            fprintf('I had to recompute the initial conditions \n') ;
            break ;
        end
        if i == 10
            not_checked = 0 ;
        end
    end
end

%compute the signal
ytot = zeros(1,2^6-1) ;
for k = 1:10
    x = xo(:,k) ;
    for i = 1:(2^6-1)
        z = A*x(:,i) ;
        x(:,i+1) = mod(z,2) ;
        y_one_signal(i) = C*x(:,i) - gama ; 
    end
    ytot = ytot + (1/10).*y_one_signal ;
end

%calculate autocorelation
autocorrelation_ytot = 0*ytot ;
autocorrelation_ytot = autocorrelation_periodic( ytot, M, [0 M-1] ) ;
subplot(2,2,2) ;
plot(0:(M-1), autocorrelation_ytot) ; hold on ;
xlabel('tao') ;
ylabel('autocorrelation') ;
title('autocorrelation of 10 signals') ;
%the autocorrelation is now higher and not constant

%% generate other signal 
% b) normaly distributed signal saturated such that max is 5

% Generate a normaly distributed signal
y_norm_sat = randn(M, 1) ;
%do the saturation
for i = 1:M
    if y_norm_sat(i) > gama
        y_norm_sat(i) = gama ;
    elseif y_norm_sat(i) < -gama
        y_norm_sat(i) = -gama ;
    end
end

%calculate autocorelation
autocorrelation_y_norm_sat = 0*ytot ;
autocorrelation_y_norm_sat = autocorrelation_periodic( y_norm_sat, M, [0 M-1] ) ;
subplot(2,2,3) ;
plot(0:(M-1), autocorrelation_y_norm_sat) ; hold on ;
xlabel('tao') ;
ylabel('autocorrelation') ;
title('autocorrelation of normal (saturated)') ;
%the autocorrelation is now higher and not constant

%% generate other signal 
% c) uniformly distributed signal on interval -gama:gama (period = M)
y_uniform = -gama + 2*gama.*rand(M,1);

%calculate autocorelation
autocorrelation_y_uniform= 0*ytot ;
autocorrelation_y_uniform = autocorrelation_periodic( y_uniform, M, [0 M-1] ) ;
subplot(2,2,4) ;
plot(0:(M-1), autocorrelation_y_uniform) ; hold on ;
xlabel('tao') ;
ylabel('autocorrelation') ;
title('autocorrelation of uniform signal') ;
%the autocorrelation is now higher and not constant

%% end
fprintf('the script ended succesfully \n') ;
    