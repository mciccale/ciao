% (included file)

% ---------------------------------------------------------------------------
% Abstract machine definition (emugen version)
% NOTE: See core/engine_oc/absmach_def.pl for ImProlog version

% Author: Jose F. Morales (based on the original code in C)

% Instruction set and auxiliary data structures for the bytecode
% emulator. The specification in this file is translated to C files,
% which are included in the engine runtime code to generate a working
% bytecode emulator.

% ---------------------------------------------------------------------------

% TODO: Make sure that 'pred' with just comp props does not introduce
%   'true' calls assertions.
% TODO:
%  - remove 'unfold' (we must always unfold!)
%  - add loop detection
%  - move fmt:call/n into code generation, support lvalues, rvalues
%  - declare constraints that can be used inside [[ ]]
%  - move more formatting into code generation
%  - multi-level resolution (stop at tokens, etc.)
%    (so that formatting as code generation is practical)
%  - better/alternative search
% TODO: Missing from optim_comp:
%  - automatic alignment (q versions)
%  - instruction merging
%  - instruction specialization

% ---------------------------------------------------------------------------
%! # C syntax and control constructs

:- pred(fmtbb/0, [grammar_level]).
fmtbb => [[indent(N)]], fmt:bb(N).

:- pred(fmtinc/0, [grammar_level]).
fmtinc =>
    [[indent(N)]],
    [[N1 is N + 2]],
    [[update(indent(N1))]].
:- pred(fmtdec/0, [grammar_level]).
fmtdec =>
    [[indent(N)]],
    [[N1 is N - 2]],
    [[update(indent(N1))]].

:- pred(stmtend/0, [grammar_level]).
stmtend => ";", fmt:nl.

:- pred(blk/1, []).
blk(Code) => "{", fmtinc, fmt:nl, Code, fmtdec, fmtbb, "}".

:- pred(for/2, [grammar_level]).
for(Range, Code) => "for (", Range, ") ", blk(Code), fmt:nl.

:- pred(foreach/4, [grammar_level]).
foreach(Ty, range(To), V, Code) => % V in [0,..., To-1]
    for((localv(Ty, V, 0), (V < To), ";", (V, "++")), Code).
foreach(Ty, revrange(From), V, Code) => % V in [From,...,0+1] (reverse)
    for((localv(Ty, V, From), (V > 0), ";", ("--", V)), Code).
foreach(Ty, revrange(From,To), V, Code) => % V in [From,...,To+1] (reverse)
    for((localv(Ty, V, From), (V > To), ";", ("--", V)), Code).
foreach(Ty, revrangeq(From,To,Step), V, Code) => % V in [From,...,To] by Step (reverse)
    for((localv(Ty, V, From), (V >= To), ";", (V, "-=", Step)), Code).

:- pred(do_while/2, [grammar_level]).
do_while(Code, Cond) =>
    "do ", blk(Code), " while (", Cond, ")", stmtend.

:- pred(if/2, [grammar_level]).
if(Cond, Then) =>
    "if (", Cond, ") ", blk(Then), fmt:nl.

:- pred(if/3, [grammar_level]).
if(Cond, Then, Else) =>
    "if (", Cond, ") ", blk(Then), " else ",
    ( [[ Else = if(_,_) ]] -> Else
    ; [[ Else = if(_,_,_) ]] -> Else
    ; blk(Else), fmt:nl
    ).

:- pred(switch/2, [grammar_level]).
switch(Expr, Cases) =>
    "switch (", Expr, ") ", blk(Cases).

:- pred(vardecl/2, [grammar_level]).
vardecl(Type, V) =>
    ( [[ Type = extern(Type0) ]] ->
        "extern ", vardecl(Type0, V)
    ; ty(Type), " ", V, stmtend
    ).

:- pred(vardecl/3, [grammar_level]).
vardecl(Type, V, A) => ty(Type), " ", V, " = ", A, stmtend.

:- pred(argdecl/2, [grammar_level]).
argdecl(Type, V) => ty(Type), " ", V.

:- pred((<-)/2, [grammar_level]).
(A <- B) => A, " = ", B, stmtend.
:- pred(assign/1, [grammar_level]).
assign(X+Y), [[ Y = 1 ]] => X, "++", stmtend.
assign(X+Y) => X, "+=", Y, stmtend.
assign(X-Y), [[ Y = 1 ]] => X, "--", stmtend.
assign(X-Y) => X, "-=", Y, stmtend.
assign(X*Y) => X, "*=", Y, stmtend.
assign(X/\Y) => X, "&=", Y, stmtend.

:- pred(label/1, [grammar_level]).
label(A) => fmt:atom(A), ":", fmt:nl.

:- pred(case/1, [grammar_level]).
case(A), [[ atom(A) ]] => "case ", fmt:atom(A), ":", fmt:nl.
case(A) => "case ", A, ":", fmt:nl.

:- pred(goto/1, [grammar_level]).
goto(A) => "goto ", fmt:atom(A), stmtend.

:- pred(break/0, [grammar_level]).
break => "break", stmtend.

:- pred(return/0, [grammar_level]).
return => "return", stmtend.

:- pred(return/1, [grammar_level]).
return(A) => "return ", A, stmtend.

:- pred(call0/1, [grammar_level]).
call0(X) => fmt:atom(X), stmtend.

% new id for a variable
:- pred(var_id/1, []).
var_id(Id) => [[ newid(vr,Id) ]].

:- pred(labeled_block/2, []).
labeled_block(Label, Code) =>
    label(Label),
    Code.

:- pred(localv/2, []).
localv(Ty, V) => var_id(V), vardecl(Ty, V).

:- pred(localv/3, []).
localv(Ty, V, Val) => var_id(V), vardecl(Ty, V, Val).

:- pred(addr/1, []).
addr(X) => "(&", X, ")".

:- pred(cast/2, []).
cast(Ty,X) => "((", ty(Ty), ")(", X, "))".

% TODO: (use write_c.pl operators)
% TODO: get prio of X,Y, add paren only if needed
:- pred((+)/2, []).
X+Y => "(", X, "+", Y, ")".
:- pred((-)/2, []).
X-Y => "(", X, "-", Y, ")".
:- pred((*)/2, []).
X*Y => "(", X, "*", Y, ")".
:- pred(('\006\postfix_block')/2, []). % both [_] and {_}
X[Y] => X, "[", Y, "]".
:- pred((^.)/2, []). % deref+access operator ("->" in C)
X^.Y => "(", X, "->", fmt:atom(Y), ")".
:- pred((^)/1, []). % deref operator ("*" in C)
X^ => "*(", X, ")".
:- pred(('\006\dot')/2, []). % TODO: functor name is not '.' here
(X.Y) => "(", X, ".", fmt:atom(Y), ")".
:- pred(not/1, []).
not(X) => "!(", X, ")".
:- pred((<)/2, []).
X<Y => X, "<", Y.
:- pred((>)/2, []).
X>Y => X, ">", Y.
:- pred((=<)/2, []).
X=<Y => X, "<=", Y.
:- pred((>=)/2, []).
X>=Y => X, ">=", Y.
:- pred((==)/2, []).
X==Y => X, "==", Y.
:- pred((\==)/2, []).
X\==Y => X, "!=", Y.
:- pred((/\)/2, []).
X/\Y => "(", X, "&", Y, ")".
:- pred((\/)/2, []).
X\/Y => "(", X, "|", Y, ")".
:- pred((logical_and)/2, []).
logical_and(X,Y) => "(", X, "&&", Y, ")".
:- pred((logical_or)/2, []).
logical_or(X,Y) => "(", X, "||", Y, ")".

% $emu_globals and other constants
:- pred((~)/1, []).
~(w) => fmt:atom(w).
~(g) => fmt:atom('G').
~(null) => fmt:atom('NULL').
~(true) => fmt:atom('TRUE').
~(false) => fmt:atom('FALSE').

:- pred(is_null/1, []).
is_null(X) => X=="NULL".
:- pred(not_null/1, []).
not_null(X) => X\=="NULL".

:- pred('$unreachable'/0, []).
'$unreachable' =>
    % Make sure that no mode dependant code appears next
    % TODO: better way?
    [[update(mode('?'))]].

% TODO: write a 'mode merge' too

:- pred(call_fC/3, []).
call_fC(Ty,F,Args) => "(", cast(Ty,F), ")", callexp('',["Arg"|Args]).

cfun_eval(Name,Args) => callexp(Name, ["Arg"|Args]).

cbool_succeed(Name,Args) => callexp(Name, ["Arg"|Args]).

cvoid_call(Name,Args) => call(Name, ["Arg"|Args]).

% ---------------------------------------------------------------------------
%! # C preprocessor macros

% C preprocessor

:- pred(cpp_define/2, [grammar_level]).
cpp_define(Name, Value) =>
    "#define ", fmt:atom(Name), " ", Value, fmt:nl.

:- pred(cpp_if_defined/1, [grammar_level]).
cpp_if_defined(Name) =>
    "#if defined(", fmt:atom(Name), ")", fmt:nl.

:- pred(cpp_endif/0, [grammar_level]).
cpp_endif => "#endif", fmt:nl.

% ---------------------------------------------------------------------------
%! # Terms

:- pred(ty/1, []).
ty(int) => "int".
ty(intmach) => "intmach_t".
ty(tagged) => "tagged_t".
ty(try_node) => "try_node_t".
ty(goal_descriptor) => "goal_descriptor_t".
ty(definition) => "definition_t".
ty(bcp) => "bcp_t".
ty(choice) => "choice_t".
ty(frame) => "frame_t".
ty(worker) => "worker_t".
ty(sw_on_key_node) => "sw_on_key_node_t".
ty(sw_on_key) => "sw_on_key_t".
ty(instance_clock) => "instance_clock_t".
%
ty(cbool0) => "cbool0_t".
ty(cbool1) => "cbool1_t".
ty(cbool2) => "cbool2_t".
ty(cbool3) => "cbool3_t".
ty(ctagged1) => "ctagged1_t".
ty(ctagged2) => "ctagged2_t".
%
ty(ftype_ctype(f_i_signed)) => "FTYPE_ctype(f_i_signed)".
%
ty(ptr(Ty)) => ty(Ty), " *".

:- pred(tagp/2, []).
tagp(hva,Ptr) => callexp('Tagp', ["HVA",Ptr]).
tagp(sva,Ptr) => callexp('Tagp', ["SVA",Ptr]).
tagp(cva,Ptr) => callexp('Tagp', ["CVA",Ptr]).
tagp(str,Ptr) => callexp('Tagp', ["STR",Ptr]).
tagp(lst,Ptr) => callexp('Tagp', ["LST",Ptr]).

:- pred(sw_on_heap_var/4, []).
sw_on_heap_var(Reg, HVACode, CVACode, NVACode) =>
    "{", localv(tagged, Aux),
    call('SwitchOnHeapVar', [Reg, Aux, blk(HVACode), blk(CVACode), blk(NVACode)]),
    "}".

:- pred(sw_on_var/5, []).
sw_on_var(Reg, HVACode, CVACode, SVACode, NVACode) =>
    "{", localv(tagged, Aux),
    call('SwitchOnVar', [Reg, Aux, blk(HVACode), blk(CVACode), blk(SVACode), blk(NVACode)]),
    "}".

% TODO: deprecate
:- pred(deref_sw/3, []).
deref_sw(Reg, Aux, VarCode) => call('DerefSwitch', [Reg, Aux, blk(VarCode)]).
:- pred(deref_sw0/2, []).
deref_sw0(Reg, VarCode) => call('DerefSwitch0', [Reg, blk(VarCode)]).

:- pred(unify_heap_atom/2, []).
unify_heap_atom(U,V) =>
    "{",
    localv(tagged, T1, V),
    sw_on_heap_var(T1,
      bind(hva, T1, U),
      bind(cva, T1, U),
      if(T1 \== U, jump_fail)),
    "}".

:- pred(unify_atom/2, []).
unify_atom(U,V) =>
    "{",
    localv(tagged, T1, V),
    sw_on_var(T1,
      bind(hva, T1, U),
      bind(cva, T1, U),
      bind(sva, T1, U),
      if(T1 \== U, jump_fail)),
    "}".

:- pred(unify_atom_internal/2, []).
unify_atom_internal(Atom,Var) =>
    "{",
    localv(tagged, T1, Var),
    if(T1 /\ "TagBitSVA",
      (bind(sva, T1, Atom)),
      (bind(hva, T1, Atom))),
    "}".

:- pred(unify_heap_structure/3, []).
unify_heap_structure(U,V,Cont) =>
    "{",
    localv(tagged, T1, V),
    [[mode(M)]],
    sw_on_heap_var(T1,
      ([[update(mode(M))]],
       setmode(w),
       cachedreg('H', H),
       bind(hva, T1, tagp(str, H)), heap_push(U),
       Cont),
      ([[update(mode(M))]],
       setmode(w),
       cachedreg('H', H),
       bind(cva, T1, tagp(str, H)), heap_push(U),
       Cont),
      ([[update(mode(M))]],
       if(logical_or(not(callexp('TaggedIsSTR', [T1])),
                     callexp('TaggedToHeadfunctor', [T1]) \== U), jump_fail),
       "S" <- callexp('TaggedToArg', [T1, 1]),
       Cont)),
    "}",
    '$unreachable'.

:- pred(unify_structure/3, []).
unify_structure(U,V,Cont) =>
    "{",
    localv(tagged, T1, V),
    [[mode(M)]],
    sw_on_var(T1,
      ([[update(mode(M))]],
       setmode(w),
       cachedreg('H', H),
       bind(hva, T1, tagp(str, H)), heap_push(U),
       Cont),
      ([[update(mode(M))]],
       setmode(w),
       cachedreg('H', H),
       bind(cva, T1, tagp(str, H)), heap_push(U),
       Cont),
      ([[update(mode(M))]],
       setmode(w),
       cachedreg('H', H),
       bind(sva, T1, tagp(str, H)), heap_push(U),
       Cont),
      ([[update(mode(M))]],
       if(logical_or(not(callexp('TaggedIsSTR', [T1])),
                     callexp('TaggedToHeadfunctor', [T1]) \== U), jump_fail),
       "S" <- callexp('TaggedToArg', [T1, 1]),
       Cont)),
    "}",
    '$unreachable'.

:- pred(unify_heap_large/2, []).
unify_heap_large(P, T) =>
    "{",
    localv(tagged, T1, T),
    sw_on_heap_var(T1,
      bind(hva, T1, cfun_eval('BC_MakeBlob', [P])),
      bind(cva, T1, cfun_eval('BC_MakeBlob', [P])),
      callexp('BC_EqBlob', [T1, P, blk(jump_fail)])),
    "}".

:- pred(unify_large/2, []).
unify_large(P, T) =>
    "{",
    localv(tagged, T1), T1<-T,
    sw_on_var(T1,
      bind(hva, T1, cfun_eval('BC_MakeBlob', [P])),
      bind(cva, T1, cfun_eval('BC_MakeBlob', [P])),
      bind(sva, T1, cfun_eval('BC_MakeBlob', [P])),
      callexp('BC_EqBlob', [T1, P, blk(jump_fail)])),
    "}".

:- pred(unify_heap_list/2, []).
unify_heap_list(V,Cont) =>
    "{",
    localv(tagged, T1, V),
    [[mode(M)]],
    sw_on_heap_var(T1,
      ([[update(mode(M))]],
       setmode(w),
       cachedreg('H', H),
       bind(hva, T1, tagp(lst, H)),
       Cont),
      ([[update(mode(M))]],
       setmode(w),
       cachedreg('H', H),
       bind(cva, T1, tagp(lst, H)),
       Cont),
      ([[update(mode(M))]],
       if(not(callexp('TermIsLST', [T1])), jump_fail),
       "S" <- callexp('TagpPtr', ["LST", T1]),
       Cont)),
    "}",
    '$unreachable'.

:- pred(unify_list/2, []).
unify_list(V,Cont) =>
    "{",
    localv(tagged, T1, V),
    [[mode(M)]],
    sw_on_var(T1,
      ([[update(mode(M))]],
       setmode(w),
       cachedreg('H', H),
       bind(hva, T1, tagp(lst, H)),
       Cont),
      ([[update(mode(M))]],
       setmode(w),
       cachedreg('H', H),
       bind(cva, T1, tagp(lst, H)),
       Cont),
      ([[update(mode(M))]],
       setmode(w),
       cachedreg('H', H),
       bind(sva, T1, tagp(lst, H)),
       Cont),
      ([[update(mode(M))]],
       if(not(callexp('TermIsLST', [T1])), jump_fail),
       "S" <- callexp('TagpPtr', ["LST", T1]),
       Cont)),
    "}",
    '$unreachable'.

:- pred(unify_local_value/1, []).
unify_local_value(T1) =>
    if(callexp('TaggedIsSVA', [T1]),
      (localv(tagged, T0),
       do_while((
           call('RefSVA', [T0,T1]),
           if(T0==T1, (
               cachedreg('H', H),
               bind(sva, T1, tagp(hva, H)),
               preload(hva, T1),
               break)),
           T1 <- T0
       ), callexp('TaggedIsSVA', [T1])))),
    heap_push(T1).

% ---------------------------------------------------------------------------
%! # Auxiliary macro definitions

% Concurrency: if we cut (therefore discarding intermediate
% choicepoints), make sure we also get rid of the linked chains which
% point to the pending calls to concurrent predicates. (MCL)

% TODO: Bug: the PROFILE__HOOK_CUT should be implemented like show_nodes
%     show_nodes(w->choice, w->previous_choice);

:- pred(do_cut/0, []).
do_cut =>
    profile_hook(cut),
    "B" <- (~w)^.previous_choice,
    call('SetChoice', ["B"]),
    call('TRACE_CHPT_CUT', [(~w)^.choice]),
    call('ConcChptCleanUp', ["TopConcChpt", (~w)^.choice]).

:- pred(cunify/2, []).
cunify(U,V) =>
    if(not(callexp('CBOOL__SUCCEED', ["cunify",U,V])), jump_fail).

% This must not clobber  t2, X[*].  Build goal from Func(X(0),...X(arity-1))
:- pred(emul_to_goal/1, []).
emul_to_goal(Ret) => % (stores: Ret)
    if("Func"^.arity == 0,
      Ret <- "Func"^.printname,
      (cachedreg('H', H),
       Ret <- tagp(str, H),
       heap_push(callexp('SetArity', ["Func"^.printname,"Func"^.arity])),
       foreach(intmach, range("Func"^.arity), I,
               (localv(tagged, T1, x(I)),
                unify_local_value(T1)))
      )).

:- pred(deallocate/0, []).
deallocate =>
    (~w)^.next_insn <- "E"^.next_insn,
    (~w)^.frame <- "E"^.frame.

:- pred(code_neck/0, []).
code_neck =>
    if(not(callexp('IsDeep',[])),
      (do_neck,
       % OK even before allocate
       call('SetE', [(~w)^.local_top]))).

:- pred(code_neck_proceed/0, []).
code_neck_proceed =>
    if(not(callexp('IsDeep',[])),
      do_neck,
      (~w)^.local_top <- 0),
    call('SetE', [(~w)^.frame]),
    "P" <- (~w)^.next_insn,
    profile_hook(neck_proceed),
    jump_ins_dispatch.

