"""
Analysis script for Mayes et al., 2026. This reproduces Tables, Figures and
the statistics reported in the text of the manuscript.

Usage: python dcd_mrs_analysis.py
"""

import platform
import warnings
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import scipy
import statsmodels
import statsmodels.formula.api as smf
from scipy import stats

warnings.filterwarnings("ignore")

HERE = Path(__file__).resolve().parent
DATA_FILE = HERE / "data" / "dcd_mrs_dataset.csv"
OUTPUT = HERE / "output"

ROIS = {"motor": "Motor", "visual": "Visual"}
METABOLITES = {"gaba": "GABA+", "glx": "Glx", "glx_gaba": "Glx/GABA+"}
GROUP_ORDER = ["NT", "pDCD", "DCD"]
GROUP_TERM = "C(group, Treatment('NT'))"


# Step 1: Load Data

def load_data():
    df = pd.read_csv(DATA_FILE)
    df["group"] = pd.Categorical(df["group"], GROUP_ORDER)
    for roi in ROIS:
        df[f"{roi}_glx_gaba"] = df[f"{roi}_glx"] / df[f"{roi}_gaba"]
        for tissue in ("gm", "wm", "csf"):
            df[f"{roi}_{tissue}_pct"] = df[f"{roi}_f_{tissue}"] * 100
    return df


def apply_exclusions(df):
    """Removes the MRS values of voxels excluded on visual inspection of the Gannet fit."""
    out = df.copy()
    for roi in ROIS:
        cols = [c for c in out.columns if c.startswith(f"{roi}_")
                and not c.endswith(("_excluded", "_exclusion_reason"))]
        out.loc[out[f"{roi}_excluded"], cols] = np.nan
    return out


ALL_SCANNED = load_data()                                              # n = 47
SAMPLE = ALL_SCANNED[ALL_SCANNED["eligible"]].reset_index(drop=True)   # n = 46
DATA = apply_exclusions(SAMPLE)


# Step 2: Statistics

def fmt_p(p):
    return "<.001" if p < .001 else f"{p:.3f}".lstrip("0")


def fmt_r(r):
    return f"{r:.2f}".replace("0.", ".")


def m_sd(x):
    x = x.dropna()
    return f"{x.mean():.2f} ({x.std(ddof=1):.2f})"


def group_contrasts(data, var):
    """Linear model with a three-level group factor; DCD and pDCD are each compared to NT.
    d is the contrast divided by the residual standard deviation."""
    sub = data.dropna(subset=[var])
    fit = smf.ols(f"{var} ~ {GROUP_TERM}", sub).fit()
    out = {"df": int(fit.df_resid)}
    for g in ("DCD", "pDCD"):
        term = f"{GROUP_TERM}[T.{g}]"
        lo, hi = fit.conf_int().loc[term]
        out[g] = {"b": fit.params[term], "ci": (lo, hi), "t": fit.tvalues[term],
                  "p": fit.pvalues[term], "d": fit.params[term] / np.sqrt(fit.mse_resid)}
    return out


def mann_whitney(nt, g):
    """Mann-Whitney U for a group against NT, with the rank-biserial correlation."""
    res = stats.mannwhitneyu(g, nt, alternative="two-sided", method="asymptotic")
    return res.statistic, res.pvalue, 2 * res.statistic / (len(nt) * len(g)) - 1


def pearson(data, x, y):
    sub = data[[x, y]].dropna()
    r, p = stats.pearsonr(sub[x], sub[y])
    return f"r = {fmt_r(r)}, p = {fmt_p(p)}, n = {len(sub)}"


def long_format(data, met):
    parts = []
    for roi, label in ROIS.items():
        sub = data[["study_id", "group", f"{roi}_{met}"]].dropna()
        parts.append(sub.rename(columns={f"{roi}_{met}": "y"}).assign(roi=label))
    out = pd.concat(parts, ignore_index=True)
    out["group"] = pd.Categorical(out["group"].astype(str), GROUP_ORDER)
    return out


