# Repository guidance

- Use four spaces for Julia indentation and Unicode for mathematical symbols.
- Keep numerical API changes separate from documentation. Preserve unrelated local edits.
- This package and its docs are public. Use repository assets and reproducible examples; do not copy research results from other projects.
- Maintain the VitePress theme in `docs/src/.vitepress/` and tutorial sources in `docs/examples/`.
- Prepare with `julia --project=docs -e 'using Pkg; Pkg.develop(path=pwd()); Pkg.instantiate()'`. Run `julia --project=docs docs/make.jl` to execute tutorial assertions, generate figures and pages, and build the site.
- Generated tutorials, figures, downloadable scripts in `docs/src/public/downloads/`, and `docs/build/` are ignored. Edit their sources.
- Preserve `/dev/` and legacy tutorial/API redirects. Only deploy from main in CI; local builds do not publish.
- Describe the amplitude-threshold heuristic accurately; it is not a guaranteed power-retention fraction.
- Use descriptive commit messages and branch names without assistant product references.
- For remote SSH computation, inspect and reconnect tmux on first use and run commands in tmux. Use Slurm for heavy RCAC work, follow the user's memory allocation convention, and retain preallocated jobs.