% TODO:[oc-merge] CODE_MAYBE_NECK_TRY
:- pred(do_neck/0, []).
do_neck => % (assume !IsDeep())
    "B" <- (~w)^.choice,
    if(not(callexp('IsShallowTry',[])),
      % retry
      (call('NECK_RETRY_PATCH', ["B"])), % TODO:[oc-merge] this is not in OC
      % try
      ("B"^.next_alt <- (~w)^.next_alt, %  /* 4 contiguous moves */
       "B"^.frame <- (~w)^.frame,
       "B"^.next_insn <- (~w)^.next_insn,
       "B"^.local_top <- (~w)^.local_top,
       localv(intmach, I, callexp('ChoiceArity', ["B"])),
       foreach(intmach, range(I), K, ("B"^.x[K] <- (~w)^.x[K])),
       maybe_choice_overflow) % TODO:[oc-merge] check for choice overflow needed here?
    ),
    call('SetDeep', []).

:- pred(maybe_choice_overflow/0, []).
maybe_choice_overflow =>
    if(callexp('ChoiceYounger',
        [callexp('ChoiceOffset', ["B","CHOICEPAD"]),(~w)^.trail_top]),
      cvoid_call('choice_overflow', [2*"CHOICEPAD"*sizeof(tagged),~true])).

% Worker state

:- pred(x/1, []).
x(Xn) => callexp('X', [Xn]).
:- pred(y/1, []).
y(Yn) => callexp('Y', [Yn]).

% ---------------------------------------------------------------------------
%! # Definition of instruction format types (ftypes)

% TODO: see engine_oc/ftype.pl qs_enc/2, ql_enc/2

% ftype_def(Code, Id, Def)

% f_o opcode
:- ftype_def(f_o, 15, basic(8, 8)).
% f_e frame_size
:- ftype_def(f_e, 8, basic(8, 8)).
% f_f functor
:- ftype_def(f_f, 9, basic(5, 6)).
% f_i count
:- ftype_def(f_i, 10, basic(8, 8)).
% f_l long
:- ftype_def(f_l, 11, basic(2, 6)).
% f_g liveinfo % TODO: be careful! 
:- ftype_def(f_g, 12, str([f_l, f_i])).
% f_p bytecode pointer
:- ftype_def(f_p, 13, basic(3, 3)).
% f_t term
:- ftype_def(f_t, 14, basic(6, 6)).
% f_x x operand
:- ftype_def(f_x, 16, basic(8, 8)).
% f_y y operand
:- ftype_def(f_y, 17, basic(8, 8)).
% f_z y operand, low bit -> unsafe
:- ftype_def(f_z, 18, basic(8, 8)).
% f_C C/native code pointer
:- ftype_def(f_C, 5, basic(9, 6)).
% f_E predicate pointer
:- ftype_def(f_E, 6, basic(7, 6)).
% f_Q pad byte
:- ftype_def(f_Q, 19, basic(8, 8)).
% f_Y ::= <i>{<y>}
:- ftype_def(f_Y, 3, array(f_i, f_y)).
% f_Z ::= <i>{<z>}
:- ftype_def(f_Z, 4, array(f_i, f_z)).
% f_b blob (large number or float) (spec functor and data object)
:- ftype_def(f_b, 7, blob).

% 'Decoding' a bytecode operand as an expression
% TODO: use [[ ]]] counter for automatic N in dec
:- pred(dec/2, []).
dec(op(f_x,N),R) => [[ R = callexp('Xb', [N]) ]].
dec(op(f_y,N),R) => [[ R = callexp('Yb', [N]) ]].
dec(op(f_b,N),R) => [[ R = addr(N) ]]. % (a reference to the blob)
dec(op(f_g,N),R) => [[ R = addr(N) ]]. % (a reference to the blob)
dec(op(_,N),R) => [[ R = N ]].

:- pred(decops/1, []).
decops(Xs) => [[ format(Fs) ]], decopsf(Fs, Xs).

:- pred(decopsf/2, []). % TODO: explicit format (avoid it...)
decopsf(Fs, Xs) => decops_(Fs, 0, Xs).

decops_([], _, []) => true.
decops_([f_Q|Fs], Idx, Xs) => decops_(Fs, Idx+fsize(f_Q), Xs).
decops_([F|Fs], Idx, [X|Xs]) => dec(op(F,bcp(F,Idx)),X), decops_(Fs, Idx+fsize(F), Xs).

% (see op_macros/0)
:- pred(bcp/2, []). % (like bcp but counts from 0)
bcp(f_b,N) => callexp('BcP', ["f_t",N]). % TODO: treated as f_t just for casting, better way?
bcp(f_E,N) => callexp('BcP', ["f_p",N]). % TODO: treated as f_p
bcp(f_g,N) => callexp('BcP', ["f_l",N]). % TODO: treated as f_l (for addr)
bcp(FType,N) => [[ Id = fmt:atom(FType) ]], callexp('BcP', [Id,N]).

% TODO: 'error' rewrite rule for compile-time errors?

% Move the program counter to discard an argument
:- pred(shiftf/1, []).
shiftf(f_i), [[ format([f_Y|Format]) ]] => [[ update(format([f_Yargs|Format])) ]],
   shiftf_(f_i).
shiftf(f_i), [[ format([f_Z|Format]) ]] => [[ update(format([f_Zargs|Format])) ]],
   shiftf_(f_i).
shiftf(f_y), [[ format([f_Yargs|_]) ]] =>
   shiftf_(f_y).
shiftf(f_z), [[ format([f_Zargs|_]) ]] =>
   shiftf_(f_z).
shiftf(_) => shiftf.

shiftf =>
   [[ format([F|Format]) ]],
   [[ update(format(Format)) ]],
   shiftf_(F).

shiftf_nodec => % like shiftf but do not update P (it is going to be rewritten)
   [[ update(format('?')) ]].

shiftf_(FType) => assign("P" + fsize(FType)).

% (fsize)
:- pred(fsize/1, []).
fsize(FType) => [[ Id = fmt:atom(FType) ]], callexp('Fs',[Id]).

:- pred(sizeof/1, []).
sizeof(tagged) => "sizeof(tagged_t)".
sizeof(sw_on_key_node) => "sizeof(sw_on_key_node_t)".

% ---------------------------------------------------------------------------
%! # (bytecode support)

% (sum of fsize)
:- pred(fsize_sum/1, []).
fsize_sum([]) => 0.
fsize_sum([X]) => fsize(X).
fsize_sum([X|Xs]) => fsize(X), "+", fsize_sum(Xs).

% Jump to a given instruction keeping the same operand stream
:- pred(goto_ins/1, []).
goto_ins(Ins) =>
    [[mode(M)]],
    [[get_ins_label(Ins, M, Label)]],
    goto(Label).

% Dispatch (using implicit format)
dispatch => [[ format(Fs) ]], dispatchf(fsize_sum(Fs)).

% Dispatch (jump to next instruction in the selected read/write
% mode). Skips OpsSize items from the operand stream.
:- pred(dispatchf/1, []).
dispatchf(OpsSize) =>
    assign("P" + OpsSize),
    jump_ins_dispatch.

% Load/store local copies of worker registers
:- pred(regload/1, []).
regload('H') => call0('LoadH').

:- pred(regstore/1, []).
regstore('H') => call0('StoreH').

:- pred(cachedreg/2, []).
:- pred(cachedreg(Reg,_), [rs_mark('cachedreg/2'(Reg))]). % (for trace only remember 1st arg)
cachedreg('H',H), [[mode(r)]] => [[H = (~w)^.heap_top]].
cachedreg('H',H), [[mode(w)]] => [[H = "H"]].

% Switch the read/write mode
:- pred(setmode/1, []).
setmode(w), [[mode(r)]] =>
    regload('H'),
    [[update(mode(w))]].
setmode(r), [[mode(w)]] =>
    regstore('H'),
    [[update(mode(r))]].
setmode(M), [[mode(M)]] => true.

% Switch mode and update H simulateneously
% (this avoids an unnecessary StoreH in w->r switch)
:- pred(setmode_setH/2, []).
setmode_setH(r, NewH), [[mode(r)]] => (~w)^.heap_top <- NewH.
setmode_setH(r, NewH), [[mode(w)]] =>
    [[update(mode(r))]],
    (~w)^.heap_top <- NewH.

:- pred(put_yvoid/0, []).
put_yvoid =>
    "{",
    localv(tagged, T0, bcp(f_y,0)),
    shiftf(f_y),
    dec(op(f_y,T0),Y),
    load(sva, Y),
    "}".
    
:- pred(heap_push/1, []).
heap_push(X) =>
    cachedreg('H', H),
    call('HeapPush', [H, X]).

:- pred(ref_stack/3, []).
ref_stack(safe, A, B) => call('RefStack', [A,addr(B)]).
ref_stack(unsafe, A, B) => ref_stack_unsafe(A,addr(B)).

% NOTE: this is an expression!
:- pred(unsafe_var_expr/1, []).
unsafe_var_expr(X) => not(callexp('YoungerStackVar', [tagp(sva,callexp('Offset',["E","EToY0"])), X])).

:- pred(ref_stack_unsafe/2, []).
ref_stack_unsafe(To,From) =>
    "{",
    localv(tagged, T0),
    localv(tagged, T1),
    call('RefStack', [T0, From]),
    if(callexp('TaggedIsSVA', [T0]),
      do_while((
          call('RefSVA', [T1,T0]),
          if(T1==T0, (
              if(unsafe_var_expr(T0),
                 (load(hva, T0),
                  bind(sva, T1, T0))),
              break)
          ),
          T0 <- T1
      ), callexp('TaggedIsSVA', [T0]))),
    To <- T0,
    "}".

:- pred(ref_heap_next/1, []).
ref_heap_next(A) =>
    call('RefHeapNext', [A, "S"]).

:- pred(preload/2, []).
preload(hva, A) =>
    cachedreg('H', H),
    call('PreLoadHVA', [A, H]).

:- pred(load2/3, []).
load2(hva, A, B) =>
    cachedreg('H', H),
    call('Load2HVA', [A, B, H]).
load2(sva, A, B) =>
    call('Load2SVA', [A, B]).

:- pred(load/2, []).
load(hva, A) =>
    cachedreg('H', H),
    call('LoadHVA', [A, H]).
load(sva, A) =>
    call('LoadSVA', [A]).
load(cva, A) =>
    cachedreg('H', H),
    call('LoadCVA', [A, H]).

:- pred(bind/3, []).
bind(hva, T0, T1) =>
    call('BindHVA', [T0,T1]).
bind(cva, T0, T1) =>
    call('BindCVA', [T0,T1]).
bind(sva, T0, T1) =>
    call('BindSVA', [T0,T1]).

% segfault patch -- jf
% 'U' is a 'Yb(I)' expression.
:- pred(get_first_value/2, []).
get_first_value(U, V) =>
    if(callexp('CondStackvar', [U]), (
      call('TrailPushCheck', [(~w)^.trail_top,tagp(sva, addr(U))]),
      U <- V
    ), (
      U <- V
    )).

:- pred(u1/1, []).
u1(void(X)), [[mode(r)]] =>
    "S" <- call('HeapOffset', ["S", X]).
u1(void(X)), [[mode(w)]] =>
    "{",
    localv(intmach, I, cast(ftype_ctype(f_i_signed), X)),
    do_while(call('ConstrHVA', ["H"]), ("--",I)),
    "}".
u1(var(X)), [[mode(r)]] =>
    ref_heap_next(X).
u1(var(X)), [[mode(w)]] =>
    load(hva,X).
u1(xval(X)), [[mode(r)]] =>
    "{",
    localv(tagged, T1), ref_heap_next(T1),
    cunify(X, T1),
    "}".
u1(yval(Y)), [[mode(r)]] =>
    "{",
    localv(tagged, T1), ref_heap_next(T1),
    localv(tagged, T0), ref_stack(safe, T0, Y),
    cunify(T0, T1),
    "}".
u1(yfval(Y)), [[mode(r)]] =>
    "{",
    localv(tagged, T0), ref_heap_next(T0),
    get_first_value(Y,T0),
    "}".
u1(xval(X)), [[mode(w)]] =>
    heap_push(X).
u1(yval(Y)), [[mode(w)]] =>
    cachedreg('H', H),
    call('HeapPushRefStack', [H,addr(Y)]).
u1(yfval(Y)), [[mode(w)]] =>
    "{",
    localv(tagged, T0), load(hva,T0),
    get_first_value(Y,T0),
    "}".
u1(xlval(X)), [[mode(r)]] =>
    u1(xval(X)).
u1(ylval(Y)), [[mode(r)]] =>
    u1(yval(Y)).
u1(xlval(X)), [[mode(w)]] =>
    "{",
    localv(tagged, T1, X),
    unify_local_value(T1),
    "}".
u1(ylval(Y)), [[mode(w)]] =>
    "{",
    localv(tagged, T1), ref_stack(safe, T1, Y),
    unify_local_value(T1),
    "}".

:- pred(alloc/0, []).
alloc => call('CODE_ALLOC', ["E"]).
    
% Emit the initialization of Y variables
:- pred(init_yvars/1, []).
init_yvars(Count) =>
    foreach(intmach, revrangeq(Count-sizeof(tagged), "EToY0"*sizeof(tagged), sizeof(tagged)), T, (
        dec(op(f_y,T),Y),
        load(sva,Y)
    )).

% Emit the code to put a Y argument (which may be 'unsafe')
:- pred(putarg/2, []).
putarg(Zn,Xn) =>
    if(Zn/\1,
      (dec(op(f_y,Zn+1),Y1),
       ref_stack(unsafe, x(Xn), Y1)),
      (dec(op(f_y,Zn),Y2),
       ref_stack(safe, x(Xn), Y2))).

% Wrapper for execution of instruction G in the specified mode M
:- pred(in_mode/2, []).
in_mode(M, G), [[mode(M)]] => G.
in_mode(M, G) => setmode(M), goto_ins(G).

% Pre-registered atoms
:- pred(get_atom/2, []).
get_atom([], X) => [[ X = "atom_nil" ]].

% ---------------------------------------------------------------------------
%! # Declaration of instructions

:- pred(ins_op_format/4, [unfold_decl]).
ins_op_format(Ins, Op, Format, Props) :-
    add(pred_prop(Ins, ins_op(Op))),
    add(pred_prop(Ins, format(Format))),
    update_max_op(Op),
    update_op_ins(Op, Ins),
    ins_op_format_(Ins, Props).

:- pred(ins_op_format_/2, [unfold_decl]).
ins_op_format_(_Ins, []) :- true. % TODO: allow facts (no ":- true")
ins_op_format_(Ins, [Prop|Props]) :-
    ins_op_format__(Ins, Prop),
    ins_op_format_(Ins, Props).

:- pred(ins_op_format__/2, [unfold_decl]).
ins_op_format__(Ins, label(M)) :- add(pred_prop(Ins, label(M))).
ins_op_format__(Ins, optional(Name)) :- add(pred_prop(Ins, optional(Name))).

% Ins instruction always switches to mode Mode
:- pred(ins_in_mode/2, [unfold_decl]).
ins_in_mode(Ins, Mode) :-
    add(pred_prop(Ins, in_mode(Mode))).

% ---------------------------------------------------------------------------
%! # Definition of the instruction set

:- ins_in_mode(inittrue, w).
inittrue => decops([N]),
    alloc,
    init_yvars(N),
    goto('firsttrue').

:- ins_in_mode(firsttrue_n, w).
firsttrue_n => decopsf([f_i],[N]),
    "{",
    localv(intmach, I, cast(ftype_ctype(f_i_signed), N)),
    shiftf(f_i),
    foreach(intmach, revrange(I), _I0, put_yvoid),
    "}",
    goto('firsttrue'),
    label('firsttrue'),
    decopsf([f_e],[EnvSize]),
    "E"^.next_insn <- (~w)^.next_insn,
    "E"^.frame <- (~w)^.frame,
    (~w)^.frame <- "E",
    % (~w)^.next_insn <- callexp('PoffR', [2]), % (before)
    (~w)^.next_insn <- callexp('BCoff', ["P", fsize_sum([f_e])]),
    (~w)^.local_top <- callexp('StackCharOffset', ["E",EnvSize]),
    if(callexp('OffStacktop',["E","Stack_Warn"]),
      call('SetEvent', [])),
    dispatchf(fsize_sum([f_e])). % (was f_i before)

initcallq => shiftf, goto_ins(initcall).

:- ins_in_mode(initcall, w).
initcall => decops([_,N]),
    alloc,
    init_yvars(N),
    goto_ins(firstcall).

firstcall_nq => shiftf, goto_ins(firstcall_n).

:- ins_in_mode(firstcall_n, w).
firstcall_n => decopsf([f_i],[N]),
    "{",
    localv(intmach, I, cast(ftype_ctype(f_i_signed), N)),
    shiftf(f_i),
    foreach(intmach, revrange(I,8), _I0, put_yvoid),
    "}",
    goto_ins(firstcall_8).

firstcall_8q => shiftf, goto_ins(firstcall_8).

:- ins_in_mode(firstcall_8, w).
firstcall_8 => put_yvoid, goto_ins(firstcall_7).

firstcall_7q => shiftf, goto_ins(firstcall_7).

:- ins_in_mode(firstcall_7, w).
firstcall_7 => put_yvoid, goto_ins(firstcall_6).

firstcall_6q => shiftf, goto_ins(firstcall_6).

:- ins_in_mode(firstcall_6, w).
firstcall_6 => put_yvoid, goto_ins(firstcall_5).

firstcall_5q => shiftf, goto_ins(firstcall_5).

:- ins_in_mode(firstcall_5, w).
firstcall_5 => put_yvoid, goto_ins(firstcall_4).

firstcall_4q => shiftf, goto_ins(firstcall_4).

:- ins_in_mode(firstcall_4, w).
firstcall_4 => put_yvoid, goto_ins(firstcall_3).

firstcall_3q => shiftf, goto_ins(firstcall_3).

:- ins_in_mode(firstcall_3, w).
firstcall_3 => put_yvoid, goto_ins(firstcall_2).

firstcall_2q => shiftf, goto_ins(firstcall_2).

:- ins_in_mode(firstcall_2, w).
firstcall_2 => put_yvoid, goto_ins(firstcall_1).

firstcall_1q => shiftf, goto_ins(firstcall_1).

:- ins_in_mode(firstcall_1, w).
firstcall_1 => put_yvoid, goto_ins(firstcall).

firstcallq => shiftf, goto_ins(firstcall).

:- ins_in_mode(firstcall, w).
firstcall => decops([PredPtr,EnvSize]),
    "E"^.next_insn <- (~w)^.next_insn,
    "E"^.frame <- (~w)^.frame,
    (~w)^.frame <- "E",
    (~w)^.next_insn <- callexp('BCoff', ["P", fsize_sum([f_E,f_e])]),
    (~w)^.local_top <- callexp('StackCharOffset', ["E",EnvSize]),
    "P" <- PredPtr,
    if(callexp('OffStacktop',["E","Stack_Warn"]),
      call('SetEvent', [])),
    goto('enter_predicate').

:- pred(putarg_z_shift/1, []).
putarg_z_shift(Xn) =>
    "{",
    localv(tagged, T1, bcp(f_z,0)),
    shiftf(f_z),
    putarg(T1,Xn),
    "}".

call_nq => shiftf, goto_ins(call_n).

:- ins_in_mode(call_n, w).
call_n => decopsf([f_i],[N]),
    "{",
    localv(intmach, I, cast(ftype_ctype(f_i_signed), N)),
    shiftf(f_i),
    foreach(intmach, revrange(I,8), I0, putarg_z_shift(I0-1)),
    "}",
    goto_ins(call_8).

call_8q => shiftf, goto_ins(call_8).

:- ins_in_mode(call_8, w).
call_8 =>
    putarg_z_shift(7),
    goto_ins(call_7).

call_7q => shiftf, goto_ins(call_7).

:- ins_in_mode(call_7, w).
call_7 =>
    putarg_z_shift(6),
    goto_ins(call_6).

call_6q => shiftf, goto_ins(call_6).

