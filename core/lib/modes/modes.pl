:- package(modes).
:- use_package(assertions).
:- use_module(engine(hiord_rt)).

%% NOTE: Should we also add indeps via ivar/1 (i.e., use ivar in all
%% places where we have var, since that is normally the intended 
%% meaning). Check in practice.

:- op(500,  fx,(?)).
:- op(500,  fx,(@)).
% :- op(500,  fx,(++)). 
% :- op(500,  fx,(--). 

%% "ISO-like" modes
:- modedef  +(A) :  nonvar(A).
:- modedef  -(A) => nonvar(A). % This was : var(A). Could also imply steadfast.
:- modedef --(A) :  var(A).     % Optional...
:- modedef  ?(_).
:- modedef  @(A) +  not_further_inst(A).

%% Useful input-output modes
:- modedef in(A)  : ground(A) => ground(A).
:- modedef ++(A)  : ground(A) => ground(A).  % Optional alias...
:- modedef out(A) : var(A)    => ground(A).  % Take out the var/1 and no need for go?
:- modedef go(A)              => ground(A).

%%% Other possibilities: 
%% : mode for meta (also implies nonvar)
%% ! mode for mutables

:- push_prolog_flag(read_hiord,on).

%% Parametric versions of above
%% TODO: hiord order? (Need to change in assrt 
:- modedef  +(A,P) :  P(A).          % This was :: P(A) : nonvar(A).
:- modedef  -(A,P)          => P(A). % This was :: P(A) : var(A).
:- modedef --(A,P) : var(A) => P(A). 
:- modedef  ?(A,P) :: P(A). 
:- modedef  @(A,P) :: P(A) + not_further_inst(A).

:- modedef in(A,P)  : (ground(A),P(A)) => ground(A). % This was :: P(A) : ground(A) => ground(A).
:- modedef ++(A,P)  : (ground(A),P(A)) => ground(A). % Optional alias...
:- modedef out(A,P) : var(A) => (ground(A),P(A)).    % This was :: P(A) : var(A)    => ground(A).
:- modedef go(A,P)           => (ground(A),P(A)).    % This was :: P(A)             => ground(A).

:- pop_prolog_flag(read_hiord).
