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

### 2. Access OrbStack's Linux VM

SSH into OrbStack from your Mac:

```bash
ssh orbstack@orbstack.local
# or
ssh orbstack@localhost
```

### 3. Create a runner directory and install dependencies

Inside OrbStack, create the runner directory and install required tools:

```bash
mkdir -p ~/actions-runner
cd ~/actions-runner

# Install curl and other dependencies
apt-get update
apt-get install -y curl git jq libicu70
```

### 4. Create a non-root user for the runner

GitHub Actions runner requires running as a non-root user for security:

```bash
# Create dedicated user
useradd -m -s /bin/bash github-runner

# Give ownership of the directory
chown -R github-runner:github-runner ~/actions-runner

# Switch to the new user
su - github-runner

# Navigate to runner directory
cd ~/actions-runner
```

### 5. Download and configure the runner

Run the configuration with your GitHub token (obtained from step 1):

```bash
curl -o actions-runner-linux-arm64-x.x.x.tar.gz -L https://github.com/actions/runner/releases/download/v.../actions-runner-linux-arm64-x.x.x.tar.gz

tar xzf ./actions-runner-linux-arm64-x.x.x.tar.gz

./config.sh --url https://github.com/tomathom15/KongAir --token <TOKEN_FROM_GITHUB>
```

**Important:** When prompted for the runner name, use something meaningful like `orbstack-runner-01`.

### 6. Install and run the service

Exit back to root, then install and start the runner service:

```bash
exit  # back to root user

cd ~/actions-runner

./svc.sh install
./svc.sh start
```

Verify it's running:

```bash
systemctl status actions-runner
```

### 7. Verify on GitHub

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
   cd ~/actions-runner
   ./svc.sh start
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
1. Update GitHub Actions workflows to use the local runner by adding `runs-on: [self-hosted, orbstack]` or `runs-on: self-hosted`
2. Test by triggering a workflow run
3. Watch the pipeline execute locally in OrbStack as you demonstrate Act 1

## Security Notes

- The runner has access to GitHub repository secrets (including KONNECT_PAT)
- Only run the runner on trusted networks (your local machine)
- Revoke the runner's registration if you no longer need it
