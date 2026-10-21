# step242

**Read, check, and release STEP (ISO 10303) product data — pure
Python, no proprietary dependencies.**

step242 opens STEP Part 21 exchange files (the `.stp`/`.step` files
every CAD system can export — geometry, assemblies, and PMI), reads
EXPRESS schemas, validates instances against AP242, and pins
releases as verifiable OSLC Config-Management baselines. Paired
with [sysmlpy](https://github.com/mycr0ft/sysmlpy) (SysML v2 parser)
and [pyoslc](https://github.com/mycr0ft/pyoslc) (OSLC server SDK),
it completes a Systems-Engineering **Vee** toolchain that is fully
open source:

```
     requirements & design              geometry & PMI
     (left/middle of Vee)               (right of Vee)
     .sysml  —  sysmlpy  —  OSLC  —  step242  —  .stp
              parse/analyze   ^  parse/structure
                              │
                    pyoslc serves BOTH sides
                    as one OSLC catalog
                              │
                 released configuration = baseline
                 (hash-pinned, verifiable)
```

## Install

```bash
pip install step242
```

Or from source:

```bash
git clone https://github.com/mycr0ft/step242.git
cd step242 && poetry install
```

## 30-second tour

```bash
# What's in a STEP file?
$ step242 inspect tests/fixtures/nist/nist_ctc_01_asme1_ap242-e1.stp
nist_ctc_01_asme1_ap242-e1.stp
  instances: 4350
  schema: AP242_MANAGED_MODEL_BASED_3D_ENGINEERING_MIM_LF {1 0 10303 442 1 1 4}
  top entity types:
    ORIENTED_EDGE       636
    STYLED_ITEM         554
    CARTESIAN_POINT     395
    ...

# Check it against the AP242 schema (advisory findings by default)
$ step242 check tests/fixtures/nist/ -s ap242_mim_lf.exp

# Product structure as OSLC resources
$ step242 structure nist_ctc_01_asme1_ap242-e1.stp --format turtle
```

## Where to next

- **[Beginner's Guide](tutorial/index.md)** — zero prior STEP
  knowledge needed; every step verified on the vendored NIST test files.
- **[Where next](directions.md)** — the roadmap this infrastructure
  unlocks (CI gates, diffing, visualization, full-baseline retrieval).
- **[Architecture](oslc-integration.md)** — how the pieces fit
  (design record with probes and decisions).