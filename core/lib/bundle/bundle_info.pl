:- module(_, [], [assertions, basicmodes, nativeprops, fsyntax, hiord, regtypes]).

:- doc(title,  "Bundle Information").
:- doc(author, "Ciao Development Team").
:- doc(author, "Jose F. Morales").

:- doc(module, "Obtain information about the registered bundles.").

:- use_module(library(terms), [atom_concat/2]).
:- use_module(library(lists), [reverse/2]).
:- use_module(library(aggregates), [findall/3]).
:- use_module(engine(internals),
	['$bundle_id'/1, '$bundle_prop'/2, '$bundle_srcdir'/2]).

% ---------------------------------------------------------------------------

:- export(root_bundle/1).
:- pred root_bundle/1 # "Meta-bundle that depends on all the system bundles.".
% TODO: Include also user bundles? or define a new meta-bundle?
root_bundle(ciao).

:- export(bundle_deps/2).
:- pred bundle_deps(Bundles, Deps) # "Obtain recursively all bundle
   dependencies of the given list of bundles @var{Bundles}, based on
   @tt{depends/1} property. Enumerate dependencies first.".

bundle_deps(Bundles, Deps) :-
	bundle_deps_(Bundles, [], _Seen, Deps, []).

bundle_deps_([], Seen0, Seen, Deps, Deps0) :- !, Deps = Deps0, Seen = Seen0.
bundle_deps_([BProps|Bs], Seen0, Seen, Deps, Deps0) :-
	( BProps = B-_Props -> true ; BProps = B ), % (ignore props)
	( member(B, Seen0) -> % seen, ignore
	    Deps = Deps2, Seen2 = Seen0
	; ( '$bundle_prop'(B, depends(Depends)) -> true
	  ; Depends = []
	  ),
	  Seen1 = [B|Seen0],
	  bundle_deps_(Depends, Seen1, Seen2, Deps, Deps1),
	  Deps1 = [B|Deps2]
	),
	bundle_deps_(Bs, Seen2, Seen, Deps2, Deps0).

% TODO: sub_bundle only make sense for root_bundle, remove or
%   generalize as 'all bundles in a workspace'?

:- export(enum_sub_bundles/2).
% Bundle is a sub-bundle of ParentBundle or a dependency of it
% (nondet, order matters)
enum_sub_bundles(ParentBundle, Bundle) :-
	( root_bundle(ParentBundle) ->
	    member(Bundle, ~bundle_deps(~all_bundles)),
	    is_sub_bundle(ParentBundle, Bundle)
	; fail
	).

:- export(enumrev_sub_bundles/2).
% Like enum_sub_bundles/2, in reverse order
enumrev_sub_bundles(ParentBundle, Bundle) :-
	( root_bundle(ParentBundle) ->
	    member(Bundle, ~reverse(~bundle_deps(~all_bundles))),
	    is_sub_bundle(ParentBundle, Bundle)
	; fail
	).

:- use_module(library(pathnames), [path_get_relative/3]).

% TODO: not very nice... rewrite bundles with sub-bundles as workspaces?
is_sub_bundle(ParentBundle, Bundle) :-
	'$bundle_srcdir'(ParentBundle, RootSrcDir),
	'$bundle_srcdir'(Bundle, SrcDir),
	% SrcDir is relative to RootSrcDir
	path_get_relative(RootSrcDir, SrcDir, _).

% All bundles except ~root_bundle
all_bundles := ~findall(B, ('$bundle_id'(B), \+ root_bundle(B))).

% ---------------------------------------------------------------------------
% Bundle name and version numbers

:- export(bundle_version/2).
% Version number of a bundle (as a atom) (fails if missing)
bundle_version(Bundle) := Version :-
	'$bundle_prop'(Bundle, version(Version)).

:- export(bundle_patch/2).
% Patch number of a bundle (as a atom) (fails if missing)
bundle_patch(Bundle) := Patch :-
	'$bundle_prop'(Bundle, patch(Patch)).

:- export(bundle_version_patch/2).
% Version and patch number
bundle_version_patch(Bundle) := ~atom_concat([~bundle_version(Bundle), '.', ~bundle_patch(Bundle)]).

:- export(bundle_name/2).
% TODO: use (and fix, not always the identity if we want to
% distinguish between the loaded bundle and the built bundle)
bundle_name(Bundle) := Bundle.

