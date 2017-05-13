function states = part2allfiles(fn)
% Program used with quick_write.m to make the homework go faster

% load marker data
markerData = load(fn);

% initialize variables and variances
x_k = zeros(12,1);
Q = diag(ones(12,1))*(1*10^-8);
P_k = diag(ones(12,1))*(1*10^-2);
H = zeros(24,12);
R = diag(ones(24,1))*(1*10^-2);
states = zeros(length(markerData),13);

% compute prediction matrix
F = eye(12,12);
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

% Kalman filtering
for n = 1:length(markerData)
   % predict state and covariance
   x_k = F*x_k;
   P_k = F*P_k*F' + Q;
   
   % read noisy data
   z = markerData(n,:)';
   
   % identify occluded markers and replace erroneous readings with
   % predicted values to prevent skewed residuals
   ind = find(z == 1*10^10);
   for i = 1:3
      z(ind(i)) = x_k(i); 
   end
   
   % find residuals and residual covariances
   y = z - H*x_k;
   K = (P_k*H')/(H*P_k*H' + R);
   
   % update predictions based on measured data
   x_k = x_k + K*y;
   P_k = (eye(size(K,1)) - K*H)*P_k;
   states(n,:) = [x_k(1:6)', eul2quat(flip(x_k(7:9)')), x_k(10:12)'];
end
end