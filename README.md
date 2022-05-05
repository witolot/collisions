# A Machine Learning Decision Tree Case Study: Minimising Vehicle Collisions in California

This is a case study in using supervised machine learning - specifically a decision tree approach - to evaluate causes of vehicle collisions. We use the publicly available [California SWITRS data](https://www.kaggle.com/alexgude/starter-california-traffic-collisions-from-switrs/data). This database contains detailed information about every traffic collision reported to the California Highway Patrol between 2001 and 2020.

Since we require a `0` and `1` binary differentiator for our Y variable, we pick `at_fault` (as in "at fault of collision"", as stated in the police report). This is usually one of the drivers. We run most of the available variables (e.g. alcohol, movement preceding collision, inattention) as independent variables against this. The resulting decision tree is shown below.

<img src="https://github.com/witolot/collisions/blob/master/images/decision_tree.png" width="800"/>

An initial interpretation of the chart is as follows. In descending order of effect size on collisions:

* `Node #7`: Performing more complicated manoeuvres accounts for 24% of collisions. The party performing such manoeuvres has an 82% probability of being at fault whilst performing these.
* `Node 13`: Unsurprisingly, alcohol is a culprit in collisions, though only in 8% of cases. However, when it is present, the probability of a party (e.g. driver) being at fault of collision is 80%.
* `Node 25`: Vision obscurements, stop and go traffic, as well as a variety of inattention factors (e.g. cell phone use) account for 4% of collisions. But when they're present, the probability of a party  (e.g. driver) being at fault is 79%.

Now, from a policy perspective, some possible conclusions regarding minimising collisions:

* `Node #7`: Most energy should be spent on this node (24% of collisions). Further qualitative investigation into this category could turn up more specifics. But without them an educated guess to lower collisions would be: (A) signage improvements (e.g. better road signs, reflectors, markings); (B) improved road safety training during driving school (similar to emphasis placed on road safety in UK).
* `Node 13`: Perhaps alcohol safety campaigns? This is probably largely due to road culture though, may be difficult to change.
* `Node 25`: Due to the idiosyncrasy of causes within this category, it's hard to prescribe anything specific. Then again, perhaps high intensity "don't use your phone while driving" campaigns could be better utilised on `Node #7`, yielding better ROI.

The full write up with the code walk-through is available <a href="https://benevolent-kangaroo-064850.netlify.app/">here</a>.
