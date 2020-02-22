[ prob ]
This is a simple pk model; going to demonstrate how we can specify reactions
as fluxes and put them together as reactions.

[ cmt ] gut cent periph

[ param ] ka = 1.2, cl = 1, v1 = 10, v2 = 40, q = 5

[ main ]
double k10 = cl/v1;
double k12 = q/v2;
double k21 = q/v2;

[ ode_assignments ]
double conc = cent/v1;

[ reactions ]
- species: gut --> cent
  form: ka * gut
- species: cent --> NULL
  form: cl * conc
- species: cent <--> periph
  form: k12 * cent - k21 * periph

[ table ] capture cp = cent/v1;

[capture] k10
