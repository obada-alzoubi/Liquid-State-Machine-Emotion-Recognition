function [ scaled_data ] = scale( data, lower, upper )

if lower < upper
    scaled_data = (data-min(data, [], 2)).*repmat((upper-lower),size(data,1),1)./...
        (max(data, [], 2)-min(data, [], 2)) + repmat(lower,size(data,1), 1);
else
    scaled_data = (data-min(data, [], 2)).*repmat((lower-upper),size(data,1),1)./...
        (max(data, [], 2)-min(data, [], 2)) + repmat(upper,size(data,1), 1);    
end


end