def group_by_region(data, met):
    """Linear mixed model with group, region and their interaction, and a random intercept
    for each participant. The interaction is tested with a likelihood ratio test. A second
    model allows the between-participant variance to differ between groups."""
    df = long_format(data, met)
    fixed = f"{GROUP_TERM} * C(roi, Treatment('Motor'))"
    full = smf.mixedlm(f"y ~ {fixed}", df, groups=df["study_id"]).fit(reml=False)
    reduced = smf.mixedlm(f"y ~ {fixed.replace('*', '+')}", df, groups=df["study_id"]).fit(reml=False)
    lr = 2 * (full.llf - reduced.llf)

    # Group-specific variances; the outcome is rescaled (x20) to help the optimiser converge.
    for g in GROUP_ORDER:
        df[f"is_{g}"] = (df["group"].astype(str) == g).astype(float)
    df["y20"] = df["y"] * 20
    m0 = smf.mixedlm(f"y20 ~ {fixed}", df, groups=df["study_id"]).fit(reml=True)
    model = smf.mixedlm(f"y20 ~ {fixed}", df, groups=df["study_id"], re_formula="0",
                        vc_formula={g: f"0 + is_{g}" for g in GROUP_ORDER})
    for method in ("lbfgs", "bfgs", "cg"):
        m1 = model.fit(reml=True, method=method, maxiter=5000)
        if m1.converged:
            break
    lr_var = max(0.0, 2 * (m1.llf - m0.llf))
    inter = [f"{GROUP_TERM}[T.{g}]:C(roi, Treatment('Motor'))[T.Visual]" for g in ("pDCD", "DCD")]
    wald = m1.wald_test(", ".join(f"{t} = 0" for t in inter), scalar=True)
    return {"lr": lr, "p": stats.chi2.sf(lr, 2), "lr_var": lr_var,
            "p_var": stats.chi2.sf(lr_var, 2), "p_inter_var": float(wald.pvalue)}


# Step 3: Tables

TABLE1 = {"mabc2_component_score": "MABC-2 CS", "adc_total": "ADC Total", "gsq_total": "GSQ Total",
          "wasi_fsiq": "FSIQ", "wasi_vci": "VCI", "wasi_pri": "PRI", "caars_inattention": "CAARS A",
          "caars_hyperactivity": "CAARS B", "caars_impulsivity": "CAARS C",
          "caars_self_concept": "CAARS D", "caars_adhd_index": "CAARS E"}


def comparison_row(data, var, label):
    res = group_contrasts(data, var)
    row = {"Measure": label}
    for g in ("NT", "DCD", "pDCD"):
        row[f"{g} M (SD)"] = m_sd(data.loc[data["group"] == g, var])
    for g in ("DCD", "pDCD"):
        row[f"NT - {g} t"] = f"{res[g]['t']:.2f}"
        row[f"NT - {g} p"] = fmt_p(res[g]["p"])
    row["df"] = res["df"]
    return row


def table1():
    return pd.DataFrame([comparison_row(SAMPLE, v, l) for v, l in TABLE1.items()])


def table2():
    rows = []
    for roi in ("visual", "motor"):
        for var, name in (("gm_pct", "GM"), ("wm_pct", "WM"), ("csf_pct", "CSF")):
            rows.append(comparison_row(DATA, f"{roi}_{var}", f"{ROIS[roi]} {name}"))
    for var, name in (("gaba_fit_error", "GABA+ fit error"), ("glx_fit_error", "Glx fit error")):
        for roi in ("visual", "motor"):
            rows.append(comparison_row(DATA, f"{roi}_{var}", f"{ROIS[roi]} {name}"))
    return pd.DataFrame(rows)


GSQ_MODALITIES = ("visual", "auditory", "tactile", "proprioceptive", "vestibular", "gustatory", "olfactory")


