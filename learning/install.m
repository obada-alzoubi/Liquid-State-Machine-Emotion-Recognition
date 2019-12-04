function install

addpath('..');

%%
%%  svm_toolbox
%%
condmex( 'evaluate', 'svm_toolbox/@rbf', 'mex -O evaluate.c' );
condmex( 'smosvctrain', 'svm_toolbox/@smosvctutor', 'mex -O smosvctrain.cpp InfCache.cpp LrrCache.cpp SmoTutor.cpp' );

%%
%% spike filters
%%
condmex( 'spikes2alpha', '.', 'mex -O spikes2alpha.c' );
condmex( 'spikes2exp', '.', 'mex -O spikes2exp.c' );
condmex( 'spikes2count', '.', 'mex -O spikes2count.c' );


%
% make pdelta C-core
%
condmex( 'cpdelta', '@pdelta/private', 'mex -O cpdelta.c' );


fprintf('Learning-Tool *succesfully* installed.\n\n');
