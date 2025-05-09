# Getting Started

These are the steps required to get the TT-MLIR project running on your machine.

## Getting the Source Code

```bash
git clone https://github.com/tenstorrent/tt-mlir.git
cd tt-mlir
```

## Prerequisites

- [System Dependencies](#system-dependencies)
- [Hardware Setup](https://docs.tenstorrent.com/getting-started/README.html)

## Environment Setup

There are two ways to set up the environment, either using a docker image or
building the environment manually. The docker image is recommended for most users
since it's easier to set up and use.

### Using a Docker Image

Please see [Docker Notes](docker-notes.md#using-the-docker-image) for more information on how to use the docker image.

Once you have the docker image running and you've logged into the container, you
should now be ready to build.

### Building the Environment Manually

You only need to build this once, it builds llvm, flatbuffers and a python virtual environment.

```bash
cmake -B env/build env
cmake --build env/build
source env/activate
```

> - Use `-DLLVM_BUILD_TYPE=*` to specify the build type of LLVM. The default is `MinSizeRel`, available options are listed [here](https://llvm.org/docs/CMake.html#frequently-used-cmake-variables).
> - It is recommended to use the **system installation of python3** for the virtual environment.
>   Please ensure that you do not already have a venv activated before running the above command.
> - Please ensure the directory `/opt/ttmlir-toolchain` exist and its
>   owner is the current user, i.e. the one that executes the above `cmake` commands.
>   The commands create it and assign the proper ownership are:
>     ```bash
>     sudo mkdir -p /opt/ttmlir-toolchain
>     sudo chown -R $USER /opt/ttmlir-toolchain
>     ```


## Build

```bash
source env/activate
cmake -G Ninja -B build
cmake --build build
```

> - To enable the ttnn/metal runtime add `-DTTMLIR_ENABLE_RUNTIME=ON`
> - Clang 17 is the minimum required version when enabling the runtime.
> - To enable the ttnn/metal perf runtime add `-DTT_RUNTIME_ENABLE_PERF_TRACE=ON`
> - To accelerate the builds with ccache use `-DCMAKE_CXX_COMPILER_LAUNCHER=ccache`
> - To accelerate builds further, if python bindings aren't needed, `-DTTMLIR_ENABLE_BINDINGS_PYTHON=OFF`. For some reason the python bindings link step is very slow.
> - TTNN build is automatically integrated / handled by tt-mlir cmake build system.  For debugging and further information regarding the TTNN backend build step, please refer to [TTNN Documentation](https://tenstorrent.github.io/tt-metal/latest/ttnn/ttnn/installing.html).
> - The runtime build  step depends on the `ARCH_NAME` environment variable, which is set in the `env/activate` script.
>   If you want to build the runtime for a different architecture, please set `ARCH_NAME` to the desired value
>   (one of `grayskull`, `wormhole_b0`, or `blackhole`).
>   Please note that the runtime is built only if `TTMLIR_ENABLE_RUNTIME=ON`.
> - In addition to `ARCH_NAME`, the runtime build depends on `TT_METAL_HOME` variable,
>   which is also set in `env/activate` script.
>   For more information, please refer to
>   [TT-NN and TT-Metailium installation documentation](https://tenstorrent.github.io/tt-metal/latest/ttnn/ttnn/installing.html#step-4-install-and-start-using-tt-nn-and-tt-metalium).

| OS | Offline Compiler Only | Runtime Enabled Build | Runtime + Perf Enabled Build |
|----|-----------------------|-----------------------| -----------------------------|
| Ubuntu 22.04  | ✅ | ✅ | ✅ |
| Ubuntu 20.04  | ✅ | ❌ | ❌ |
| MacOS         | ✅ | ❌ | ❌ |

## Test

```bash
source env/activate
cmake --build build -- check-ttmlir
```

## Lint

```bash
source env/activate
cmake --build build -- clang-tidy
```

### Pre-Commit
Pre-Commit applies a git hook to the local repository such that linting is checked and applied on every `git commit` action. Install from the root of the repository using:

```bash
source env/activate
pre-commit install
```

If you have already committed before installing the pre-commit hooks, you can run on all files to "catch up":

```bash
pre-commit run --all-files
```

For more information visit [pre-commit](https://pre-commit.com/)

## Docs

```bash
source env/activate
cmake --build build -- docs
mdbook serve build/docs
```

> - `mdbook` can be installed with the system's package manager.
> - `mdbook serve` will by default create a local server at `http://localhost:3000`.

**Note:** If you want to build the docs on MacOS, there are two extra dependencies:
- [doxygen](https://www.doxygen.nl/)
- [graphviz](https://graphviz.org/)

Both can be installed using Homebrew by running the following commands:

```bash
brew install doxygen
brew install graphviz
```

## System Dependencies

### Ubuntu 22.04

On Ubuntu 22.04 we need to install clang, ninja, and to update the version of cmake because 3.20 is the minimum required for this project.

```bash
sudo apt update
sudo apt upgrade

sudo apt install git clang cmake ninja-build pip python3.10-venv
```

If you intend to build with runtime enabled, you also need to install tt-metal
dependencies which can be found
[here](https://docs.tenstorrent.com/tt-metal/latest/ttnn/ttnn/installing.html#install-system-level-dependencies).

### MacOS

On MacOS we need to install the latest version of [cmake](https://cmake.org/), and [ninja](https://ninja-build.org/) which can be done using Homebrew with (Docs for installing Homebrew: https://brew.sh).

```bash
brew install cmake ninja
```

## Common Build Errors

### `TTMLIRPythonCAPI target requires changing an RPATH`

```
CMake Error at /opt/ttmlir-toolchain/lib/cmake/llvm/AddLLVM.cmake:594 (add_library):
  The install of the TTMLIRPythonCAPI target requires changing an RPATH from
  the build tree, but this is not supported with the Ninja generator unless
  on an ELF-based or XCOFF-based platform.  The
  CMAKE_BUILD_WITH_INSTALL_RPATH variable may be set to avoid this relinking
  step.
```

If you get the above error, it means you tried to build with an old version of cmake or ninja and there is a stale file. To fix this, `rm -rf` your build directory, install a newer version of cmake/ninja, and then rebuild. If you installed ninja via `sudo apt install ninja-build`, it might still be not up-to-date (v1.10.0). You may use ninja in the python virtual environment, or install it via `pip3 install -U ninja`, either way the version `1.11.1.git.kitware.jobserver-1` should work.

### `clang++ is not a full path and was not found in the PATH`

```
CMake Error at CMakeLists.txt:2 (project):
  The CMAKE_CXX_COMPILER:
    clang++
  is not a full path and was not found in the PATH.
  Tell CMake where to find the compiler by setting either the environment
  variable "CXX" or the CMake cache entry CMAKE_CXX_COMPILER to the full path
  to the compiler, or to the compiler name if it is in the PATH.
CMake Error at CMakeLists.txt:2 (project):
  The CMAKE_C_COMPILER:
    clang
  is not a full path and was not found in the PATH.
  Tell CMake where to find the compiler by setting either the environment
  variable "CC" or the CMake cache entry CMAKE_C_COMPILER to the full path to
  the compiler, or to the compiler name if it is in the PATH.
```

If you get the following error, it means you need to install clang which you can do with `sudo apt install clang` on Ubuntu.

### tt-metal Update Failures

```
Failed to unstash changes in: '/path/to/tt-metal/src/tt-metal'
You will have to resolve the conflicts manually
```

This error occurs during CMake's ExternalProject update of tt-metal. The build system tries to apply changes using Git's stash mechanism, but fails due to conflicts. This can happen even if you haven't manually modified any files, as the build process itself may leave behind artifacts or partial changes from previous builds.

To resolve, clean up the tt-metal directory:

```bash
cd third_party/tt-metal/src/tt-metal
git reset --hard HEAD  # Reset any tracked file modifications
git clean -fd         # Remove all untracked files and directories
```

Then retry your build command. If the error persists, you may also need to:
1. Remove the build directory: `rm -rf build`
2. Run CMake commands again.
3. Run the above.

## Common Runtime Errors

### Debugging python on macOS

When debugging python on macOS via lldb you may see an error like:
```
(lldb) r
error: process exited with status -1 (attach failed (Not allowed to attach to process.  Look in the console messages (Console.app), near the debugserver entries, when the attach failed.  The subsystem that denied t
he attach permission will likely have logged an informative message about why it was denied.))
```

For preinstalled macOS binaries you must manually codesign with debug entitlements.

Create file `debuggee-entitlement.xml`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>com.apple.security.cs.disable-library-validation</key>
        <true/>
        <key>com.apple.security.get-task-allow</key>
        <true/>
</dict>
</plist>
```

Sign the binary:
```bash
sudo codesign -f -s - --entitlements debuggee-entitlement.xml /opt/ttmlir-toolchain/venv/bin/python
```
