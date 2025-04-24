# Usage


## Python venv Activate

```
source .venv/bin/activate
```

## Python venv Deactivate

```
deactivate
```

## Encrypt

```
sops -e terraform.tfvars.json > terraform.tfvars.json.enc
```

## Decrypt

```
sops -d --output-type json terraform.tfvars.json.enc > terraform.tfvars.json
```

## tflint

```
tflint --init --config "[Path]/.tflint.hcl"
```

## checkov

```
checkov -d . --config-file [Path]/.checkov.yml
```

## Use WSL2 with Cursor

```
`CTRL+P` -> `>Connect to WSL using Distro` -> Ubuntsu
```

## Squash Commits

```
git log --oneline
git reset --soft HEAD~XXX
```

