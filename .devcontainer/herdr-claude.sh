#!/bin/bash
# Convenience wrapper for running Claude Code inside one of the .devcontainer/*
# variants from a bare host shell (e.g. as a herdr pane command), without
# needing VS Code or remembering the --config path for each variant.
#
# The container is rebuilt automatically when the variant's container config
# (Dockerfile, compose.yml, devcontainer.json, ...) or the shared post-create
# script has changed since the last successful `devcontainer up`. Plain
# `devcontainer up` reuses an existing container and would silently keep
# running the stale image. Pass --rebuild to force a rebuild anyway.
#
# Usage: .devcontainer/herdr-claude.sh [--rebuild] [default|C|Cs]
set -eu

force_rebuild=false
variant=default
for arg in "$@"; do
    case "$arg" in
        --rebuild) force_rebuild=true ;;
        -*)
            echo "Unknown option: $arg" >&2
            exit 1
            ;;
        *) variant="$arg" ;;
    esac
done

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
workspace_folder="$(dirname "$script_dir")"
config_path="$script_dir/$variant/devcontainer.json"
# Host-side record of the config the current container was built from.
# Gitignored; deleting it forces a rebuild on the next run.
hash_file="$script_dir/$variant/.config-hash"

if [ ! -f "$config_path" ]; then
    echo "Unknown variant: $variant (expected one of: default, C, Cs)" >&2
    exit 1
fi

sha256() {
    # sha256sum on Linux, shasum on macOS
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum
    else
        shasum -a 256
    fi
}

# Hashes every input that only takes effect when the container is created.
# .env is excluded because write-env.sh regenerates it on every up.
config_hash() {
    (
        cd "$script_dir"
        find "$variant" post-create.sh -type f ! -name .env ! -name .config-hash \
            | LC_ALL=C sort \
            | while IFS= read -r f; do
                printf '%s\n' "$f"
                cat "$f"
            done
    ) | sha256 | cut -d' ' -f1
}

current_hash="$(config_hash)"
up_args=(--workspace-folder "$workspace_folder" --config "$config_path")

if $force_rebuild; then
    echo "Rebuilding container (--rebuild)." >&2
    up_args+=(--remove-existing-container)
elif [ "$(cat "$hash_file" 2>/dev/null)" != "$current_hash" ]; then
    echo "Container config changed since last build; rebuilding container." >&2
    up_args+=(--remove-existing-container)
fi

devcontainer up "${up_args[@]}"
printf '%s\n' "$current_hash" > "$hash_file"

# The foreground process herdr sees on the host is `devcontainer`/`docker`
# (the exec wrapper), not `claude`, so herdr can't identify the agent by
# process name alone. HERDR_AGENT tells herdr which manifest to use instead.
export HERDR_AGENT=claude
exec devcontainer exec --workspace-folder "$workspace_folder" --config "$config_path" claude
