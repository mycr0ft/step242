# STEP gates in CI/CD

Parse failures block, in any mode. Schema-level semantic checks
(default `advisory`) warn without blocking — flip `strict` when your
models are clean enough to trust it.

## What runs

```bash
step242 check models/cad.stp --semantic advisory
```

* parse of every instance against Part 21 (blocking),
* EXPRESS schema stage (`--schema`), plus the vendored AP242 MIM when
  the file declares one (advisory/strict per flag),
* WHERE-rule evaluation (the `where` module) — findings reported,
  blocking only under `--semantic strict`.

## GitHub Actions (reusable workflow)

```yaml
jobs:
  step-check:
    uses: mycr0ft/step242/.github/workflows/step-check.yml@main
    with:
      paths: "step/"
      semantic: "advisory"          # off | advisory | strict
      exclude: "vendor/,fixtures/"  # substring patterns, comma-separated
      # baseline-manifest: "config-mgmt/baseline.json"
```

Inputs: `paths`, `exclude`, `semantic`, `baseline-manifest`,
`baseline-inputs`, `python-version`, `step242-version`. Parse is
always blocking; `semantic` scales the schema stage; setting
`baseline-manifest` adds the drift gate.

Note: the project was called `stepper` until 2026-10-21 and is now
`step242` — PyPI's `stepper` name belongs to an unrelated motor-control
package, so the distribution name had to change. Install pins resolve to
`git+https://github.com/mycr0ft/step242@main` by default; once the first
PyPI release is out, use `step242==X.Y.Z`.

step242 itself dogfoods the workflow in `step-dogfood.yml` against
its vendored NIST corpus.

## GitLab CI

```yaml
include:
  - remote: 'https://raw.githubusercontent.com/mycr0ft/step242/main/gitlab/step-check.gitlab-ci.yml'

step-check:
  extends: .step-check
  variables:
    STEP_PATHS: "step/"
    STEP242_SEMANTIC: "advisory"
    # STEP242_BASELINE: "config-mgmt/baseline.json"
```

## The baseline gate (released-configuration discipline)

Pin a configuration once, from the machine that declared it:

```bash
step242 baseline create \
  --step released/cad.stp \
  --title "SRR-1" --author "jf" \
  --out config-mgmt/baseline.json
```

The manifest pins raw file digests AND the derived payloads (structure
JSON-LD, OBP view, uuid bridge) — content-addressed, id `bl:<16hex>`.
The id covers CONTENT only: title/author are annotations and never
gate a pipeline (renaming a release cannot fire the gate).

In CI:

```bash
step242 baseline gate config-mgmt/baseline.json --step step/cad.stp
```

* identical derived content → exit 0 (pin holds),
* any content change → exit 1, printing the first differing artifact
  (`changed: step cad.stp 036683e8358a → 2d05bd399463`).

Pin it by passing `baseline-manifest` to the reusable workflow (or
`STEP242_BASELINE` on GitLab). Commit the manifest — the gate then
enforces "this merge stays inside the already-released configuration,
or you consciously re-pin."

## Pre-commit

`.pre-commit-hooks/step-check.sh` is a thin wrapper around
`step242 check` for the repo you keep models in — wire it via
[`pre-commit`](https://pre-commit.com/) (`language: system`, files
`\.(stp|step|p21)$`).

## Design notes

* Advisory-by-default matches the `sysmlpy ci` convention (parse
  blocking, semantics advisory, `strict` opt-in) — the two gates read
  the same from a pipeline's point of view.
* The gate never blocks on INDETERMINATE WHERE outcomes — undecided
  is not failure (ISO 10303-11 §12.3 UNKNOWN propagation).
* The manifest is plain JSON with no external tooling — reviewable,
  diffable, commit-safe.