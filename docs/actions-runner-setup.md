# GitHub Actions Local Runner on OrbStack

This guide sets up a **self-hosted GitHub Actions runner** inside OrbStack so the APIOps pipeline can run locally during the demo without relying on GitHub's cloud runners.

## Why a Local Runner?

For the APIOps Helsinki demo, we want:
- Complete control over the execution environment
- Real-time visibility into what the pipeline is doing
- No dependencies on GitHub cloud runner availability
- Ability to interact with locally running backends and Kong

## Prerequisites

- OrbStack running with KongAir backends started (see [orbstack-setup.md](orbstack-setup.md))
- GitHub account with this repository forked (`tomathom15/KongAir`)
- Personal Access Token with `repo` and `workflow` scopes
  - Create at: https://github.com/settings/tokens/new

## Setup Steps

### 1. Create a runner on GitHub

Go to your forked repo settings:
```
https://github.com/tomathom15/KongAir/settings/actions/runners/new
```

Choose **Linux** and **ARM64** (OrbStack runs on ARM).

GitHub will provide a download token and setup commands — you'll use these next.

### 2. Create a directory in OrbStack

Inside OrbStack, create a dedicated directory for the runner:

```bash
# From your Mac, execute commands in OrbStack
docker run --rm -it ubuntu:latest bash
# (or use another approach to access OrbStack's Linux VM)

mkdir -p ~/github-runner
cd ~/github-runner
```

### 3. Download and configure the runner

Inside OrbStack, run the setup commands GitHub provides. They look like:

```bash
mkdir actions-runner && cd actions-runner

curl -o actions-runner-linux-arm64-x.x.x.tar.gz -L https://github.com/actions/runner/releases/download/v.../actions-runner-linux-arm64-x.x.x.tar.gz

tar xzf ./actions-runner-linux-arm64-x.x.x.tar.gz

./config.sh --url https://github.com/tomathom15/KongAir --token <TOKEN_FROM_GITHUB>
```

**Important:** Register it with a meaningful name like `orbstack-runner-01`.

### 4. Install and run the service

```bash
sudo ./svc.sh install
sudo ./svc.sh start
```

Verify it's running:

```bash
sudo systemctl status actions-runner
```

### 5. Verify on GitHub

Go back to:
```
https://github.com/tomathom15/KongAir/settings/actions/runners
```

You should see `orbstack-runner-01` listed as **Idle**.

## Using the Runner in Workflows

To use the local runner in GitHub Actions workflows, add:

```yaml
runs-on: [self-hosted, orbstack]
```

Or just:

```yaml
runs-on: self-hosted
```

For the demo, update the APIOps pipeline workflows to use the local runner so the pipeline runs on your machine with access to the KongAir backends.

## Making the Runner Persistent

The runner will stop if OrbStack restarts. To make it persist:

1. **Option A (Simple):** Manual restart after OrbStack reboot
   ```bash
   cd ~/github-runner/actions-runner
   sudo ./svc.sh start
   ```

2. **Option B (Automated):** Add to OrbStack's startup scripts (OrbStack-specific)
   - Requires understanding OrbStack's init/startup behavior

TBD: Document the exact persistent setup for OrbStack.

## Troubleshooting

### Runner shows "Offline"
- SSH into OrbStack and check runner status: `sudo systemctl status actions-runner`
- Check logs: `sudo journalctl -u actions-runner -n 50`

### Workflow jobs fail with "no runner"
- Ensure the runner has the correct labels for your workflow's `runs-on`
- Check that the runner process is actually running

### Pipeline can't reach local backends
- Ensure KongAir services are running: `docker-compose -f docker-compose-orbstack.yaml ps`
- From inside the runner container, test: `curl http://flights.kongair:8080/flights`
- The runner runs in the same OrbStack VM, so it has access to `kong-edu-net`

## Next Steps

Once the runner is configured:
1. Update the [APIOps pipeline workflow](.github/workflows/stage-changes-for-kong.yaml) to use the local runner
2. Test by triggering a workflow run
3. Watch the pipeline execute locally as you demonstrate Act 1

## Security Notes

- The runner has access to GitHub repository secrets (including KONNECT_PAT)
- Only run the runner on trusted networks (your local machine)
- Revoke the runner's registration if you no longer need it
