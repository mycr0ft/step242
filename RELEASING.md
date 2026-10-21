# Releasing to PyPI

`step242` publishes with **trusted publishing** (OIDC): the GitHub Actions
workflow gets a short-lived token from PyPI, and no API token is stored in the
repository.

## One-time setup (PyPI side)

The project name has to exist on PyPI and have a trusted publisher that
matches this repository. Do this once, from your PyPI account:

1. **Create the project.** <https://pypi.org/manage/account/publishing/> →
   *Publishing* → *Add a new project* → `step242`.
2. **Add the trusted publisher.** On the `step242` *Manage* page →
   *Publishing* → *Add a new publisher* → *GitHub*:
   - Owner: `mycr0ft`
   - Repository: `step242`
   - Workflow name: `python-publish.yml`
   - Environment name: `pypi`

   The environment `pypi` already exists on the GitHub repository; it must
   match exactly.

   The claims the workflow sends are printed in the failed publish run's log,
   so you can copy them from there to double-check.

3. **Publish.** Create the GitHub release; the `Upload Python Package`
   workflow fires on `release: published` and uploads the distributions.

## Why the name is `step242`

The project was `stepper` until 2026-10-21. PyPI's `stepper` name belongs to
an unrelated motor-control package (W. Trevor King's, v0.4, last upload
2012-07-22) and PyPI never releases names, so the distribution, the module
(`step242`) and the console script (`step242 check|inspect|structure|baseline`)
all changed. The GitHub repository was renamed `mycr0ft/stepper` →
`mycr0ft/step242`; the old URL redirects.

The vocabulary namespace moved with it:
`https://github.com/mycr0ft/step242/vocab#`. The JSON-LD and Turtle property
prefix changed from `stepper:*` to `step242:*`; pyoslc reads both.

The environment variables still work under their old names —
`STEP242_WHERE` falls back to `STEPPER_WHERE`, and the pre-commit hook and
GitLab CI accept `STEP242_SEMANTIC` / `STEP242_BASELINE` or the legacy
`STEPPER_SEMANTIC` / `STEPPER_BASELINE`.

## What the workflow does

`.github/workflows/python-publish.yml`:

- builds an sdist and a wheel with `python -m build`,
- publishes them with `pypa/gh-action-pypi-publish@release/v1` using the
  `pypi` GitHub environment and OIDC.

## Releasing a new version

```sh
# bump the version in pyproject.toml and src/step242/__init__.py (__version__)
# update CHANGELOG.md
git commit -am "v0.X.Y: ..."
git tag -a v0.X.Y -m "v0.X.Y: ..."
git push origin main && git push origin v0.X.Y
gh release create v0.X.Y --title "v0.X.Y" --notes "..."
```

## Checking what happened

```sh
gh run list -R mycr0ft/step242 --limit 5
gh run view <id> -R mycr0ft/step242 --log-failed
curl -s https://pypi.org/pypi/step242/json | python3 -m json.tool | head -20
```

## If the publish fails with `invalid-publisher`

That means PyPI has no trusted publisher matching the claims. The claims are
in the run log. The usual causes:

- the repository name in the PyPI publisher entry is `stepper` rather than
  `step242` (the repository was renamed),
- the workflow name does not match `python-publish.yml`,
- the environment name does not match `pypi`.

## The reusable `step-check.yml` workflow

Other repositories can use the STEP gate directly:

```yaml
jobs:
  step-check:
    uses: mycr0ft/step242/.github/workflows/step-check.yml@main
    with:
      paths: "step/"
      semantic: "advisory"        # off | advisory | strict
      baseline-manifest: "config-mgmt/baseline.json"   # optional
```

It installs from GitHub by default; pass `step242-version: "step242==X.Y.Z"`
to pin a published release.