def table_s1():
    """Supplementary Table 1: GSQ scores by group. Totals are compared with the linear model (t, d);
    modality scores, which are bounded ordinal scales, with the Mann-Whitney U test (U, r)."""
    rows = []
    nt = SAMPLE[SAMPLE["group"] == "NT"]
    totals = {"gsq_total": "GSQ Total", "gsq_hyper_total": "GSQ Hypersensitivity Total",
              "gsq_hypo_total": "GSQ Hyposensitivity Total"}
    modality = {f"gsq_{m}_{k}": f"{m.capitalize()} {label}" for m in GSQ_MODALITIES
                for k, label in (("hyper", "Hypersensitivity"), ("hypo", "Hyposensitivity"))}
    modality.update({f"gsq_{m}_total": f"{m.capitalize()} Total" for m in GSQ_MODALITIES})
    for var, label in {**totals, **modality}.items():
        row = {"Measure": label}
        for g in ("NT", "DCD", "pDCD"):
            row[f"{g} M (SD)"] = m_sd(SAMPLE.loc[SAMPLE["group"] == g, var])
        if var in totals:
            res = group_contrasts(SAMPLE, var)
            for g in ("DCD", "pDCD"):
                row[f"NT - {g} statistic"] = f"t = {res[g]['t']:.2f}"
                row[f"NT - {g} p"] = fmt_p(res[g]["p"])
                row[f"NT - {g} effect size"] = f"d = {fmt_r(res[g]['d'])}"
        else:
            for g in ("DCD", "pDCD"):
                u, p, r = mann_whitney(nt[var].dropna(), SAMPLE.loc[SAMPLE["group"] == g, var].dropna())
                row[f"NT - {g} statistic"] = f"U = {u:.1f}"
                row[f"NT - {g} p"] = fmt_p(p)
                row[f"NT - {g} effect size"] = f"r = {fmt_r(r)}"
        rows.append(row)
    return pd.DataFrame(rows)


# Step 4: Statistics reported