:- ins_in_mode(call_6, w).
call_6 =>
    putarg_z_shift(5),
    goto_ins(call_5).

call_5q => shiftf, goto_ins(call_5).

:- ins_in_mode(call_5, w).
call_5 =>
    putarg_z_shift(4),
    goto_ins(call_4).

call_4q => shiftf, goto_ins(call_4).

:- ins_in_mode(call_4, w).
call_4 =>
    putarg_z_shift(3),
    goto_ins(call_3).

call_3q => shiftf, goto_ins(call_3).

:- ins_in_mode(call_3, w).
call_3 =>
    putarg_z_shift(2),
    goto_ins(call_2).

call_2q => shiftf, goto_ins(call_2).

:- ins_in_mode(call_2, w).
call_2 =>
    putarg_z_shift(1),
    goto_ins(call_1).

call_1q => shiftf, goto_ins(call_1).

:- ins_in_mode(call_1, w).
call_1 =>
    putarg_z_shift(0),
    goto_ins(call).

callq => shiftf, goto_ins(call).

:- ins_in_mode(call, w).
call => decops([Pred,_]),
    (~w)^.next_insn <- callexp('BCoff', ["P", fsize_sum([f_E,f_e])]),
    "P" <- Pred,
    goto('enter_predicate').

lastcall_nq => shiftf, goto_ins(lastcall_n).

:- ins_in_mode(lastcall_n, w).
lastcall_n => decopsf([f_i],[N]),
    "{",
    localv(intmach, I, cast(ftype_ctype(f_i_signed), N)),
    shiftf(f_i),
    foreach(intmach, revrange(I,8), I0, putarg_z_shift(I0-1)),
    "}",
    goto_ins(lastcall_8).

lastcall_8q => shiftf, goto_ins(lastcall_8).

:- ins_in_mode(lastcall_8, w).
lastcall_8 =>
    putarg_z_shift(7),
    goto_ins(lastcall_7).

lastcall_7q => shiftf, goto_ins(lastcall_7).

:- ins_in_mode(lastcall_7, w).
lastcall_7 =>
    putarg_z_shift(6),
    goto_ins(lastcall_6).

lastcall_6q => shiftf, goto_ins(lastcall_6).

:- ins_in_mode(lastcall_6, w).
lastcall_6 =>
    putarg_z_shift(5),
    goto_ins(lastcall_5).

lastcall_5q => shiftf, goto_ins(lastcall_5).

:- ins_in_mode(lastcall_5, w).
lastcall_5 =>
    putarg_z_shift(4),
    goto_ins(lastcall_4).

lastcall_4q => shiftf, goto_ins(lastcall_4).

:- ins_in_mode(lastcall_4, w).
lastcall_4 =>
    putarg_z_shift(3),
    goto_ins(lastcall_3).

lastcall_3q => shiftf, goto_ins(lastcall_3).

:- ins_in_mode(lastcall_3, w).
lastcall_3 =>
    putarg_z_shift(2),
    goto_ins(lastcall_2).

lastcall_2q => shiftf, goto_ins(lastcall_2).

:- ins_in_mode(lastcall_2, w).
lastcall_2 =>
    putarg_z_shift(1),
    goto_ins(lastcall_1).

lastcall_1q => shiftf, goto_ins(lastcall_1).

:- ins_in_mode(lastcall_1, w).
lastcall_1 =>
    putarg_z_shift(0),
    goto_ins(lastcall).

lastcallq => shiftf, goto_ins(lastcall).

:- ins_in_mode(lastcall, w).
lastcall =>
    deallocate,
    goto_ins(execute).

executeq => decops([Pred]),
    setmode(w),
    "P" <- Pred,
    goto('enter_predicate').

execute => decops([Pred]),
    setmode(w),
    "P" <- Pred,
    goto('enter_predicate').

:- ins_in_mode(put_x_void, w).
put_x_void => decops([X]),
    load(hva,X),
    dispatch.

:- ins_in_mode(put_x_variable, w).
put_x_variable => decops([A,B]),
    load2(hva, A, B),
    dispatch.

put_xval_xval => decops([A,B,C,D]),
    A <- B,
    C <- D,
    dispatch.

put_x_value => decops([A,B]),
    A <- B,
    dispatch.

:- ins_in_mode(put_x_unsafe_value, w).
put_x_unsafe_value => decops([A,B]),
    "{",
    localv(tagged, T0), ref_stack(unsafe,T0,B),
    A <- T0,
    B <- T0,
    "}",
    dispatch.

:- ins_in_mode(put_y_first_variable, w).
put_y_first_variable =>
    alloc,
    goto_ins(put_y_variable).

:- ins_in_mode(put_y_variable, w).
put_y_variable => decops([A,B]),
    load2(sva, A, B),
    dispatch.

:- ins_in_mode(put_yfvar_yvar, w).
put_yfvar_yvar =>
    alloc,
    goto_ins(put_yvar_yvar).

:- ins_in_mode(put_yvar_yvar, w).
put_yvar_yvar => decops([A,B,C,D]),
    load2(sva, A, B),
    load2(sva, C, D),
    dispatch.

put_yval_yval => decops([A,B,C,D]),
    ref_stack(safe,A,B),
    ref_stack(safe,C,D),
    dispatch.

put_y_value => decops([A,B]),
    ref_stack(safe,A,B),
    dispatch.

:- ins_in_mode(put_y_unsafe_value, w).
put_y_unsafe_value => decops([A,B]),
    ref_stack(unsafe,A,B),
    dispatch.

put_constantq => decops([A,B]),
    A <- B,
    dispatch.

put_constant => decops([A,B]),
    A <- B,
    dispatch.

put_nil => decops([A]),
    get_atom([], Nil),
    A <- Nil,
    dispatch.

:- ins_in_mode(put_largeq, w).
put_largeq => decops([A,B]),
    [[mode(M)]],
    setmode(r),
    A <- cfun_eval('BC_MakeBlob', [B]),
    setmode(M),
    dispatchf(fsize_sum([f_Q,f_x])+callexp('LargeSize',[B^])).

:- ins_in_mode(put_large, w).
put_large => decops([A,B]),
    [[mode(M)]],
    setmode(r),
    A <- cfun_eval('BC_MakeBlob', [B]),
    setmode(M),
    dispatchf(fsize_sum([f_x])+callexp('LargeSize',[B^])).

:- ins_in_mode(put_structureq, w).
put_structureq => decops([A,B]),
    cachedreg('H', H),
    A <- tagp(str, H),
    heap_push(B),
    dispatch.

:- ins_in_mode(put_structure, w).
put_structure => decops([A,B]),
    cachedreg('H', H),
    A <- tagp(str, H),
    heap_push(B),
    dispatch.

:- ins_in_mode(put_list, w).
put_list => decops([A]),
    cachedreg('H', H),
    A <- tagp(lst, H),
    dispatch.

:- ins_in_mode(put_yval_yuval, w).
put_yval_yuval => decops([A,B,C,D]),
    ref_stack(safe,A,B),
    ref_stack(unsafe,C,D),
    dispatch.

:- ins_in_mode(put_yuval_yval, w).
put_yuval_yval => decops([A,B,C,D]),
    ref_stack(unsafe,A,B),
    ref_stack(safe,C,D),
    dispatch.

:- ins_in_mode(put_yuval_yuval, w).
put_yuval_yuval => decops([A,B,C,D]),
    ref_stack(unsafe,A,B),
    ref_stack(unsafe,C,D),
    dispatch.

:- ins_in_mode(get_x_value, r).
get_x_value => decops([A,B]),
    cunify(B,A),
    dispatch.

:- ins_in_mode(get_y_first_value, r).
get_y_first_value => decops([A,B]),
    get_first_value(B,A),
    dispatch.

:- ins_in_mode(get_y_value, r).
get_y_value => decops([A,B]),
    "{",
    localv(tagged, T1), ref_stack(safe,T1,B),
    cunify(A,T1),
    "}",
    dispatch.

get_constantq => shiftf, goto_ins(get_constant).

:- ins_in_mode(get_constant, r).
get_constant => decops([A,B]),
    unify_atom(B,A),
    dispatch.

get_largeq => shiftf, goto_ins(get_large).

:- ins_in_mode(get_large, r).
get_large => decops([A,B]),
    unify_large(B,A),
    dispatchf(fsize_sum([f_x])+callexp('LargeSize',[B^])).

get_structureq => shiftf, goto_ins(get_structure).

:- ins_in_mode(get_structure, r).
get_structure => decops([A,B]),
    unify_structure(B,A,dispatch).

:- ins_in_mode(get_nil, r).
get_nil => decops([A]),
    get_atom([], Nil),
    unify_atom(Nil,A),
    dispatch.

:- ins_in_mode(get_list, r).
get_list => decops([A]),
    unify_list(A, dispatch).

get_constant_neck_proceedq => shiftf, goto_ins(get_constant_neck_proceed).

:- ins_in_mode(get_constant_neck_proceed, r).
get_constant_neck_proceed => decops([A,B]),
    unify_atom(B,A),
    setmode(w),
    goto_ins(neck_proceed).

:- ins_in_mode(get_nil_neck_proceed, r).
get_nil_neck_proceed => decops([A]),
    get_atom([], Nil),
    unify_atom(Nil,A),
    setmode(w),
    goto_ins(neck_proceed).

:- ins_in_mode(cutb_x, r).
cutb_x => decops([A]),
    (~w)^.local_top <- 0, % may get hole at top of local stack
    (~w)^.previous_choice <- call('ChoiceFromTagged', [A]),
    do_cut,
    dispatch.

:- ins_in_mode(cutb_x_neck, r).
cutb_x_neck => decops([A]),
    (~w)^.local_top <- 0, % may get hole at top of local stack
    (~w)^.previous_choice <- call('ChoiceFromTagged', [A]),
    shiftf,
    goto_ins(cutb_neck).

:- ins_in_mode(cutb_neck, r).
cutb_neck =>
    do_cutb_neck,
    dispatch.

:- ins_in_mode(cutb_x_neck_proceed, r).
cutb_x_neck_proceed => decops([A]),
    (~w)^.previous_choice <- call('ChoiceFromTagged', [A]),
    shiftf_nodec,
    % w->local_top <- 0 % done by CODE_PROCEED
    goto_ins(cutb_neck_proceed).

:- ins_in_mode(cutb_neck_proceed, r).
cutb_neck_proceed =>
    do_cutb_neck,
    goto_ins(proceed).

:- pred(do_cutb_neck/0, []).
do_cutb_neck =>
    do_cut,
    if(not(callexp('IsDeep',[])),
      (call('SetDeep', []),
       % TODO:[merge-oc] if neck is not pending, then choice overflow has already been checked?
       maybe_choice_overflow)).

:- ins_in_mode(cute_x, r).
cute_x => decops([A]),
    (~w)^.previous_choice <- call('ChoiceFromTagged', [A]),
    (~w)^.local_top <- "E", % w->local_top may be 0 here
    do_cut,
    call('SetE', [(~w)^.local_top]),
    dispatch.

:- ins_in_mode(cute_x_neck, r).
cute_x_neck => decops([A]),
    (~w)^.previous_choice <- call('ChoiceFromTagged', [A]),
    shiftf,
    goto_ins(cute_neck).

:- ins_in_mode(cute_neck, r).
cute_neck =>
    (~w)^.local_top <- "E", %  w->local_top may be 0 here.
    do_cut,
    % w->next_alt can't be NULL here
    call('SetDeep', []),
    if(callexp('ChoiceYounger', [callexp('ChoiceOffset', ["B","CHOICEPAD"]),(~w)^.trail_top]),
      cvoid_call('choice_overflow', [2*"CHOICEPAD"*sizeof(tagged),~true])),
    call('SetE', [(~w)^.local_top]),
    dispatch.

:- ins_in_mode(cutf_x, r).
cutf_x => decops([A]),
    (~w)^.previous_choice <- call('ChoiceFromTagged', [A]),
    shiftf,
    goto_ins(cutf). % TODO: check that pending 'format' after shift is the expected one

:- ins_in_mode(cutf, r).
cutf =>
    do_cut,
    call('SetE', [(~w)^.frame]),
    dispatch.

:- ins_in_mode(cut_y, r).
cut_y => decops([A]),
    "{",
    localv(tagged, T1), ref_stack(safe,T1,A),
    (~w)^.previous_choice <- callexp('ChoiceFromTagged', [T1]),
    "}",
    do_cut,
    call('SetE', [(~w)^.frame]),
    dispatch.

choice_x => decops([X]),
    X <- callexp('ChoiceToTagged', [(~w)^.previous_choice]),
    dispatch.

choice_yf =>
    alloc,
    goto_ins(choice_y).

choice_y => decops([Y]),
    Y <- callexp('ChoiceToTagged', [(~w)^.previous_choice]),
    dispatch.

:- ins_in_mode(kontinue, w).
kontinue =>
    % after wakeup, write mode!
    call('Setfunc', [callexp('TaggedToFunctor', [y(0)])]),
    foreach(intmach, range("Func"^.arity), I, (x(I) <- y(I+1))),
    deallocate,
    goto('enter_predicate').

:- ins_in_mode(leave, r).
leave => goto_ins(exit_toplevel).

:- ins_in_mode(exit_toplevel, r).
exit_toplevel =>
    goto('exit_toplevel').

:- ins_in_mode(retry_cq, r).
retry_cq => decops([A]),
    if(not(callexp('IsDeep',[])),
      (call('NECK_RETRY_PATCH', ["B"]),
       call('SetDeep', []))),
    if(not(call_fC(cbool0,A,[])), jump_fail),
    goto_ins(proceed).

:- ins_in_mode(retry_c, r).
retry_c => decops([A]),
    if(not(callexp('IsDeep',[])),
      (call('NECK_RETRY_PATCH', ["B"]),
       call('SetDeep', []))),
    if(not(call_fC(cbool0,A,[])), jump_fail),
    goto_ins(proceed).

% _x0 instructions, where read-mode match has been done during indexing

get_structure_x0q, [[mode(r)]] =>
    "{",
    localv(tagged, T0, x(0)),
    "S" <- callexp('TaggedToArg', [T0, 1]),
    "}",
    dispatch.
get_structure_x0q, [[mode(w)]] =>
    shiftf, goto_ins(get_structure_x0).

get_structure_x0, [[mode(r)]] =>
    "{",
    localv(tagged, T0, x(0)),
    "S" <- callexp('TaggedToArg', [T0, 1]),
    "}",
    dispatch.
get_structure_x0, [[mode(w)]] => decops([A]),
    "{",
    cachedreg('H', H),
    localv(tagged, T1, tagp(str, H)),
    localv(tagged, T0, x(0)),
    if(callexp('TaggedIsHVA', [T0]),
      bind(hva,T0,T1),
      if(T0 /\ "TagBitSVA",
        bind(sva,T0,T1),
        bind(cva,T0,T1))),
    heap_push(A),
    "}",
    dispatch.

get_large_x0q, [[mode(r)]] => decops([A]),
    "{",
    localv(tagged, T0, x(0)),
    unify_large(A,T0),
    "}",
    dispatchf(fsize_sum([f_x])+callexp('LargeSize',[A^])).
get_large_x0q, [[mode(w)]] =>
    shiftf, goto_ins(get_large_x0).

get_large_x0, [[mode(r)]] => decops([A]),
    "{",
    localv(tagged, T0, x(0)),
    unify_large(A,T0),
    "}",
    dispatchf(callexp('LargeSize',[A^])).
get_large_x0, [[mode(w)]] => decops([A]),
    "{",
    setmode(r),
    localv(tagged, T1, cfun_eval('BC_MakeBlob', [A])),
    setmode(w),
    localv(tagged, T0, x(0)),
    if(callexp('TaggedIsHVA', [T0]),
      bind(hva,T0,T1),
      if(T0 /\ "TagBitSVA",
        bind(sva,T0,T1),
        bind(cva,T0,T1))),
    "}",
    dispatchf(callexp('LargeSize',[A^])).

get_constant_x0q, [[mode(r)]] =>
    dispatch.
get_constant_x0q, [[mode(w)]] =>
    shiftf, goto_ins(get_constant_x0).

get_constant_x0, [[mode(r)]] =>
    dispatch.
get_constant_x0, [[mode(w)]] => decops([A]),
    "{",
    localv(tagged, T0, x(0)),
    if(callexp('TaggedIsHVA', [T0]),
      bind(hva,T0,A),
      if(T0 /\ "TagBitSVA",
        bind(sva,T0,A),
        bind(cva,T0,A))),
    "}",
    dispatch.

get_nil_x0, [[mode(r)]] =>
    dispatch.
get_nil_x0, [[mode(w)]] =>
    "{",
    localv(tagged, T0, x(0)),
    get_atom([], Nil),
    if(callexp('TaggedIsHVA', [T0]),
      bind(hva,T0,Nil),
      if(T0 /\ "TagBitSVA",
        bind(sva,T0,Nil),
        bind(cva,T0,Nil))),
    "}",
    dispatch.

get_list_x0, [[mode(r)]] =>
    "{",
    localv(tagged, T0, x(0)),
    "S" <- callexp('TagpPtr', ["LST", T0]),
    "}",
    dispatch.
get_list_x0, [[mode(w)]] =>
    "{",
    cachedreg('H', H),
    localv(tagged, T1, tagp(lst, H)),
    localv(tagged, T0, x(0)),
    if(callexp('TaggedIsHVA', [T0]),
      bind(hva,T0,T1),
      if(T0 /\ "TagBitSVA",
        bind(sva,T0,T1),
        bind(cva,T0,T1))),
    "}",
    dispatch.

get_xvar_xvar => decops([A,B,C,D]),
    B <- A,
    D <- C,
    dispatch.

get_x_variable => decops([A,B]),
    B <- A,
    dispatch.

get_y_first_variable =>
    alloc,
    goto_ins(get_y_variable).

get_y_variable => decops([A,B]),
    B <- A,
    dispatch.

get_yfvar_yvar =>
    alloc,
    goto_ins(get_yvar_yvar).

get_yvar_yvar => decops([A,B,C,D]),
    B <- A,
    D <- C,
    dispatch.

branch => decops([Addr]),
    "P" <- callexp('BCoff', ["P", Addr]),
    dispatchf(0).

% Call Expr function returning a tagged, goto fail on ERRORTAG
:- pred(cfun_semidet/2, []).
cfun_semidet(Target, Expr) =>
    "{",
    localv(tagged, Res, cast(tagged, Expr)),
    Target <- Res,
    if("ERRORTAG"==Res, jump_fail),
    "}".

:- pred(cblt_semidet/1, []).
cblt_semidet(Expr) => if(not(Expr), jump_fail).

:- ins_in_mode(function_1q, r).
function_1q => decops([A,B,C,Li]),
    (~w)^.liveinfo <- Li,
    cfun_semidet(A, call_fC(ctagged1, C, [B])),
    dispatch.

:- ins_in_mode(function_1, r).
function_1 => decops([A,B,C,Li]),
    (~w)^.liveinfo <- Li,
    cfun_semidet(A, call_fC(ctagged1, C, [B])),
    dispatch.

:- ins_in_mode(function_2q, r).
function_2q => decops([A,B,C,D,Li]),
    (~w)^.liveinfo <- Li,
    cfun_semidet(A, call_fC(ctagged2, D, [B,C])),
    dispatch.

:- ins_in_mode(function_2, r).
function_2 => decops([A,B,C,D,Li]),
    (~w)^.liveinfo <- Li,
    cfun_semidet(A, call_fC(ctagged2, D, [B,C])),
    dispatch.

:- ins_in_mode(builtin_1q, r).
builtin_1q => decops([A,B]),
    cblt_semidet(call_fC(cbool1,B,[A])),
    dispatch.

