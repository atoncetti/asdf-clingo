# asdf-clingo

[asdf](https://github.com/asdf-vm/asdf) plugin for [Clingo](https://github.com/potassco/clingo),
a grounder and solver for logic programs from the [Potassco](https://potassco.org) project.

## Install

```bash
asdf plugin add clingo https://github.com/antonio/asdf-clingo.git
```

## Use

```bash
# Install the latest version
asdf install clingo latest

# Install a specific version
asdf install clingo 5.8.2

# Set a global version
asdf set --home clingo latest

# Use the tool
clingo --version
```

## Requirements

Clingo is built from source. The following build dependencies are required:

- A C++14 conforming compiler (GCC >= 4.9, Clang >= 3.1, or MSVC >= 15.0)
- [CMake](https://cmake.org/) >= 3.10 (>= 3.18 recommended)

Optional dependencies for scripting support (not enabled by default in this plugin):

- Python >= 3.6 with CFFI >= 1.14
- Lua >= 5.1

## Environment variables

- `ASDF_CONCURRENCY` - number of parallel jobs for the build (defaults to `nproc`)

## License

MIT
