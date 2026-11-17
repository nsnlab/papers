# Sensory atypicality and cortical GABA+ in Developmental Coordination Disorder

This repository contains the anonymised data and analysis code for Mayes, W. P., Gentle, J., Jones, D., Sattar, O., Papadopoulou, A., Ivanova, M., & Violante, I. R. (2026).

## Data

The file `data/dcd_mrs_dataset.csv` contains the data for each of the 47 participants who took part in this study, consisting of 22 neurotypical (NT) participants, 8 participants with probable DCD (pDCD) and 17 participants with DCD. One participant with DCD exceeded our selected CAARS exclusion criteria; this participant is marked as ineligible and is excluded from the primary analyses.

The dataset includes age (in whole years), sex, self-reported handedness, the background measures (MABC-2, ADC, WASI-II and CAARS), the Glasgow Sensory Questionnaire (GSQ) subscales and total scores, and, for the motor and visual regions of interest, GABA+ and Glx concentrations together with their fit errors, linewidths, signal-to-noise ratios and voxel tissue fractions, the water and creatine linewidths, and the number of averages acquired and rejected. MRS data were acquired with MEGA-PRESS and quantified relative to water with CSF correction in Gannet 3.1.5. Voxels excluded on visual inspection of the Gannet fits are marked in the `motor_excluded` and `visual_excluded` columns, with the reason given in the corresponding `exclusion_reason` column. 

## Analysis

All analyses are carried out by a single script, `dcd_mrs_analysis.py`, using Python 3.12 with SciPy 1.18 and statsmodels 0.15. To reproduce the results, install the packages listed in `requirements.txt` and run the script as follows:

```
pip install -r requirements.txt
python dcd_mrs_analysis.py
```

The script reproduces Tables 1 and 2, Figures 1 to 6 and Supplementary Table 1 of the manuscript, together with the statistics reported in the text. The tables are written to `output` as CSV files and the figures to `output/figures`. The statistics reported in the text are printed when the script is run.

## Licence

The data and code in this folder are licensed under the Creative Commons Attribution 4.0 International licence (CC BY 4.0); see `LICENSE`.
