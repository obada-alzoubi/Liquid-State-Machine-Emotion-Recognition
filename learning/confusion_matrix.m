function C=confusion_matrix(o,y,values)

C=zeros(length(values));
for i=1:length(values)
  oo=o(y==values(i));
  if ~isempty(oo)
    for j=1:length(values)
      C(i,j) = sum(oo==values(j));  
    end
  end
end

