# Development Container Features

A collection of reusable Development Container Features for adding tools, CLIs and languages to your dev containers.

## Available Features

This repository contains Features for:

- Container Tools: argocd, calicoctl, cilium, helm, istioctl, kind, kubectl
- Cloud & Infrastructure: bicep, gcloud, pulumi, terraform
- Databases: mongosh, redis
- Languages & Runtimes: deno, zig, wasm-tools
- Build Tools: just, task
- Other Tools: flux, kubebuilder, spin, wit-bindgen

## Usage

Add Features to your `.devcontainer.json`:

```json
{
    "features": {
        "ghcr.io/ljtill/features/atlas:latest": {},
        "ghcr.io/ljtill/features/kind:latest": {},
        "ghcr.io/ljtill/features/zig:latest": {}
    }
}
```

Each Feature's directory contains its own README with specific configuration options.

## Development

1. Features are organized in the `src` directory
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