:- ins_in_mode(builtin_1, r).
builtin_1 => decops([A,B]),
    cblt_semidet(call_fC(cbool1,B,[A])),
    dispatch.

:- ins_in_mode(builtin_2q, r).
builtin_2q => decops([A,B,C]),
    cblt_semidet(call_fC(cbool2,C,[A,B])),
    dispatch.

:- ins_in_mode(builtin_2, r).
builtin_2 => decops([A,B,C]),
    cblt_semidet(call_fC(cbool2,C,[A,B])),
    dispatch.

:- ins_in_mode(builtin_3q, r).
builtin_3q => decops([A,B,C,D]),
    cblt_semidet(call_fC(cbool3,D,[A,B,C])),
    dispatch.

:- ins_in_mode(builtin_3, r).
builtin_3 => decops([A,B,C,D]),
    cblt_semidet(call_fC(cbool3,D,[A,B,C])),
    dispatch.

% backtracking into clause/2
:- ins_in_mode(retry_instance, r).
retry_instance =>
    % Take into account 'open' predicates.  (MCL)
    % If there is *definitely* no next instance, remove choicepoint
    if(logical_or(logical_and(callexp('TaggedToRoot',[x("RootArg")])^.behavior_on_failure \== "DYNAMIC",
                              % Wait and removes handle if needed
                              not(cbool_succeed('next_instance_conc', [addr((~w)^.misc^.ins)]))),
                  logical_and(callexp('TaggedToRoot',[x("RootArg")])^.behavior_on_failure == "DYNAMIC",
                              not(cbool_succeed('next_instance', [addr((~w)^.misc^.ins)])))), (
        call('SetDeep', []),
        "B" <- (~w)^.previous_choice,
        call('SetChoice', ["B"])
    )),
    if(is_null((~w)^.misc^.ins),
      % A conc. predicate has been closed, or a non-blocking call was made (MCL)
      (trace(retry_instance_debug_1),
       "TopConcChpt" <- callexp('TermToPointerOrNull', ["choice_t", x("PrevDynChpt")]),
       trace(retry_instance_debug_2),
       % But fail anyway
       jump_fail)),
    trace(retry_instance_debug_3),
    "P" <- cast(bcp, (~w)^.misc^.ins^.emulcode),
    jump_ins_dispatch.

:- ins_in_mode(get_constraint, w).
get_constraint => decops([A]),
    "{", 
    localv(tagged, T1, A),
    localv(tagged, T2), load(cva,T2),
    sw_on_var(T1,
      (bind(hva,T1,T2), A <- T2),
      bind(cva,T2,T1),
      (bind(sva,T1,T2), A <- T2),
      bind(cva,T2,T1)),
    "}",
    dispatch.

unify_void, [[mode(r)]] => decops([N]),
    u1(void(N)),
    dispatch.
unify_void, [[mode(w)]] => decops([N]),
    "{",
    localv(intmach, I, cast(ftype_ctype(f_i_signed), N)),
    shiftf(f_i),
    foreach(intmach, revrange(I,4), _I0,
      (cachedreg('H', H),
       call('ConstrHVA', [H]))),
    "}",
    goto_ins(unify_void_4).

unify_void_1, [[mode(r)]] =>
    u1(void(1)),
    dispatch.
unify_void_1, [[mode(w)]] =>
    cachedreg('H', H),
    call('ConstrHVA', [H]),
    dispatch.

unify_void_2, [[mode(r)]] =>
    u1(void(2)),
    dispatch.
unify_void_2, [[mode(w)]] =>
    cachedreg('H', H),
    call('ConstrHVA', [H]),
    goto_ins(unify_void_1).

unify_void_3, [[mode(r)]] =>
    u1(void(3)),
    dispatch.
unify_void_3, [[mode(w)]] =>
    cachedreg('H', H),
    call('ConstrHVA', [H]),
    goto_ins(unify_void_2).

unify_void_4, [[mode(r)]] =>
    u1(void(4)),
    dispatch.
unify_void_4, [[mode(w)]] =>
    cachedreg('H', H),
    call('ConstrHVA', [H]),
    goto_ins(unify_void_3).

unify_x_variable => decops([A]),
    u1(var(A)),
    dispatch.

unify_x_value, [[mode(r)]] => goto_ins(unify_x_local_value).
unify_x_value, [[mode(w)]] => decops([A]),
    u1(xval(A)),
    dispatch.

unify_x_local_value => decops([A]),
    u1(xlval(A)),
    dispatch.

unify_y_first_variable =>
    alloc,
    goto_ins(unify_y_variable).

unify_y_variable => decops([A]),
    u1(var(A)),
    dispatch.

unify_y_first_value => decops([A]),
    u1(yfval(A)),
    dispatch.

unify_y_value, [[mode(r)]] => goto_ins(unify_y_local_value).
unify_y_value, [[mode(w)]] => decops([A]),
    u1(yval(A)),
    dispatch.

unify_y_local_value => decops([A]),
    u1(ylval(A)),
    dispatch.

unify_constantq, [[mode(r)]] =>
    shiftf, goto_ins(unify_constant).
unify_constantq, [[mode(w)]] => decops([A]),
    heap_push(A),
    dispatch.

unify_constant, [[mode(r)]] => decops([A]),
    "{",
    localv(tagged, T1), ref_heap_next(T1),
    unify_heap_atom(A,T1),
    "}",
    dispatch.
unify_constant, [[mode(w)]] => decops([A]),
    heap_push(A),
    dispatch.

unify_largeq => shiftf, goto_ins(unify_large).

unify_large, [[mode(r)]] => decops([A]),
    "{",
    localv(tagged, T1), ref_heap_next(T1),
    unify_heap_large(A,T1),
    "}",
    dispatchf(callexp('LargeSize',[A^])).
unify_large, [[mode(w)]] => decops([A]),
    % TODO: try to switch to r mode properly (this code is tricky)
    % (this is 'heap_push and switch to read')
    cachedreg('H', H),
    (~w)^.heap_top <- callexp('HeapOffset', [H,1]),
    H^ <- cfun_eval('BC_MakeBlob', [A]),
    [[update(mode(r))]],
    dispatchf(callexp('LargeSize',[A^])).

unify_structureq, [[mode(r)]] =>
    shiftf, goto_ins(unify_structure).
unify_structureq, [[mode(w)]] => decops([A]),
    cachedreg('H', H),
    heap_push(tagp(str,callexp('HeapOffset', [H,1]))),
    heap_push(A),
    dispatch.

unify_structure, [[mode(r)]] => decops([A]),
    "{",
    localv(tagged, T1), ref_heap_next(T1),
    unify_heap_structure(A,T1,dispatch),
    "}".
unify_structure, [[mode(w)]] => decops([A]),
    cachedreg('H', H),
    heap_push(tagp(str,callexp('HeapOffset', [H,1]))),
    heap_push(A),
    dispatch.

unify_nil, [[mode(r)]] =>
    "{",
    localv(tagged, T1), ref_heap_next(T1),
    get_atom([], Nil),
    unify_heap_atom(Nil, T1),
    "}",
    dispatch.
unify_nil, [[mode(w)]] =>
    get_atom([], Nil),
    heap_push(Nil),
    dispatch.

unify_list, [[mode(r)]] =>
    "{",
    localv(tagged, T1), ref_heap_next(T1),
    unify_heap_list(T1,dispatch),
    "}".
unify_list, [[mode(w)]] =>
    cachedreg('H', H),
    heap_push(tagp(lst,callexp('HeapOffset', [H,1]))),
    dispatch.

unify_constant_neck_proceedq, [[mode(r)]] =>
    shiftf, goto_ins(unify_constant_neck_proceed).
unify_constant_neck_proceedq, [[mode(w)]] => decops([A]),
    heap_push(A),
    goto_ins(neck_proceed).

unify_constant_neck_proceed, [[mode(r)]] => decops([A]),
    "{",
    localv(tagged, T1), ref_heap_next(T1),
    unify_heap_atom(A,T1),
    "}",
    setmode(w),
    goto_ins(neck_proceed).
unify_constant_neck_proceed, [[mode(w)]] => decops([A]),
    heap_push(A),
    goto_ins(neck_proceed).

unify_nil_neck_proceed, [[mode(r)]] =>
    "{",
    localv(tagged, T1), ref_heap_next(T1),
    get_atom([], Nil),
    unify_heap_atom(Nil, T1),
    "}",
    setmode(w),
    goto_ins(neck_proceed).
unify_nil_neck_proceed, [[mode(w)]] =>
    get_atom([], Nil),
    heap_push(Nil),
    goto_ins(neck_proceed).

u2_void_xvar => decops([N,B]),
    u1(void(N)),
    u1(var(B)),
    dispatch.

u2_void_yfvar =>
    alloc,
    goto_ins(u2_void_yvar).

u2_void_yvar => decops([N,B]),
    u1(void(N)),
    u1(var(B)),
    dispatch.

u2_void_xval, [[mode(r)]] => goto_ins(u2_void_xlval).
u2_void_xval, [[mode(w)]] => decops([N,B]),
    u1(void(N)),
    u1(xval(B)),
    dispatch.

u2_void_xlval => decops([N,B]),
    u1(void(N)),
    u1(xlval(B)),
    dispatch.

u2_void_yfval => decops([N,B]),
    u1(void(N)),
    u1(yfval(B)),
    dispatch.

u2_void_yval, [[mode(r)]] => goto_ins(u2_void_ylval).
u2_void_yval, [[mode(w)]] => decops([N,B]),
    u1(void(N)),
    u1(yval(B)),
    dispatch.

u2_void_ylval => decops([N,B]),
    u1(void(N)),
    u1(ylval(B)),
    dispatch.

u2_xvar_void => decops([A,N]),
    u1(var(A)),
    u1(void(N)),
    dispatch.

u2_xvar_xvar => decops([A,B]),
    u1(var(A)),
    u1(var(B)),
    dispatch.

u2_xvar_yfvar =>
    alloc,
    goto_ins(u2_xvar_yvar).

u2_xvar_yvar => decops([A,B]),
    u1(var(A)),
    u1(var(B)),
    dispatch.

u2_xvar_xval, [[mode(r)]] => goto_ins(u2_xvar_xlval).
u2_xvar_xval, [[mode(w)]] => decops([A,B]),
    u1(var(A)),
    u1(xval(B)),
    dispatch.

u2_xvar_xlval => decops([A,B]),
    u1(var(A)),
    u1(xlval(B)),
    dispatch.

u2_xvar_yfval => decops([A,B]),
    u1(var(A)),
    u1(yfval(B)),
    dispatch.

u2_xvar_yval, [[mode(r)]] => goto_ins(u2_xvar_ylval).
u2_xvar_yval, [[mode(w)]] => decops([A,B]),
    u1(var(A)),
    u1(yval(B)),
    dispatch.

u2_xvar_ylval => decops([A,B]),
    u1(var(A)),
    u1(ylval(B)),
    dispatch.

u2_yfvar_void =>
    alloc,
    goto_ins(u2_yvar_void).

u2_yvar_void => decops([A,N]),
    u1(var(A)),
    u1(void(N)),
    dispatch.

u2_yfvar_xvar =>
    alloc,
    goto_ins(u2_yvar_xvar).

u2_yvar_xvar => decops([A,B]),
    u1(var(A)),
    u1(var(B)),
    dispatch.

u2_yfvar_yvar =>
    alloc,
    goto_ins(u2_yvar_yvar).

u2_yvar_yvar => decops([A,B]),
    u1(var(A)),
    u1(var(B)),
    dispatch.

u2_yfvar_xval, [[mode(r)]] => goto_ins(u2_yfvar_xlval).
u2_yfvar_xval, [[mode(w)]] =>
    alloc,
    goto_ins(u2_yvar_xval).

u2_yfvar_xlval =>
    alloc,
    goto_ins(u2_yvar_xlval).

u2_yvar_xval, [[mode(r)]] => goto_ins(u2_yvar_xlval).
u2_yvar_xval, [[mode(w)]] => decops([A,B]),
    u1(var(A)),
    u1(xval(B)),
    dispatch.

u2_yvar_xlval => decops([A,B]),
    u1(var(A)),
    u1(xlval(B)),
    dispatch.

u2_yfvar_yval, [[mode(r)]] => goto_ins(u2_yfvar_ylval).
u2_yfvar_yval, [[mode(w)]] =>
    alloc,
    goto_ins(u2_yvar_yval).

u2_yfvar_ylval =>
    alloc,
    goto_ins(u2_yvar_ylval).

u2_yvar_yval, [[mode(r)]] => goto_ins(u2_yvar_ylval).
u2_yvar_yval, [[mode(w)]] => decops([A,B]),
    u1(var(A)),
    u1(yval(B)),
    dispatch.

u2_yvar_ylval => decops([A,B]),
    u1(var(A)),
    u1(ylval(B)),
    dispatch.

u2_yfval_void => decops([A,N]),
    u1(yfval(A)),
    u1(void(N)),
    dispatch.

u2_yfval_xvar => decops([A,B]),
    u1(yfval(A)),
    u1(var(B)),
    dispatch.

u2_yfval_yfval => decops([A,B]),
    u1(yfval(A)),
    u1(yfval(B)),
    dispatch.

u2_yfval_xval, [[mode(r)]] => goto_ins(u2_yfval_xlval).
u2_yfval_xval, [[mode(w)]] => decops([A,B]),
    u1(yfval(A)),
    u1(xval(B)),
    dispatch.

u2_yfval_xlval => decops([A,B]),
    u1(yfval(A)),
    u1(xlval(B)),
    dispatch.

u2_yfval_yval, [[mode(r)]] => goto_ins(u2_yfval_ylval).
u2_yfval_yval, [[mode(w)]] => decops([A,B]),
    u1(yfval(A)),
    u1(yval(B)),
    dispatch.

u2_yfval_ylval => decops([A,B]),
    u1(yfval(A)),
    u1(ylval(B)),
    dispatch.

u2_xval_void, [[mode(r)]] => goto_ins(u2_xlval_void).
u2_xval_void, [[mode(w)]] => decops([A,N]),
    u1(xval(A)),
    u1(void(N)),
    dispatch.

u2_xlval_void => decops([A,N]),
    u1(xlval(A)),
    u1(void(N)),
    dispatch.

u2_xval_xvar, [[mode(r)]] => goto_ins(u2_xlval_xvar).
u2_xval_xvar, [[mode(w)]] => decops([A,B]),
    u1(xval(A)),
    u1(var(B)),
    dispatch.

u2_xlval_xvar => decops([A,B]),
    u1(xlval(A)),
    u1(var(B)),
    dispatch.

u2_xval_yfvar, [[mode(r)]] => goto_ins(u2_xlval_yfvar).
u2_xval_yfvar, [[mode(w)]] =>
    alloc,
    goto_ins(u2_xval_yvar).

u2_xlval_yfvar =>
    alloc,
    goto_ins(u2_xlval_yvar).

u2_xval_yvar, [[mode(r)]] => goto_ins(u2_xlval_yvar).
u2_xval_yvar, [[mode(w)]] => decops([A,B]),
    u1(xval(A)),
    u1(var(B)),
    dispatch.

u2_xlval_yvar => decops([A,B]),
    u1(xlval(A)),
    u1(var(B)),
    dispatch.

u2_xval_xval, [[mode(r)]] => goto_ins(u2_xval_xlval).
u2_xval_xval, [[mode(w)]] => decops([A,B]),
    u1(xval(A)),
    u1(xval(B)),
    dispatch.

u2_xval_xlval, [[mode(r)]] => goto_ins(u2_xlval_xval).
u2_xval_xlval, [[mode(w)]] => decops([A,B]),
    u1(xval(A)),
    u1(xlval(B)),
    dispatch.

u2_xlval_xval, [[mode(r)]] => goto_ins(u2_xlval_xlval).
u2_xlval_xval, [[mode(w)]] => decops([A,B]),
    u1(xlval(A)),
    u1(xval(B)),
    dispatch.

u2_xlval_xlval => decops([A,B]),
    u1(xlval(A)),
    u1(xlval(B)),
    dispatch.

u2_xval_yfval, [[mode(r)]] => goto_ins(u2_xlval_yfval).
u2_xval_yfval, [[mode(w)]] => decops([A,B]),
    u1(xval(A)),
    u1(yfval(B)),
    dispatch.

u2_xlval_yfval => decops([A,B]),
    u1(xlval(A)),
    u1(yfval(B)),
    dispatch.

u2_xval_yval, [[mode(r)]] => goto_ins(u2_xval_ylval).
u2_xval_yval, [[mode(w)]] => decops([A,B]),
    u1(xval(A)),
    u1(yval(B)),
    dispatch.

u2_xval_ylval, [[mode(r)]] => goto_ins(u2_xlval_yval).
u2_xval_ylval, [[mode(w)]] => decops([A,B]),
    u1(xval(A)),
    u1(ylval(B)),
    dispatch.

u2_xlval_yval, [[mode(r)]] => goto_ins(u2_xlval_ylval).
u2_xlval_yval, [[mode(w)]] => decops([A,B]),
    u1(xlval(A)),
    u1(yval(B)),
    dispatch.

u2_xlval_ylval => decops([A,B]),
    u1(xlval(A)),
    u1(ylval(B)),
    dispatch.

u2_yval_void, [[mode(r)]] => goto_ins(u2_ylval_void).
u2_yval_void, [[mode(w)]] => decops([A,N]),
    u1(yval(A)),
    u1(void(N)),
    dispatch.

u2_ylval_void => decops([A,N]),
    u1(ylval(A)),
    u1(void(N)),
    dispatch.

u2_yval_xvar, [[mode(r)]] => goto_ins(u2_ylval_xvar).
u2_yval_xvar, [[mode(w)]] => decops([A,B]),
    u1(yval(A)),
    u1(var(B)),
    dispatch.

u2_ylval_xvar => decops([A,B]),
    u1(ylval(A)),
    u1(var(B)),
    dispatch.

u2_yval_yvar, [[mode(r)]] => goto_ins(u2_ylval_yvar).
u2_yval_yvar, [[mode(w)]] => decops([A,B]),
    u1(yval(A)),
    u1(var(B)),
    dispatch.

u2_ylval_yvar => decops([A,B]),
    u1(ylval(A)),
    u1(var(B)),
    dispatch.

u2_yval_yfval, [[mode(r)]] => goto_ins(u2_ylval_yfval).
u2_yval_yfval, [[mode(w)]] => decops([A,B]),
    u1(yval(A)),
    u1(yfval(B)),
    dispatch.

u2_ylval_yfval => decops([A,B]),
    u1(ylval(A)),
    u1(yfval(B)),
    dispatch.

u2_yval_xval, [[mode(r)]] => goto_ins(u2_yval_xlval).
u2_yval_xval, [[mode(w)]] => decops([A,B]),
    u1(yval(A)),
    u1(xval(B)),
    dispatch.

u2_yval_xlval, [[mode(r)]] => goto_ins(u2_ylval_xval).
u2_yval_xlval, [[mode(w)]] => decops([A,B]),
    u1(yval(A)),
    u1(xlval(B)),
    dispatch.

u2_ylval_xval, [[mode(r)]] => goto_ins(u2_ylval_xlval).
u2_ylval_xval, [[mode(w)]] => decops([A,B]),
    u1(ylval(A)),
    u1(xval(B)),
    dispatch.

u2_ylval_xlval => decops([A,B]),
    u1(ylval(A)),
    u1(xlval(B)),
    dispatch.

u2_yval_yval, [[mode(r)]] => goto_ins(u2_yval_ylval).
u2_yval_yval, [[mode(w)]] => decops([A,B]),
    u1(yval(A)),
    u1(yval(B)),
    dispatch.

