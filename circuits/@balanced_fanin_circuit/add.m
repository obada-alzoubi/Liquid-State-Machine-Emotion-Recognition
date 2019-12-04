function [nmc, o] = add(nmc, what, varargin)

switch lower(what)
  
 case 'pool'
  [nmc, o] = add_pool(nmc, varargin{:});
 case 'conn'
  [nmc, o] = add_conn(nmc, 'rand', varargin{:});
 case 'randconn'
  [nmc, o] = add_conn(nmc, 'rand', varargin{:});
 case 'randposconn'
  [nmc, o] = add_conn(nmc, 'randpos', varargin{:});
 case 'defidxconn'
  [nmc, o] = add_defidx_conn(nmc, 'defidxconn', varargin{:});
 case 'faninconn'
  [nmc, o] = add_conn(nmc, 'fanin', varargin{:});
 otherwise
  error('Please specify whether you want to create a pool of neurons (Pool) or synaptic connections between two pools (Conn).');
  
end 

