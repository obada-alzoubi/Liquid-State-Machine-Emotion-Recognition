function print(nmc, what)

% PRINT prints the internal fields of the neural microcircuit object
%
%  Syntax
%
%    print(nmc, what)
%
%  Arguments
%
%              nmc - neural microcircuit object
%             what - OPTIONAL. possible values: 'Default', 'Pool', 'Conn', 'Recorder'
%
%  Description
%
%    For internal/debugging purposes.
%
%  Author
%
%    Christian Naeger, naeger@igi.tu-graz.ac.at

if nargin < 2, what = []; end

if ~isempty(what)
  switch what
    case 'Default'
      recur_print(nmc, nmc.def, sprintf('%s.def', inputname(1)));
    case 'Pool'
      recur_print(nmc, nmc.pool, sprintf('%s.pool', inputname(1)));
    case 'Conn'
      recur_print(nmc, nmc.conn, sprintf('%s.conn', inputname(1)));
    case 'Recorder'
      recur_print(nmc, nmc.recorder, sprintf('%s.recorder', inputname(1)));
    otherwise
      estr=sprintf('recur_print(nmc, nmc.%s, ''%s.%s'')',what,inputname(1),what);
      eval(estr);
  end
else
  recur_print(nmc, nmc, inputname(1));
end

fprintf('\n');