def results_text():
    lines = [f"Python {platform.python_version()}, NumPy {np.__version__}, pandas {pd.__version__}, "
             f"SciPy {scipy.__version__}, statsmodels {statsmodels.__version__}, "
             f"matplotlib {matplotlib.__version__}", ""]

    def section(title):
        lines.extend(["", title, "-" * len(title)])

    section("2.1 Participants")
    lines.append(f"Scanned: {len(ALL_SCANNED)}; excluded on the CAARS criterion: "
                 f"{', '.join(ALL_SCANNED.loc[~ALL_SCANNED['eligible'], 'study_id'])}")
    for g in GROUP_ORDER:
        s = SAMPLE[SAMPLE["group"] == g]
        lines.append(f"{g}: n = {len(s)}, {(s['sex'] == 'Female').sum()} female, "
                     f"age M = {s['age_years'].mean():.2f}, SD = {s['age_years'].std(ddof=1):.2f}; "
                     f"handedness {s['handedness'].value_counts().to_dict()}")
    age = smf.ols("age_years ~ C(group)", SAMPLE).fit()
    chi = stats.chi2_contingency(pd.crosstab(SAMPLE["group"], SAMPLE["sex"]))
    lines.append(f"Age: F({age.df_model:.0f}, {age.df_resid:.0f}) = {age.fvalue:.2f}, "
                 f"p = {fmt_p(age.f_pvalue)}")
    lines.append(f"Sex: chi2({chi.dof}) = {chi.statistic:.2f}, p = {fmt_p(chi.pvalue)}")

    section("2.4 MRS data included")
    for roi, label in ROIS.items():
        n = DATA.groupby("group", observed=False)[f"{roi}_gaba"].count().to_dict()
        lines.append(f"{label} ROI: {n}")

    section("3.1 GSQ")
    for var, label in (("gsq_total", "GSQ total"), ("gsq_hyper_total", "Hypersensitivity"),
                       ("gsq_hypo_total", "Hyposensitivity")):
        res = group_contrasts(SAMPLE, var)
        for g in ("DCD", "pDCD"):
            r = res[g]
            lines.append(f"{label}, {g} vs NT: t({res['df']}) = {r['t']:.2f}, p = {fmt_p(r['p'])}, "
                         f"d = {fmt_r(r['d'])}")
    nt = SAMPLE[SAMPLE["group"] == "NT"]
    for m in ("visual", "auditory", "tactile", "proprioceptive"):
        for k in ("hyper", "hypo"):
            var = f"gsq_{m}_{k}"
            for g in ("DCD", "pDCD"):
                u, p, r = mann_whitney(nt[var].dropna(), SAMPLE.loc[SAMPLE["group"] == g, var].dropna())
                lines.append(f"{m} {k}sensitivity, {g} vs NT: U = {u:.1f}, p = {fmt_p(p)}, "
                             f"r = {fmt_r(r)}")

    section("3.2 MRS")
    for roi, label in ROIS.items():
        for met, mlabel in METABOLITES.items():
            res = group_contrasts(DATA, f"{roi}_{met}")
            for g in ("DCD", "pDCD"):
                r = res[g]
                lines.append(f"{label} {mlabel}, {g} vs NT: t({res['df']}) = {r['t']:.2f}, "
                             f"p = {fmt_p(r['p'])}, d = {fmt_r(r['d'])}, difference = {r['b']:.2f}, "
                             f"95% CI [{r['ci'][0]:.2f}, {r['ci'][1]:.2f}]")
    for roi, label in ROIS.items():
        for var, name in (("rejected_averages", "rejected averages"), ("water_fwhm", "water FWHM"),
                          ("cr_fwhm", "Cr FWHM")):
            res = group_contrasts(DATA[DATA[f"{roi}_gaba"].notna()], f"{roi}_{var}")
            lines.append(f"{label} {name}: DCD vs NT p = {fmt_p(res['DCD']['p'])}, "
                         f"pDCD vs NT p = {fmt_p(res['pDCD']['p'])}")
    for roi, label in ROIS.items():
        inc = DATA[DATA[f"{roi}_gaba"].notna()]
        med = inc.groupby("group", observed=False)[f"{roi}_rejected_averages"].median().to_dict()
        lines.append(f"{label} included voxels: rejected averages median by group {med}, "
                     f"maximum {inc[f'{roi}_rejected_averages'].max():.0f}; median water FWHM "
                     f"{inc[f'{roi}_water_fwhm'].median():.1f} Hz, Cr FWHM {inc[f'{roi}_cr_fwhm'].median():.1f} Hz, "
                     f"GABA+ fit error {inc[f'{roi}_gaba_fit_error'].median():.1f}%")
    for met in ("gaba", "glx"):
        r = group_by_region(DATA, met)
        lines.append(f"{METABOLITES[met]} group x region: chi2(2) = {r['lr']:.2f}, p = {fmt_p(r['p'])}; "
                     f"group-specific variances: chi2(2) = {r['lr_var']:.2f}, p = {fmt_p(r['p_var'])}, "
                     f"group x region p = {fmt_p(r['p_inter_var'])}")

    section("3.3 Exploratory correlations")
    lines.append(f"Motor vs visual GABA+: {pearson(DATA, 'motor_gaba', 'visual_gaba')}")
    for roi, label in ROIS.items():
        lines.append(f"Age vs {label} GABA+: {pearson(DATA, 'age_years', f'{roi}_gaba')}")
    samples = {"Whole sample": (DATA, SAMPLE),
               "DCD+pDCD": (DATA[DATA["group"] != "NT"], SAMPLE[SAMPLE["group"] != "NT"]),
               "NT": (DATA[DATA["group"] == "NT"], SAMPLE[SAMPLE["group"] == "NT"])}
    for name, (mrs, background) in samples.items():
        lines.append(f"[{name}]")
        for roi, label in ROIS.items():
            for met, mlabel in METABOLITES.items():
                for x, xl in (("gsq_total", "GSQ total"), ("adc_total", "ADC total"),
                              ("mabc2_component_score", "MABC-2 CS")):
                    lines.append(f"  {label} {mlabel} vs {xl}: {pearson(mrs, x, f'{roi}_{met}')}")
        for x, y in (("gsq_proprioceptive_hyper", "motor_gaba"), ("gsq_proprioceptive_hypo", "motor_gaba"),
                     ("gsq_visual_hyper", "visual_gaba"), ("gsq_visual_hypo", "visual_gaba")):
            lines.append(f"  {y} vs {x}: {pearson(mrs, x, y)}")
        for x, y in (("gsq_proprioceptive_hyper", "gsq_proprioceptive_hypo"),
                     ("gsq_visual_hyper", "gsq_visual_hypo")):
            lines.append(f"  {x} vs {y}: {pearson(background, x, y)}")

    section("4. Discussion: ADHD symptoms")
    dcd = SAMPLE[SAMPLE["group"] == "DCD"]
    lines.append(f"DCD with CAARS ADHD Index >= 65: {(dcd['caars_adhd_index'] >= 65).sum()} of {len(dcd)}")
    for roi, label in ROIS.items():
        lines.append(f"ADHD Index vs {label} GABA+ (whole sample): "
                     f"{pearson(DATA, 'caars_adhd_index', f'{roi}_gaba')}")
    return "\n".join(lines)


