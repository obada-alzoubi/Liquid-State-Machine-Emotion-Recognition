
% run a per user startup if it exists
if exist('user_startup')==2
  user_startup
end

rand('state',sum(100*clock));
randn('state',sum(100*clock));

addpath('../../..');  % add the 'yourpath/lsm/common/etc' directory where
lsm_startup;                     % lsm_startup resides.
