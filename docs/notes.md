# Status screen

The main screen everything is controlled from. Gives a brief overview.

## Alerts

- Field Reports: May or may not be a new SCP or anomalous object.
- Containment Breaches: An immediate emergency to deal with. Different options
  and percentages of chance leading to different outcomes.
- Research Completed: A new finding leads to an increase in safety, reduction in
  costs, or increase in income.
- New Research Available: A proposal for new research. Depending on what it is,
  may have different costs and risks. (note: 'research' can be programs that
  aren't strictly research (the college program for example))

## Construction

Basically, how much space is available for containment/research.

Two master variables: site_count (which acts as a multiplier, and is incremented
by build new site) and site_size (which is incremented by expand site).

- Build new site (more expensive, but multiplier)
- Expand site (cheaper, but typically only adds a small amount of space)
  (may add new storage type?)

## Manage

Opens another screen which displays total efficacy, safety, research, funds, as
well as items that have been contained (and stats on them).

- efficacy: basically score, are you doing a good job, mostly affected by safety
- safety: there is a balance between research capability and safety to be
  maintained
- research: balance between research and safety, this controls ability to
  maintain facilities and ultimately may offer more safety techniques
- funds: used to run everything!