# Step 5: Figures

COLOURS = {"NT": "#5098C8", "DCD": "#D87058", "pDCD": "#E8A818"}
MARKERS = {"NT": "o", "DCD": "^", "pDCD": "s"}
PLOT_ORDER = ["NT", "DCD", "pDCD"]   # order of groups in the figures, as in Tables 1 and 2


def stars(p):
    return "***" if p < .001 else "**" if p < .01 else "*" if p < .05 else None


def add_brackets(ax, vals, pairwise, top=None, bottom=None):
    """Significance brackets between NT and each clinical group (uncorrected p)."""
    top = max(v.max() for v in vals) if top is None else top
    span = top - (min(v.min() for v in vals) if bottom is None else bottom)
    level = 0
    for g, p in pairwise:
        if stars(p) is None:
            continue
        y, x2 = top + span * (0.08 + 0.1 * level), PLOT_ORDER.index(g)
        ax.plot([0, 0, x2, x2], [y - span * .02, y, y, y - span * .02], color="black", lw=0.8)
        ax.text(x2 / 2, y, stars(p), ha="center", va="bottom")
        level += 1
    ax.set_ylim(top=top + span * (0.15 + 0.1 * level))


def group_panel(ax, df, var, ylabel, rng, pairwise=None):
    """Box plot with individual data points (Figure 1)."""
    vals = [df.loc[df["group"] == g, var].dropna().to_numpy() for g in PLOT_ORDER]
    bp = ax.boxplot(vals, positions=range(3), widths=0.45, showfliers=False, patch_artist=True,
                    medianprops={"color": "black", "lw": 1.2}, whiskerprops={"lw": 0.8},
                    capprops={"lw": 0.8}, boxprops={"lw": 0.8})
    for patch, g in zip(bp["boxes"], PLOT_ORDER):
        patch.set_facecolor(COLOURS[g])
        patch.set_alpha(0.6)
    for i, (g, v) in enumerate(zip(PLOT_ORDER, vals)):
        ax.scatter(i + rng.uniform(-0.13, 0.13, len(v)), v, s=16, color=COLOURS[g],
                   marker=MARKERS[g], edgecolor="white", linewidth=0.4, zorder=3)
    ax.set_xticks(range(3))
    ax.set_xticklabels([f"{g}\n(n = {len(v)})" for g, v in zip(PLOT_ORDER, vals)])
    ax.set_ylabel(ylabel)
    if pairwise:
        add_brackets(ax, vals, pairwise)


