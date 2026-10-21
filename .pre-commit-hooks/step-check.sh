#!/usr/bin/env bash
# pre-commit hook: STEP parse gate on staged .stp/.step/.p21 files.
#
# .pre-commit-config.yaml (in the MODELS repo):
#
#   repos:
#     - repo: local
#       hooks:
#         - id: step-check
#           name: step242 check (parse gate)
#           entry: step-check.sh          # copy or link this script
#           language: system
#           files: '\.(stp|step|p21)$'
#
# Parse failures block the commit. Schema/semantic findings print as
# warnings (flip to strict by setting STEP242_SEMANTIC=strict).
set -uo pipefail

# STEP242_SEMANTIC is the current name; STEPPER_SEMANTIC is the deprecated
# pre-rename spelling and still works.
sem="${STEP242_SEMANTIC:-${STEPPER_SEMANTIC:-advisory}}"
rc=0
for f in "$@"; do
  step242 check "$f" --semantic "$sem" || rc=1
done
exit $rc