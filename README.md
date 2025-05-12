# els-oe-analysis

Automated analysis and report generation for ELS optical engines

# analysis work flow

## pre burn in analysis

Before OE-level burn in, LD LIV curves and MPD dark IV curves are measured. Passing OEs are picked for burn in based on the test results.

1.  summarize MPD dark IV parameter extractions
2.  summarize LD LIV parameter extractions
3.  apply pass/fail judgement criteria
4.  output passing OE pick list

## post burn in analysis

After burn in LIV curves are measured again along with optical spectra. During the LIV sweeps the MPD photocurrent response should also be measured **although currently I don't think it is implemented.**

1.  summarize LD LIV parameter extractions again
2.  summarize OSA parameter extractions
3.  compute percent change in **threshold current** and **output power**
4.  apply pass fail criteria to burn in results
5.  for units passing burn in deltas, check that all performance parameters are also passing
6.  output final picklist for shipment
