function this = loadobj(this)

% If there is a stored csim network ...
if ~isempty(this.csimNet)

  % ... we destroy the old one ...
  csim('destroy');
  
  % ... and import the new one into csim.
  csim('import',this.csimNet);

  % save a little bit of memory
  this.csimNet = [];
end
