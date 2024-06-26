:- doc(version(1*22+0,2022/9/28,17:41*23+'CET'), "
   TBD
").
:- doc(version(1*21+0,2022/3/2,20:34*30+'CET'), "
   @begin{itemize}
   @item Build system:
     @begin{itemize}
     @item IMPROVED: Partial rewrite of network-based installation
        (better selection of releases, allow prebuilt docs and
        binaries).
     @item IMPROVED: Tighter integration of @tt{ciao publish} into the
        builder.
     @item IMPROVED: Third-party commands moved to \"advanced\" help.
     @end{itemize}
   @item Core (compiler/engine, toplevel, libraries):
     @begin{itemize}
     @item ADDED: Support PowerPC 64-bit in little-endian mode.
     @item ADDED: Replaced using_tty/0 with system_extra:istty/1
        (specify fd).
     @item ADDED: cgoal/1 property (to distinguish from callable/1 ISO
        pred).
     @item ADDED: @tt{binexec} option for automatic spawning of active
        modules. This produces multi-purpose binaries that can start
        as either normal processes or active modules.
     @item ADDED: Added @tt{ivar/1} meta-property in assertions
        (expands to @tt{var/1} plus independence from all other vars).
     @item ADDED: New rtchecks (run-time assertion checking) code for
        @tt{det/1}, @tt{semidet/1}, @tt{multidet/1}, @tt{nondet/1}
        properties.
     @item ADDED: Option to run unit tests in the same process.
     @item ADDED: Custom headers in foreign interface gluecode (useful
        for custom type translations).
     @item IMPROVED: Faster dependency checks in the compiler (see
        @tt{itf_sections}). Improves x2 loading time of large
        executables.
     @item IMPROVED: @tt{iso} package renamed @tt{iso_strict}, code
        adapted.
     @item IMPROVED: merged @tt{bf} and @tt{af} search rule
        translation modules.
     @item IMPROVED: Document need for @tt{devenv} for running tests.
     @item IMPROVED: Preserve timestamps when engine metadata does not
        change. 
     @item IMPROVED: More resilient unit test runner.
     @item FIXED: Fixes to termux compilation (Android).
     @item FIXED: Cleanup of itf when @tt{opt_suff/1} used.
     @item FIXED: Default hostname to @tt{localhost} in active modules.
     @item FIXED: Location of relative paths in @tt{reexport}.
     @item FIXED: Documentation of timeout library.
     @item FIXED: Allow multiple doccomments before condcomp directives.
     @item FIXED: Markdown parser issues.
     @item FIXED: Fix @tt{|} operator priority to 1105 (ISO DCG draft).
     @item FIXED: Bug in @tt{sub_atom/5}.
     @item FIXED: Removed bashism in @tt{config-sysdep.sh}.
     @item FIXED: Use stderr consistently in unit test output.
     @end{itemize}
   @item Ciao emacs mode:
     @begin{itemize}
     @item ADDED: Distribute flycheck and company support for
        ciao-mode.
     @item ADDED: New @tt{ciao-emacs} command (start emacs with
        \"batteries included\"). It preinstalls markdown mode and
        contrib packages.
     @item IMPROVED: library for navigating options menus (used in,
        e.g., CiaoPP): allow cursor navigation, eliminated need for
        OK/cancel buttons, allow integer values in responses.
     @item CHANGED: Change check assertions binding to @tt{C-c V}.
     @item FIXED: @tt{=>} is no longer a prompt recognised my ciao-emacs.
     @item FIXED: Issue in passing of system-args to ciao process.
     @end{itemize}
   @end{itemize}
").

:- doc(version(1*20+0,2021/3/18,19:33*30+'CET'), "
   @begin{itemize}
   @item Build system:
     @begin{itemize}
     @item ADDED: Experimental @tt{analyze} build grade for analyzing whole
       bundles (depends on CiaoPP).
     @item FIXED: Fix activation links for @tt{pkgconfig} files in
       3rd-party installation.
     @item DEPRECATED: Removed support for 3rd-party @tt{bower} package
       system (all existing uses ported to @tt{npm}).
     @end{itemize}
   @item Language, compiler, and toplevel:
     @begin{itemize}
     @item FIXED: Fix a bug that redirected @tt{main/1} calls from the
      toplevel to the @tt{ciaosh} @tt{main/1} predicate (accidentally via
      the @tt{user} module).
     @item FIXED: Detect wrong arity in @tt{add_goal_trans} directives.
     @item IMPROVED: Towards a more modular @tt{native_props.pl},
       documentation improvements.
     @item IMPROVED: Progress towards merging optim-comp branch for native
       compilation.
     @item IMPROVED: Refactored default language packages (they can be used
       from modules and toplevels).
     @item CHANGED: @tt{note} messages go to user error (like other
       compiler messages).
     @end{itemize}
   @item Engine:
     @begin{itemize}
     @item ADDED: Support for new Apple M1. This port is based on existing
       support for the aarch64 (ARM64) architecture. NOTE: some
       executable formats depend on redoing 'codesign' after the
       executable is linked (this may cause issues when distributing
       binaries).
     @end{itemize}
   @item Runtime checks, testing, and debugging:
     @begin{itemize}
     @item IMPROVED: @tt{mshare/1} internally represented as
       @tt{mshare/2}, with explicit relevant arguments (for
       @tt{rtchecks}).
     @item IMPROVED: Refactor pieces of embedded debugger.
     @item IMPROVED: Note message for modules compiled with the trace
       or debug packages.
     @item FIXED: Do not ignore assertions with empty compats, calls,
       success, and comps fields (also for @tt{texec}).
     @item FIXED: Improve debugging of modules with rtcheck instrumentation.
     @item FIXED: Expansion for runtime checks preserve @tt{?- ...}
       directives.
     @end{itemize}
   @item Libraries:
     @begin{itemize}
     @item ADDED: Support for Unicode (UTF8) in source code:
       @begin{itemize}
       @item Pre-generated character code classes for 0..127
       @item Documented code class types and identifier syntax for Unicode
         source code (see @tt{tokenize.pl}).
       @item Very efficient and compact (8KB) code class table (see
          @tt{unicode_gen.pl} for details).
       @end{itemize}
     @item ADDED: Unicode escape \\\\uDDDD and \\\\UDDDDDDDD in strings and atoms.
     @item ADDED: Added byte-oriented predicates (see @tt{stream_utils.pl}) and
       types (@tt{basic_props:bytelist/1}), using them when needed.
     @item ADDED: Added string_bytes/2 predicate. This predicate bidirectionally
       transforms between lists of character codes and lists of bytes
       (using UTF8 encoding/decoding). It is equivalent to =/2 when at
       least one of the lists is already a list of ASCII codes (0..127).
     @item ADDED: Stronger redirection predicates (@tt{open_std_redirect/3} and
       @tt{close_std_redirect/1}), which allow the redirection of the standard
       output/error file descriptors together with the default output
       stream, user_output, and user_error. Added @tt{system:fd_dup/2} and
       @tt{system:fd_close/1} predicates to manipulate POSIX file
       descriptors.
     @item ADDED: Added stream_utils:copy_stream/3 predicate (copies bytes from one
       stream to the other).
     @item ADDED: Extended @tt{io_once_port_reify/@{3,4@}} with better redirections
       (subset of process channels available for @tt{process_call/3}).
     @item ADDED: Parsing of version strings (@tt{version_strings:version_parse/4}).
     @item IMPROVED: Heuristics in @tt{write_assertion/@{6,7@}}, more
       readable output.
     @item IMPROVED: Allow JSON values (not only lists) as top argument for
       JSON write and parse.
     @item IMPROVED: Faster and more reliable sockets predicates. New
       @tt{socket_sendall/2}, @tt{socket_send_stream/2}, changed
       @tt{socket_send/3}. @tt{socket_recv_code/3} is replaced by
       @tt{socket_recv/3} (treating the returned length is encouraged, do
       not use @tt{socket_recv/2}).
     @item IMPROVED: Faster and more robust HTTP libraries (sockets improvements,
       faster IO). Several bug fixes. 
     @item FIXED: Fixed bug in markdown parser which confused some
       predicate heads with items.
     @item FIXED: Allow numbers (as constants) in assertion head arguments.
     @item FIXED: Fixed bug in @tt{attrdump.pl} introduced when @tt{assoc} replaced
       @tt{dict}.
     @item FIXED: Write blanks before -0.Nan if needed. Fixed some corner cases in
       parser for 0.Inf, 0.Nan .
     @item FIXED: Cleanups in messages_basic:messages/1.
     @item FIXED: Allow @tt{use_package(tabling)} in a toplevel.
     @end{itemize}
   @item ISO and Portability:
     @begin{itemize}
     @item ADDED: Implemented @tt{at_end_of_stream/0},
       @tt{at_end_of_stream/1}. Peek byte in @tt{at_end_of_stream/@{0,1@}} for
       improved ISO compatibility.
     @item ADDED: Implemented @tt{peek_byte/1}, @tt{peek_byte/2}.
     @item ADDED: Added call_det/2 predicate (compatible with @tt{gprolog}).
     @item ADDED: Added forall/2 predicate (compatible with @tt{gprolog}).
     @item FIXED: callable/1 is an instantiation check.
     @item IMPROVED: Added version_data flag as
       @tt{ciao(Major,Minor,Patch,Extra)}.
     @item IMPROVED: Added stream property @tt{type(_)} in @tt{open/4}
       predicate (for compatibility).
     @item ADDED: @tt{--iso-strict} flag in @tt{ciaoc} and @tt{ciaosh} to enable
       stricter compatibility ISO mode by default. Use with care, switching the flag
       will not enforce the recompilation of already compiled user files
       and modules (i.e., .po files).
     @item IMPROVED: Additions to the @tt{iso_strict.pl} package (only for code
       using this package):
       @begin{itemize}
       @item More compatible version of @tt{absolute_file_name/2} (do not
         repeat last path component when resolving library paths).
       @item Allow stream aliases in most IO operations.
       @item Import @tt{keysort/2} and @tt{format/?} predicates by default.
       @item Enable @tt{call/N} by default.
       @item Enable @tt{runtime_ops} package by default.
       @end{itemize}
     @end{itemize}
   @item Ciao emacs mode:
     @begin{itemize}
     @item ADDED: Initial support for @tt{flycheck}, integrating ciaoc, 
       ciaopp, lpdoc, and testing. 
     @item ADDED: Support for company mode (text completion). Manuals
       are located dynamically. Completion list obtained using
       @lib{librowser}.
     @item ADDED: Extended Ciao mode (@tt{ciao-emacs-plus.el}) using
       @tt{flycheck} and @tt{company} extensions.
     @item ADDED: @tt{M-x ciao-server-start}, @tt{M-x ciao-server-stop}
       to start/stop the @tt{ciao-serve} process (serving local HTML
       documentation and hub for HTTP based interface to active
       modules).
     @item ADDED: Mark and color new @tt{passed}, @tt{failed},
       @tt{aborted} message types (for unit tests).
     @item IMPROVED: Replace outdated @tt{word-help} by
       @tt{info-look}.
     @item IMPROVED: Better binding for next error, better code
       highlight, narrow error location.
     @item IMPROVED: Allow short location paths (resolved from the
       elisp side). See @tt{bundle_paths:bundle_extend_path/2} for
       details on path extension.
     @item IMPROVED: Faster font-lock in @tt{ciao-inferior-mode}, only
       treat keywords. 
     @item FIXED: Fixed indentation and coloring of @tt{=:=}.
     @item FIXED: Fix build errors when compiling using emacs 27.1.
     @end{itemize}
   @item Unit Tests:
     @begin{itemize}
     @item ADDED: Allow @tt{opt_suff/1} in unit tests (for alternative
       source files, e.g., for flycheck).
     @item ADDED: New options for handling tests for stdout and stderr 
       in unittest.
     @item ADDED: Added support for test filters (see options in
       @tt{run_tests/4}).
     @item ADDED: Using 'passed', 'failed', and 'aborted' message types.
     @item ADDED: Test timeout.
     @item ADDED: Initial support for integrated regression testing 
       (see @tt{save}, @tt{compare}, etc. actions in @tt{run_tests/3}).
     @item IMPROVED: More flexible quering of results and statistics
       (@tt{get_statistical_summary/2}, @tt{print_statistical_summary/1},
       @tt{status(S)} option).
     @item IMPROVED: Simpler one-line output per test.
     @item IMPROVED: Warnings when predicate fails/throws and there were no
       failure/exception properties in test assertion.
     @item FIXED: Unittest regression does not depend on Ciao root path.
     @end{itemize}
   @end{itemize}
").

:- doc(version(1*19+0,2020/3/20,14:48*45+'CET'), "
   Highlights of this release:
   @begin{itemize}   
   @item Build system: optional (weak) dependencies in bundle
     Manifest, out-of-tree builds by default in bundles (sources are
     no longer polluted with .po/.itf files).
   @item Language and libraries: a more natural argument order in
     partial applications, clarified semantics of shared variables in
     predicate abstractions (and faster implementation), improvements
     in tabling with constraints (TCLP).
   @item System: several fixes in small and large integer operations,
     new algorithm for float to string conversion (based on Ryu,
     fixing the round-trip property), and thread-safe exception
     handling mechanism.
   @item Runtime checks and unit tests: major cleanups, fixes, and
     improvements in functionality and efficiency.
   @item Top level: cyclic terms detected by default (@tt{check_cycles}
     flag no longer needed), faster pretty printing of solutions.
   @item Ciao emacs mode: 4-space indentation by default. Improvements
     to syntax coloring. Coloring of info manuals generated by
     LPdoc. Connection with ciao-serve. Dropped support for xemacs.
   @item Installation: new instructions for Windows based on WSL and
     for Android based on Termux.
   @end{itemize}

   Detailed list of new features and changes:
   @begin{itemize}   
   @item Builder and installation:
     @begin{itemize}   
     @item ADDED: Optional (weak) dependencies in bundle
       Manifests. Weak dependencies allow bundles with conditional
       code which depends on the availability of other bundles.
     @item ADDED: Allow gitlab aliases in @tt{ciao get}, i.e.,
       @tt{ciao get gitlab.x.y.z/some/path} will recognize (as a
       heuristic) that we are trying to install a bundle from a Gitlab
       repository. It should work for any instance of gitlab (as long
       as there is public access to the repository).
     @item ADDED: Exposed @tt{third-party-install} command (e.g.,
       @tt{ciao third-party-install ciao_ppl.ppl} to install @tt{ppl}
       3rd-party from @tt{ciao_ppl} bundle).
     @item ADDED: Execute @tt{autoreconf -i} when GNU build system is
       selected and the @tt{configure} file is not available
       (3rd-party installer).
     @item ADDED: Support for @tt{zsh} shell, unified config in
       @tt{--core:update_shell=[yes|no]}
     @item ENHANCED: Improved interactive @tt{ciao-boot.sh} (reordered
       questions, check deps).
     @item EXPERIMENTAL: Support for @tt{--parallel=yes} build option.
     @item FIXED: Throw exception if foreign config tool is not found.
     @item FIXED: Absolute path in rpath for 3rd-party libs.
     @item FIXED: Make sure that @tt{cache/} dir exists before loading
       bundle manifest hooks.
     @item FIXED: @tt{ciao clean-tree} works with non-absolute paths.
     @item FIXED: Do not assume @tt{/bin/rm} is there, use @tt{TMPDIR}
       if defined.
     @item FIXED: Make @tt{./ciao-boot.sh clean} work even if
       @tt{core} is not built.
     @item FIXED: Make sure that building @tt{core} prepares the bin grade
       (@tt{core.ciaobase}).
     @end{itemize}
   @item Language, compiler, and toplevel:
     @begin{itemize}   
     @item ADDED: Out-of-tree builds, enabled by default. Use
       @tt{CIAOCCACHE=0} to disable it. The compilation of modules
       under a bundle produces @tt{.itf} and @tt{.po} files located in
       the build/cache directory of their corresponding workspace.
     @item ENHANCED: Using atomic file writes everywhere in the
       compiler. Now several processes may compile simultaneously the
       same code base without corrupting the @tt{.po}/@tt{.itf}
       compiler output files (there are a few documented bugs in the
       build scripts that should be fixed in the next commits to allow
       parallel systems builds).
     @item ENHANCED: New internal representation for predicate
       abstraction, which fixes a potential performance problem due to
       unnecessary renaming of shared variables.
     @item ENHANCED: Pretty printing of solutions from the toplevel is
       now orders of magnitude faster for some corner cases.
     @item CHANGED: Using standard hiord argument order. This changes
       the argument ordering for predicate abstractions for @tt{hiord}
       to make it compatible with other systems and languages. The old
       order was implemented to favor 1st argument indexing, but it
       can be confusing because of the difference with other languages
       with higher-order (specially for partial applications).

       Note that was overdue because it was a complicated backwards
       incompatible change that required many changes in the compiler
       and libraries (including the assertion language, parametric
       properties, runtime checks, and parts of the CiaoPP analysis
       framework).
     @item CHANGED: Made the semantics of shared variables in
       predicate abstractions more strict. Now only the variables
       specified in @tt{ShVs} for @tt{call((ShVs -> ''(...) :- ...), ...)}
       will share with the caller's body variables. No other
       variables will be implicitly shared.
     @item CHANGED: Conditional compilation is built-in in the
       compiler now.  This improves the portability of some
       experimental libraries.
     @item EXPERIMENTAL: @tt{string_type} package for native strings.
     @item EXPERIMENTAL: a default behavior was defined for
       @tt{ciao-serve} so that it provides the available manuals in
       @tt{index.html} (via the HTTP protocol).
     @item FIXED: Make partial application work as expected (e.g.,
       @tt{X=append, Y = X([1]), Y([2], Z)})
     @item FIXED: Syntactic errors in assertion normalization are now
       treated correctly by @tt{c_itf.pl}.
     @item FIXED: Program point assertions
       (@tt{check/1},@tt{true/1},etc.) are not removed by
       @tt{mexpand.pl}
     @item FIXED: @tt{load_compilation_module/1} was incorrectly
       ignoring modules that were already processed (e.g., compiled)
       but not loaded in the context of @tt{c_itf.pl}.
     @item ENHANCED: Pretty printing of solutions detects cyclic terms
       automatically. The @tt{check_cycles} flag is no longer needed
       and has been removed.
     @item REMOVED: @tt{check_cycles} flag is no longer needed.
     @end{itemize}
   @item Engine:
     @begin{itemize}   
     @item ADDED: Support for @tt{aarch64} on Android (using Termux).
     @item ADDED: Support for 64-bits in tabling libraries. Trie
       adapted to allow the use of big numbers.
     @item FIXED: using C @tt{-fno-stack-check} option as a workaround
       for Darwin19/Xcode-11 bug (macOS Catalina)
     @item FIXED: Using C @tt{MoveFileEx()} intead of @tt{rename()} in
       Win32.
     @item FIXED: Normalize @tt{c_headers_directory()} in Win32.
     @item FIXED: Fix C warnings due to casts of integers of different
       sizes.
     @item FIXED: Using @tt{__builtin_mul_overflow()} for better
       32-bit/64-bit portability.
     @item FIXED: Fix evaluation of right shift with large numbers.
     @item FIXED: Fixed round-trip property in float to string and
       string to float conversions. The new code is based on the
       extremely fast Ryu algorithm (see 2018 paper).
     @item FIXED: Added @tt{lib(engine)} to @tt{core/Manifest} (this
       ensures that @tt{engine/} files are copied in global
       installations).
     @item FIXED: Thread-safe and more efficient reimplementation of
       exceptions.
     @item FIXED: Handler for signals that are not intercepted.
     @item FIXED: Fix right shift of negative @tt{smallint}. For
       @tt{Shift} in 0..70 and @tt{V=(-1<<57)} or @tt{V=(-1)}, @tt{X
       is V>>Shift} produced @tt{X=0} instead of a negative number.
     @end{itemize}
   @item Runtime checks, testing, and debugging:
     @begin{itemize}   
     @item ADDED: New @tt{timeout/2} property for test assertions (10
       min default).
     @item ADDED: New @tt{generate_from_calls_n/2} property for test
       assertions (generate multiple test states from the calls field,
       1 by default).
     @item ENHANCED: Major cleanups in @tt{rtchecks} package.
     @item CHANGED: Default value of @tt{try_sols/2} is 2 (rather than
       infinite).
     @item CHANGED: @tt{unittest} aborts on compilation errors.
     @item CHANGED: Replaced @tt{num_solutions('>'(N))} by
       @tt{num_solutions('<'(N))} (due to new hiord).
     @item FIXED: rtchecks for exception properties rethrow rtcheck
       error exceptions.
     @item FIXED: Added @tt{@@} option also in embedded debugger (see
       @tt{debug} or @tt{trace} package).
     @end{itemize}
   @item Libraries:
     @begin{itemize}   
     @item ADDED: Improvements to TCLP: support for 64 bits, interface
       with the Mod TCLP modular framework, new solver interfaces
       (difference constraints, CLP(Q), CLP(R)), new constraint solver
       over lattices (abs_new_constraint), a new framework for
       incremental evaluation of lattice-based aggregates
       (@tt{tclp_aggregates}).
     @item ADDED: New @tt{system:get_numcores/1}, obtains the number
       of logical CPU cores.
     @item ENHANCED: Updated pretty printing-style formatting of
       clauses and assertions.
     @item CHANGED: Inline foreign code feature moved to
       @tt{foreign_inliner} package.
     @item CHANGED: Update indentation rules in
       @tt{write:portray_clause/@{1,2@}}.
     @item CHANGED: All code ported to the new hiord argument order
       and predicate abstraction sharing rules.
     @item FIXED: Bug in fastrw due to wrong integer casting (64-bit).
     @item FIXED: @tt{C-c} restarts the toplevel only if it was
       started (for embedded toplevels).
     @item FIXED: @tt{bfall} and @tt{afall} search rules compatible
       with more language extensions.
     @item FIXED: Add missing parenthesis for @tt{(,)/2} in
       @tt{assrt_write} predicates.
     @item FIXED: Fix foreign interface C embedding example.
     @item FIXED: Missing cuts, @tt{==/2}, and meta_predicate
       declarations in @tt{assoc.pl}.
     @item FIXED: Avoid invalid cross-device link errors in
       @tt{file_buffer.pl} predicates.
     @item FIXED: Missing GC roots in @tt{system:extract_paths/2}.
     @end{itemize}
   @item Reference manual:
     @begin{itemize}   
     @item ADDED: Installation instructions for Windows based on WSL
       and for Android based on Termux.
     @item ENHANCED: Improved documentation of several libraries
       (@tt{regexp}, @tt{runtime_control}, read).
     @item ENHANCED: Separate language conventions from introduction.
     @item FIXED: Document that @tt{call_with_time_limit/@{2,3@}} behaves
       as @tt{once/1}.
     @item FIXED: Added @tt{classic_predicates.pl} (for classic
       compatibility package)
     @end{itemize}
   @item Ciao emacs mode:
     @begin{itemize}   
     @item ENHANCED: Indentation code rewritten (supporting block
       syntax, better indentation of if-then-else, argument-based
       indentation for columns).
     @item ENHANCED: New syntax coloring code (better multiline
       coloring of strings and comments, quoted atoms, doccomments
       blocks, documentation commands, assertion syntax)
     @item ENHANCED: Coloring of info manuals generated by LPdoc.
     @item ENHANCED: Do not set tty colors for ciao faces (modern
       terminals look great with the default colors).
     @item CHANGED: Using 4-space indentation by default.
     @item CHANGED: @tt{C-g} clears compilation error marks.
     @item CHANGED: Blanks instead of tabs in ciao-mode.
     @item CHANGED: Set default emacs init file to
       @tt{~/.emacs.d/init.d} (@tt{~/.emacs.el}, @tt{~/.emacs} are
       still detected if present)
     @item EXPERIMENTAL: @tt{M-x ciao-serve} (starts a Ciao server),
        @tt{M-x ciao-dist} (prepares data for a Ciao service).
     @item FIXED: @tt{word-help-extract-index} ignore missing indices.
     @item FIXED: use the lpdoc toplevel to generate/view buffer
       documentation (instead of a shell).
     @item FIXED: Modified error location colors for clarity when
       background is dark.
     @item FIXED: Fixing many elisp compilation warnings.
     @item REMOVED: Dropped support for xemacs.
     @end{itemize}
   @end{itemize}
").

:- doc(version(1*18+0,2018/12/06,11:25*08+'CEST'), "
   @begin{itemize}
   @item Backward-incompatible changes in this version:
      @begin{itemize}
      @item Changed the defaults for modules declared with
      @tt{module/3}.  The following predicates and features are no
      longer included by default in module/3. They should be
      enabled explicitly with the following packages or modules:
      @begin{itemize}
      @item @tt{call/N}: @tt{hiord} package.
      @item @tt{data}, @tt{concurrent} declarations,
        @tt{assertz_fact/1}, etc.: @tt{datafacts} package.
      @item @tt{dynamic} declarations, @tt{assertz/1}, etc.:
        @tt{dynamic} package.
      @item @tt{set_prolog_flag/2}, etc.:
        @tt{engine(runtime_control)} (which merges deprecated
        @tt{engine(prolog_flags)} and @tt{engine(prolog_sys)}).
      @item nl/0, nl/1, display/0, open/3, etc.: library(streams)
        (which reexports stream handling and operations, namely
        @tt{engine(stream_basic)} and @tt{engine(io_basic)}).
      @end{itemize}
      @item Added @tt{noprelude} that prevents loading the prelude
     (default definitions).
      @item The @tt{pure} package now includes a minimum set of
     control constructs @tt{(,)/2}, @tt{true/0}, @tt{fail/0}.
      @end{itemize}
   @item Language, compiler, toplevel:
      @begin{itemize}
      @item Major update of the Ciao manual (basic language, language
     extensions, Ciao standard library, additional libraries,
     abstract data types, ISO and compatibility, etc.).
      @item Built-in build system and software packaging system
     (@em{bundles}) (see documentation for details).
      @item Added (optional) @tt{CIAOROOT} and @tt{CIAOPATH}
     environment variables (replace @tt{CIAOLIB}). @tt{CIAOROOT}
     points to the root of the Ciao sources rather than the lib
     directory.
      @item New @tt{ciao-env} command to set up the environment for
     some specific Ciao installations.
      @item Fix @tt{MANPATH},@tt{INFOPATH} in @tt{ciao-env} (trailing
     @tt{:} was incorrectly removed, it is meaningful and
     represents default paths).
      @item Fixed @tt{ciaosh -e Goal} (accepts any goal), removed
     @tt{-g} option.
      @item DCG @tt{phrase/3} available by default in classic mode
     (toplevel, user modules, and modules declared with
     @tt{module/2}).
      @item Fixes in runtime check versions of @tt{mshare/1},
     @tt{indep/1}, @tt{indep/2}, and @tt{covered/2}.
      @item Fixed issues with cyclic terms in debugger (when
     @tt{check_cycles} flag is activated).
      @item (experimental) @tt{ciao-serve} command to start a Ciao
     server to serve both HTTP and active module requests.
      @end{itemize}
   @item Ciao emacs mode:
      @begin{itemize}
      @item Added @tt{M-x ciao-set-ciao-root}, @tt{M-x
    ciao-set-ciao-path} (see @tt{CIAOROOT} and @tt{CIAOPATH}
    changes).
      @item Improved syntax highlighting.
      @end{itemize}
   @item Engine:
      @begin{itemize}
      @item Fixed a bug while freeing sources in @tt{eng_call/@{3,4@}}.
      @item Fixed bug in dynamic/data predicates (uninitialized
     registers may lead to memory corruption during garbage
     collection).
      @item Added @tt{ciao_root/1}, replaces @tt{ciao_lib_dir/1}.
      @item Improved documentation and examples for interfacing with
     C/C++ (including embedding engines in C/C++ applications).
      @end{itemize}
   @item Libraries:
      @begin{itemize}
      @item Fixed bug in tokenizer (dealing with @tt{@\\^} escape
     sequences in strings).
      @item Refurbished HTTP libraries (separated from pillow, see
     documentation).
      @item Added @tt{library(io_port_reify)} (like @tt{port_reify}
     but allows IO redirection).
      @item Added @tt{filter/3}, @tt{partition/4}, @tt{maplist/N} to
     @tt{library(hiordlib)}.
      @item Added @tt{library(opendoc)} (opens a document with the
     default OS viewer).
      @item Revamped active modules model and implementation (see
     documentation for details).
      @item Renamed @tt{library(file_utils)} to
     @tt{library(stream_utils)}.
      @item Predicates @tt{stream_to_string/@{2,3@}} replaced by
     @tt{read_to_end/@{2,3@}} (which do not close the stream).
      @item Added @tt{library(terms_io)} (@tt{terms_to_file/2},
     @tt{file_to_terms/2}).
      @item (experimental) @tt{library(timeout)}
     (@tt{call_with_time_limit/@{2,3@}}).
      @item (experimental) package for traits (interfaces).
      @end{itemize}
   @end{itemize}
").

% (We skip development version 1.17 this time)

:- doc(version(1*16+0,2016/12/31,11:36*37+'CEST'), "
   @begin{itemize}
   @item Engine:
      @begin{itemize}
      @item Generating the emulator loop with our own code expansion
     and emulator generator (emugen).
      @item Refactor, clean up, rewrite some engine parts.
      @item Reworking custom engine compilation (under @tt{build/}
     directory). Ciao headers must be included now using
     @tt{#include <ciao/...>} rather than double quotes.
      @item Fix bug in arithmetic shifting operators by 0.
      @item Fix @tt{X is (1<<20)*(1<<10)} returned @tt{X=0} (detect
     multiplication overflows using @tt{__builtin_smul_overflow}
     to avoid C undefined behaviours, i.e., in clang).
      @item Fixes in bignums and float to integer conversion in
     64-bits mode.
      @item @tt{lib/engine/} merged into @tt{engine/} (no need to
     separate Prolog and C files).
      @item 64-bit port, enabled by default (this was a very large
     change which required rewriting some parts of the engine).
      @item Adding @tt{--trace-instr} engine option (traces
     instructions, for debugging).
      @item Faster implementation of @tt{unify_with_occurs_check/2}.
      @item Fix potential overflow in string to number conversion.
      @item Better support for @tt{UTF8}.
      @item Properly escaping all control characters in quoted atom
     print (ISO compliance).
      @item Fix ending of quoted atom and strings (ISO compliance).
      @item Fix @tt{get_char/1} (ISO conformance, past end of file).
      @item Fix in treatment of @tt{EOF} in IO predicates (do not
     assume @tt{EOF == -1}).
      @item @tt{CIAOARCH} replaced by @tt{CIAOOS} (e.g., Linux) and
     @tt{CIAOARCH} (e.g., @tt{i686}). New @tt{ciao_sysconf}
     command (replaces @tt{ciao_get_arch} script), which accepts
     the arguments @tt{--os}, @tt{--arch}, and @tt{--osarch}.
      @end{itemize}
   @item Portability and OS support:
      @begin{itemize}
      @item Using @tt{clang} as default C compiler in MacOS.
      @item Identify @tt{MINGW64_NT} as Win32 (which is commonly
     accepted as a generic OS name which does not necessarily mean
     32-bits).
      @item Drop support for IRIX and SunOS4.
      @item Improved support for NetBSD (NetBSD 7), FreeBSD.
      @item Support for Raspberry Pi.
      @item (experimental) support for MINGW32 and MINGW64 (and MSYS2)
     builds (for Windows).
      @item (experimental) support for EMSCRIPTEN as compilation
     target.
      @end{itemize}
   @item Language, compiler, toplevel:
      @begin{itemize}
      @item Conditional compilation library @tt{library(condcomp)}
     enabled by default.
      @item Deprecated @tt{alias(a(b(...)))} as a module specifier
     name (using the more compatible @tt{alias(a/b/...)} instead).
      @item Fix exit status (returns 1) for toplevel and executables
     on abort, e.g., due to uncaught exceptions or unexpected
     failure.
      @item New @tt{ciaoc_sdyn} tool to help in the distribution of
     standalone executables with foreign code (collects all
     required dynamic libraries).
      @item Starting work on new build system.
      @item (experimental) syntax extension for infix dot @tt{(A.B)}
     (see @tt{set_prolog_flag(read_infix_dot, on)}).
      @item (experimental) syntax extension for string data type (see
     @tt{set_prolog_flag(read_string_data_type, on)}).
      @end{itemize}
   @item Libraries:
      @begin{itemize}
      @item Fix @tt{system:touch/1}, implemented through C
      @tt{utime()}.
      @item Fix buffer overflow in @tt{absolute_file_name/?} with
     @tt{nul/NUL} in Win32 (it is a reserved name).
      @item Fix bug in check for cyclic terms, implemented faster C
     (low-level) version.
      @item Fix @tt{get_tmp_dir/1} so that it always produces a
     normalized path, with no trailing @tt{/}, and considering 
     @tt{TMPDIR} on POSIX systems.
      @item Better use of @tt{current_executable/1} implementation
     (macOS: @tt{_NSGetExecutablePath()}, Linux: @tt{readlink} on
     @tt{/proc/self/exe}, Windows: @tt{GetModuleFileName()} with
     @tt{hModule = NULL}).
      @item Added support for @tt{phrase/2} and @tt{phrase/3} in DCGs
     (in @tt{dcg_phrase} package).
      @item Added @tt{library(global_vars)}, backtrackable global
     variables.
      @item Added @tt{library(datetime)}, manipulate date and time in
     different formats.
      @item Added @tt{library(clpfd)}, new CLP(FD) implementation.
      @item Added @tt{library(glob)}, support @em{glob} patterns,
     filenames with wildcard characters.
      @item Added @tt{library(pathnames)}, predicates for file path
     name manipulation, compatible with common semantics in other
     languages.
      @item Added @tt{library(port_reify)}, metacalls which reify the
     @tt{exit} port so that it can be delayed.
      @item Added @tt{library(process)}, portable high-level
     interface for child process creation, supporting stream
     redirection, background processes, signals, etc.
      @item Added @tt{library(text_template)}, text-based templates.
      @item Added @tt{library(http_get)}, retrieve files via
     HTTP/HTTPs/FTP protocol.
      @item Added @tt{system:get_home/1},
     @tt{system:find_executable/2}.
      @item Added @tt{system:extract_paths/2}, split atom containing a
     colon-separated path list as individual paths.
      @item Deprecated @tt{exec/?} from @tt{library(system)}.
      @item Deprecated @tt{system:get_exec_dir/1}, can be replaced
     by @tt{current_executable/1} and @tt{path_dirname/2}.
      @item (experimental) @tt{library(indexer)}, a package that
     extends first-argument indexing.
      @item (experimental) heap limits exceptions
     (@tt{set_heap_limit/1}).
      @item (experimental) @tt{library(stream_wait)}, wait for input
     to be available, with timeouts.
      @end{itemize}
   @item Ciao emacs mode:
      @begin{itemize}
      @item Cleanups, refactoring into smaller individual components
     (highlighting, interaction with Ciao, etc.).
      @item @tt{M-x ciao-grep*} emacs command (search over all code).
      @end{itemize}
   @item Foreign interface:
      @begin{itemize}
      @item Fix exception throw from C builtins during shallow
     backtracking.
      @item Allow exception throwing using arbitrary terms.
      @item Foreign interface types corresponding to different
     fixed-width C types
     (@tt{c_int},@tt{c_size},@tt{c_uint8}, etc.).
      @end{itemize}
   @end{itemize}
").

:- doc(version(1*14+2,2011/08/12,18:14*31+'CEST'), "
   Merging r13606 (trunk) into 1.14.
   This backports an optimization for DARWIN platforms (Jose Morales)").

:- doc(version(1*14+1,2011/08/10,18:17*10+'CEST'), "
   Merging r13583 through r13586 (trunk) into 1.14. This fixes
   problems in the Windows version of Ciao (Edison Mera, Jose
   Morales)").

:- doc(version(1*15+0,2011/07/08,11:48*01+'CEST'), "New development
   version (Jose Morales)").

:- doc(version(1*14+0,2011/07/08,10:51*55+'CEST'), "
   It has been a long while since declaring the last major version
   (basically since moving to subversion after 1.10/1.12), so quite a
   bit is included in this release. Here is the (longish) summary:

   @begin{itemize}
   @item Extensions to functional notation:
      @begin{itemize}
      @item Introduced @tt{fsyntax} package (just functional
        syntax). (Daniel Cabeza)
      @item Added support to define on the fly a return argument
        different from the default one
        (e.g. @tt{~functor(~,f,2)}). (Daniel Cabeza)
      @item Use of '@tt{:- function(defined(true)).}' so that the
        defined function does not need to be preceded by @tt{~} in the
        return expression of a functional clause. (Daniel Cabeza)
      @item Functional notation: added to documentation to reflect more
        of the FLOPS paper text and explanations.  Added new
        functional syntax examples: arrays, combination with
        constraints, using func notation for properties, lazy
        evaluation, etc. (Manuel Hermenegildo)
      @item Added functional abstractions to @tt{fsyntax} and correct
        handling of predicate abstractions (the functions in the body
        where expanded outside the abstraction). (Jose Morales)
      @item Improved translation of functions. In particular, old
        translation could lose last call optimization for functions
        with body or with conditional expressions.  Furthermore, the
        translation avoids now some superfluous intermediate
        unifications.  To be studied more involved
        optimizations. (Daniel Cabeza, Jose Morales).
      @item More superfluous unifications taken out from translated code,
        in cases where a goal @tt{~f(X) = /Term/} appears in the
        body. (Daniel Cabeza)
      @item Added @tt{library/argnames_fsyntax.pl}: Package to be able to
        use @tt{$~/2} as an operator. (Daniel Cabeza)
      @item Added a new example for lazy evaluation, saving memory using
        lazy instead of eager evaluation. (Amadeo Casas)
      @end{itemize}

   @item Improvements to signals and exceptions:
      @begin{itemize}
      @item Distinguished between exceptions and signals. Exceptions are
        thrown and caught (using @pred{throw/1} and @pred{catch/3}).
        Signals are sent and intercepted (using @pred{send_signal/1}
        and @pred{intercept/3}).  (Jose Morales, Remy Haemmerle)
      @item Back-port of the (improved) low-level exception handling from
        @tt{optim_comp} branch. (Jose Morales)
      @item Fixed @pred{intercept/3} bug, with caused the toplevel to not
        properly handle exceptions after one was handled and
        displayed (bug reported by Samir Genaim on 04 Dec 05, in ciao
        mailing list, subject ``@tt{ciao top-level : exception
        handling}'').  Updated documentation. (Daniel Cabeza)
      @item @pred{intercept/3} does not leave pending choice points if
        the called goal is deterministic (the same optimization that
        was done for @pred{catch/3}). (Jose Morales)
      @end{itemize}

   @item New/improved libraries:
      @begin{itemize}
      @item New @tt{assoc} library to represent association tables.
        (Manuel Carro, Pablo Chico)
      @item New @tt{regexp} library to handle regular expressions.
        (Manuel Carro, Pablo Chico)
      @item Fixed bug in string_to_number that affected ASCII to
        floating point number conversions (@pred{number_codes/2}
        and bytecode read). (Jose Morales)
      @item @tt{system.pl}: Added predicates @pred{copy_file/2} and
        @pred{copy_file/3}. Added predicates @pred{get_uid/1},
        @pred{get_gid/1}, @pred{get_pwnam/1}, @pred{get_grnam/1}
        implemented natively to get default user and groups of the
        current process. (Edison Mera)
      @item Added library for mutable variables. (Remy Haemmerle)
      @item Added package for block declarations (experimental). (Remy
        Haemmerle)
      @item Ported CHR as a Ciao package (experimental). (Tom
        Schrijvers)
      @item Debugged and improved performance of the CHR library port.
        (Remy Haemmerle)
      @item @tt{contrib/math}: A library with several math functions
        that depends on the GNU Scientific Library (GSL). (Edison
        Mera)
      @item @tt{io_aux.pl}: Added @pred{messages/1}
        predicate. Required to facilitate printing of compact
        messages (compatible with emacs). (Edison Mera)
      @item Added library @tt{hrtimer.pl} that allow us to measure the
        time using the higest resolution timer available in the
        current system. (Edison Mera)
      @item Global logical (backtrackable) variables (experimental).
        (Jose Morales)
      @item New dynamic handling (@tt{dynamic_clauses} package).  Not
        yet documented. (Daniel Cabeza)
      @item Moved @tt{\=} from @tt{iso_misc} to
        @tt{term_basic}. (Daniel Cabeza)
      @item @tt{lib/lists.pl}: Added predicate
        @pred{sequence_to_list/2}. (Daniel Cabeza)
      @item @tt{lib/lists.pl}: Codification of @pred{subordlist/2}
        improved.  Solutions are given in other order. (Daniel
        Cabeza)
      @item @tt{lib/filenames.pl}: Added
        @pred{file_directory_base_name/3}. (Daniel Cabeza)
      @item @tt{library/symlink_locks.pl}: preliminary library to make
        locks a la emacs. (Daniel Cabeza)
      @item @tt{lib/between.pl}: Bug in @tt{between/3} fixed: when the
        low bound was a float, an smaller integer was
        generated. (Daniel Cabeza)
      @item Fixed bug related to implication operator @tt{->} in Fuzzy
        Prolog (Claudio Vaucheret)
      @item @tt{contrib/gendot}: Generator of dot files, for drawing graphs
        using the dot tool. (Claudio Ochoa)
      @item Addded @tt{zeromq} library (bindings for the Zero Message
        Queue (ZeroMQ, 0MQ) cross-platform messaging middleware)
        (Dragan Ivanovic)
      @item Minor documentation changes in @tt{javall} library (Jesus
        Correas)
      @item Fix a bug in calculator @tt{pl2java} example (Jesus
        Correas)
      @item @tt{lib/aggregates.pl}: Deleted duplicated clauses of
        @pred{findnsols/4}, detected by Pawel. (Daniel Cabeza)
      @item Added library to transform between color spaces (HSL and
        HVS) (experimental). (Jose Morales)
      @item Added module qualification in DCGs. (Remy Haemmerle, Jose
        Morales)
      @item @pred{prolog_sys:predicate_property/2} behaves similar to
        other Prolog systems (thanks to Paulo Moura for reporting
        this bug). (Jose Morales)
      @item Added DHT library (implementation of distributed hash
        table) (Arsen Kostenko)
      @item Adding property @tt{intervals/2} in @tt{native_props.pl}
        (for intervals information) (Luthfi Darmawan)
      @item Added code to call polynomial root finding of GSL (Luthfi
        Darmawan)
      @item Some improvements (not total, but easy to complete) to
        error messages given by errhandle.pl .  Also, some of the
        errors in @tt{sockets_c.c} are now proper exceptions
        instead of faults. (Manuel Carro)
      @item @tt{sockets} library: added a library (@tt{nsl}) needed
        for Solaris (Manuel Carro)
      @item Driver, utilities, and benchmarking programs from the ECRC
        suite.  These are aimed at testing some well-defined
        characteristics of a Prolog system. (Manuel Carro)
      @item @tt{library/getopts.pl}: A module to get command-line
        options and values. Intended to be used by Ciao
        executables. (Manuel Carro)
      @end{itemize}

   @item Improved ISO compliance:
      @begin{itemize}
      @item Ported the Prolog ISO conformance testing.
      @item Fixed read of files containing single ``@tt{%}'' char
        (reported by Ulrich Neumerkel). (Jose Morales)
      @item Added exceptions in @pred{=../2}. (Remy Haemmerle)
      @item Added exceptions in arithmetic predicates. (Remy
        Haemmerle)
      @item Arithmetics integer functions throw exceptions when used
        with floats. (Remy Haemmerle)
      @item Added exceptions for resource errors. (Remy Haemmerle)
      @end{itemize}

   @item Improvements to constraint solvers:
      @begin{itemize}
      @item Improved CLPQ documentation. (Manuel Hermenegildo)
      @item Added clp_meta/1 and clp_entailed/1 to the clpq and clpr
        packages (Samir Genaim):
        @begin{itemize}
        @item @tt{clp_meta/1}: meta-programming with clp constraints,
              e.g, @tt{clp_meta([A.>.B,B.>.1])}.
        @item @tt{clp_entailed/1}: checks if the store entails
              specific cnstraints, e.g, @tt{clp_entailed([A.>.B])}
              succeeds if the current store entailes @tt{A.>.B},
              otherwise fails.
        @end{itemize}
      @item Exported the simplex predicates from CLP(Q,R). (Samir Genaim)
      @end{itemize}

   @item Other language extensions:
      @begin{itemize}
      @item Added new @tt{bf/bfall} package. It allows running all
        predicates in a given module in breadth-first mode without
        changing the syntax of the clauses (i.e., no @tt{<-}
        needed). Meant basically for experimentation and,
        specially, teaching pure logic programming.  (Manuel
        Hermenegildo)
      @item Added @tt{afall} package in the same line as @tt{bf/bfall}
        (very useful!). (Manuel Hermenegildo)
      @item Improved documentation of @tt{bf} and @tt{af}
        packages. (Manuel Hermenegildo)
      @item Added partial commons-style dialect support, including
        dialect flag. (Manuel Hermenegildo)
      @item @tt{yap_compat} and @tt{commons_compat} compatibility
        packages (for Yap and Prolog Commons dialects). (Jose
        Morales)
      @item @tt{argnames} package: enhanced to allow argument name
        resolution at runtime. (Jose Morales)
      @item A package for conditional compilation of code (@tt{:-
        use_package(condcomp)}). (Jose Morales)
      @end{itemize}

   @item Extensions for parallelism (And-Prolog):
      @begin{itemize}
      @item Low-level support for andprolog library has been taken out
        of the engine and moved to @tt{library/apll} in a similar
        way as the sockets library. We are planning to reduce the
        size of the actual engine further, by taking some
        components out of engine, such as locks, in future
        releases. (Amadeo Casas)
      @item Improved support for deterministic parallel goals,
        including some bug fixes. (Amadeo Casas)
      @item Goal stack definition added to the engine. (Amadeo Casas)
      @item And-parallel code and the definition of goal stacks in the
        engine are now wrapped with conditionals (via
        @tt{AND_PARALLEL_EXECUTION} variable), to avoid the
        machinery necessary to run programs in parallel affects in
        any case the sequential execution. (Amadeo Casas)
      @item Stack expansion supported when more than one agent is
        present in the execution of parallel deterministic
        programs. This feature is still in experimental. Support
        for stack expansion in nondeterministic benchmarks will be
        added in a future release. (Amadeo Casas)
      @item Support for stack unwinding in deterministic parallel
        programs, via @tt{metachoice}/@tt{metacut}. However,
        garbage collection in parallel programs is still
        unsupported. We are planning to include support for it in
        a future release. (Amadeo Casas)
      @item Backward execution of nondeterministic parallel goals made
        via events, without speculation and continuation
        join. (Amadeo Casas)
      @item Improved agents support. New primitives included that aim
        at increasing the flexibility of creation and management
        of agents. (Amadeo Casas)
      @item Agents synchronization is done now by using locks, instead
        of using @tt{assertz}/@tt{retract}, to improve efficiency
        in the execution of parallel programs. (Amadeo Casas)
      @item Optimized version of @tt{call/1} to invoke deterministic
        goals in parallel has been added
        (@tt{call_handler_det/1}). (Amadeo Casas)
      @item Optimization: locks/@tt{new_atom} only created when the
        goal is stolen by other process, and not when this is
        pushed on to the @tt{goal_stack}. (Amadeo Casas)
      @item Integration with the new annotation algorithms supported
        by CiaoPP, both with and without preservation of the order
        of the solutions. (Amadeo Casas)
      @item New set of examples added to the @tt{andprolog}
        library. (Amadeo Casas)
      @item Several bug fixes to remove some cases in execution of
        parallel code in which races could appear. (Amadeo Casas)
      @item @tt{andprolog_rt:&} by @tt{par_rt:&} have been moved to
        @tt{native_builtin} (Amadeo Casas)
      @item @tt{indep/1} and @tt{indep/2} have been moved to
        @tt{native_props}, as @tt{ground/1}, @tt{var/1},
        etc. (Amadeo Casas)
      @item Added assertions to the @tt{library/apll} and
        @tt{library/andprolog} libraries. (Amadeo Casas)
      @item Removed clauses in @tt{pretty_print} for the @tt{&>/2} and
        @tt{<&/1} operators. (Amadeo Casas)
      @item Shorter code for @tt{<& / 1} and @tt{<&! / 1} (Manuel
        Carro)
      @item Trying to solve some problems when resetting WAM pointers
        (Manuel Carro)
      @item Better code to clean the stacks (Manuel Carro)
      @end{itemize}

   @item Improvements to foreign (C language) interface:
      @begin{itemize}
      @item Better support for cygwin and handling of dll libraries in
        Windows.  Now usage of external dll libraries are supported
        in Windows under cygwin. (Edison Mera)
      @item Improvements to documentation of foreign interface (examples).
        (Manuel Hermenegildo)
      @item Allow reentrant calls from Prolog to C and then from C to
        Prolog. (Jose Morales)
      @item Fix bug that prevented @tt{ciaoc -c MODULE} from generating
        dynamic @tt{.so} libraries files. (Jose Morales)
      @item Fix bug that prevented @tt{ciaoc MODULE && rm MODULE && ciaoc
        MODULE} from emitting correct executables (previously,
        dynamic @tt{.so} libraries files where ignored in executable
        recompilations when only the main file was missing). (Jose
        Morales)
      @end{itemize}

   @item Run-Time Checking and Unit Tests:
      @begin{itemize}
      @item Added support to perfom run-time checking of assertions
        and predicates outside @apl{ciaopp} (see the documentation
        for more details).  In addition to those already
        available, the new properties that can be run-time checked
        are: @tt{exception/1}, @tt{exception/2},
        @tt{no_exception/1}, @tt{no_exception/2},
        @tt{user_output/2}, @tt{solutions/2},
        @tt{num_solutions/2}, @tt{no_signal/1}, @tt{no_signal/2},
        @tt{signal/1}, @tt{signal/2}, @tt{signals/2},
        @tt{throws/2}.  See library
        @tt{assertions/native_props.pl} (Edison Mera)
      @item Added support for testing via the @lib{unittest} library.
        Documentation available at
        @tt{library(unittest/unittest)}. (Edison Mera)
      @end{itemize}

   @item Profiling:
      @begin{itemize}
      @item Improved profiler, now it is cost center-based and works
        together with the run-time checking machinery in order to
        also validate execution time-related properties. (Edison
        Mera)
      @item A tool for automatic bottleneck detection has been
        developed, which is able to point at the predicates
        responsible of lack of performance in a program. (Edison
        Mera)
      @item Improved profiler documentation. (Manuel Hermenegildo)
      @end{itemize}

   @item Debugger enhancements:
      @begin{itemize}
      @item Added the flag @tt{check_cycles} to control whether the
        debugger takes care of cyclic terms while displaying
        goals.  The rationale is that to check for cyclic terms
        may lead to very high response times when having big
        terms.  By default the flag is in off, which implies that
        a cyclic term in the execution could cause infinite loops
        (but otherwise the debugger is much more speedy). (Daniel
        Cabeza)
      @item Show the variable names instead of underscores with
        numbers.  Added option @tt{v} to show the variables
        list. Added @tt{v <N>} option, where @tt{N} is the
        @tt{Name} of the variable you like to watch
        (experimental). (Edison Mera)
      @item Distinguish between program variables and
        compiler-introduced variables. Show variables modified in
        the current goal. (Edison Mera)
      @item @tt{debug_mode} does not leave useless choicepoints (Jose
        Morales)
      @end{itemize}

   @item Emacs mode:
      @begin{itemize}
      @item Made ciao mode NOT ask by default if one wants to set up
        version control when first saving a file. This makes more
        sense if using other version control systems and probably
        in any case (several users had asked for this). There is a
        global customizable variable (which appears in the LPdoc
        area) which can be set to revert to the old behaviour.
        Updated the manual accordingly. (Manuel Hermenegildo)
      @item Added possibility of chosing which emacs Ciao should use
        during compilation, by LPdoc, etc. Previously only a
        default emacs was used which is not always the right
        thing, specially, e.g., in Mac OS X, where the
        latest/right emacs may not even be in the paths. Other
        minor typos etc. (Manuel Hermenegildo)
      @item Moved the version control menu entries to the LPdoc
        menu. (Manuel Hermenegildo)
      @item Updated highlighting for new functional syntax, unit
        tests, and all other new features. (Manuel Hermenegildo)
      @item Completed CiaoPP-java environment (menus, buttons, etc.)
        and automated loading when visiting Java files (still
        through hand modification of .emacs).  CiaoPP help (e.g.,
        for properties) now also available in Java mode.  (Manuel
        Hermenegildo)
      @item Changes to graphical interface to adapt better to current
        functionality of CiaoPP option browser.  Also some minor
        aesthetic changes. (Manuel Hermenegildo)
      @item Various changes and fixes to adapt to emacs-22/23 lisp. In
        particular, fixed cursor error in emacs 23 in Ciao shell
        (from Emilio Gallego). Also fixed prompt in ciaopp and
        LPdoc buffers for emacs 23. (Manuel Hermenegildo)
      @item Unified several versions of the Ciao emacs mode (including
        the one with the experimental toolbar in xemacs) that had
        diverged. Sorely needed to be able to make progress
        without duplication. (Manuel Hermenegildo)
      @item New version of ciao.el supporting tool bar in xemacs and
        also, and perhaps more importantly, in newer emacsen (>=
        22), where it previously did not work either. New icons
        with opaque background for xemacs tool bar. (Manuel
        Hermenegildo)
      @item Using @tt{key-description} instead of a combination of
        @tt{text-char-description} and @tt{string-to-char}.  This
        fixes a bug in the Ciao Emacs Mode when running in emacs
        23, that shows wrong descriptions for @tt{M-...} key
        bindings. The new code runs correctly in emacs 21 and
        22. (Jose Morales)
      @item Coloring strings before functional calls and @tt{0'}
        characters (strings like @tt{\"~w\"} were colored
        incorrectly) (Jose Morales)
      @item @tt{@@begin@{verbatim@}} and @tt{@@include} colored as
        LPdoc commands only inside LPdoc comments. (Jose Morales)
      @item Fixed colors for dark backgrounds (workaround to avoid a
        bug in emacs) (Jose Morales)
      @item Added an automatic indenter (contrib/plindent) and
        formatting tool, under emacs you can invoque it using the
        keyword @tt{C-c I} in the current buffer containing your
        prolog source. (Edison Mera)
      @end{itemize}

   @item Packaging and distribution:
      @begin{itemize}
      @item User-friendly, binary installers for several systems are
        now generated regularly and automatically: Ubuntu/Debian,
        Fedora/RedHat, Windows (XP, Vista, 7) and MacOSX. (Edison
        Mera, Remy Haemmerle)
      @end{itemize}

   @item Improvements in Ciao toplevel:
      @begin{itemize}
      @item Introduced @tt{check_cycles} @tt{prolog_flag} which
        controls whether the toplevel handles or not cyclic terms.
        Flag is set to false by default (cycles not detected and
        handled) in order to speed up responses. (Daniel Cabeza)
      @item Modified @pred{valid_solution/2} so that it asks no
        question when there are no pending choice points and the
        @tt{prompt_alternatives_no_bindings} prolog flag is
        on. (Jose Morales)
      @item Now 'Y' can be used as well as 'y' to accept a solution of a
        query. (Daniel Cabeza)
      @item Added newline before @tt{true} when displaying empty
        solutions. (Jose Morales)
      @item Multifile declarations of packages used by the toplevel were
        not properly handled.  Fixed. (Daniel Cabeza)
      @item Fixed bug in output of bindings when current output
        changed.
      @item Changes so that including files in the toplevel (or loading
        packages) does not invoke an expansion of the ending
        end_of_file.  This makes sense because the toplevel code is
        never completed, and thus no cleanup code of translations is
        invoked. (Daniel Cabeza)
      @end{itemize}

   @item Compiler enhancements and bug fixes:
      @begin{itemize}
      @item Added a command line option to @tt{ciaoc} for generating code
        with runtime checks. (Daniel Cabeza)
      @item Now the compiler reads assertions by default (when using the
        assertion package), and verifies their syntax. (Edison Mera)
      @item Added option @tt{-w} to @tt{ciaoc} compiler to generate the
        WAM code of the specified prolog files. (Edison Mera)
      @item Fixed bug in exemaker: now when
        @pred{main/0} and @pred{main/1} exists, @pred{main/0} is
        always the program entry (before in modules either could
        be). (Daniel Cabeza)
      @item Fixed bug: when compiling a file, if an imported file had no
        itf and it used the redefining declaration, the declaration was
        forgotten between the reading of the imported file (to get
        its interface) and its later compilation.  By now those
        declarations are never forgotten, but perhaps it could be
        done better. (Daniel Cabeza)
      @item The unloading of files kept some data related to them, which
        caused in some cases errors or warnings regarding module
        redefinitions.  Now this is fixed. (Daniel Cabeza)
      @item Undefined predicate warnings also for predicate calls
        qualified with current module (bug detected by Pawel
        Pietrzak). (Daniel Cabeza)
      @item Fixed bug @tt{debugger_include} (that is, now a change in a
        file included from a module which is debugged is detected
        when the module is reloaded). (Daniel Cabeza)
      @item Fixed @tt{a(B) :- _=B, b, c(B)} bug in compilation of
        unification. (Jose Morales)
      @end{itemize}

   @item Improving general support for language extensions:
      @begin{itemize}
      @item Every package starts with '@tt{:- package(...)}' declaration
        now.  This allows a clear distinction between packages,
        modules, and files that are just included; all of them using
        the same @tt{.pl} extension. (Jose Morales)
      @item Added priority in syntax translations. Users are not required
        to know the details of translations in order to use them
        (experimental: the the correct order for all the Ciao
        packages is still not fixed) (Jose Morales)
      @item Now the initialization of sentence translations is done in
        the translation package, when they are added.  In this way,
        previous active translations cannot affect the initialization
        of new translations, and initializations are not started each
        time a new sentence translation is added.  Additionally, now
        the initialization of sentence translations in the toplevel
        is done (there was a bug). (Daniel Cabeza)
      @item Added @tt{addterm(Meta)} meta-data specification for the
        implementation of the changes to provide a correct
        @pred{clause/2} predicate. (Daniel Cabeza)
      @item Generalized @tt{addmodule} meta-data specification to
        @tt{addmodule(Meta)}, @tt{addmodule} is now an alias for
        @tt{addmodule(?)}.  Needed for the implementation of the
        changes to provide a correct @pred{clause/2}
        predicate. (Daniel Cabeza)
      @end{itemize}

   @item Improvements to system assertions:
      @begin{itemize}
      @item Added regtype @pred{basic_props:num_code/1} and more
        assertions to @tt{basic_props.pl} (German Puebla)
      @item Added trust assertion for
        @pred{atomic_basic:number_codes/2} in order to have more
        accurate analysis info (first argument a number and second
        argument is a list of num_codes) (German Puebla)
      @item Added some more binding insensitivity assertions in
        @tt{basic_props.pl} (German Puebla)
      @item Added the @pred{basic_props:filter/2} property which is
        used at the global control level in order to guarantee
        termination. (German Puebla)
      @item Added @tt{equiv} assertion for @pred{basiccontrol:fail/0}
        (German Puebla)
      @item Modified eval assertion so that partial evaluation does
        not loop with ill-typed, semi-instantiated calls to
        @pred{is/2} (this problem was reported some time ago)
        (German Puebla)
      @item Replaced @tt{true} assertions for arithmetic predicates
        with @tt{trust} assertions (@tt{arithmetic.pl}). (German
        Puebla)
      @item Added assertions for @pred{term_basic:'\='/2} (the @em{not
        unification}) (German Puebla)
      @item Added assertions for @pred{lists:nth/3} predicate and
        @pred{lists:reverse/3}. (German Puebla)
      @item Changed calls to @pred{atom/1} to @pred{atm/1} in
        @pred{c_itf_props:moddesc/1} (it is a regular type) (Jesus
        Correas)
      @item @pred{formulae:assert_body_type/1} switched to @tt{prop},
        it is not a @tt{regtype}. (Jesus Correas)
      @item Added assertions to @pred{atom_concat/2}. (Jesus Correas)
      @item Added some assertions to @tt{dec10_io}, @tt{lists},
        @tt{strings} libraries. (Jesus Correas)
      @item Removed @tt{check} from pred and success froom many
        library assertions. (Jesus Correas)
      @item Fixed a problem when reading multiple disjunction in
        assertions (@tt{library/formulae.pl} and
        @tt{lib/assertions/assrt_write.pl}). (Pawel Pietrzak)
      @item Added/improved assertions in several modules under
        @tt{lib/} (Pawel Pietrzak)
      @end{itemize}

   @item Engine enhancements:
      @begin{itemize}
      @item Added support for Ciao compilation in @tt{ppc64}
        architecture. (Manuel Carro)
      @item @tt{sun4v} added in @tt{ciao_get_arch}. (Amadeo Casas)
      @item Solved compilation issue in Sparc. (Manuel Carro, Amadeo
        Casas)
      @item Support for 64 bits Intel processor (in 32-bit compatibility
        mode). (Manuel Carro)
      @item Switched the default memory manager from linear to the binary
        tree version (which improves management of small memory
        blocks). (Remy Haemmerle)
      @item Using @tt{mmap} in Linux/i86, Linux/Sparc and Mac OS X
        (Manuel Carro)
      @item A rename of the macro @tt{REGISTER} to @tt{CIAO_REGISTER}.
        There have been reports of the macro name clashing with an
        equally-named one in third-party packages (namely, the PPL
        library). (Manuel Carro)
      @item A set of macros @tt{CIAO_REG_n} (@tt{n} currently goes from
        @tt{1} to @tt{4}, but it can be enlarged) to force the GCC
        compiler to store a variable in a register.  This includes
        assignments of hardware registers for @tt{n = 1} to @tt{3},
        in seemingly ascending order of effectiveness.  See coments
        in registers.h (Manuel Carro)
      @item An assignement of (local) variables to be definitely stored
        in registers for some (not all) functions in the engine --
        notably @tt{wam.c}.  These were decided making profiling of C
        code to find out bottlenecks and many test runs with
        different assignments of C variables to registers. (Manuel
        Carro)
      @item Changed symbol name to avoid clashes with other third-party
        packages (such as minisat). (Manuel Carro)
      @item Fixed a memory alignment problem (for RISC architectures
        where words must be word-aligned, like Sparc). (Jose Morales)
      @item Unifying some internal names (towards merge with optim_comp
        experimental branch). (Jose Morales)
      @end{itemize}

   @item Attributed variables:
      @begin{itemize}
      @item Attributes of variables are correctly displayed in the
        toplevel even if they contain cyclic terms.  Equations added
        in order to define cyclic terms in attributes are output
        after the attributes, and do use always new variable names
        (doing otherwise was very involved). (Daniel Cabeza)
      @item @tt{lib/attrdump.pl}: The library now works for infinite
        (cyclic) terms. (Daniel Cabeza)
      @item Changed multifile predicate @pred{dump/3} to
        @pred{dump_constraints/3}. (Daniel Cabeza)
      @item Added @pred{copy_extract_attr_nc/3} which is a faster version
        of @pred{copy_extract_attr/3} but does not handle cyclic
        terms properly. (Daniel Cabeza)
      @item Added @pred{term_basic:copy_term_nat/2} to copy a term
        taking out attributes. (Daniel Cabeza)
      @end{itemize}

   @item Documentation:
      @begin{itemize}
      @item Added @tt{deprecated/1}. (Manuel Hermenegildo)
      @item Improvements to documentation of @tt{rtchecks} and
        tests. (Manuel Hermenegildo)
      @item Many updates to manuals: dates, copyrights, etc. Some text
        updates also. (Manuel Hermenegildo)
      @item Fixed all manual generation errors reported by LPdoc
        (still a number of warnings and notes left). (Manuel
        Hermenegildo)
      @item Adding some structure (minor) to all manuals (Ciao, LPdoc,
        CiaoPP) using new LPdoc @tt{doc_structure/1}. (Jose
        Morales)
      @end{itemize}

   @item Ciao Website:
      @begin{itemize}
      @item Redesigned the Ciao website. It is generated again through
        LPdoc, but with new approach. (Jose Morales)
      @end{itemize}
   @end{itemize}
").

% note: approximate release date (r7508)
:- doc(version(1*10+8,2007/01/28,18:01*27+'CEST'), "
   Backports and bug fixes to stable 1.10:
   @begin{itemize}
   @item Changes to make Ciao 1.10 compile with the latest GCC
     releases.
   @item Imported from
     @tt{CiaoDE/branches/CiaoDE-memory_management-20051016},
     changes from revisions 4909 to 4910: Changes to make Ciao
     issue a better message at startup if the allocated memory
     does not fall within the limits precomputed at compile time
     (plus some code tidying).
   @item Port of revisions 5415, 5426, 5431, 5438, 5546, 5547 applied
     to Ciao 1.13 to Ciao 1.10 in order to make it use @tt{mmap()}
     when possible and to make it compile on newer Linux kernels.
     Tested in Ubuntu, Fedora (with older kernel) and MacOSX.
   @item Configuration files for DARWIN (ppc) and 64-bit platforms
     (Intel and Sparc, both in 32-bit compatibility mode).
   @item Force the creation of the module containing the foreign
     interface compilation options before they are needed.
   @end{itemize}
").

:- doc(version(1*13+0,2005/07/03,19:05*53+'CEST'), "New development
   version after 1.12. (Jose Morales)").

:- doc(version(1*12+0,2005/07/03,18:50*50+'CEST'), "Temporary version
   before transition to SVN. (Jose Morales)").

% :- doc(version(1*11+247,2004/07/02,13:27*33+'CEST'), "Improved
%    front cover (old authors are now listed as editors, mention UNM,
%    new TR number including system version, pointer to
%    @tt{www.ciaohome.org}, mention multi-paradigm, etc.). Also changed
%    mention of GPL in summary to LGPL.  (Manuel Hermenegildo)").

:- doc(version(1*11+1,2003/04/04,18:30*31+'CEST'), "New
   development version to begin the builtin modularization (Jose
   Morales)").

% :- doc(version(1*10+1,2003/04/04,18:29*07+'CEST'), "Version
%    skipped (Jose Morales)").

% TODO: (pre SVN) missing notes from 1.10.0 to 1.10.7

:- doc(version(1*10+0,2004/07/29,16:12*03+'CEST'), "
   @begin{itemize}
   @item Classical prolog mode as default behavior.
   @item Emacs-based environment improved.
      @begin{itemize}
      @item Improved emacs inferior (interaction) mode for Ciao and CiaoPP.
      @item Xemacs compatibility improved (thanks to A. Rigo).
      @item New icons and modifications in the environment for the 
        preprocessor.
      @item Icons now installed in a separate dir.          
      @item Compatibility with newer versions of @apl{Cygwin}.
      @item Changes to programming environment:
        @begin{itemize}
        @item Double-click startup of programming environment. 
        @item Reorganized menus: help and customization grouped in 
              separate menus.
        @item Error location extended.
        @item Automatic/Manual location of errors produced when 
              running Ciao tools now customizable.
        @item Presentation of CiaoPP preprocessor output improved.
        @end{itemize}
      @item Faces and coloring improved:
        @begin{itemize}
        @item Faces for syntax-based highlighting more customizable.
        @item Syntax-based coloring greatly
              improved. Literal-level assertions also correctly
              colored now.
        @item Syntax-based coloring now also working on ASCII
              terminals (for newer versions of emacs).
        @item Listing user-defined directives allowed to be colored in
              special face.
        @item Syntax errors now colored also in inferior buffers.
        @item Customizable faces now appear in the documentation.
        @item Added new tool bar button (and binding) to refontify
              block/buffer.
        @item Error marks now cleared automatically also when 
              generating docs.
        @item Added some fixes to hooks in lpdoc buffer.
        @end{itemize}  
      @end{itemize}
   @item Bug fixes in compiler.
      @begin{itemize}
      @item Replication of clauses in some cases (thanks to S. Craig).
      @end{itemize} 

   @item Improvements related to supported platforms
      @begin{itemize}
      @item Compilation and installation in different palatforms have been 
        improved.
      @item New Mac OS X kernels supported.
      @end{itemize}

   @item Improvement and bugs fixes in the engine:
      @begin{itemize}
      @item Got rid of several segmentation violation problems.
      @item Number of significant decimal digits to be printed now computed 
        accurately.
      @item Added support to test conversion of a Ciao integer into a machine 
        int.
      @item Unbound length atoms now always working.
      @item C interface .h files reachable through a more standard location 
        (thanks to R. Bagnara).
      @item Compatibility with newer versions of gcc.
      @end{itemize}

   @item New libraries and utilities added to the system:
      @begin{itemize}
      @item Factsdb: facts defined in external files can now be automatically 
        cached on-demand.
      @item Symfnames: File aliasing to internal streams added.
      @end{itemize}

   @item New libraries added (in beta state):
      @begin{itemize}
      @item fd: clp(FD)
      @item xml_path: XML querying and transformation to Prolog.
      @item xdr_handle: XDR schema to HTML forms utility.
      @item ddlist: Two-way traversal list library.
      @item gnuplot: Interface to GnuPlot.
      @item time_analyzer: Execution time profiling.
      @end{itemize}

   @item Some libraries greatly improved:
      @begin{itemize}
      @item Interface to Tcl/Tk very improved. 
      @begin{itemize}
      @item Corrected many bugs in both interaction Prolog to
            Tcl/Tk and viceversa.
      @item Execution of Prolog goals from TclTk revamped.
      @item Treatment of Tcl events corrected.
      @item Predicate  @pred{tcl_eval/3} now allows the execution of Tcl 
            procedures running multiple Prolog goals.
      @item Documentation heavily reworked.
      @item Fixed unification of prolog goals run from the Tcl side.
      @end{itemize}
      @item Pillow library improved in many senses.
      @begin{itemize}
      @item HTTP media type parameter values returned are always strings 
            now, not atoms. 
      @item Changed verbatim() pillow term so that newlines are translated 
            to <br>.
      @item Changed management of cookies so that special characters in 
            values are correctly handled. 
      @item Added predicate @pred{url_query_values/2}, reversible. 
            Predicate @pred{url_query/2} now obsolete.
      @item Now attribute values in tags are escaped to handle values 
            which have double quotes.
      @item Improved @pred{get_form_input/1} and @pred{url_query/2} so 
            that names of parameters having unusual characters are always 
            correctly handled.
      @end{itemize}
      @item Fixed bug in tokenizer regarding non-terminated single or 
        multiple-line comments.  When the last line of a file has a 
        single-line comment and does not end in a newline, it is accepted 
        as correct.  When an open-comment /* sequence is not terminated in 
        a file, a syntax error exception is thrown.
      @end{itemize}

   @item Other libraries improved:
      @begin{itemize}
      @item Added native_props to assertions package and included
        @pred{nonground/1}.
      @item In atom2terms, changed interpretation of double quoted strings so 
        that they are not parsed to terms.
      @item Control on exceptions improved.
      @item Added @pred{native/1,2} to basic_props.
      @item Davinci error processing improved.
      @item Foreign predicates are now automatically declared as 
        implementation-defined.
      @item In lists, added @pred{cross_product/2} to compute the cartesian 
        product of a list of lists. Also added 
        @pred{delete_non_ground/3}, enabling deletion of nonground terms 
        from a list. 
      @item In llists added @pred{transpose/2} and changed @pred{append/2} 
        implementation with a much more efficient code. 
      @item The make library has been improved.
      @item In persdb, added @pred{pretractall_fact/1} and 
        @pred{retractall_fact/1} as persdb native capabilities. 
      @item Improved behavior with user environment from persdb.
      @item In persdb, added support for @pred{persistent_dir/4},
        which includes arguments to specify permission modes for
        persistent directory and files.
      @item Some minor updates in persdb_sql.
      @item Added treatment of operators and module:pred calls to
        pretty-printer.
      @item Updated report of read of syntax errors.
      @item File locking capabilities included in @pred{open/3}.
      @item Several improvements in library system.
      @item New input/output facilities added to sockets.
      @item Added @pred{most_specific_generalization/3} and 
        @pred{most_general_instance/3} to terms_check.
      @item Added @pred{sort_dict/2} to library vndict.
      @item The xref library now treats also empty references.
      @end{itemize}

   @item Miscellaneous updates:
      @begin{itemize}
      @item Extended documentation in libraries actmods, arrays, 
        foreign_interface, javall, persdb_mysql, prolog_sys, old_database, 
        and terms_vars.
      @end{itemize}
   @end{itemize}").

% :- doc(version(1*9+355,2004/07/02,13:28*02+'CEST'), "Improved
%    front cover (old authors are now listed as editors, mention UNM,
%    new TR number including system version, pointer to
%    @tt{www.ciaohome.org}, mention multi-paradigm, etc.). Also changed
%    mention of GPL in summary to LGPL.  (Manuel Hermenegildo)").

% :- doc(version(1*9+38,2002/12/12,20:06*26+'CET'), "Manual now
%    posted in pdf format (since lpdoc now generates much better pdf).
%    (Manuel Hermenegildo)").

% :- doc(version(1*9+34,2002/11/30,14:42*45+'CET'), "Installation
%    can now be done in Test distribution directory (for testing
%    purposes).  (Manuel Hermenegildo)").

% :- doc(version(1*9+33,2002/11/30,14:37*10+'CET'), "Modified
%    installation site text to make more explicit the fact that we
%    support Mac OS X and XP.  (Manuel Hermenegildo)").

:- doc(version(1*9+0,2002/05/16,23:17*34+'CEST'), " New
   development version after stable 1.8p0 (MCL, DCG)").

% TODO: (pre SVN) missing notes from 1.8.0 to 1.8.3

:- doc(version(1*8+0,2002/05/16,21:20*27+'CEST'), "
   @begin{itemize}
   @item Improvements related to supported platforms:
       @begin{itemize}
       @item Support for Mac OS X 10.1, based on the Darwin kernel.
       @item Initial support for compilation on Linux for Power PC
         (contributed by @author{Paulo Moura}).
       @item Workaround for incorrect C compilation while using newer
         (> 2.95) gcc compilers.
       @item .bat files generated in Windows.
       @end{itemize}
   
   @item Changes in compiler behavior and user interface:
       @begin{itemize}
       @item Corrected a bug which caused wrong code generation in some cases.
       @item Changed execution of initialization directives.  Now the
         initialization of a module/file never runs before the
         initializations of the modules from which the module/file
         imports (excluding circular dependences).
       @item The engine is more intelligent when looking for an engine
         to execute bytecode; this caters for a variety of
         situations when setting explicitly the CIAOLIB
         environment variable.
       @item Fixed bugs in the toplevel: behaviour of @tt{module:main}
         calls and initialization of a module (now happens after
         related modules are loaded).
       @item Layout char not needed any more to end Prolog files.
       @item Syntax errors now disable .itf creation, so that they
         show next time the code is used without change.
       @item Redefinition warnings now issued only when an unqualified call
         is seen. 
       @item Context menu in Windows can now load a file into the toplevel.
       @item Updated Windows installation in order to run CGI
         executables under Windows: a new information item is
         added to the registry.
       @item Added new directories found in recent Linux distributions to
         INFOPATH. 
       @item Emacs-based environment and debugger improved:
       @begin{itemize}
       @item Errors located immediataly after code loading.
       @item Improved ciao-check-types-modes (preprocessor progress
             now visible). 
       @item Fixed loading regions repeatedly (no more predicate
             redefinition warnings).
       @item Added entries in @apl{ciaopp} menu to set verbosity of output.
       @item Fixed some additional xemacs compatibility issues
             (related to searches). 
       @item Errors reported by inferior processes are now
             explored in forward order (i.e., the first error
             rewported is the first one highlighted). Improved
             tracking of errors.
       @item Specific tool bar now available, with icons for main
             fuctions (works from emacs 21.1 on). Also, other
             minor adaptations for working with emacs 21.1 and
             later.
       @item Debugger faces are now locally defined (and better
             customization). This also improves comtability with xemacs
             (which has different faces).
       @item Direct access to a common use of the preprocessor
             (checking modes/types and locating errors) from toolbar.
       @item Inferior modes for Ciao and CiaoPP improved: contextual
             help turned on by default.
       @item Fixes to set-query. Also, previous query now appears
             in prompt.
       @item Improved behaviour of stored query.
       @item Improved behaviour of recentering, finding errors, etc.
       @item Wait for prompt has better termination characteristics.
       @item Added new interactive entry points (M-x): ciao,
             prolog, ciaopp.
       @item Better tracking of last inferior buffer used.
       @item Miscellanous bugs removed; some colors changed to
             adapt to different Emacs versions.
       @item Fixed some remaining incompatibilities with xemacs.
       @item @tt{:- doc} now also supported and highlighted.
       @item Eliminated need for calendar.el
       @item Added some missing library directives to fontlock
             list, organized this better.
       @end{itemize}
       @end{itemize}
   
   @item New libraries added to the system:
       @begin{itemize}
       @item hiord: new library which needs to be loaded in order to use
           higher-order call/N and P(X) syntax. Improved model for predicate
           abstractions. 
       @item fuzzy: allows representing fuzzy information in the form or
           Prolog rules.
       @item use_url: allows loading a module remotely by using a WWW
           address of the module source code
       @item andorra: alternative search method where goals which become
           deterministic at run time are executed before others.
       @item iterative deepening (id): alternative search method which makes a
           depth-first search until a predetermined depth is reached.
           Complete but in general cheaper than breadth first.
       @item det_hook: allows making actions when a deterministic
           situation is reached.
       @item ProVRML: read VRML code and translate it into Prolog terms,
           and the other way around.
       @item io_alias_redirection: change where stdin/stdout/stderr point to
           from within Ciao programs.
       @item tcl_tk: an interface to Tcl/Tk programs.
       @item tcl_tk_obj: object-based interface to Tcl/Tk graphical
       objects.
       @item CiaoPP: options to interface with the CiaoPP Prolog preprocessor.
       @end{itemize}
   
   @item Some libraries greatly improved:
       @begin{itemize}
       @item WebDB: utilities to create WWW-based database interfaces.
       @item Improved java interface implementation (this forced
         renaming some interface primitives). 
       @item User-transparent persistent predicate database revamped:
       @begin{itemize}
       @item Implemented passerta_fact/1 (asserta_fact/1).
       @item Now it is never necessary to explicitly call
             init_persdb, a call to initialize_db is only needed
             after dynamically defining facts of persistent_dir/2.
             Thus, pcurrent_fact/1 predicate eliminated.
       @item Facts of persistent predicates included in the
             program code are now included in the persistent
             database when it is created.  They are ignored in
             successive executions.
       @item Files where persistent predicates reside are now
             created inside a directory named as the module where
             the persistent predicates are defined, and are named
             as F_A* for predicate F/A.
       @item Now there are two packages: persdb and 'persdb/ll'
             (for low level).  In the first, the standard builtins
             asserta_fact/1, assertz_fact/1, and retract_fact/1
             are replaced by new versions which handle persistent
             data predicates, behaving as usual for normal data
             predicates.  In the second package, predicates with
             names starting with 'p' are defined, so that there is
             not overhead in calling the standard builtins.
       @item Needed declarations for persistent_dir/2 are now
             included in the packages.
       @end{itemize}
   
       @item SQL now works with mysql.
       @item system: expanded to contain more predicates which act as
         interface to the underlying system /  operating system.  
       @end{itemize}
   
   @item Other libraries improved:
       @begin{itemize}
       @item xref: creates cross-references among Prolog files.
       @item concurrency: new predicates to create new concurrent
         predicates on-the-fly.
       @item sockets: bugs corrected.
       @item objects: concurrent facts now properly recognized.
       @item fast read/write: bugs corrected.
       @item Added 'webbased' protocol for active modules: publication of
         active module address can now be made through WWW.
       @item Predicates in library(dynmods) moved to library(compiler).
       @item Expansion and meta predicates improved.
       @item Pretty printing.
       @item Assertion processing.
       @item Module-qualified function calls expansion improved.
       @item Module expansion calls goal expansion even at runtime.
       @end{itemize}
   
   @item Updates to builtins (there are a few more; these are the most
     relevant):

       @begin{itemize}
       @item Added a prolog_flag to retrieve the version and patch.
       @item current_predicate/1 in library(dynamic) now enumerates
         non-engine modules, prolog_sys:current_predicate/2 no longer
         exists.
       @item exec/* bug fixed.
       @item srandom/1 bug fixed.
       @end{itemize}
   
   @item Updates for C interface:
     @begin{itemize}
     @item Fixed bugs in already existing code.
     @item Added support for creation and traversing of Prolog data
     structures from C predicates.
     @item Added support for raising Prolog exceptions from C
     predicates. 
     @item Preliminary support for calling Prolog from C.
     @end{itemize}
   
   @item Miscellaneous updates:
     @begin{itemize}
     @item Installation made more robust.
     @item Some pending documentation added.
     @item 'ciao' script now adds (locally) to path the place where
     it has been installed, so that other programs can be located
     without being explicitly in the $PATH.
     @item Loading programs is somewhat faster now.
     @item Some improvement in printing path names in Windows.
     @end{itemize}
   @end{itemize}").

% :- doc(version(1*7+203,2002/04/20,13:38*54+'CEST'), "Minor changes
%    to Ciao description.  (Manuel Hermenegildo)").

% :- doc(version(1*7+155,2001/11/24,11:53*36+'CET'), "Minor changes
%    to installation scripts to make sure permissions are left correctly
%    if installation is aborted.  (Manuel Hermenegildo)").

% :- doc(version(1*7+154,2001/11/23,18:02*30+'CET'), "'ciao' script
%    now locally adds CIAOBIN path to PATH if not already present
%    (MCL)").

% :- doc(version(1*7+108,2001/06/02,12:17*18+'CEST'), "Minor bug in
%    main Makefile during uninstallation fixed: added rm -f of engine
%    Makefile before linking.  (Manuel Hermenegildo)").

% :- doc(version(1*7+101,2001/05/15,17:34*09+'CEST'), "Minor error
%    in manual fixed: the section explaining the Ciao name did not
%    appear.  (Manuel Hermenegildo)").

% :- doc(version(1*7+100,2001/05/13,15:48*57+'CEST'), "Added
%    @tt{/usr/share/info} to default @tt{INFOPATH} paths.  (Manuel
%    Hermenegildo)").

% :- doc(version(1*7+87,2001/04/08,15:15*18+'CEST'), "Added @tt{doc}
%    and @tt{install_doc} targets to top level installation @{Makefile}
%    (can be used to regenerate and reinstall documentation if
%    @apl{lpdoc} is available.  (Manuel Hermenegildo)").

% :- doc(version(1*7+14,2000/08/29,12:16*12+'CEST'), "Updated COMMON
%    to include makefile-sysindep; changed SETLOCAL{CIAOC,CIAOSHELL} to
%    SETLOCALCIAO (MCL)").

% :- doc(version(1*7+12,2000/08/22,18:16*33+'CEST'), "Changed a bug
%    in the installation: the .sta engine was not being copied!
%    (MCL)").

:- doc(version(1*7+0,2000/07/12,19:01*20+'CEST'), "Development
   version following even 1.6 distribution.").

% TODO: (pre SVN) missing notes from 1.6.0 to 1.6.3

:- doc(version(1*6+0,2000/07/12,18:55*50+'CEST'), "
   @begin{itemize}
   @item Source-level debugger in emacs, breakpts.
   @item Emacs environment improved, added menus for Ciaopp and LPDoc.
   @item Debugger embeddable in executables.
   @item Standalone executables available for Unix-like operating
     systems. 
   @item Many improvements to emacs interface.
   @item Menu-based interface to autodocumenter.
   @item Threads now available in Win32.
   @item Many improvements to threads.
   @item Modular clp(R) / clp(Q).
   @item Libraries implementing And-fair breadth-first and iterative
     deepening included.
   @item Improved syntax for predicate abstractions.
   @item Library of higher-order list predicates.
   @item Better code expansion facilities (macros).
   @item New delay predicates (when/2).
   @item Compressed object code/executables on demand.
   @item The size of atoms is now unbound.
   @item Fast creation of new unique atoms.
   @item Number of clauses/predicates essentially unbound.
   @item Delayed goals with freeze restored.
   @item Faster compilation and startup.
   @item Much faster fast write/read. 
   @item Improved documentation.
   @item Other new libraries.
   @item Improved installation/deinstallation on all platforms.
   @item Many improvements to autodocumenter.
   @item Many bug fixes in libraries and engine.
   @end{itemize}").

% :- doc(version(1*5+134,2000/05/09,11:52*13+'CEST'), "Changed
%    location of suite to examples, updated documentation.  (MCL)").

% :- doc(version(1*5+94,2000/03/28,23:19*20+'CEST'), "The manual
%    intro now provides an overview of the different parts of the
%    manual.  (Manuel Hermenegildo)").

:- doc(version(1*5+0,1999/11/29,16:16*23+'MEST'),"Development
   version following even 1.4 distribution.").

:- doc(version(1*4+0,1999/11/27,19:00*00+'MEST'),"
   @begin{itemize}
   @item Documentation greatly improved.
   @item Automatic (re)compilation of foreign files.
   @item Concurrency primitives revamped; restored &Prolog-like 
     multiengine capability. 
   @item Windows installation and overall operation greatly improved.
   @item New version of O'Ciao class/object library, with improved performance.
   @item Added support for ""predicate abstractions"" in call/N. 
   @item Implemented reexportation through reexport declarations.
   @item Changed precedence of importations, last one is now higher.
   @item Modules can now implicitly export all predicates.
   @item Many minor bugs fixed.
   @end{itemize}").

:- doc(version(1*3+0,1999/06/16,17:05*58+'MEST'), "Development
   version following even 1.2 distribution.").

% TODO: this version does not seem to have been distributed

:- doc(version(1*2+0,1999/06/14,16:54*55+'MEST'), "Temporary version
   distributed locally for extensive testing of reexportation and
   other 1.3 features.").

:- doc(version(1*1+0,1999/06/04,13:30*37+'MEST'), "Development
   version following even 1.0 distribution.").

% TODO: (pre SVN) missing notes from 1.0.0 to 1.0.7

:- doc(version(1*0+0,1999/06/04,13:27*42+'MEST'), "
   @begin{itemize}
   @item Added Tcl/Tk interface library to distribution.
   @item Added push_prolog_flag/2 and pop_prolog_flag/1 declarations/builtins.
   @item Filename processing in Windows improved.
   @item Added redefining/1 declaration to avoid redefining warnings.
   @item Changed syntax/1 declaration to use_package/1.
   @item Added add_clause_trans/1 declaration.
   @item Changed format of .itf files such that a '+' stands for all
     the standard imports from engine, which are included in c_itf
     source internally (from engine(builtin_exports)).  Further
     changes in itf data handling, so that once an .itf file is
     read in a session, the file is cached and next time it is
     needed no access to the file system is required.
   @item Many bugs fixed.
   @end{itemize}").

% :- doc(version(0*9+32,1999/04/05,20:38*17+'MEST'), "Improved
%    uninstallation makefiles so that (almost) nothing is left behind.
%    (Manuel Hermenegildo)").

:- doc(version(0*9+0,1999/03/10,17:03*49+'CET'), "
   @begin{itemize}
   @item Test version before 1.0 release. Many bugs fixed.
   @end{itemize}").

% Previously to 0.8, all versions where released as stable.
% TODO: (pre SVN) missing notes from 0.8.0 to 0.8.44

:- doc(version(0*8+0,1998/10/27,13:12*36+'MET'), "
   @begin{itemize}
   @item Changed compiler so that only one pass is done, eliminated @tt{.dep}
     files.
   @item New concurrency primitives.
   @item Changed assertion comment operator to #.
   @item Implemented higher-order with call/N.
   @item Integrated SQL-interface to external databases with 
     persistent predicate concept. 
   @item First implementation of object oriented programming package.
   @item Some bugs fixed.
   @end{itemize}").

% TODO: (pre SVN) missing notes from 0.7.0 to 0.7.28

:- doc(version(0*7+0,1998/09/15,12:12*33+'MEST'), "
   @begin{itemize}
   @item Improved debugger capabilities and made easier to use.
   @item Simplified assertion format.
   @item New arithmetic functions added, which complete all ISO functions.
   @item Some bugs fixed.
   @end{itemize}").

% TODO: (pre SVN) missing notes from 0.6.0 to 0.6.18

:- doc(version(0*6+0,1998/07/16,21:12*07+'MET DST'), "
   @begin{itemize}
   @item Defining other path aliases (in addition to 'library') which can
     be loaded dynamically in executables is now possible.
   @item Added the posibility to define multifile predicates in the shell.
   @item Added the posibility to define dynamic predicates dynamically.
   @item Added addmodule meta-argument type.
   @item Implemented persistent data predicates.
   @item New version of PiLLoW WWW library (XML, templates, etc.).
   @item Ported active modules from ``distributed Ciao'' (independent 
     development version of Ciao).
   @item Implemented lazy loading in executables.
   @item Modularized engine(builtin).
   @item Some bugs fixed.
   @end{itemize}").

% TODO: (pre SVN) missing notes from 0.5.0 to 0.5.50

:- doc(version(0*5+0,1998/3/23), "
   @begin{itemize}
   @item First Windows version.
   @item Integrated debugger in toplevel.
   @item Implemented DCG's as (Ciao-style) expansions.
   @item Builtins renamed to match ISO-Prolog.
   @item Made ISO the default syntax/package.
   @end{itemize}").

% TODO: (pre SVN) missing notes from 0.4.0 to 0.4.12

:- doc(version(0*4+0,1998/2/24), "
   @begin{itemize}
   @item First version with the new Ciao emacs mode.
   @item Full integration of concurrent engine and compiler/library.
   @item Added new_declaration/1 directive.
   @item Added modular syntax enhancements.
   @item Shell script interpreter separated from toplevel shell.
   @item Added new compilation warnings.
   @end{itemize}").

:- doc(version(0*3+0,1997/8/20), "
   @begin{itemize}
   @item Ciao builtins modularized.
   @item New prolog flags can be defined by libraries.
   @item Standalone comand-line compiler available, with automatic ""make"".
   @item Added assertions and regular types.
   @item First version using the automatic documentation generator.
   @end{itemize}").

:- doc(version(0*2+0,1997/4/16), "
   @begin{itemize}
   @item First module system implemented.
   @item Implemented exceptions using catch/3 and throw/1.
   @item Added functional & record syntax.
   @item Added modular sentence, term, and goal translations.
   @item Implemented attributed variables.
   @item First CLPQ/CLPR implementation.
   @item Added the posibility of linking external .so files.
   @item Changes in syntax to allow @tt{P(X)} and @tt{""string""||L}.
   @item Changed to be closer to ISO-Prolog.
   @item Implemented Prolog shell scripts.
   @item Implemented data predicates.
   @end{itemize}").

:- doc(version(0*1+0,1997/2/13), "First fully integrated,
   standalone Ciao distribution. Based on integrating into an
   evolution of the &-Prolog engine/libraries/preprocessor
   @cite{Hampaper,ngc-and-prolog} many functionalities from several
   previous independent development versions of Ciao
   @cite{ciao-prolog-compulog,ciao-ppcp,att-var-iclp,ciao-manual-tr,
   ciao-comp-dist-tr-deliv,ciao-ilps95,ciao-jicslp96-ws-update,pillow-ws-dist,
   ciao-novascience}.").