u2_yval_ylval, [[mode(r)]] => goto_ins(u2_ylval_yval).
u2_yval_ylval, [[mode(w)]] => decops([A,B]),
    u1(yval(A)),
    u1(ylval(B)),
    dispatch.

u2_ylval_yval, [[mode(r)]] => goto_ins(u2_ylval_ylval).
u2_ylval_yval, [[mode(w)]] => decops([A,B]),
    u1(ylval(A)),
    u1(yval(B)),
    dispatch.

u2_ylval_ylval => decops([A,B]),
    u1(ylval(A)),
    u1(ylval(B)),
    dispatch.

bump_counterq => shiftf, goto_ins(bump_counter).

bump_counter => decops([A]),
    gauge_incr_counter(A),
    dispatch.

counted_neckq => shiftf, goto_ins(counted_neck).

counted_neck => decops([A,B]),
    cpp_if_defined('GAUGE'),
    if(not(callexp('IsDeep',[])), (
      "B" <- (~w)^.choice,
      if(not(callexp('IsShallowTry',[])), (
        gauge_incr_counter(A) % retry counter
      ),(
        gauge_incr_counter(B) % try counter
      ))
    )),
    cpp_endif,
    assign("P" + fsize_sum([f_l,f_l])),
    goto_ins(neck).

fail =>
    jump_fail.

% TODO: PATCH_LIVEINFO requires f_g (we cannot expand to f_l,f_i in instruction format like in OC)

heapmargin_callq => shiftf, goto_ins(heapmargin_call).

heapmargin_call => decopsf([f_l,f_i],[A,B]), % TODO: abstract code to use f_g
    cachedreg('H',H),
    if(callexp('HeapCharDifference', [H, "Heap_End"]) < cast(intmach,A),
      ([[mode(M)]],
       setmode(r),
       cvoid_call('explicit_heap_overflow', [cast(intmach,A)*2, cast(ftype_ctype(f_i_signed),B)]),
       setmode(M)
       )),
    dispatch.

neck =>
    code_neck,
    dispatch.

:- ins_in_mode(dynamic_neck_proceed, w).
dynamic_neck_proceed => % (needs: w->misc->ins)
    unify_atom_internal(callexp('PointerToTerm',[(~w)^.misc^.ins]),x(3)),
    if(callexp('IsDeep',[]), goto_ins(proceed)),
    "B" <- (~w)^.choice,
    % (assume w->next_alt != NULL)
    if(callexp('IsShallowTry', []),(
        "def_clock" <- "use_clock"+1,
        if("def_clock"=="0xffff",(
            setmode(r),
            cvoid_call('clock_overflow', []),
            setmode(w)
        ))
    )),
    goto_ins(neck_proceed).

:- ins_in_mode(neck_proceed, w).
neck_proceed =>
    code_neck_proceed.

proceed =>
    (~w)^.local_top <- 0,
    call('SetE', [(~w)^.frame]),
    "P" <- (~w)^.next_insn,
    profile_hook(proceed),
    dispatch.

% TODO: this a new instruction really needed here? consider special builtin functions
restart_point =>
    setmode_setH(r, callexp('TaggedToPointer', [(~w)^.choice^.x[0]])),
    setmode(w),
    "P" <- cast(bcp, ("*",callexp('TaggedToPointer',[(~w)^.choice^.x[0]]))),
    (~w)^.next_insn <- (~w)^.choice^.next_insn,
    cvoid_call('pop_choicept', []),
    goto('enter_predicate').

% ---------------------------------------------------------------------------
%! # WAM execution tracing

:- pred(pred_trace/1, []).
pred_trace(Kind) =>
    call('PredTrace', [Kind, "Func"]).

:- pred(trace/1, []).
trace(X) => call('ON_DEBUG', [blk(trace_(X))]).

trace_print(Args) => call('fprintf', ["stderr"|Args]).

:- pred(trace_/1, []).
trace_(wam_loop_begin) =>
    if("debug_threads",
       trace_print([fmt:string("Worker state address is %p\n"), "desc"])).
trace_(wam_loop_exit) =>
    % trace_print([fmt:string("Goal %p returning!\n"), "desc"]),
    true.
trace_(create_choicepoint) =>
    if("debug_choicepoints",
       trace_print([fmt:string("WAM created choicepoint (r), node = %p\n"), (~w)^.choice])).
trace_(failing_choicepoint) =>
    if("debug_choicepoints",
       trace_print([fmt:string("Failing: node = %p, previous_choice = %p, conc. node = %p\n"), (~w)^.choice, (~w)^.previous_choice, "TopConcChpt"])),
    if(logical_and((~w)^.misc^.top_conc_chpt < (~w)^.choice,
                   (~w)^.misc^.top_conc_chpt < (~w)^.previous_choice), 
       trace_print([fmt:string("********** what happened here?\n")])).
trace_(deep_backtracking) =>
    if("debug_choicepoints",
       trace_print([fmt:string("deep backtracking, node = %p\n"), (~w)^.choice])).
trace_(restore_xregs_choicepoint(I)) =>
    if("debug_choicepoints",
       trace_print([fmt:string("Reloading %d words from node %p\n"), I, (~w)^.choice])).
trace_(worker_expansion_blt) =>
    trace_print([fmt:string("wam() detected worker expanded by C predicate\n")]).
trace_(worker_expansion_cterm) =>
    trace_print([fmt:string("Reallocation of wrb detected in wam()\n")]).
trace_(retry_instance_debug_1) =>
    % Extended check
    if("debug_concchoicepoints",
      if(logical_and(callexp('TaggedToRoot', [x("RootArg")])^.behavior_on_failure \== "CONC_CLOSED",
                     callexp('IS_BLOCKING', [x("InvocationAttr")])),
         trace_print([fmt:string("**wam(): failing on a concurrent closed pred, chpt=%p, failing chpt=%p .\n"),
                      (~w)^.choice,
                      "TopConcChpt"]))),
    if("debug_conc",
      if(logical_or(callexp('TaggedToRoot', [x("RootArg")])^.x2_pending_on_instance,
                    callexp('TaggedToRoot', [x("RootArg")])^.x5_pending_on_instance),
         trace_print([fmt:string("**wam(): failing with invokations pending from root, type = %d.\n"),
                      callexp('TaggedToRoot', [x("RootArg")])^.behavior_on_failure]))).
trace_(retry_instance_debug_2) =>
    if("debug_concchoicepoints",
       trace_print([fmt:string("New topmost concurrent chpt = %x\n"), "TopConcChpt"])).
trace_(retry_instance_debug_3) =>
    if(logical_and("debug_conc",
                   callexp('TaggedToRoot', [x("RootArg")])^.behavior_on_failure \== "DYNAMIC"),
       trace_print([(fmt:string("*** "), " PRIdm ", fmt:string("backtracking on a concurrent predicate.\n")),
                    cast(intmach,"Thread_Id"),
                    cast(intmach,"GET_INC_COUNTER")])),
    if(logical_and("debug_concchoicepoints",
                   callexp('TaggedToRoot', [x("RootArg")])^.behavior_on_failure \== "DYNAMIC"),
       trace_print([fmt:string("backtracking to chpt. = %p\n"), (~w)^.choice])).

% ---------------------------------------------------------------------------
%! # WAM profiling

:- pred(profile_hook/1, []).
profile_hook(cut) =>
    call0('PROFILE__HOOK_CUT').
profile_hook(proceed) =>
    call0('PROFILE__HOOK_PROCEED').
profile_hook(neck_proceed) =>
    call0('PROFILE__HOOK_NECK_PROCEED').
profile_hook(fail) =>
    call0('PROFILE__HOOK_FAIL').
profile_hook(redo) =>
    call0('PROFILE__HOOK_REDO').

% ---------------------------------------------------------------------------
%! # Gauge (profiling counters)

gauge_incr_counter(Counter) =>
    cpp_if_defined('GAUGE'),
    call('INCR_COUNTER', [Counter]),
    cpp_endif.

% ---------------------------------------------------------------------------
%! # Entries to generate other engine support files

% IDs for exported instructions (names visible from C code)
:- pred(all_ins_op/0, []).
all_ins_op =>
    autogen_warning_comment,
    %
    [[ all_insns(exported_ins, Insns) ]],
    '$foreach'(Insns, ins_op).

ins_op(exported_ins(Ins, Name)), [[ prop(Ins, optional(Flag)) ]] =>
    cpp_if_defined(Flag),
    ins_op_(Ins, Name),
    cpp_endif.
ins_op(exported_ins(Ins, Name)) =>
    ins_op_(Ins, Name).

ins_op_(Ins, Name) =>
    [[ uppercase(Name, NameUp) ]],
    [[ prop(Ins, ins_op(Opcode)) ]],
    cpp_define(NameUp, Opcode).

% TODO: refactor
% Engine info (for inclusion in Makefile)
:- pred(eng_info_mk/0, []).
eng_info_mk =>
    [[ findall(F, use_native(F, c), Cs) ]],
    [[ findall(F, use_native(F, h), Hs) ]],
    [[ findall(F, use_native(F, h_noalias), HsNoAlias) ]],
    [[ engine_stubmain(StubMain) ]],
    makefile_def('ENG_STUBMAIN', [StubMain]),
    makefile_def('ENG_CFILES', Cs),
    makefile_def('ENG_HFILES', Hs),
    makefile_def('ENG_HFILES_NOALIAS', HsNoAlias).

:- pred(makefile_def/2, []).
makefile_def(X, Fs) =>
    fmt:atom(X), " = ", 
    '$foreach_sep'(" ", Fs, fmt_atom),
    [fmt:nl].

% Engine info (for inclusion in sh scripts)
:- pred(eng_info_sh/0, []).
eng_info_sh =>
    [[ findall(F, use_native(F, c), Cs) ]],
    [[ findall(F, use_native(F, h), Hs) ]],
    [[ findall(F, use_native(F, h_noalias), HsNoAlias) ]],
    [[ engine_stubmain(StubMain) ]],
    sh_def('ENG_STUBMAIN', [StubMain]),
    sh_def('ENG_CFILES', Cs),
    sh_def('ENG_HFILES', Hs),
    sh_def('ENG_HFILES_NOALIAS', HsNoAlias).

:- pred(sh_def/2, []).
sh_def(X, Fs) =>
    fmt:atom(X), "=\"", 
    '$foreach_sep'(" ", Fs, fmt_atom),
    "\"",
    [fmt:nl].

:- pred(fmt_atom/1, []).
fmt_atom(X) => fmt:atom(X).     

% Meta-information
:- pred(absmachdef/0, []).
absmachdef =>
    autogen_warning_comment,
    %
    [[ max_op(MaxOp) ]],
    [[ NumOp is MaxOp + 1 ]],
    cpp_define('INS_OPCOUNT', NumOp),
    cpp_define('Fs(Ty)',"FTYPE_size(Ty)"), % (shorter name) % TODO: duplicated
    %
    "absmachdef_t abscurr = {", fmt:nl,
    [[ ftype_def(f_i, FId_i, _) ]],
    [[ ftype_def(f_o, FId_o, _) ]],
    ".ftype_id_i = ", FId_i, ",", fmt:nl,
    ".ftype_id_o = ", FId_o, ",", fmt:nl,
    ".ins_info = (ftype_base_t *[]){", fmt:nl,
    absmach_insinfo,
    "},", fmt:nl,
    ".ins_n = ", NumOp, ",", fmt:nl,
    ftype_info,
    ".q_pad1 = 128 * 4,", fmt:nl,
    ".q_pad2 = 1152 * 4,", fmt:nl,
    ".tagged_size = sizeof(tagged_t),", fmt:nl,
    ".size_align = sizeof(tagged_t)", fmt:nl,
    "}", stmtend,
    %
    insnames.

absmach_insinfo =>
    [[ max_op(MaxOp) ]],
    [[ range(0, MaxOp, Ops) ]],
    '$foreach_sep'(",\n", Ops, absmach_insinfo_).

absmach_insinfo_(Op) =>
    ( [[ op_ins(Op, Ins) ]] ->
        [[ prop(Ins, format(Format)) ]],
        ftype_info__str(Format)
    ; ftype_info__str([])
    ).

ftype_info =>
    [[ max_ftype(MaxFType) ]],
    [[ NumFType is MaxFType + 1 ]],
    [[ range(0, MaxFType, FTypes) ]],
    ".ftype_info = (ftype_base_t *[]){", fmt:nl,
    '$foreach_sep'(",\n", FTypes, ftype_info_),
    "},", fmt:nl,
    ".ftype_n = ", NumFType, ",", fmt:nl.

ftype_info_(Id), [[ id_ftype(Id, FType) ]] =>
    [[ ftype_def(FType, _, Def) ]],
    ftype_info__(Def, FType).
ftype_info_(_) => ftype_info__(str([]), none).

ftype_info__(array(A,B), _FType) =>
    [[ map_ftype_id([A,B], Ys) ]],
    callexp('FTYPE_ARRAY', Ys).
ftype_info__(str(Xs), _FType) => ftype_info__str(Xs).
ftype_info__(basic(SMethod,LMethod), FType) => callexp('FTYPE_BASIC', [fsize(FType),SMethod,LMethod]).
ftype_info__(blob, _) => callexp('FTYPE_BLOB', []).

ftype_info__str([]) => callexp('FTYPE_STR0', []).
ftype_info__str(Xs) =>
    [[ length(Xs, N) ]],
    [[ map_ftype_id(Xs, Ys) ]],
    callexp('FTYPE_STR', [N, callexp('BRACES', Ys)]).

:- pred(ftype_id/1, []).
ftype_id(FType) =>
    [[ ftype_def(FType, Id, _) ]],
    fmt:number(Id).

:- pred(insnames/0, []).
insnames =>
    [[ max_op(MaxOp) ]],
    [[ NumOp is MaxOp + 1 ]],
    "char *ins_name[", NumOp, "] = {", fmt:nl,
    [[ range(0, MaxOp, Ops) ]],
    '$foreach_sep'(",\n", Ops, op_insname),
    "}", stmtend.

:- pred(op_insname/1, []).
op_insname(Op) =>
    ( [[ op_ins(Op, Ins) ]] ->
        [[ prop(Ins, ins_op(Op)) ]],
        "\"", fmt:atom(Ins), "\""
    ; fmt:string("(none)")
    ).

:- pred(autogen_warning_comment/0, []).
autogen_warning_comment =>
    "/***************************************************************************/", fmt:nl,
    "/*                             WARNING!!!                                  */", fmt:nl,
    "/*                      D O   N O T   M O D I F Y                          */", fmt:nl,
    "/*                This file is autogenerated by emugen                     */", fmt:nl,
    "/***************************************************************************/", fmt:nl,
    fmt:nl.

% ---------------------------------------------------------------------------
%! # The WAM loop function

% KERNEL OF EMULATOR

% If the wam() local variables are changed, those on wam_private_t
% should be changed as well to reflect the current state! They should
% as well be saved and recovered in SAVE_WAM_STATE and
% RECOVER_WAM_STATE

/* --------------------------------------------------------------------------- */

:- pred(op_macros/0, []).
op_macros =>
    cpp_define('LoadH',"(H = w->heap_top)"),
    cpp_define('StoreH',"(w->heap_top = H)"),
    %
    cpp_define('BcOPCODE',"BcFetchOPCODE()"),
    % address for a bytecode operand
    cpp_define('BcP(Ty,X)',"(*(FTYPE_ctype(Ty) *)BCoff(P, (X)))"),
    cpp_define('Fs(Ty)',"FTYPE_size(Ty)"). % (shorter name)

:- pred(wam_loop_defs/0, []).
wam_loop_defs =>
    autogen_warning_comment,
    % TODO: move somewhere else
    vardecl(extern(instance_clock), "def_clock"),
    vardecl(extern(instance_clock), "use_clock"),
    %
    op_macros,
    wam__2_proto,
    wam_def,
    wam__2_def.

:- pred(wam_def/0, []).
wam_def =>
    "CVOID__PROTO(",
    "wam", ",",
    argdecl(ptr(goal_descriptor), "desc"),
    ")", " ",
    "{", fmt:nl,
    % We separate the catch block from wam__2 to make sure that
    % the implicit setjmp in EXCEPTION__CATCH do not affect
    % negatively to the optimizations in the main engine loop.
    vardecl(ptr(definition), "func", cast(ptr(definition), ~null)),
    goto('again'),
    label('again'),
    "EXCEPTION__CATCH({", fmt:nl, % try
    "CVOID__CALL(wam__2, desc, func)", stmtend,
    return,
    "}, {", fmt:nl, % catch
    vardecl(ptr(choice), "b"),
    vardecl(ptr(frame), "e"),
    code_neck, % Force neck if not done
    x(0) <- callexp('MakeSmall', ["ErrCode"]), % Error code
    x(1) <- callexp('GET_ATOM', ["ErrFuncName"]), % Builtin name
    x(2) <- callexp('MakeSmall', ["ErrFuncArity"]), % Builtin arity
    x(4) <- "Culprit", % Culprit arg.
    x(3) <- callexp('MakeSmall', ["ErrArgNo"]), % w. number
    "func" <- "address_error",
    goto('again'),
    "})", stmtend,
    "}", fmt:nl.

:- pred(wam__2_proto/0, []).
wam__2_proto =>
    "CVOID__PROTO(",
    "wam__2", ",",
    argdecl(ptr(goal_descriptor), "desc"), ",",
    argdecl(ptr(definition), "start_func"),
    ")", stmtend.

:- pred(wam__2_def/0, []).
wam__2_def =>
    "CVOID__PROTO(",
    "wam__2", ",",
    argdecl(ptr(goal_descriptor), "desc"), ",",
    argdecl(ptr(definition), "start_func"),
    ")", " ",
    "{", fmt:nl,
    wam_loop,
    "}", fmt:nl.

:- pred(wam_loop/0, []).
wam_loop =>
    wam_loop_decls,
    code_loop_begin,
    % MISCELLANEOUS SUPPORT
    %
    labeled_block('escape_to_p2', escape_to_p2),
    %
    labeled_block('escape_to_p', escape_to_p),
    %
    % ENTERING A PREDICATE:  H always live.
    % Take into account attributed variables !!
    labeled_block('enter_predicate', code_enter_pred),
    %
    labeled_block('switch_on_pred', switch_on_pred),
    %
    labeled_block('switch_on_pred_sub', code_switch_on_pred_sub),
    %
    % FAILING
    labeled_block('fail', code_fail),
    %
    alt_ins_dispatcher,
    %
    labeled_block('exit_toplevel', code_exit_toplevel),
    %
    labeled_block('illop', code_illop).

% Local variable declarations for the WAM loop
:- pred(wam_loop_decls/0, []).
wam_loop_decls =>
    vardecl(bcp, "p"),
    vardecl(ptr(try_node), "alts"),
    vardecl(ptr(choice), "b"), % TODO:[merge-oc] B
    vardecl(ptr(frame), "e"), % TODO:[merge-oc] E
    vardecl(ptr(tagged), "cached_r_h"), % TODO:[merge-oc] H
    vardecl(ptr(tagged), "r_s"), % TODO:[merge-oc] S
    %
    vardecl(intmach, "ei"), % (parameter of switch_on_pred, switch_on_pred_sub, call4)
    vardecl(bcp, "ptemp", ~null), % (parameter of escape_to_p, escape_to_p2)
    %
    "alts" <- ~null,
    "b" <- ~null,
    "e" <- ~null,
    "cached_r_h" <- ~null,
    "r_s" <- ~null,
    %
    "ei" <- "~0".

