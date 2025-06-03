# Development Container Features

A collection of reusable Development Container Features for adding tools, CLIs and languages to your dev containers.

## Available Features

This repository contains Features for:

- **Container Tools**: argocd, calicoctl, cilium, helm, istioctl, kind, kubectl
- **Cloud & Infrastructure**: bicep, clusterctl, gcloud, pulumi, terraform
- **Databases**: mongosh, redis
- **Languages & Runtimes**: deno, pkl, ruff, swift, uv, zig
- **Build Tools**: just, task, volta
- **WebAssembly Tools**: wasm-tools, wasmtime, wit-bindgen, wit-deps
- **Development Tools**: atlas, flux, kubebuilder, spin

## Development

1. Features are organised in the `src` directory
2. Each Feature has its own test suite in `test`
3. Features are automatically tested and published via GitHub Actions

## Contributing

1. Fork the repository
2. Create a new Feature directory in `src`
3. Add installation scripts and Feature documentation
4. Add tests in `test`
5. Submit a Pull Request

## Learn More

- [Dev Container Features Specification](https://containers.dev/implementors/features/)
- [Features Documentation](https://containers.dev/features)
- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