def raincloud_panel(ax, df, var, ylabel, rng, pairwise=None):
    """Raincloud plot: individual data points, box plot and half-violin (Figures 2C and 3C)."""
    vals = [df.loc[df["group"] == g, var].dropna().to_numpy() for g in PLOT_ORDER]
    lo, hi = np.inf, -np.inf
    for i, (g, v) in enumerate(zip(PLOT_ORDER, vals)):
        ax.scatter(i - 0.22 + rng.uniform(-0.07, 0.07, len(v)), v, s=14, color=COLOURS[g],
                   marker="o", edgecolor="none", alpha=0.9, zorder=3)
        bp = ax.boxplot([v], positions=[i], widths=0.11, showfliers=False, patch_artist=True,
                        medianprops={"color": "black", "lw": 1.2}, whiskerprops={"lw": 0.8},
                        capprops={"lw": 0}, boxprops={"lw": 0.8})
        bp["boxes"][0].set_facecolor(COLOURS[g])
        bp["boxes"][0].set_alpha(0.5)
        pad = 0.5 * v.std(ddof=1)
        grid = np.linspace(v.min() - pad, v.max() + pad, 200)
        dens = stats.gaussian_kde(v)(grid)
        ax.fill_betweenx(grid, i + 0.09, i + 0.09 + 0.38 * dens / dens.max(), color=COLOURS[g],
                         alpha=0.85, lw=0)
        lo, hi = min(lo, grid[0]), max(hi, grid[-1])
    ax.set_xticks(range(3))
    ax.set_xticklabels([f"{g}\n(n = {len(v)})" for g, v in zip(PLOT_ORDER, vals)])
    ax.set_xlim(-0.5, 2.6)
    ax.set_ylim(lo - 0.03 * (hi - lo), hi + 0.03 * (hi - lo))
    ax.set_xlabel("Group")
    ax.set_ylabel(ylabel)
    if pairwise:
        add_brackets(ax, vals, pairwise, top=hi, bottom=lo)


def scatter_panel(ax, df, x, y, xlabel, ylabel):
    sub = df[[x, y, "group"]].dropna()
    for g in PLOT_ORDER:
        s = sub[sub["group"] == g]
        ax.scatter(s[x], s[y], s=18, color=COLOURS[g], marker=MARKERS[g], edgecolor="white",
                   linewidth=0.4, label=g, zorder=3)
    r, p = stats.pearsonr(sub[x], sub[y])
    slope, icpt = np.polyfit(sub[x], sub[y], 1)
    xs = np.linspace(sub[x].min(), sub[x].max(), 50)
    ax.plot(xs, icpt + slope * xs, color="#555555", lw=1.2)
    ax.set_title(f"r = {fmt_r(r)}, p = {fmt_p(p)}, n = {len(sub)}", loc="left", fontsize=8,
                 color="#222222")
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)


