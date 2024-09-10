# Immutable GitHub Actions self-hosted runner on podman.

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

**WIP**

## What is this?

Have you ever wanted to run a GitHub Actions self-hosted runner in an environment with guaranteed immutability like a hosted runner?

This script uses podman to set up a self-hosted runner that resets its environment every time, just like the hosted runner in GitHub Actions.
By using this, you can ensure that the runner environment is always clean and that runner state remnants do not affect your builds or tests.
All you have to do is prepare a fast physical machine, run podman on it, and launch as many container instances as you like!

* Each time the runner is run once, the running container is recycled, maintaining the same environment each time.
* Automatically applies the latest version of the GitHub Actions runner.
* Files downloaded by the GitHub Actions runner runtime, APT, NPM, and NuGet are stored in the host's cache directory, so the same file request is processed faster the second time around.

## Usage

Clone this repository.

```bash
$ git clone https://github.com/kekyo/immutable-runner
```

Then execute the following commands for each instance you wish to activate.

```bash
$ YOUR_RUNNER_NAME=foobar-1
$ YOUR_REPO_URL=https://github.com/foobar/foobar
$ YOUR_RUNNER_TOKEN=ABPF....
$ YOUR_RUNNER_CACHE_PATH=/a/cache/dir/path
$ CONTAINER_VERSION=latest

$ ./setup-runner.sh $YOUR_RUNNER_NAME $YOUR_REPO_URL $YOUR_RUNNER_TOKEN $YOUR_RUNNER_CACHE_PATH $CONTAINER_VERSION
```

Note that the token can only be used once per instance.
If you wish to launch multiple instances of the same repository, obtain different tokens.

## Build

A pre-built Docker image is available here: https://hub.docker.com/r/kekyo/immutable-runner
However, if you want to build it yourself, you can use `build-image.sh`.

## License

MIT
