# Deployment History

Deployed via [deploy-orion.sh](../../deploy-orion.sh) - Aristotle Manager → Cloudflare Pages

## Version history

| # | Project ID | Deployed At | Files | Status | URL |
|---|-----------|-------------|-------|--------|-----|
| 1 | `17da0589-2bfc-44c4-8169-dbdb61676da2` | 2026-10-05 14:22:11 UTC-04:00 | 138 | ✅ deployed | https://orion-40y.pages.dev |
| 0 | `0f9b0981-1dc9-4321-a46b-53e3cc6ee6e3` | 2026-09-27 16:48:35 UTC | 60 | ✅ deployed | - |

## Usage

```bash
# Deploy default/latest project
./deploy-orion.sh

# Deploy latest project from Aristotle API
./deploy-orion.sh --latest

# Dry-run before deploying
./deploy-orion.sh --dry-run

# Force rebuild of the bundle
./deploy-orion.sh --build
```

## Credentials

Cloudflare credentials are stored in SOPS: `/mnt/data1/kant/pastebin/.sops/registry.sops.yaml`
(decrypted via `SOPS_AGE_KEY_FILE=/home/mdupont/.config/sops/age/keys.txt`)
