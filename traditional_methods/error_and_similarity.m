function [relative_error,correlation_coefficient] = error_and_similarity(x, x_hat)
% ERROR_AND_SIMILARITY Computes relative error and correlation coefficient between two signals
%   [relative_error, correlation_coefficient] = error_and_similarity(x, x_hat)
%   Returns the relative error and correlation coefficient between x and x_hat.


x_minus_x_hat  = (x - x_hat).^2 ; 
x_minus_x_hat  = sqrt(sum(x_minus_x_hat(~isnan(x_minus_x_hat))));
x_hat_mean = mean(x_hat(~isnan(x_hat)));
x_mean     = mean(x(~isnan(x)))        ;
x_square = x.^2;  x_square =  x_square(~isnan(x_square));
relative_error =x_minus_x_hat/sqrt(sum((x_square))) ; 
A = (x_hat-x_hat_mean).*(x-x_mean) ; A = A(~isnan(A));
B = (x_hat-x_hat_mean).^2          ; B = B(~isnan(B)); 
C = (x-x_mean).^2                  ; C = C(~isnan(C));
correlation_coefficient = sum(A)/sqrt(sum(B)*sum(C));

% 
% 
% x      = x(:)     ; x=x(~isnan(x))  ;
% x_hat  = x_hat(:) ; x_hat=x_hat(~isnan(x_hat)) ;
% x_hat_mean = mean(x_hat);
% x_mean     = mean(x)    ;
% 
% relative_error = sqrt(sum((x-x_hat).^2))/sqrt(sum((x.^2))) ; 
% 
% correlation_coefficient = sum((x_hat-x_hat_mean).*(x-x_mean))/sqrt(sum((x_hat-x_hat_mean).^2)*sum((x-x_mean).^2));
%        
 
end