# Context: RI balance table and smoothness-test variants (reply to editors)

*Last updated: 2026-08-31*

Notes on the August 2026 changes to the balance/smoothness tables used in the
reply to editors (`R&R REStud - July 3.2025/1.Reply_Editor&Referees.tex`, the
comment on baseline state-capacity balance). All code lives in
`replication_code/Table 1 within.do`; outputs go to the Overleaf
`tables/` folder via `${tables}`.

## RI balance table (reply Table 22, `rdd_lc_statecapacity_dummies_RI.tex`)

Produced by the self-contained block at the end of `Table 1 within.do`
("RI balance for the dichotomous state capacity indicators").

Final layout (run 2026-08-31, Stata 16, seed 123, **10,000 RI permutations**
within border-segment strata):

- Individual presence dummies: military base (1980), state administration
  (1980), city/village (1945), school (1980), telecommunications (1945),
  **road or railway combined** (`rail_road`, 1980), parish (1979), Ecclesial
  Base Community (1974).
- One composite: **Had Any State Institution** (`any_inst`) = max of military
  base, state administration, city/village, school, telecommunications.
  It excludes roads/railway and the church indicators.
- Columns: Coefficient, SE, RI p-value, Dependent Mean, MDE, MDE (% of mean),
  Obs. MDE = 2.8 x SE (80% power, 5% significance). A test is underpowered
  when the MDE exceeds the dependent mean.

Decisions taken along the way (with Claude, 2026-08-31 session):

- Road and railway were first added as separate rows. Railway alone is
  imbalanced (+2.7pp on a 7.5% base, RI p ~ 0.01, favoring the guerrilla
  side); the combined road/railway row is balanced (p ~ 0.38) because the
  balanced road dummy dominates the union. The table now shows only the
  combined row, so the railway imbalance is not visible in it.
- Broader composites (state institutions + road/railway, and all indicators
  incl. parish/BEC) were computed and then removed from the final table.
  Both were significant (RI p ~ 0.02-0.04), driven entirely by railway.
  Estimates are in the session logs / backups if needed.
- **School (1980): RI p = 0.000 at 10,000 reps** (coefficient +0.4pp on a
  0.3% base) although conventionally insignificant (t ~ 1.3). This is a
  genuine exact-inference imbalance, not a small-reps artifact; the reply
  should acknowledge it.
- The reply note for this table says "10,000 replications" - the final run
  matches that. Intermediate runs used 1,000 reps for speed.

## Smoothness test without distances (reply table `tab: lc_nodist`)

`tables/rdd_lc_all_panel3_nodist.tex` is a copy of the manuscript's Table 1
(`tables/rdd_lc_all_panel3.tex`) with the five distance rows removed
(distance to military base, school, telecommunications, city/village,
parish). Telecommunications *density* was kept (not a distance). Panel A
additionally has a "Had Any State Institution" row taken from the RI run
(same specification: 2.266 km bandwidth, triangular weights, up to 400
border-segment FE).

**Caveat:** `rdd_lc_all_panel3.tex` is not produced by any do-file in this
repo (unlike `rdd_lc_all_panel2.tex` from `Table 1.do`), so the `_nodist`
variant is also a static file. If Table 1 is ever regenerated, both files
must be updated by hand or the variant scripted.

## Distances distribution table (reply Table 23, `sumstats_dist_any_samesided.tex`)

Left in its original 4-row form: distance to **any institution** only
(same-side and unconditional, full and RD sample). "Any institution" =
min over school/cities/comms centroid distances, **excluding roads and
railway** by design. A 20-row version with all component distances was
generated and then reverted on 2026-08-31.
