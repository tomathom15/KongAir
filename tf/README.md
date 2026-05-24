# Terraform — Konnect Provisioning

This directory contains Terraform configuration to provision Kong Konnect environments for both acts of the APIOps demo.

## Structure

```
tf/
├── konnect-us/     # Act 1: Discovery & APIOps pipeline (live demo)
└── konnect-au/     # Act 2: Governance & Standards (pre-staged)
```

## Regions

### US Region (Act 1)
- **Purpose**: Live demo environment where the APIOps pipeline runs
- **Starting state**: Blank — populated as the pipeline executes
- **Audience visibility**: Real-time demonstration of API discovery and deployment

### AU Region (Act 2)
- **Purpose**: Hero state with full governance and standards
- **Starting state**: Pre-deployed before the talk with all governance in place
- **Audience visibility**: "This is what good looks like" — complete Dev Portal, documented specs, enforced standards

## Usage

### Initialize Terraform

```bash
# US region
cd tf/konnect-us
terraform init

# AU region
cd ../konnect-au
terraform init
```

### Plan and Apply

```bash
# US region (Act 1)
terraform plan
terraform apply

# AU region (Act 2)
cd ../konnect-au
terraform plan
terraform apply
```

### Environment Variables

Provide the Konnect PAT via environment variable:

```bash
export TF_VAR_konnect_pat="<your-konnect-pat>"
terraform apply
```

Or create a `terraform.tfvars` file (gitignored):

```hcl
konnect_pat = "kpat_..."
```

## What Gets Deployed

TBD as we build out the configuration, but will include:

### US Region (Act 1)
- Konnect gateway
- Data planes
- Empty API configurations (to be populated by pipeline)

### AU Region (Act 2)
- Konnect gateway with full API coverage
- Dev Portal with published specs
- Rate limiting, authentication, logging policies
- Common standards applied
- Spectral enforcement

## Next Steps

1. Define Konnect gateway and data plane resources
2. Configure Kong API definitions
3. Set up policies and plugins
4. Integrate with submodule for shared standards (Act 2)
5. Add outputs for demo reference (URLs, credentials, etc.)
