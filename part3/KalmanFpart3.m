% Homework 4 Part 3
% Kalman Filter for Variable Marker Locations

% load marker data
markerData = load('part3/p3n00');

% initialize variables and variances
x_k = zeros(36,1);
Q = diag(ones(36,1))*(1*10^-7);
P_k = diag(ones(36,1))*(1*10^-2);
H = zeros(24,12);
R = diag(ones(24,1))*(1*10^-2);
states = zeros(length(markerData),37);

% compute prediction matrix
F = eye(36,36);
for n = [1:3,7:9]
   F(n,n+3) = 0.1; 
end

% encode sensor readings
for n = 1:3:24
    for i = 1:3
        H((n-1)+i,i) = 1;
        H((n-1)+i,i+6) = pi/180;
    end
end
H = [H eye(24,24)];

% do Kalman filtering
for n = 1:length(markerData)
   % predict state and covariance
   x_k = F*x_k;
   P_k = F*P_k*F' + Q;
   
   % use noisy data to find residuals and residual covariances
   z = markerData(n,:)';   
   y = z - H*x_k;
   K = (P_k*H')/(H*P_k*H' + R);
   
   % update predictions based on measured data
   x_k = x_k + K*y;
   P_k = (eye(size(K,1)) - K*H)*P_k;
   states(n,:) = [x_k(1:6)', eul2quat(flip(x_k(7:9)')), x_k(10:end)'];
end