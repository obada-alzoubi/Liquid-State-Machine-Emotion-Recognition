function this = saveobj(this)

% We also want to store the csim network (along with the other info).
% Therfore we tell csim to export the whole network and save it as the
% field csimNet.

this.csimNet = csim('export');
