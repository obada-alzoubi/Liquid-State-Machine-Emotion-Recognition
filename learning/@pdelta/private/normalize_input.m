function z_out = normalize_input(z_in,mean_input,std_input);

%   z_out = normalize_input(z_in,mean_input,std_input);
%
%      z_in(1:m,1:d)
%      mean_input(1,1:d)
%      std_input(1,1:d)
%
%      z_out(1:m,1:(d+1))   [ first coordinate is bias ]

[m,d] = size(z_in);

std_input(find(std_input==0)) = 1;

z_out = [ones(m,1) (z_in - ones(m,1)*mean_input)./(ones(m,1)*std_input)];



