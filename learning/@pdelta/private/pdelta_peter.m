function [best_Weights,mean_input,std_input,min_output,max_output] ...
    = pdelta(train_data,eps,n,rho,mu,print_flag)


%   [Weights,mean_input,std_input,min_output,max_output] 
%   = pdelta(train_data,eps,n,rho,mu,print_flag)
%   
%   train_data(1:m,1:(d+1))
%
%   Weights(1:n,1:(d+1))   [ first coordinate is bias ]
%   mean_input(1,1:d)
%   std_input(1,1:d) 

[m,d1] = size(train_data); d=d1-1;


% Learning parameters

momentum = 0.9;               % how much of the old weights should be kept
eta_promote = 1.1;            % factor for increasing the learning rate
eta_demote = 0.9;             % factor for decreasing the learning rate
max_gamma_count = 1;          % number of gamma iterations without change
max_epoch_count = 100;        % number of epoch iterations without change
significance = 0.01;          % significance of change of errors
gamma_fraction = 0.1;         % fraction of inner products within the margin


% normalizing the data and adding bias

z = train_data(1:m,1:d);      % inputs
mean_input = mean(z);
std_input = std(z);
z = normalize_input(z,mean_input,std_input);

max_norm = 0;
for i=1:m
  max_norm = max(max_norm,norm(z(i,:)));
end
z = z / max_norm;

o = train_data(1:m,d1);       % outputs
min_output = min(o);
max_output = max(o);
o = normalize_output(o,min_output,max_output);
if min_output == max_output 
  eps = 2;
else
  eps = 2*eps/(max_output-min_output);
end


% Initialize gamma

gamma = 1/m;                  % margin
total_epochs = 0;


% Start of gamma iteration
  
gamma_count = 0;
best_absolute_error = Inf;
best_mistakes = Inf;
while gamma_count < max_gamma_count & best_mistakes > 0
  
  % Initialize the weights
  
  rp = randperm(m);
  z = z(rp,:);
  o = o(rp,:);
  
  for i=1:n
    Weights(i,:) = z(i,:) .* o(i);
  end

  % Start of epoch iteration
  
  epoch_count = 0;
  error_function_old = Inf;
  Weights_derivative_cumulated = zeros(n,d1);
  best_error_function = Inf;
  eta = gamma/d;              % learning rate
  while epoch_count < max_epoch_count & best_error_function > gamma/m/n

    total_epochs = total_epochs + 1;
    
    % Shuffling of training data in each epoch
    rp = randperm(m);
    z = z(rp,:);
    o = o(rp,:);
  
    % Normalization of weights
    for i=1:n
      Weights(i,:) = Weights(i,:)/norm(Weights(i,:));
    end

    % Calculation of output ho
    Y = z * Weights';
    Y1 = sign(Y);
    ho = max(-1,min(1,sum(Y1,2)/(2*rho)));
    
    % Calculation of incorrect outputs
    output_not_too_large = find( ho <= o + eps );
    output_too_large = find( ho > o + eps );
    output_not_too_small = find( ho >= o - eps );
    output_too_small = find( ho < o - eps );

    % Classification of weight-input pairs according to their inner product
    positives = find(Y >= 0);
    negatives = find(Y < 0);
    pos_margin = find(0 <= Y & Y <= gamma);
    neg_margin = find(-gamma <= Y & Y < 0);
  
    % Calculation if weight-example pairs which need to be updated
    make_smaller = zeros(m,n);
    make_smaller(positives) = +1;
    make_smaller(output_not_too_large,:) = 0;
    
    make_larger = zeros(m,n);
    make_larger(negatives) = -1;
    make_larger(output_not_too_small,:) = 0;
    
    make_wider_pos = zeros(m,n);
    make_wider_pos(pos_margin) = -1;
    make_wider_pos(output_too_large,:) = 0;

    make_wider_neg = zeros(m,n);
    make_wider_neg(neg_margin) = +1;
    make_wider_neg(output_too_small,:) = 0;

    sum_makes = make_smaller+make_larger+mu*(make_wider_pos+make_wider_neg);
  
    % Calculation of error function
    error_function = ...
	sum(sum(abs(sign(sum_makes)))) * mu * gamma + sum(sum(sum_makes .* Y));

    % Calculation of absolute error
    absolute_error = sum(abs(ho-o));

    % Calculation of mistakes
    mistakes = size(find(abs(o - ho)>eps),1);
    
    % Calculation of the derivative of weights
    Weights_derivative = sum_makes' * z;
    
    % Adaption of the learning rate
    if error_function > error_function_old
      eta = eta * eta_demote;
    elseif error_function <= error_function_old
      eta = eta * eta_promote;
    end
    
    % Weight update
    if error_function <= error_function_old * (1+significance)
      error_function_old = error_function;
      Weights_derivative_cumulated = ...
	  momentum * Weights_derivative_cumulated ...
	  + (1-momentum) * Weights_derivative;
      Weights_old = Weights;
      Weights = Weights_old - eta * Weights_derivative_cumulated;
    else
      Weights_derivative_cumulated = momentum * Weights_derivative_cumulated;
      Weights = Weights_old - eta * Weights_derivative_cumulated;
    end
    
    % Control of epoch iteration
    if error_function < (1-significance) * best_error_function
      best_error_function = error_function;
      epoch_count = 0;
    else
      epoch_count = epoch_count + 1;
    end

    % Progress report
    if print_flag
      if rem(total_epochs,print_flag) == 0
	fprintf('epochs:%d count:%3d eta:%e gamma:%e err_fun:%f mae:%f mistakes:%g%%\n',...
	    total_epochs, epoch_count, eta, gamma, ...
	    error_function,absolute_error/m,mistakes/m*100);
      end
    end
    
  end   % of epoch iteration
  
  % Gamma Update
  make_margin_pos = zeros(m,n);
  make_margin_pos(positives) = 1;
  make_margin_pos(output_too_large,:) = 0;
  
  make_margin_neg = zeros(m,n);
  make_margin_neg(negatives) = 1;
  make_margin_neg(output_too_small,:) = 0;
  
  Y = abs(Y .* (make_margin_pos + make_margin_neg));
  H = Y(find(Y(:) > 0));
  gamma = percentile(H,100*gamma_fraction);

  % Control of gamma iteration
  if mistakes < best_mistakes
    best_mistakes = mistakes;
    best_Weights = Weights;
  end
  if absolute_error < (1-significance) * best_absolute_error
      best_absolute_error = absolute_error;
      gamma_count = 0;
    else
      gamma_count = gamma_count + 1;
    end
  
end   % of gamma iteration


