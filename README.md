# BaPCodVRPSolver

The BaPCodVRPSolver.jl package is a Julia interface for [VRPSolver](https://vrpsolver.math.u-bordeaux.fr/). Unlike the
original distribution, this package allows one to run VRPSolver on any major operating system without Docker.

This package is *only for academic use*.

## Requirements

- [Julia](https://julialang.org/downloads/oldreleases/) versions 1.0.5 -- 1.5.4.
- [CPLEX](https://www.ibm.com/products/ilog-cplex-optimization-studio) versions 12.9 and higher.
- [BaPCod](https://bapcod.math.u-bordeaux.fr/) shared library version 0.66 (see below how to generate it).

Julia versions 1.6 and later are not supported for the moment due to a
[JuMP issue](https://github.com/jump-dev/JuMP.jl/issues/2438). Support of Julia 1.6 requires a significant work and will
depend on the number of inquiries for it. Please let the contributors of this package know if this support is critical
for you.

## Installation

Open the Julia REPL and type:
```
    ]add https://github.com/inria-UFF/BaPCodVRPSolver.jl.git
```

On Linux, set the `LD_LIBRARY_PATH` environment variable with the absolute path to the subdirectory of your CPLEX
installation which contains the executable files and shared libraries.  For example, if your CPLEX is installed at
`/opt/ibm/ILOG/CPLEX_Studio1210` and you are using Bash, you can declare it in the `~/.bashrc`:

```
export LD_LIBRARY_PATH=/opt/ibm/ILOG/CPLEX_Studio1210/cplex/bin/x86-64_linux/:$LD_LIBRARY_PATH
```

On Windows, be sure that the `PATH` environment variable contains the folder with CPLEX dynamic library.

Next, set the `BAPCOD_RCSP_LIB` environment variable with the absolute path to the BaPCod shared library (which has
`.so` extension on linux, `.dylib` extension on Mac OS, and `.dll` extension on Windows).
For example, if you are using Bash on Linux, you can declare it in the `~/.bashrc`:

```
export BAPCOD_RCSP_LIB=/path/to/lib/libbapcod-shared.so
```

If you want to use the [complete formulation](https://vrpsolver.math.u-bordeaux.fr/doc/methods.html#VrpSolver.get_complete_formulation) (the one that includes mapping constraints with λ variables for paths, and it's very useful for debugging), then you have to configurate a MIP solver via [JuMP 0.18](https://jump.dev/JuMP.jl/0.18/) interface for that (e.g. you can install [CPLEX.jl](https://github.com/jump-dev/CPLEX.jl), which requires CPLEX version 12.10 or higher).  

## Producing BaPCod shared library

If the BaPCod shared library you have does not work for you, or you do not have one, you can produce it in the following
way.

Download BaPCod source code on its [web-page](https://bapcod.math.u-bordeaux.fr/). You need an e-mail address from an academic institution for this. Then, install BaPCod using installation instructions in the [BaPCod user guide](https://bapcod.math.u-bordeaux.fr/#userguide).

Then run the following command from the folder you have installed BaPCod

```
cmake --build build --config Release --target bapcod-shared
```

This will produce shared library file `<path to BaPCod>/build/Bapcod/libbapcod-shared.so` on Linux, `<path to BaPCod>/build/Bapcod/libbapcod-shared.dylib` on Mac OS, and `<path to BaPCod>/build/Bapcod/Release/bapcod-shared.dll` on Windows. Note that the `BAPCOD_RCSP_LIB` environment variable should contain the absolute path to this BaPCod shared library, and not to RCSP library. 

## Troubleshooting

On Linux, you may have error:

```
ERROR: LoadError: could not load library "<path to>/libbapcod-shared.so"
<path to Julia>/bin/../lib/julia/libstdc++.so.6: version `GLIBCXX_3.4.26' not found (required by "<path to>/libbapcod-shared.so")
```

This is because Julia comes with an older version of the `libstdc++.so.6` library. One solution is build Julia from sources. 
An easier solution is to replace file `<path to Julia>/lib/julia/libstdc++.so.6` with your system `libstdc++.so.6` file. For local machines it is usually located in the folder `/usr/lib/x86_64-linux-gnu/`.

## Running an application

Firstly, add the folowing dependences:

```
   ]add JuMP, ArgParse
```

All the demos available in the [VRPSolver website](https://vrpsolver.math.u-bordeaux.fr/) will work after replacing `using VrpSolver` with `using BaPCodVRPSolver` in the file *src/run.jl*. Also, you should comment/remove the using of CPLEX.jl at the beginning of *src/run.jl* if the package is not installed. 

For example, the [CVRP demo](https://vrpsolver.math.u-bordeaux.fr/cvrpdemo.zip) can be invoked (after making the aforementioned replacement) for the instance X-n101-k25 using an upper bound of 27591.1 as follows:

```
julia src/run.jl data/X/X-n101-k25.vrp -u 27591.1
```

## Working in NixOs

##### Installation

You need to edit `flake.nix` to update paths for the following variables:
```sh
export LD_LIBRARY_PATH=/home/onyr/cplex1210/cplex/bin/x86-64_linux:$LD_LIBRARY_PATH
export CPLEX_ROOT=/home/onyr/cplex1210
export BAPCOD_ROOT=/home/onyr/bapcod/bapcod-0.82.8
export BOOST_ROOT=/home/onyr/bapcod/bapcod-0.82.8/Tools/boost_1_76_0/build
export BAPCOD_RCSP_LIB=/home/onyr/bapcod/bapcod-0.82.8/build/Bapcod/libbapcod-shared.so
```

That requires quite a lot of manual work to install CPLEX 12.10 and BaPCod 0.82.8 but the current flake holds the necessary available dependencies, so you can reuse its shell for installing BaPCod. For CPLEX, the easiest way is to reboot on a more traditional distribution like Debian and install it from there, then reboot on NixOs and just modify the variable LD_LIBRARY_PATH where you installed it. Indeed, this requires a multi-distro system with shared `home/` partition. But a simpler copy/past of installed files would also probably work as well.

##### Julia commands when running the project for the first time

Activate dev shell:
```
nix develop
```

Then load Julia REPL, download dependencies and activate Julia environment.
```
julia
] activate .
resolve
```

### Run 

`julia vrpsolver/src/run.jl vrpsolver/data/100/C204.txt --cfg vrpsolver/config/VRPTW_set_2.cfg`: run VrpSolver for a given Solomon instance.

Broken, I get error:
```
 ❮onyr ★ nixos❯ ❮BaPCodVRPSolver.jl❯❯ julia vrpsolver/src/run.jl vrpsolver/data/100/C204.txt --cfg vrpsolver/config/VRPTW_set_2.cfg
Application parameters:
  batch  =>  nothing
  tikz  =>  nothing
  instance  =>  "vrpsolver/data/100/C204.txt"
  out  =>  nothing
  nosolve  =>  false
  ub  =>  1.0e7
  sol  =>  nothing
  cfg  =>  "vrpsolver/config/VRPTW_set_2.cfg"
  enable_cap_res  =>  false
 solve 
ERROR: LoadError: could not load library "/home/onyr/bapcod/bapcod-0.82.8/build/Bapcod/libbapcod-shared.so"
/nix/store/26v9009yj6yyz60261523pzvbj2vv4jc-gfortran-9.3.0-lib/lib/libstdc++.so.6: version `GLIBCXX_3.4.29' not found (required by /home/onyr/bapcod/bapcod-0.82.8/build/Bapcod/libbapcod-shared.so)
Stacktrace:
 [1] macro expansion at /home/onyr/code/phd/BaPCodVRPSolver.jl/src/bapcod/bc_common.jl:12 [inlined]
 [2] new!(::String, ::Bool, ::Bool, ::Bool, ::Int32, ::Array{String,1}) at /home/onyr/code/phd/BaPCodVRPSolver.jl/src/bapcod/wrapper/model.jl:19
 [3] BaPCodVRPSolver.BaPCod.BcModel(; param_file::String, print_param::Bool, integer_objective::Bool, baptreedot_file::String, user_params::String) at /home/onyr/code/phd/BaPCodVRPSolver.jl/src/bapcod/bc_model.jl:20
 [4] BaPCodVRPSolver.BaPCod.BcMathProgModel(::BaPCodVRPSolver.BaPCod.BaPCodSolver) at /home/onyr/code/phd/BaPCodVRPSolver.jl/src/bapcod/BaPCodSolverInterface.jl:132
 [5] LinearQuadraticModel at /home/onyr/code/phd/BaPCodVRPSolver.jl/src/bapcod/BaPCodSolverInterface.jl:134 [inlined]
 [6] build(::Model; suppress_warnings::Bool, relaxation::Bool, traits::JuMP.ProblemTraits) at /home/onyr/.julia/packages/JuMP/I7whV/src/solvers.jl:358
 [7] solve(::Model; suppress_warnings::Bool, ignore_solve_hook::Bool, relaxation::Bool, kwargs::Base.Iterators.Pairs{Union{},Union{},Tuple{},NamedTuple{(),Tuple{}}}) at /home/onyr/.julia/packages/JuMP/I7whV/src/solvers.jl:168
 [8] vrp_hook(::Model; suppress_warnings::Bool, relaxation::Bool, kwargs::Base.Iterators.Pairs{Union{},Union{},Tuple{},NamedTuple{(),Tuple{}}}) at /home/onyr/code/phd/BaPCodVRPSolver.jl/src/BaPCodVRPSolver.jl:2425
 [9] solve(::Model; suppress_warnings::Bool, ignore_solve_hook::Bool, relaxation::Bool, kwargs::Base.Iterators.Pairs{Union{},Union{},Tuple{},NamedTuple{(),Tuple{}}}) at /home/onyr/.julia/packages/JuMP/I7whV/src/solvers.jl:151
 [10] solve at /home/onyr/.julia/packages/JuMP/I7whV/src/solvers.jl:150 [inlined]
 [11] optimize!(::VrpOptimizer) at /home/onyr/code/phd/BaPCodVRPSolver.jl/src/BaPCodVRPSolver.jl:1767
 [12] run_vrptw(::Dict{String,Any}) at /home/onyr/code/phd/BaPCodVRPSolver.jl/vrpsolver/src/run.jl:61
 [13] main(::Array{String,1}) at /home/onyr/code/phd/BaPCodVRPSolver.jl/vrpsolver/src/run.jl:101
 [14] top-level scope at /home/onyr/code/phd/BaPCodVRPSolver.jl/vrpsolver/src/run.jl:108
 [15] include(::Function, ::Module, ::String) at /nix/store/s5ydxxzjjahgq3jj6jissi2m5qgwh1hw-julia-1.5.4/lib/julia/sys.so:? (repeats 2 times)
 [16] exec_options(::Base.JLOptions) at /nix/store/s5ydxxzjjahgq3jj6jissi2m5qgwh1hw-julia-1.5.4/lib/julia/sys.so:?
 [17] _start() at /nix/store/s5ydxxzjjahgq3jj6jissi2m5qgwh1hw-julia-1.5.4/lib/julia/sys.so:?
in expression starting at /home/onyr/code/phd/BaPCodVRPSolver.jl/vrpsolver/src/run.jl:105
```

I need to find a way to patch Julia 1.5.4 with a more modern version of libstdc++.so.6 but I'm really unsure of how to do that...  