def make_figures():
    plt.rcParams.update({"font.family": "Arial", "font.size": 9, "axes.spines.top": False,
                         "axes.spines.right": False, "axes.linewidth": 0.8,
                         "savefig.dpi": 300, "savefig.bbox": "tight"})
    rng = np.random.default_rng(2024)  # fixed jitter so the figures are reproducible
    figures = OUTPUT / "figures"
    figures.mkdir(parents=True, exist_ok=True)

    # Figure 1: key GSQ variables (Mann-Whitney U for subscales, linear model for the total)
    keys = [(f"gsq_{m}_{k}", f"{m.capitalize()} {k}sensitivity")
            for m in ("visual", "auditory", "tactile", "proprioceptive") for k in ("hyper", "hypo")]
    nt = SAMPLE[SAMPLE["group"] == "NT"]
    fig, axes = plt.subplots(3, 3, figsize=(7.2, 8.2))
    for ax, (var, label), letter in zip(axes.flat, keys, "ABCDEFGH"):
        p = [(g, mann_whitney(nt[var].dropna(), SAMPLE.loc[SAMPLE["group"] == g, var].dropna())[1])
             for g in ("pDCD", "DCD")]
        group_panel(ax, SAMPLE, var, label, rng, p)
        ax.text(-0.28, 1.04, letter, transform=ax.transAxes, fontweight="bold", fontsize=11)
    res = group_contrasts(SAMPLE, "gsq_total")
    group_panel(axes.flat[8], SAMPLE, "gsq_total", "GSQ total score", rng,
                [(g, res[g]["p"]) for g in ("pDCD", "DCD")])
    axes.flat[8].text(-0.28, 1.04, "I", transform=axes.flat[8].transAxes, fontweight="bold", fontsize=11)
    fig.tight_layout()
    fig.savefig(figures / "Figure1_GSQ.png")
    plt.close(fig)

    # Figures 2C and 3C: metabolites by group (raincloud plots; brackets show linear-model contrasts)
    for roi, name in (("motor", "Figure2C_motor_metabolites"), ("visual", "Figure3C_visual_metabolites")):
        fig, axes = plt.subplots(1, 3, figsize=(7.2, 2.9))
        for ax, (met, label) in zip(axes, (("gaba", "GABA+ Concentration"), ("glx", "Glx Concentration"),
                                           ("glx_gaba", "Glx/GABA+ Ratio"))):
            res = group_contrasts(DATA, f"{roi}_{met}")
            raincloud_panel(ax, DATA, f"{roi}_{met}", label, rng,
                            [(g, res[g]["p"]) for g in ("DCD", "pDCD")])
        axes[0].text(-0.32, 1.02, "C", transform=axes[0].transAxes, fontweight="bold", fontsize=12)
        fig.tight_layout()
        fig.savefig(figures / f"{name}.png")
        plt.close(fig)

    # Figures 4 and 5: metabolites against background measures
    xs = (("gsq_total", "GSQ total score"), ("adc_total", "ADC total score"),
          ("mabc2_component_score", "MABC-2 component score"))
    ys = (("gaba", "GABA+ (i.u.)"), ("glx", "Glx (i.u.)"), ("glx_gaba", "Glx/GABA+"))
    for roi, name in (("motor", "Figure4_motor_correlations"), ("visual", "Figure5_visual_correlations")):
        fig, axes = plt.subplots(3, 3, figsize=(7.2, 7.0))
        for i, (met, ylab) in enumerate(ys):
            for j, (x, xlab) in enumerate(xs):
                scatter_panel(axes[i, j], DATA, x, f"{roi}_{met}", xlab if i == 2 else "",
                              ylab if j == 0 else "")
        handles, labels = axes[0, 0].get_legend_handles_labels()
        fig.legend(handles, labels, loc="lower center", ncol=3, frameon=False)
        fig.suptitle(f"{ROIS[roi]} ROI", x=0.02, ha="left", fontweight="bold")
        fig.tight_layout(rect=(0, 0.04, 1, 1))
        fig.savefig(figures / f"{name}.png")
        plt.close(fig)

    # Figure 6: GABA+ against the modality-matched GSQ subscales
    panels = (("gsq_proprioceptive_hypo", "motor_gaba", "Proprioceptive hyposensitivity", "Motor GABA+ (i.u.)"),
              ("gsq_proprioceptive_hyper", "motor_gaba", "Proprioceptive hypersensitivity", "Motor GABA+ (i.u.)"),
              ("gsq_visual_hypo", "visual_gaba", "Visual hyposensitivity", "Visual GABA+ (i.u.)"),
              ("gsq_visual_hyper", "visual_gaba", "Visual hypersensitivity", "Visual GABA+ (i.u.)"))
    fig, axes = plt.subplots(2, 2, figsize=(6.0, 5.4))
    for ax, (x, y, xl, yl), letter in zip(axes.flat, panels, "ABCD"):
        scatter_panel(ax, DATA, x, y, xl, yl)
        ax.text(-0.22, 1.04, letter, transform=ax.transAxes, fontweight="bold", fontsize=11)
    handles, labels = axes[0, 0].get_legend_handles_labels()
    fig.legend(handles, labels, loc="lower center", ncol=3, frameon=False)
    fig.tight_layout(rect=(0, 0.05, 1, 1))
    fig.savefig(figures / "Figure6_GABA_vs_GSQ.png")
    plt.close(fig)


def main():
    OUTPUT.mkdir(exist_ok=True)
    table1().to_csv(OUTPUT / "Table1_background.csv", index=False)
    table2().to_csv(OUTPUT / "Table2_voxel_composition_and_fit.csv", index=False)
    table_s1().to_csv(OUTPUT / "TableS1_GSQ.csv", index=False)
    make_figures()
    print(results_text())


if __name__ == "__main__":
    main()
