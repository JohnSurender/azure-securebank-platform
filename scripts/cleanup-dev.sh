#!/usr/bin/env bash
# Tear down dev to save cost (e.g. every Friday evening).
set -euo pipefail
terraform -chdir=infra/envs/dev destroy -auto-approve