% Begin emulation in WAM loop
:- pred(code_loop_begin/0, []).
code_loop_begin =>
    [[update(mode(r))]],
    trace(wam_loop_begin),
    [[mode(M)]],
    if(not_null("start_func"), (
      % Directly execute a predicate (used to call from an exception 
      % throwed from C)
      "P" <- cast(bcp, "start_func"),
      "B" <- (~w)^.choice,
      % TODO: this should not be necessary, right?
      % call('GetFrameTop', [(~w)^.local_top,"B",(~g)^.frame]),
      setmode(w), % switch_on_pred expects we are in write mode, load H
      goto('switch_on_pred')
    )),
    [[update(mode(M))]],
    %
    if(logical_and(not_null("desc"), "desc"^.action /\ "BACKTRACKING"), (
      call0('RECOVER_WAM_STATE'),
      jump_fail % Probably...
    )),
    goto_ins(proceed).

:- pred(escape_to_p2/0, []).
escape_to_p2 => % (needs: ptemp)
    [[update(mode(w))]],
    "{",
    localv(tagged, T2),
    localv(tagged, T3),
    T2 <- call('PointerToTerm', ["Func"^.code.intinfo]),
    emul_to_goal(T3), % (stores: T3)
    "P" <- "ptemp",
    x(0) <- T3,
    x(1) <- T2,
    "}",
    goto('switch_on_pred').

:- pred(escape_to_p/0, []).
escape_to_p => % (needs: ptemp)
    [[update(mode(w))]],
    "{",
    localv(tagged, T3),
    emul_to_goal(T3), % (stores: T3)
    "P" <- "ptemp",
    x(0) <- T3,
    "}",
    goto('switch_on_pred').

:- pred(code_undo/1, []).
code_undo(T0) =>
    [[update(mode(r))]],
    (~w)^.frame <- "B"^.frame,
    (~w)^.next_insn <- "B"^.next_insn,
    call('SetE', [callexp('NodeLocalTop', ["B"])]),
    "E"^.frame <- (~w)^.frame,
    "E"^.next_insn <- (~w)^.next_insn,
    (~w)^.frame <- "E",
    (~w)^.next_insn <- "failcode",
    (~w)^.local_top <- cast(ptr(frame), callexp('Offset', ["E","EToY0"])),
    setmode(w),
    x(0) <- T0,
    do_builtin_call(syscall, T0).

:- pred(jump_fail/0, []).
jump_fail => goto('fail').
:- pred(code_fail/0, []).
code_fail =>
    altcont0.

% Restore state and jump to next alternative instructions
% TODO:[oc-merge] altcont/1
:- pred(altcont0/0, []).
altcont0 =>
    [[update(mode(r))]],
    % The profiling code must be here
    profile_hook(fail),
    % (w->choice->next_alt!=NULL);
    trace(failing_choicepoint),
    call('ResetWakeCount', []),
    "B" <- (~w)^.choice,
    %
    untrail.

% (continues at backtrack_ or undo_goal)
:- pred(untrail/0, []).
untrail =>
    call('ON_TABLING', [blk("MAKE_TRAIL_CACTUS_STACK;")]),
    %
    "{",
    localv(tagged, T0),
    localv(tagged, T1),
    localv(ptr(tagged), Pt2),
    Pt2 <- (~w)^.trail_top,
    T1 <- cast(tagged, callexp('TrailTopUnmark', ["B"^.trail_top])),
    if(callexp('TrailYounger',[Pt2,T1]),
      (do_while(
        ([[mode(M)]],
         call('PlainUntrail', [Pt2, T0, blk((
           (~w)^.trail_top <- Pt2,
           code_undo(T0)
         ))]),
         [[update(mode(M))]]),
        (callexp('TrailYounger', [Pt2,T1]))),
      (~w)^.trail_top <- Pt2)),
    "}",
    %
    backtrack_.

:- pred(backtrack_, []).
backtrack_ =>
    (~w)^.heap_top <- callexp('NodeGlobalTop', ["B"]),
    code_restore_args,
    profile_hook(redo),
    "P" <- cast(bcp, (~w)^.next_alt),
    "{",
    localv(ptr(try_node), Alt),
    Alt <- cast(ptr(try_node), "P")^.next,
    [[mode(M)]],
    if(is_null(Alt), ( % TODO: This one is not a deep check! (see line above)
      % TODO:[oc-merge] 'altmode.jump_fail_cont'(_,no_alt)
      [[update(mode(M))]],
      jump_fail_cont(no_alt, Alt)
    ), (
      [[update(mode(M))]],
      jump_fail_cont(next_alt, Alt)
    )), % TODO:[oc-merge] choice_patch also modified w->choice->next_alt in OPTIM_COMP
    "}",
    '$unreachable'.

:- pred(jump_fail_cont/2, []).
jump_fail_cont(no_alt, _Alt) =>
    call('SetDeep', []),
    "B" <- (~w)^.previous_choice,
    call('SetChoice', ["B"]),
    call('ON_TABLING', [blk((
        % To avoid sharing wrong trail - it might be associated to the
        % previous frozen choice point
        if(callexp('FrozenChpt', ["B"]),
           call('push_choicept', [(~w),"address_nd_fake_choicept"]))
    ))]),
    jump_alt_code("P").
jump_fail_cont(next_alt, Alt) =>
    % TODO:[oc-merge] 'altmode.jump_fail_cont'(_,next_alt)
    call('CODE_CHOICE_PATCH', [(~w)^.choice, Alt]),
    jump_alt_code("P").

:- pred(jump_alt_code/1, []).
jump_alt_code(Alt) =>
    "P" <- cast(ptr(try_node), Alt)^.emul_p,
    if(not(callexp('IsVar',[x(0)])), jump_ins_dispatch),
    setmode(w),
    jump_ins_dispatch.

:- pred(code_restore_args/0, []).
code_restore_args =>
    if(callexp('IsDeep',[]), deep_backtrack).

% TODO:[oc-merge] part of code_restore_args0
:- pred(deep_backtrack/0, []).
deep_backtrack =>
    % deep backtracking
    trace(deep_backtracking),
    (~w)^.frame <- "B"^.frame,
    (~w)^.next_insn <- "B"^.next_insn,
    (~w)^.next_alt <- "B"^.next_alt,
    (~w)^.local_top <- callexp('NodeLocalTop', ["B"]),
    "{",
    % TODO: use this syntax? I::intmach <- B^.next_alt^.arity,
    localv(intmach, I, "B"^.next_alt^.arity),
    (~w)^.previous_choice <- callexp('ChoiceCont0', ["B",I]),
    % TODO:[oc-merge] set_shallow_retry here?
    call('SetShallowRetry', []),
    foreach(intmach, range(I), K, ((~w)^.x[K] <- "B"^.x[K])),
    "}".

:- pred(code_enter_pred/0, []).
code_enter_pred =>
    [[update(mode(w))]],
    call('ON_ANDPARALLEL', [blk((
      if("Suspend" == "TOSUSPEND", (
          "Suspend" <- "SUSPENDED",
          call('Wait_Acquire_lock', ["Waiting_For_Work_Lock"]),
          call('Cond_Var_Wait', ["Waiting_For_Work_Cond_Var","Waiting_For_Work_Lock"]),
          "Suspend" <- "RELEASED",
          call('Release_lock', ["Waiting_For_Work_Lock"])))
    % if (Cancel_Goal_Exec && Safe_To_Cancel) {
    %   Cancel_Goal_Exec = FALSE;
    %   Safe_To_Cancel = FALSE;
    %   SetChoice(w->choice);
    %   goto fail;
    % }
    % 
    % if (Cancel_Goal_Exec_Handler != NULL && Safe_To_Cancel) {
    %   Cancel_Goal_Exec_Handler = NULL;
    %   Safe_To_Cancel = FALSE;
    %   // Metacut
    %   w->choice = Current_Init_ChP;
    %   w->trail_top = Current_Trail_Top;
    %   SetChoice(w->choice);
    %   goto fail;
    % }
    ))]),
    % #if defined(PARBACK)
    %   if (Suspend == CHECK_SUSP) {
    %     //Save argument registers
    %     tagged_t *Htmp = H = w->heap_top;
    %     if (HeapCharDifference(w->heap_top,Heap_End) < CONTPAD + (1 + Func->arity)*sizeof(tagged_t))
    %       explicit_heap_overflow(w, (CONTPAD + (1 + Func->arity)*sizeof(tagged_t))*2, 0);
    %     HeapPush(H,(tagged_t)P);
    %     int i;
    %     for (i = 0; i < Func->arity; i++) HeapPush(H,X(i));
    %     w->heap_top = H;
    %     push_choicept(Arg,address_nd_suspension_point);
    %     w->choice->x[0] = Tagp(HVA, Htmp);
    %     //w->choice->next_insn = w->misc->backInsn;
    % 
    %     //No nore suspensions
    %     Suspend = RELEASED;
    %     //Jump to continuation of the current goal
    %     w->next_insn = w->misc->contFrame->next_insn;
    %     w->frame = w->misc->contFrame->frame;
    %     P = w->next_insn;
    %     //SetE(w->frame);
    %     //Execute next_insn
    %     DISPATCH_R(0);
    %   }
    % #endif
    if(callexp('TestEventOrHeapWarnOverflow', ["H"]), (
      vardecl(int, "wake_count"),
      %
      if(cbool_succeed('Stop_This_Goal',[]), goto('exit_toplevel')),
      %
      "wake_count" <- callexp('WakeCount', []),
      %
      if(callexp('HeapCharAvailable', ["H"]) =< "CALLPAD"+4*"wake_count"*sizeof(tagged), % TODO: It was OffHeaptop(H+4*wake_count,Heap_Warn), equivalent to '<='; but '<' should work?! (also in TestEventOrHeapWarnOverflow?)
        (call('SETUP_PENDING_CALL', ["E", "address_true"]),
         setmode(r),
         cvoid_call('heap_overflow', [2*("CALLPAD"+4*"wake_count"*sizeof(tagged))]),
         setmode(w))),
      if("wake_count" > 0,
        if("wake_count"==1, (
          call('SETUP_PENDING_CALL', ["E", "address_uvc"]),
          cvoid_call('collect_one_pending_unification', []), % does not touch H
          localv(tagged, T0),
          call('DEREF', [T0,x(1)]),
          if(callexp('TaggedIsCVA', [T0]),
            (% X(1)=*TaggedToGoal(t0);
             x(1) <- T0,
             % patch prev. SETUP_PENDING_CALL
             call('Setfunc', ["address_ucc"])))),
          % wake_count > 1
          ([[update(mode(w))]],
           call('SETUP_PENDING_CALL', ["E", "address_pending_unifications"]),
           setmode(r),
           cvoid_call('collect_pending_unifications', ["wake_count"]),
           setmode(w)))),
      if(callexp('OffStacktop', [(~w)^.frame,"Stack_Warn"]), (
         call('SETUP_PENDING_CALL', ["E", "address_true"]),
         cvoid_call('stack_overflow', []))),
      call('UnsetEvent', []),
      if(callexp('TestCIntEvent', []), (
         call('SETUP_PENDING_CALL', ["E", "address_help"]),
         cvoid_call('control_c_normal', []))))),
    goto('switch_on_pred').

:- pred(switch_on_pred/0, []).
switch_on_pred =>
    jump_switch_on_pred_sub("Func"^.enter_instr).

:- pred(pred_enter_undefined/0, []).
pred_enter_undefined =>
    [[update(mode(w))]],
    pred_trace(fmt:string("U")),
    "ptemp" <- cast(bcp,"address_undefined_goal"), % (arity 1)
    goto('escape_to_p').

:- pred(pred_enter_interpreted/0, []).
pred_enter_interpreted =>
    [[update(mode(w))]],
    % pred_trace(fmt:string("I")),
    "ptemp" <- cast(bcp,"address_interpret_c_goal"), % (arity 2)
    goto('escape_to_p2').

:- pred(pred_enter_c/0, []).
pred_enter_c =>
    [[update(mode(w))]],
    pred_trace(fmt:string("C")),
    setmode(r),
    % Changed by DCG to handle errors in Prolog
    "{",
    localv(intmach, I, call_fC(cbool0,"Func"^.code.proc,[])),
    if(not_null("Expanded_Worker"),
      (trace(worker_expansion_blt),
      if(is_null("desc"),
        (% JFKK this is temp sometimes wam is called without gd
         trace_print([fmt:string("bug: invalid WAM expansion\n")]),
         call('abort', []))),
      "Arg" <- "Expanded_Worker",
      "desc"^.worker_registers <- "Arg",
      "Expanded_Worker" <- ~null)),
    if(I,goto_ins(proceed),jump_fail),
    "}".

:- pred(pred_enter_builtin_true/0, []).
pred_enter_builtin_true =>
    [[update(mode(w))]],
    pred_trace(fmt:string("B")),
    goto_ins(proceed).

:- pred(pred_enter_builtin_fail/0, []).
pred_enter_builtin_fail =>
    [[update(mode(w))]],
    pred_trace(fmt:string("B")),
    jump_fail.

:- pred(pred_enter_builtin_current_instance/0, []).
pred_enter_builtin_current_instance =>
    [[update(mode(w))]],
    pred_trace(fmt:string("B")),
    setmode(r),
    (~w)^.misc^.ins <- callexp('CFUN__EVAL', ["current_instance0"]),
    if(is_null((~w)^.misc^.ins), jump_fail),
    "P" <- cast(bcp, (~w)^.misc^.ins^.emulcode),
    jump_ins_dispatch.

:- pred(pred_enter_builtin_compile_term/0, []).
pred_enter_builtin_compile_term =>
    [[update(mode(w))]],
    pred_trace(fmt:string("B")),
    setmode(r),
    "{",
    localv(ptr(worker), NewWorker), % Temp - for changes in regbanksize
    if(not(cbool_succeed('compile_term', [addr(NewWorker)])),jump_fail),
    if(not_null(NewWorker), % TODO: use Expanded_Worker?
      (if(is_null("desc"),
        (% JFKK this is temp sometimes wam is called without gd
         trace_print([fmt:string("bug: invalid WAM expansion\n")]),
         call('abort', []))),
      "Arg" <- NewWorker,
      "desc"^.worker_registers <- "Arg",
      trace(worker_expansion_cterm))),
    "}",
    goto_ins(proceed).

:- pred(pred_enter_builtin_instance/0, []).
pred_enter_builtin_instance =>
    [[update(mode(w))]],
    % ASSERT: X(2) is a dereferenced integer
    pred_trace(fmt:string("B")),
    load(hva, x(3)),
    (~w)^.misc^.ins <- callexp('TaggedToInstance', [x(2)]),
    "P" <- cast(bcp, (~w)^.misc^.ins^.emulcode),
    jump_ins_dispatch.

:- pred(pred_enter_builtin_geler/0, []).
pred_enter_builtin_geler =>
    [[update(mode(w))]],
    pred_trace(fmt:string("B")),
    "{",
    localv(tagged, T1, x(0)),
    deref_sw0(T1,";"),
    localv(tagged, T3),
    T3 <- x(1),
    deref_sw0(T3,";"),
    call('Setfunc', [callexp('find_definition', ["predicates_location",T3,addr((~w)^.structure),~true])]),
    % suspend the goal  t3  on  t1.  Func, must be live.
    [[mode(M)]],
    setmode(r),
    call('CVOID__CALL', ["SUSPEND_T3_ON_T1", "Func", T3, T1]),
    setmode(M),
    "}",
    goto_ins(proceed).

% Like pred_enter_builtin_syscall/0, but fails on undefined
:- pred(pred_enter_builtin_nodebugcall/0, []).
pred_enter_builtin_nodebugcall =>
    [[update(mode(w))]],
    pred_trace(fmt:string("B")),
    "{",
    localv(tagged, T0, x(0)),
    deref_sw(T0,x(0),";"),
    do_builtin_call(nodebugcall, T0),
    "}".

% Like pred_enter_builtin_call/0, but ignores Current_Debugger_Mode
:- pred(pred_enter_builtin_syscall/0, []).
pred_enter_builtin_syscall =>
    [[update(mode(w))]],
    pred_trace(fmt:string("B")),
    "{",
    localv(tagged, T0, x(0)), 
    deref_sw(T0,x(0),";"),
    do_builtin_call(syscall, T0),
    "}".

:- pred(pred_enter_builtin_call/0, []).
pred_enter_builtin_call =>
    [[update(mode(w))]],
    pred_trace(fmt:string("B")),
    "{",
    localv(tagged, T0, x(0)),
    deref_sw(T0,x(0),";"),
    do_builtin_call(call, T0),
    "}".

:- pred(do_builtin_call/2, []).
do_builtin_call(CallMode, T0) =>
    call('Setfunc', [callexp('find_definition', ["predicates_location",T0,addr((~w)^.structure),~false])]),
    % Undefined?
    ( [[ CallMode = nodebugcall ]] ->
        if(is_null("Func"),jump_fail)
    ; ( [[ CallMode = syscall ]] -> true
      ; [[ CallMode = call ]] -> true
      ; [[ fail ]]
      ),
      if(is_null("Func"),
        (call('Setfunc', ["address_undefined_goal"]),
         goto('switch_on_pred')))
    ),
    % Debug hook?
    ( [[ CallMode = nodebugcall ]] -> true
    ; [[ CallMode = syscall ]] -> true
    ; [[ CallMode = call ]],
      if("Current_Debugger_Mode" \== "atom_off",
        (call('Setfunc', ["address_trace"]),
         goto('switch_on_pred')))
    ),
    %
    jump_call4("Func"^.enter_instr).

:- pred(jump_call4/1, []).
jump_call4(Enter) => "ei" <- Enter, goto('call4').
:- pred(code_call4/0, []).
code_call4 =>
    switch("ei", (
        case('ENTER_INTERPRETED'), pred_call_interpreted,
        case('BUILTIN_DIF'), pred_call_builtin_dif,
        case('SPYPOINT'), pred_call_spypoint,
        case('WAITPOINT'), label('call_waitpoint'), pred_call_waitpoint,
        labeled_block('call5', code_call5), % TODO: move outside switch?
        label('default'), pred_call_default
    )).

:- pred(pred_call_interpreted/0, []).
pred_call_interpreted =>
    [[update(mode(w))]],
    % pred_trace(fmt:string("I")),
    x(1) <- call('PointerToTerm', ["Func"^.code.intinfo]),
    call('Setfunc', ["address_interpret_goal"]),
    goto('switch_on_pred').

:- pred(pred_call_builtin_dif/0, []).
pred_call_builtin_dif =>
    [[update(mode(w))]],
    pred_trace(fmt:string("B")),
    "{",
    localv(ptr(tagged), Pt1, (~w)^.structure),
    localv(tagged, T0), call('RefHeapNext', [T0,Pt1]), x(0) <- T0,
    localv(tagged, T1), call('RefHeapNext', [T1,Pt1]), x(1) <- T1,
    "}",
    %goto('dif1').
    goto('dif0').

:- pred(pred_call_spypoint/0, []).
pred_call_spypoint =>
    [[update(mode(w))]],
    if(not("Func"^.properties.wait), jump_call5),
    goto('call_waitpoint').

:- pred(pred_call_waitpoint/0, []).
pred_call_waitpoint =>
    [[update(mode(w))]],
    "{",
    localv(tagged, T0),
    localv(tagged, T1),
    call('RefHeap', [T0,(~w)^.structure]),
    deref_sw(T0,T1, (
       localv(tagged, T3),
       T3 <- x(0),
       % suspend the goal  t3  on  t1.  Func, must be live.
       [[mode(M)]],
       setmode(r),
       call('CVOID__CALL', ["SUSPEND_T3_ON_T1", "Func", T3, T1]),
       setmode(M),
       goto_ins(proceed)
    )),
    "}",
    jump_call5.

:- pred(jump_call5/0, []).
jump_call5 => goto('call5').
:- pred(code_call5/0, []).
code_call5 => jump_call4("Func"^.predtyp).

