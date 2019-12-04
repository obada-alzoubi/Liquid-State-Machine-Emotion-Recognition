function o_out = normalize_input(o_in,min_output,max_output);

%   o_out = normalize_input(o_in,min_output,max_output);

if min_output == max_output
  o_out = o_in * 0; 
else 
  o_out = (2*o_in - max_output - min_output)/(max_output-min_output);
end



