function data = os_parameter(model,O)

orders = model.data.orders;
nlinear = model.data.nlinear;

if O > nlinear
   error(sprintf('Maximum order of nonlinearity is %g!',nlinear))
end

idx = 1;
for nl = 0:O
   % generate inidices

   nnl = (orders+1)^nl;
   nl_idx = repmat([0:nnl-1]',[1,nl]);
   nl_idx = floor(nl_idx./repmat((orders+1).^[0:nl-1],[nnl,1]));
   nl_idx = mod(nl_idx,(orders+1));
   nl_idx = unique(sort(nl_idx,2),'rows');

   a_idx = idx + (1:length(nl_idx));

   idx = idx + length(nl_idx);
end

if isempty(a_idx)
   a_idx = 1;
end

data = model.data.a(a_idx);

if O > 0

   w1 = repmat((orders+1).^([0:nl-1]),[size(nl_idx,1) 1]);
   w2 = repmat((orders+1).^([nl-1:-1:0]),[size(nl_idx,1) 1]);
   idx1 = sum(nl_idx.*w1,2) + 1;
   idx2 = sum(nl_idx.*w2,2) + 1;

   clear d
   d(idx1) = data;
   d(idx2) = data;
   
   if O == 1
      data = reshape(d,[(orders+1) 1]);
   else
      data = reshape(d,(orders+1)*ones(1,O));
   end

   for i = 1:O
      data = flipdim(data,i);
   end
end