:- pred(pred_call_default/0, []).
pred_call_default =>
    [[update(mode(w))]],
    "{",
    localv(intmach, I, "Func"^.arity),
    if(I\==0,
       (
       localv(ptr(tagged), Pt1, (~w)^.x),
       localv(ptr(tagged), Pt2, (~w)^.structure),
       do_while(
         call('PushRefHeapNext', [Pt1,Pt2]),
         ("--",I))
      )),
    "}",
    jump_switch_on_pred_sub("ei").

% NOTE: see prolog_dif
:- pred(pred_enter_builtin_dif/0, []).
pred_enter_builtin_dif =>
    [[update(mode(w))]],
    pred_trace(fmt:string("B")),
    "{",
    localv(tagged, T0, x(0)), deref_sw0(T0,";"),
    localv(tagged, T1, x(1)), deref_sw0(T1,";"),
    (~w)^.structure <- ~null,
    %goto('dif1'),
    % check fast cases first
    %label('dif1'),
    %[[update(mode(w))]],
    if(T0==T1,
      jump_fail,
      if(logical_and(not(callexp('IsVar',[T0/\T1])),
                     logical_or(callexp('IsAtomic',[T0]),
                                callexp('IsAtomic',[T1]))),
        goto_ins(proceed),
        (x(0) <- T0,
         x(1) <- T1,
         setmode(r),
         goto('dif2')))),
    "}",
    label('dif2'),
    [[update(mode(r))]],
    if(not(cbool_succeed('prolog_dif', ["Func"])), jump_fail),
    goto_ins(proceed).

:- pred(pred_enter_builtin_abort/0, []).
pred_enter_builtin_abort =>
    [[update(mode(w))]],
    % cut all the way and fail, leaving wam with a return code
    pred_trace(fmt:string("B")),
    "{",
    localv(tagged, T0, x(0)), deref_sw0(T0,";"),
    (~w)^.misc^.exit_code <- callexp('GetSmall', [T0]),
    "}",
    (~w)^.previous_choice <- "InitialChoice",
    do_cut,
    jump_fail.

:- pred(pred_enter_spypoint/0, []).
pred_enter_spypoint =>
    [[update(mode(w))]],
    if("Current_Debugger_Mode" \== "atom_off",
      ("ptemp" <- cast(bcp,"address_trace"), % (arity 1)
       goto('escape_to_p'))),
    if(not("Func"^.properties.wait), goto('nowait')),
    goto('waitpoint').

:- pred(pred_enter_waitpoint/0, []).
pred_enter_waitpoint =>
    [[update(mode(w))]],
    "{",
    localv(tagged, T1, x(0)),
    deref_sw(T1,x(0),(
      localv(tagged, T3),
      emul_to_goal(T3), % (stores: t3)
      T1 <- x(0),
      if(callexp('TaggedIsSVA', [T1]), % t1 may have been globalised
        call('RefSVA', [T1,x(0)])),
      % suspend the goal  t3  on  t1.  Func, must be live.
      [[mode(M)]],
      setmode(r),
      call('CVOID__CALL', ["SUSPEND_T3_ON_T1", "Func", T3, T1]),
      setmode(M),
      goto_ins(proceed)
    )),
    "}",
    goto('nowait'),
    label('nowait'),
    jump_switch_on_pred_sub("Func"^.predtyp).

:- pred(pred_enter_breakpoint/0, []).
pred_enter_breakpoint =>
    [[update(mode(w))]],
    jump_switch_on_pred_sub("Func"^.predtyp).

:- pred(pred_enter_compactcode_indexed/0, []).
pred_enter_compactcode_indexed =>
    [[update(mode(w))]],
    pred_trace(fmt:string("E")),
    "{",
    localv(tagged, T0, x(0)),
    deref_sw(T0,x(0), jump_tryeach("Func"^.code.incoreinfo^.varcase)),
    localv(tagged, T1),
    setmode(r),
    % non variable
    if(T0 /\ "TagBitComplex",
      if(T0 /\ "TagBitFunctor", (
          "S" <- callexp('TaggedToArg', [T0,0]),
          T1 <- callexp('HeapNext', ["S"])
      ), (
          "S" <- callexp('TagpPtr', ["LST",T0]),
          jump_tryeach("Func"^.code.incoreinfo^.lstcase)
      )),
      T1 <- T0),
    %
    localv(intmach, I),
    vardecl(ptr(sw_on_key), "Htab", "Func"^.code.incoreinfo^.othercase),
    %
    I <- 0,
    localv(tagged, T2),
    T2 <- T1,
    assign(T1 /\ "Htab"^.mask),
    vardecl(ptr(sw_on_key_node), "HtabNode"),
    do_while((
        "HtabNode" <- callexp('SW_ON_KEY_NODE_FROM_OFFSET', ["Htab", T1]),
        if(logical_or("HtabNode"^.key==T2, not("HtabNode"^.key)), break),
        assign(I + sizeof(sw_on_key_node)),
        T1 <- (T1+I) /\ "Htab"^.mask
    ), ~true),
    jump_tryeach("HtabNode"^.value.try_chain), % (this will break the loop)
    "}".

:- pred(pred_enter_compactcode/0, []).
pred_enter_compactcode =>
    [[update(mode(w))]],
    pred_trace(fmt:string("E")),
    [[update(mode(w))]],
    jump_tryeach("Func"^.code.incoreinfo^.varcase).

:- pred(jump_switch_on_pred_sub/1, []).
jump_switch_on_pred_sub(Enter), [[ Enter = "ei" ]] => goto('switch_on_pred_sub').
jump_switch_on_pred_sub(Enter) =>
   "ei" <- Enter,
   goto('switch_on_pred_sub').
:- pred(code_switch_on_pred_sub/0, []).
code_switch_on_pred_sub => % (needs: ei)
    switch("ei", (
        case('ENTER_FASTCODE_INDEXED'), goto('enter_undefined'),
        case('ENTER_FASTCODE'), goto('enter_undefined'),
        case('ENTER_UNDEFINED'), label('enter_undefined'), pred_enter_undefined,
        case('ENTER_INTERPRETED'), pred_enter_interpreted,
        case('ENTER_C'), pred_enter_c,
        case('BUILTIN_TRUE'), pred_enter_builtin_true,
        case('BUILTIN_FAIL'), pred_enter_builtin_fail,
        case('BUILTIN_CURRENT_INSTANCE'), pred_enter_builtin_current_instance,
        case('BUILTIN_COMPILE_TERM'), pred_enter_builtin_compile_term,
        case('BUILTIN_INSTANCE'), pred_enter_builtin_instance,
        case('BUILTIN_GELER'), pred_enter_builtin_geler,
        case('BUILTIN_NODEBUGCALL'), pred_enter_builtin_nodebugcall,
        case('BUILTIN_SYSCALL'), pred_enter_builtin_syscall,
        labeled_block('call4', code_call4), % TODO: move outside switch?
        case('BUILTIN_CALL'), pred_enter_builtin_call,
        case('BUILTIN_DIF'), label('dif0'), pred_enter_builtin_dif,
        case('BUILTIN_ABORT'), pred_enter_builtin_abort,
        case('SPYPOINT'), pred_enter_spypoint,
        case('WAITPOINT'), label('waitpoint'), pred_enter_waitpoint,
        case('BREAKPOINT'), pred_enter_breakpoint,
        case('ENTER_PROFILEDCODE_INDEXED'), goto('enter_compactcode_indexed'),
        case('ENTER_COMPACTCODE_INDEXED'), label('enter_compactcode_indexed'), pred_enter_compactcode_indexed,
        case('ENTER_PROFILEDCODE'), goto('enter_compactcode'),
        case('ENTER_COMPACTCODE'), label('enter_compactcode'), pred_enter_compactcode
    )).

:- pred(code_exit_toplevel/0, []).
code_exit_toplevel =>
    (~w)^.insn <- "P",
    % What should we save here? MCL
    % w->choice = B;
    % w->frame = E->frame;
    if(logical_and(not_null("desc"), "desc"^.action /\ "KEEP_STACKS"),
       % We may backtrack
       call0('SAVE_WAM_STATE')),
    % We may have been signaled and jumped here from enter_predicate:
    if(cbool_succeed('Stop_This_Goal', []),
       (~w)^.misc^.exit_code <- "WAM_INTERRUPTED"),
    trace(wam_loop_exit),
    return.

:- pred(code_illop/0, []).
code_illop =>
    call('SERIOUS_FAULT', [fmt:string("unimplemented WAM instruction")]).

% Alternative and instruction dispatcher
:- pred(alt_ins_dispatcher/0, []).
alt_ins_dispatcher =>
    alt_ins_dispatcher(r),
    alt_ins_dispatcher(w).

% Alternative and instruction dispatcher (read or write mode)
:- pred(alt_ins_dispatcher/1, []).
alt_ins_dispatcher(Mode) =>
    [[ update(mode(Mode)) ]],
    alt_dispatcher,
    ins_dispatcher.

:- pred(emul_p/2, []).
% emul_p(Alts, EmulP), [[ mode(r) ]] => [[ EmulP = (Alts^.emul_p) ]]. % TODO:[merge-oc] no p2 optimization, disable X0 optimization? (it runs slower)
emul_p(Alts, EmulP), [[ mode(r) ]] => [[ EmulP = (Alts^.emul_p2) ]]. % TODO:[merge-oc] no p2 optimization, disable X0 optimization? (it runs slower)
emul_p(Alts, EmulP), [[ mode(w) ]] => [[ EmulP = (Alts^.emul_p) ]].

:- pred(jump_tryeach/1, []).
jump_tryeach(Alts) =>
    "alts" <- Alts,
    tryeach_lab(Lab),
    goto(Lab).

:- pred(tryeach_lab/1, []).
tryeach_lab(Lab), [[ mode(r) ]] => [[ Lab = 'tryeach_r' ]].
tryeach_lab(Lab), [[ mode(w) ]] => [[ Lab = 'tryeach_w' ]].

:- pred(alt_dispatcher/0, []).
alt_dispatcher => % (needs: alts)
    tryeach_lab(TryEach),
    label(TryEach),
    [[ Alts = "alts" ]],
    %
    gauge_incr_counter_alts(Alts),
    %
    emul_p(Alts, EmulP),
    "P" <- EmulP,
    % TODO:[merge-oc] try_alt/1
    (~w)^.previous_choice <- (~w)^.choice,
    "{",
    localv(ptr(try_node), Alt, (Alts^.next)),
    if(not_null(Alt), ( % TODO: This one is not a deep check! (see line above)
      "B" <- (~w)^.choice,
      call('GetFrameTop', [(~w)^.local_top,"B",(~g)^.frame]),
      cachedreg('H',H),
      call('CODE_CHOICE_NEW0', ["B", Alt, H]),
      trace(create_choicepoint),
      % segfault patch -- jf
      maybe_choice_overflow
    ),(
      call('SetDeep', [])
    )),
    "}",
    jump_ins_dispatch.

gauge_incr_counter_alts(Alts) => % Counter in Alts
    ( [[ mode(r) ]] -> [[ EntryCounter = (Alts^.entry_counter + 1) ]] % TODO: do not use pointer arith
    ; [[ mode(w) ]], [[ EntryCounter = (Alts^.entry_counter) ]]
    ),
    gauge_incr_counter(EntryCounter).

:- pred(jump_ins_dispatch/0, []).
jump_ins_dispatch =>
    ins_dispatch_label(DispatchLabel),
    goto(DispatchLabel).

:- pred(ins_dispatch_label/1, []).
% TODO: define special meta-predicates? (Label is a output meta-argument)
:- pred(ins_dispatch_label(Label), [rs_mark('ins_dispatch_label/1')]).
ins_dispatch_label(Label), [[ mode(r) ]] => [[ Label = 'ReadMode' ]]. /* Here with H in memory. */
ins_dispatch_label(Label), [[ mode(w) ]] => [[ Label = 'WriteMode' ]]. /* Here with H in register. */

:- pred(ins_dispatcher/0, []).
ins_dispatcher =>
    ins_dispatch_label(Label),
    label(Label),
    [[ all_insns(entry, Insns) ]],
    switch("BcOPCODE",
      (% (all instructions)
      '$foreach'(Insns, inswrap),
      label('default'),
      goto('illop'))).

% Wrapper for instructions
inswrap(entry(I,Format)), [[ prop(I, optional(Flag)) ]] =>
    % Emit optional instructions (based on C preprocessor flags)
    cpp_if_defined(Flag),
    inswrap_(I,Format),
    cpp_endif.
inswrap(entry(I,Format)) => inswrap_(I,Format).

inswrap_(I,Format) =>
    [[ update(format(Format)) ]],
    ins_label(I),
    ins_case(I),
    [[ mode(M) ]],
    inswrap__(I),
    [[ update(mode(M)) ]].

inswrap__(I), [[ prop(I, in_mode(M)) ]] => in_mode(M, I).
inswrap__(I) => I.

% 'case' statement for the instruction
ins_case(Ins) =>
    [[ prop(Ins, ins_op(Opcode)) ]],
    % [[ uppercase(Ins, InsUp) ]], % (do not use name, just opcode)
    case(Opcode).

% 'label' statement for the instruction
ins_label(Ins), [[ mode(M),
                   prop(Ins, label(M)),
                   get_ins_label(Ins, M, Label) ]] =>
   label(Label).
ins_label(_) => true.

%! # Instruction set switch
% NOTE: declaration order is important (for performance)

ins_entry(Ins,Opcode,Format) =>
    decl(ins_op_format(Ins,Opcode,Format,[])),
    entry(Ins,Format).

ins_entry(Ins,Opcode,Format,Props) =>
    decl(ins_op_format(Ins,Opcode,Format,Props)),
    entry(Ins,Format).

% :- ins_op_format(ci_call, 241, [f_i,f_i])),
% :- ins_op_format(ci_inarg, 242, [f_i,f_i])),
% :- ins_op_format(ci_outarg, 243, [f_i,f_i])),
% :- ins_op_format(ci_retval, 244, [f_i,f_i])),

:- iset(instruction_set/0).
instruction_set =>
    iset_init,
    iset_call,
    iset_put,
    iset_get1,
    iset_cut,
    iset_choice,
    iset_misc1,
    iset_get2,
    ins_entry(branch, 68, [f_i]),
    iset_blt,
    ins_entry(get_constraint, 247, [f_x], [label(w)]),
    iset_unify,
    iset_u2,
    iset_misc2,
    exported_insns.

iset_init =>
    ins_entry(inittrue, 260, [f_e], [label(w)]),
    ins_entry(firsttrue_n, 261, [f_Y,f_e], [label(w)]),
    ins_entry(initcallq, 0, [f_Q,f_E,f_e]),
    ins_entry(initcall, 1, [f_E,f_e], [label(_)]).

iset_call =>
    ins_entry(firstcall_nq, 20, [f_Q,f_Y,f_E,f_e]),
    ins_entry(firstcall_n, 21, [f_Y,f_E,f_e], [label(_)]),
    ins_entry(firstcall_8q, 18, [f_Q,f_y,f_y,f_y,f_y,f_y,f_y,f_y,f_y,f_E,f_e]),
    ins_entry(firstcall_8, 19, [f_y,f_y,f_y,f_y,f_y,f_y,f_y,f_y,f_E,f_e], [label(_)]),
    ins_entry(firstcall_7q, 16, [f_Q,f_y,f_y,f_y,f_y,f_y,f_y,f_y,f_E,f_e]),
    ins_entry(firstcall_7, 17, [f_y,f_y,f_y,f_y,f_y,f_y,f_y,f_E,f_e], [label(_)]),
    ins_entry(firstcall_6q, 14, [f_Q,f_y,f_y,f_y,f_y,f_y,f_y,f_E,f_e]),
    ins_entry(firstcall_6, 15, [f_y,f_y,f_y,f_y,f_y,f_y,f_E,f_e], [label(_)]),
    ins_entry(firstcall_5q, 12, [f_Q,f_y,f_y,f_y,f_y,f_y,f_E,f_e]),
    ins_entry(firstcall_5, 13, [f_y,f_y,f_y,f_y,f_y,f_E,f_e], [label(_)]),
    ins_entry(firstcall_4q, 10, [f_Q,f_y,f_y,f_y,f_y,f_E,f_e]),
    ins_entry(firstcall_4, 11, [f_y,f_y,f_y,f_y,f_E,f_e], [label(_)]),
    ins_entry(firstcall_3q, 8, [f_Q,f_y,f_y,f_y,f_E,f_e]),
    ins_entry(firstcall_3, 9, [f_y,f_y,f_y,f_E,f_e], [label(_)]),
    ins_entry(firstcall_2q, 6, [f_Q,f_y,f_y,f_E,f_e]),
    ins_entry(firstcall_2, 7, [f_y,f_y,f_E,f_e], [label(_)]),
    ins_entry(firstcall_1q, 4, [f_Q,f_y,f_E,f_e]),
    ins_entry(firstcall_1, 5, [f_y,f_E,f_e], [label(_)]),
    ins_entry(firstcallq, 2, [f_Q,f_E,f_e]),
    ins_entry(firstcall, 3, [f_E,f_e], [label(_)]),
    %
    ins_entry(call_nq, 40, [f_Q,f_Z,f_E,f_e]),
    ins_entry(call_n, 41, [f_Z,f_E,f_e], [label(_)]),
    ins_entry(call_8q, 38, [f_Q,f_z,f_z,f_z,f_z,f_z,f_z,f_z,f_z,f_E,f_e]),
    ins_entry(call_8, 39, [f_z,f_z,f_z,f_z,f_z,f_z,f_z,f_z,f_E,f_e], [label(_)]),
    ins_entry(call_7q, 36, [f_Q,f_z,f_z,f_z,f_z,f_z,f_z,f_z,f_E,f_e]),
    ins_entry(call_7, 37, [f_z,f_z,f_z,f_z,f_z,f_z,f_z,f_E,f_e], [label(_)]),
    ins_entry(call_6q, 34, [f_Q,f_z,f_z,f_z,f_z,f_z,f_z,f_E,f_e]),
    ins_entry(call_6, 35, [f_z,f_z,f_z,f_z,f_z,f_z,f_E,f_e], [label(_)]),
    ins_entry(call_5q, 32, [f_Q,f_z,f_z,f_z,f_z,f_z,f_E,f_e]),
    ins_entry(call_5, 33, [f_z,f_z,f_z,f_z,f_z,f_E,f_e], [label(_)]),
    ins_entry(call_4q, 30, [f_Q,f_z,f_z,f_z,f_z,f_E,f_e]),
    ins_entry(call_4, 31, [f_z,f_z,f_z,f_z,f_E,f_e], [label(_)]),
    ins_entry(call_3q, 28, [f_Q,f_z,f_z,f_z,f_E,f_e]),
    ins_entry(call_3, 29, [f_z,f_z,f_z,f_E,f_e], [label(_)]),
    ins_entry(call_2q, 26, [f_Q,f_z,f_z,f_E,f_e]),
    ins_entry(call_2, 27, [f_z,f_z,f_E,f_e], [label(_)]),
    ins_entry(call_1q, 24, [f_Q,f_z,f_E,f_e]),
    ins_entry(call_1, 25, [f_z,f_E,f_e], [label(_)]),
    ins_entry(callq, 22, [f_Q,f_E,f_e]),
    ins_entry(call, 23, [f_E,f_e], [label(_)]),
    %
    ins_entry(lastcall_nq, 60, [f_Q,f_Z,f_E]),
    ins_entry(lastcall_n, 61, [f_Z,f_E], [label(_)]),
    ins_entry(lastcall_8q, 58, [f_Q,f_z,f_z,f_z,f_z,f_z,f_z,f_z,f_z,f_E]),
    ins_entry(lastcall_8, 59, [f_z,f_z,f_z,f_z,f_z,f_z,f_z,f_z,f_E], [label(_)]),
    ins_entry(lastcall_7q, 56, [f_Q,f_z,f_z,f_z,f_z,f_z,f_z,f_z,f_E]),
    ins_entry(lastcall_7, 57, [f_z,f_z,f_z,f_z,f_z,f_z,f_z,f_E], [label(_)]),
    ins_entry(lastcall_6q, 54, [f_Q,f_z,f_z,f_z,f_z,f_z,f_z,f_E]),
    ins_entry(lastcall_6, 55, [f_z,f_z,f_z,f_z,f_z,f_z,f_E], [label(_)]),
    ins_entry(lastcall_5q, 52, [f_Q,f_z,f_z,f_z,f_z,f_z,f_E]),
    ins_entry(lastcall_5, 53, [f_z,f_z,f_z,f_z,f_z,f_E], [label(_)]),
    ins_entry(lastcall_4q, 50, [f_Q,f_z,f_z,f_z,f_z,f_E]),
    ins_entry(lastcall_4, 51, [f_z,f_z,f_z,f_z,f_E], [label(_)]),
    ins_entry(lastcall_3q, 48, [f_Q,f_z,f_z,f_z,f_E]),
    ins_entry(lastcall_3, 49, [f_z,f_z,f_z,f_E], [label(_)]),
    ins_entry(lastcall_2q, 46, [f_Q,f_z,f_z,f_E]),
    ins_entry(lastcall_2, 47, [f_z,f_z,f_E], [label(_)]),
    ins_entry(lastcall_1q, 44, [f_Q,f_z,f_E]),
    ins_entry(lastcall_1, 45, [f_z,f_E], [label(_)]),
    ins_entry(lastcallq, 42, [f_Q,f_E]),
    ins_entry(lastcall, 43, [f_E], [label(_)]),
    %
    ins_entry(executeq, 62, [f_Q,f_E]),
    ins_entry(execute, 63, [f_E], [label(w)]).

