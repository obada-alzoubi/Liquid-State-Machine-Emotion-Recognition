function [nmc, o, idx] = add(nmc, what, varargin)

% ADD Creates either a connection (set of synapses) or a pool of neurons
%
%  Syntax
%
%    [nmc, h, idx] = add_conn(nmc, 'Conn', parameters)
%    [nmc, h, idx] = add_conn(nmc, 'Pool', parameters)
%
%  Arguments
%
%         nmc - neural microcircuit object
%  parameters - ..., 'paramter name', parameter, ...
%               pairs to override the default parameters of connections/synapses and pools/neurons
%               (see default_parameters.m for possible parameters)
%
%           h - connection/pool handle
%         idx - csim indices of the synapses/neurons created by this call
%
%  Description
%
%    [nmc, h, idx] = add_conn(nmc, 'Conn', parameters) creates a connection (synapses) between two
%    pools or 3D-regions in space according to the default parameters given in default_parameters.m.
%    However, one can override the default values of the connection and the synapses.
%    'dest' and 'src' are additional required parameters and denote the
%    destination and source of the connection (either as pool handle or 3D Volume)
%
%    [nmc, h, idx] = add_pool(nmc, 'Pool', parameters) creates a pool of neurons and adds it to the
%    neural_microcircuit object/current csim network.
%    Pools are created according to the default parameters given in default_parameters.m.
%    However, one can override the default values of the pools and neurons.
%    'origin' is a required parameter and denotes a 1x3 position vector in space.
%    (pools of neurons must not overlap in space!)
%
%  See also Tutorial on circuit construction (www.lsm.tugraz.at)
%
%  Author
%
%    Christian Naeger, naeger@igi.tu-graz.ac.at



switch lower(what)

 case 'pool'
  [nmc, o, idx] = add_pool(nmc, varargin{:});
 case 'conn'
  [nmc, o, idx] = add_conn(nmc, varargin{:});
 otherwise
  error('Please specify whether you want to create a pool of neurons (Pool) or synaptic connections between two pools (Conn).');

end 

