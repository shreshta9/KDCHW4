% Homework 4 Part 0
% Kalman Filter for Center of Mass Location and Velocity Estimation

% load marker data
markerData = load('part0/p1n00');

% initialize variables and variances
x_k = zeros(6,1);
Q = diag(ones(6,1))*(1*10^-8);
P_k = diag(ones(6,1))*(1*10^-2);
H = zeros(24,6);
R = diag(ones(24,1))*(1*10^-2);
states = zeros(length(markerData),6);

% compute prediction matrix
F = eye(6,6);
for n = 1:3
   F(n,n+3) = 0.1; 
end

% encode sensor readings
for n = 1:3:24
    for i = 1:3
        H((n-1)+i,i) = 1;
    end
end

% Kalman filtering
for n = 1:length(markerData)
   % predict state and covariance
   x_k = F*x_k;
   P_k = F*P_k*F' + Q;
   
   % use noisy data to find residuals and residual covariances
   z = markerData(n,:)';
   y = z - H*x_k;
   K = P_k*H'*inv(H*P_k*H' + R);
   
   % update predictions based on measured data
   x_k = x_k + K*y;
   P_k = (eye(size(K,1)) - K*H)*P_k;
   states(n,:) = x_k;
end