iset_put =>
    ins_entry(put_x_void, 69, [f_x], [label(w)]),
    ins_entry(put_x_variable, 70, [f_x,f_x], [label(w)]),
    ins_entry(put_xval_xval, 85, [f_x,f_x,f_x,f_x]),
    ins_entry(put_x_value, 71, [f_x,f_x]),
    ins_entry(put_x_unsafe_value, 72, [f_x,f_x], [label(w)]),
    ins_entry(put_y_first_variable, 73, [f_x,f_y], [label(w)]),
    ins_entry(put_y_variable, 74, [f_x,f_y], [label(w)]),
    ins_entry(put_yfvar_yvar, 83, [f_x,f_y,f_x,f_y], [label(w)]),
    ins_entry(put_yvar_yvar, 84, [f_x,f_y,f_x,f_y], [label(w)]),
    ins_entry(put_y_value, 75, [f_x,f_y]),
    ins_entry(put_y_unsafe_value, 76, [f_x,f_y], [label(w)]),
    ins_entry(put_constantq, 77, [f_Q,f_x,f_t]),
    ins_entry(put_constant, 78, [f_x,f_t]),
    ins_entry(put_nil, 81, [f_x]),
    ins_entry(put_largeq, 252, [f_Q,f_x,f_b], [label(w)]),
    ins_entry(put_large, 253, [f_x,f_b], [label(w)]),
    ins_entry(put_structureq, 79, [f_Q,f_x,f_f], [label(w)]),
    ins_entry(put_structure, 80, [f_x,f_f], [label(w)]),
    ins_entry(put_list, 82, [f_x], [label(w)]),
    ins_entry(put_yval_yval, 86, [f_x,f_y,f_x,f_y]),
    ins_entry(put_yval_yuval, 87, [f_x,f_y,f_x,f_y], [label(w)]),
    ins_entry(put_yuval_yval, 88, [f_x,f_y,f_x,f_y], [label(w)]),
    ins_entry(put_yuval_yuval, 89, [f_x,f_y,f_x,f_y], [label(w)]).

iset_blt =>
    ins_entry(function_1q, 222, [f_Q,f_x,f_x,f_C,f_g], [label(r)]),
    ins_entry(function_1, 223, [f_x,f_x,f_C,f_g], [label(r)]),
    ins_entry(function_2q, 224, [f_Q,f_x,f_x,f_x,f_C,f_g], [label(r)]),
    ins_entry(function_2, 225, [f_x,f_x,f_x,f_C,f_g], [label(r)]),
    ins_entry(builtin_1q, 226, [f_Q,f_x,f_C], [label(r)]),
    ins_entry(builtin_1, 227, [f_x,f_C], [label(r)]),
    ins_entry(builtin_2q, 228, [f_Q,f_x,f_x,f_C], [label(r)]),
    ins_entry(builtin_2, 229, [f_x,f_x,f_C], [label(r)]),
    ins_entry(builtin_3q, 230, [f_Q,f_x,f_x,f_x,f_C], [label(r)]),
    ins_entry(builtin_3, 231, [f_x,f_x,f_x,f_C], [label(r)]),
    ins_entry(retry_instance, 232, [], [label(r)]).

iset_get1 =>
    ins_entry(get_x_value, 91, [f_x,f_x], [label(r)]),
    ins_entry(get_y_first_value, 94, [f_x,f_y], [label(r)]),
    ins_entry(get_y_value, 95, [f_x,f_y], [label(r)]),
    ins_entry(get_constantq, 96, [f_Q,f_x,f_t]),
    ins_entry(get_constant, 97, [f_x,f_t], [label(_)]),
    ins_entry(get_largeq, 254, [f_Q,f_x,f_b]),
    ins_entry(get_large, 255, [f_x,f_b], [label(_)]),
    ins_entry(get_structureq, 98, [f_Q,f_x,f_f]),
    ins_entry(get_structure, 99, [f_x,f_f], [label(_)]),
    ins_entry(get_nil, 100, [f_x], [label(r)]),
    ins_entry(get_list, 101, [f_x], [label(r)]),
    ins_entry(get_constant_neck_proceedq, 111, [f_Q,f_x,f_t]),
    ins_entry(get_constant_neck_proceed, 112, [f_x,f_t], [label(_)]),
    ins_entry(get_nil_neck_proceed, 113, [f_x], [label(r)]).

iset_cut =>
    ins_entry(cutb_x, 208, [f_x], [label(r)]),
    ins_entry(cutb_x_neck, 210, [f_x], [label(r)]),
    ins_entry(cutb_neck, 211, [], [label(r)]),
    ins_entry(cutb_x_neck_proceed, 212, [f_x], [label(r)]),
    ins_entry(cutb_neck_proceed, 213, [], [label(r)]),
    ins_entry(cute_x, 214, [f_x], [label(r)]),
    ins_entry(cute_x_neck, 216, [f_x], [label(r)]),
    ins_entry(cute_neck, 217, [], [label(r)]),
    ins_entry(cutf_x, 215, [f_x], [label(r)]),
    ins_entry(cutf, 209, [], [label(r)]),
    ins_entry(cut_y, 218, [f_y], [label(r)]).

iset_choice =>
    ins_entry(choice_x, 219, [f_x]),
    ins_entry(choice_yf, 220, [f_y]),
    ins_entry(choice_y, 221, [f_y], [label(_)]).

iset_misc1 =>
    ins_entry(kontinue, 233, [], [label(w)]),
    ins_entry(leave, 234, [], [label(r)]),
    ins_entry(exit_toplevel, 235, [], [label(r)]),
    ins_entry(retry_cq, 237, [f_Q,f_C], [label(r)]),
    ins_entry(retry_c, 238, [f_C], [label(r)]).

iset_get2 =>
    ins_entry(get_structure_x0q, 104, [f_Q,f_f]),
    ins_entry(get_structure_x0, 105, [f_f], [label(w)]),
    ins_entry(get_large_x0q, 256, [f_Q,f_b]),
    ins_entry(get_large_x0, 257, [f_b], [label(w)]),
    ins_entry(get_constant_x0q, 102, [f_Q,f_t]),
    ins_entry(get_constant_x0, 103, [f_t], [label(w)]),
    ins_entry(get_nil_x0, 106, []),
    ins_entry(get_list_x0, 107, []),
    ins_entry(get_xvar_xvar, 108, [f_x,f_x,f_x,f_x]),
    ins_entry(get_x_variable, 90, [f_x,f_x]),
    ins_entry(get_y_first_variable, 92, [f_x,f_y]),
    ins_entry(get_y_variable, 93, [f_x,f_y], [label(_)]),
    ins_entry(get_yfvar_yvar, 109, [f_x,f_y,f_x,f_y]),
    ins_entry(get_yvar_yvar, 110, [f_x,f_y,f_x,f_y], [label(_)]).

iset_unify =>
    ins_entry(unify_void, 114, [f_i]),
    ins_entry(unify_void_1, 115, [], [label(w)]),
    ins_entry(unify_void_2, 116, [], [label(w)]),
    ins_entry(unify_void_3, 117, [], [label(w)]),
    ins_entry(unify_void_4, 118, [], [label(w)]),
    ins_entry(unify_x_variable, 119, [f_x]),
    ins_entry(unify_x_value, 120, [f_x]),
    ins_entry(unify_x_local_value, 121, [f_x], [label(r)]),
    ins_entry(unify_y_first_variable, 122, [f_y]),
    ins_entry(unify_y_variable, 123, [f_y], [label(_)]),
    ins_entry(unify_y_first_value, 124, [f_y]),
    ins_entry(unify_y_value, 125, [f_y]),
    ins_entry(unify_y_local_value, 126, [f_y], [label(r)]),
    ins_entry(unify_constantq, 127, [f_Q,f_t]),
    ins_entry(unify_constant, 128, [f_t], [label(r)]),
    ins_entry(unify_largeq, 258, [f_Q,f_b]),
    ins_entry(unify_large, 259, [f_b], [label(_)]),
    ins_entry(unify_structureq, 129, [f_Q,f_f]),
    ins_entry(unify_structure, 130, [f_f], [label(r)]),
    ins_entry(unify_nil, 131, []),
    ins_entry(unify_list, 132, []),
    ins_entry(unify_constant_neck_proceedq, 133, [f_Q,f_t]),
    ins_entry(unify_constant_neck_proceed, 134, [f_t], [label(r)]),
    ins_entry(unify_nil_neck_proceed, 135, []).

iset_u2 =>
    ins_entry(u2_void_xvar, 136, [f_i,f_x]),
    ins_entry(u2_void_yfvar, 139, [f_i,f_y]),
    ins_entry(u2_void_yvar, 140, [f_i,f_y], [label(_)]),
    ins_entry(u2_void_xval, 137, [f_i,f_x]),
    ins_entry(u2_void_xlval, 138, [f_i,f_x], [label(r)]),
    ins_entry(u2_void_yfval, 141, [f_i,f_y]),
    ins_entry(u2_void_yval, 142, [f_i,f_y]),
    ins_entry(u2_void_ylval, 143, [f_i,f_y], [label(r)]),
    ins_entry(u2_xvar_void, 144, [f_x,f_i]),
    ins_entry(u2_xvar_xvar, 145, [f_x,f_x]),
    ins_entry(u2_xvar_yfvar, 148, [f_x,f_y]),
    ins_entry(u2_xvar_yvar, 149, [f_x,f_y], [label(_)]),
    ins_entry(u2_xvar_xval, 146, [f_x,f_x]),
    ins_entry(u2_xvar_xlval, 147, [f_x,f_x], [label(r)]),
    ins_entry(u2_xvar_yfval, 150, [f_x,f_y]),
    ins_entry(u2_xvar_yval, 151, [f_x,f_y]),
    ins_entry(u2_xvar_ylval, 152, [f_x,f_y], [label(r)]),
    ins_entry(u2_yfvar_void, 153, [f_y,f_i]),
    ins_entry(u2_yvar_void, 154, [f_y,f_i], [label(_)]),
    ins_entry(u2_yfvar_xvar, 155, [f_y,f_x]),
    ins_entry(u2_yvar_xvar, 156, [f_y,f_x], [label(_)]),
    ins_entry(u2_yfvar_yvar, 157, [f_y,f_y]),
    ins_entry(u2_yvar_yvar, 158, [f_y,f_y], [label(_)]),
    ins_entry(u2_yfvar_xval, 159, [f_y,f_x]),
    ins_entry(u2_yfvar_xlval, 161, [f_y,f_x], [label(r)]),
    ins_entry(u2_yvar_xval, 160, [f_y,f_x], [label(w)]),
    ins_entry(u2_yvar_xlval, 162, [f_y,f_x], [label(_)]),
    ins_entry(u2_yfvar_yval, 163, [f_y,f_y]),
    ins_entry(u2_yfvar_ylval, 165, [f_y,f_y], [label(r)]),
    ins_entry(u2_yvar_yval, 164, [f_y,f_y], [label(w)]),
    ins_entry(u2_yvar_ylval, 166, [f_y,f_y], [label(_)]),
    ins_entry(u2_yfval_void, 185, [f_y,f_i]),
    ins_entry(u2_yfval_xvar, 188, [f_y,f_x]),
    ins_entry(u2_yfval_yfval, 199, [f_y,f_y]),
    ins_entry(u2_yfval_xval, 193, [f_y,f_x]),
    ins_entry(u2_yfval_xlval, 196, [f_y,f_x], [label(r)]),
    ins_entry(u2_yfval_yval, 202, [f_y,f_y]),
    ins_entry(u2_yfval_ylval, 205, [f_y,f_y], [label(r)]),
    ins_entry(u2_xval_void, 167, [f_x,f_i]),
    ins_entry(u2_xlval_void, 168, [f_x,f_i], [label(r)]),
    ins_entry(u2_xval_xvar, 169, [f_x,f_x]),
    ins_entry(u2_xlval_xvar, 170, [f_x,f_x], [label(r)]),
    ins_entry(u2_xval_yfvar, 171, [f_x,f_y]),
    ins_entry(u2_xlval_yfvar, 172, [f_x,f_y], [label(r)]),
    ins_entry(u2_xval_yvar, 173, [f_x,f_y], [label(w)]),
    ins_entry(u2_xlval_yvar, 174, [f_x,f_y], [label(_)]),
    ins_entry(u2_xval_xval, 175, [f_x,f_x]),
    ins_entry(u2_xval_xlval, 177, [f_x,f_x], [label(r)]),
    ins_entry(u2_xlval_xval, 176, [f_x,f_x], [label(r)]),
    ins_entry(u2_xlval_xlval, 178, [f_x,f_x], [label(r)]),
    ins_entry(u2_xval_yfval, 179, [f_x,f_y]),
    ins_entry(u2_xlval_yfval, 180, [f_x,f_y], [label(r)]),
    ins_entry(u2_xval_yval, 181, [f_x,f_y]),
    ins_entry(u2_xval_ylval, 183, [f_x,f_y], [label(r)]),
    ins_entry(u2_xlval_yval, 182, [f_x,f_y], [label(r)]),
    ins_entry(u2_xlval_ylval, 184, [f_x,f_y], [label(r)]),
    ins_entry(u2_yval_void, 186, [f_y,f_i]),
    ins_entry(u2_ylval_void, 187, [f_y,f_i], [label(r)]),
    ins_entry(u2_yval_xvar, 189, [f_y,f_x]),
    ins_entry(u2_ylval_xvar, 190, [f_y,f_x], [label(r)]),
    ins_entry(u2_yval_yvar, 191, [f_y,f_y]),
    ins_entry(u2_ylval_yvar, 192, [f_y,f_y], [label(r)]),
    ins_entry(u2_yval_yfval, 200, [f_y,f_y]),
    ins_entry(u2_ylval_yfval, 201, [f_y,f_y], [label(r)]),
    ins_entry(u2_yval_xval, 194, [f_y,f_x]),
    ins_entry(u2_yval_xlval, 197, [f_y,f_x], [label(r)]),
    ins_entry(u2_ylval_xval, 195, [f_y,f_x], [label(r)]),
    ins_entry(u2_ylval_xlval, 198, [f_y,f_x], [label(r)]),
    ins_entry(u2_yval_yval, 203, [f_y,f_y]),
    ins_entry(u2_yval_ylval, 206, [f_y,f_y], [label(r)]),
    ins_entry(u2_ylval_yval, 204, [f_y,f_y], [label(r)]),
    ins_entry(u2_ylval_ylval, 207, [f_y,f_y], [label(r)]).

iset_misc2 =>
    ins_entry(bump_counterq, 248, [f_Q,f_l]),
    ins_entry(bump_counter, 249, [f_l], [label(_)]),
    ins_entry(counted_neckq, 250, [f_Q,f_l,f_l]),
    ins_entry(counted_neck, 251, [f_l,f_l], [label(_)]),
    ins_entry(fail, 67, []),
    ins_entry(heapmargin_callq, 245, [f_Q,f_g]),
    ins_entry(heapmargin_call, 246, [f_g], [label(_)]),
    ins_entry(neck, 65, [], [label(_)]),
    ins_entry(dynamic_neck_proceed, 236, [], [label(w)]),
    ins_entry(neck_proceed, 66, [], [label(w)]),
    ins_entry(proceed, 64, [], [label(_)]),
    ins_entry(restart_point, 262, [], [optional('PARBACK')]).

% exported instructions
exported_insns =>
    exported_ins(dynamic_neck_proceed, dynamic_neck_proceed),
    exported_ins(retry_cq, retry_cq),
    exported_ins(retry_instance, retry_instance),
    exported_ins(exit_toplevel, exit_toplevel),
    exported_ins(kontinue, kontinue),
    % needed for cterm
    exported_ins(get_constant, get_constant),
    exported_ins(get_constant_x0, get_constant_x0),
    exported_ins(get_constant_x0q, get_constant_x0q),
    exported_ins(get_large, get_large),
    exported_ins(get_list, get_list),
    exported_ins(get_list_x0, get_list_x0),
    exported_ins(get_nil, get_nil),
    exported_ins(get_nil_x0, get_nil_x0),
    exported_ins(get_structure, get_structure),
    exported_ins(get_structure_x0, get_structure_x0),
    exported_ins(get_structure_x0q, get_structure_x0q),
    exported_ins(get_x_value, get_x_value),
    exported_ins(get_x_variable, get_x_variable),
    exported_ins(unify_constant, unify_constant),
    exported_ins(unify_constantq, unify_constantq),
    exported_ins(unify_large, unify_large),
    exported_ins(unify_largeq, unify_largeq),
    exported_ins(unify_list, unify_list),
    exported_ins(unify_nil, unify_nil),
    exported_ins(unify_structure, unify_structure),
    exported_ins(unify_structureq, unify_structureq),
    exported_ins(unify_void, unify_void),
    exported_ins(unify_void_1, unify_void_1),
    exported_ins(unify_void_2, unify_void_2),
    exported_ins(unify_void_3, unify_void_3),
    exported_ins(unify_void_4, unify_void_4),
    exported_ins(unify_x_value, unify_x_value),
    exported_ins(unify_x_variable, unify_x_variable),
    % chat_tabling.c
    exported_ins(lastcall, lastcall),
    % compile_term_aux
    exported_ins(heapmargin_call, heapmargin_call),
    exported_ins(get_constraint, get_constraint),
    % ciao_initcode and init_some_bytecode
    exported_ins(callq, callq),
    exported_ins(execute, execute),
    exported_ins(fail, fail),
    exported_ins(restart_point, restart_point),
    % needed for qread
    exported_ins(branch, branch).

% TODO: horrible hack
:- [[ all_insns(decl, G) ]], '$exec_decls'(G).

