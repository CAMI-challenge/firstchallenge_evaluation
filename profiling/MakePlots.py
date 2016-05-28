import sys
import numpy as np
script_directory = '/Users/dkoslicki/Dropbox/Repositories/firstchallenge_evaluation/profiling/MyAnalysis/Scripts'
sys.path.extend([script_directory])
import matplotlib as mpl
mpl.use('TkAgg')
import matplotlib.pyplot as plt
import AnalyzeData as AD
import time

# The following is to allow the user to press "c" and have the current figure saved to /tmp/fig.png
# or press "w" to save and close
# To automatically trim the white space, use imagemajick: cd /tmp; ls *.png | xargs -I{} convert {} -trim {}
import matplotlib
if not globals().has_key('__figure'):
    __figure = matplotlib.pyplot.figure


def on_key(event):
    """
     This function will save the current figure to /tmp/fig.png upon pressing 'c'. Pressing 'w' will save the figure to /tmp/fig<timestamp> and close the figure
    """
    print event
    if event.key=='c':
        plt.savefig("/tmp/fig.png",bbox_inches='tight')
    if event.key=='w':
        plt.savefig("/tmp/fig" + str(time.time())+".png",bbox_inches=0)
        plt.close()
def my_figure():
    fig = __figure()
    fig.canvas.mpl_connect('key_press_event',on_key)
    return fig
matplotlib.pyplot.figure = my_figure


# Get the metric result files.
# Assumes that the results are organized out as follows:
# DescriptionFiles.txt: List of full paths to the *.description files (eg: /path/to/profiling/data/submissions_evaluation/00fda87642a7d7279f31bb65/description.properties
# The directory containing the description file should contain the folders "input" and "output", with "metrics.txt" in "output":
#
# profiling/data/submissions_evaluation/00fda87642a7d7279f31bb65/ <-directory name of one entry of DescriptionFiles.txt
# |--description.properties
# |--input
# |   |--biobox.yaml
# |--output
# |   |--biobox.yaml
# |   |--metrics.txt
#
mac = 'y'
if mac=='y':
    base_dir = '/Users/dkoslicki/Dropbox/Repositories/firstchallenge_evaluation/profiling/MyAnalysis/'  # Mac
    description_files = []
    fid = open(base_dir + '/Data/DescriptionFiles.txt','r')  # Mac
    for line in fid:
        description_files.append(line.strip())
    fid.close()
else:
    base_dir = 'C:\\Users\\David\\Dropbox\\Repositories\\firstchallenge_evaluation\\profiling\\MyAnalysis'  # Windows
    description_files = []
    fid = open(base_dir + '\\Data\\DescriptionFiles.txt', 'r')  # Windows
    for line in fid:
        description_files.append(line.strip())
    fid.close()
    description_files_windows = list()
    for item in description_files:
        description_files_windows.append('C:\\Users\\David\\Dropbox\\Repositories\\firstchallenge_evaluation\\profiling\\data\\submissions_evaluation\\' + '\\'.join(item.split('/')[9:11]))
    description_files = description_files_windows

###################################################
# Parse results
# Format is:
# results[method][version][competition][sample_name][truth_type] = metrics_content
# with
# metrics_content[metric][rank] = value
(results, names, competitions, sample_names, truth_types, metrics, ranks) = AD.parse_results(description_files, mac=mac)

###############################################
# Binning results.
# Note, this will add the binning results to each plot. Do not evaluate these if you want *just* the profiling results

binning_results_dir = "/Users/dkoslicki/Dropbox/Repositories/firstchallenge_evaluation/profiling/MyAnalysis/BinnerResults"
binning_names = ["evil_yalow_2","fervent_sammet_2","modest_babbage_6", "prickly_fermi_0"]
sample = 'CAMI_low_S001'
(results2, names2, competitions2, sample_names2, truth_types2, metrics2, ranks2) = AD.add_binning(binning_results_dir, binning_names, results, sample)
names = set(names)
names.update(names2)
names = list(names)

binning_results_dir = "/Users/dkoslicki/Dropbox/Repositories/firstchallenge_evaluation/profiling/MyAnalysis/BinnerResults/medium"
binning_names = ['evil_yalow_1','fervent_sammet_0','modest_babbage_1','modest_babbage_2','modest_babbage_4','prickly_fermi_1']
sample = 'CAMI_medium'
(results2, names2, competitions2, sample_names2, truth_types2, metrics2, ranks2) = AD.add_binning(binning_results_dir, binning_names, results, sample)
names = set(names)
names.update(names2)
names = list(names)

binning_results_dir = "/Users/dkoslicki/Dropbox/Repositories/firstchallenge_evaluation/profiling/MyAnalysis/BinnerResults/high"
binning_names = ['evil_yalow_0','fervent_sammet_1','modest_babbage_0','modest_babbage_3','prickly_fermi_2']
sample = 'CAMI_high'
(results2, names2, competitions2, sample_names2, truth_types2, metrics2, ranks2) = AD.add_binning(binning_results_dir, binning_names, results, sample)
names = set(names)
names.update(names2)
names = list(names)
####################################
# Versions

# Get the versions with multiple names
base_names = list()
for name in names:
    base_name = name.split('_')[0]
    base_names.append(base_name)

base_names_with_mult_vers = list()
for base_name in set(base_names):
    if base_names.count(base_name) > 1:
        base_names_with_mult_vers.append(base_name)

for base_name in base_names_with_mult_vers:
    to_plot = list()
    for name in names:
        if name.split('_')[0] == base_name:
            to_plot.append(name)
    plt.figure()
    AD.plot_versus_rank(results,
                        to_plot,
                     'CAMI_low_S001',
                     'filtered',
                     'L1norm',
                     ['superkingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species', 'strain']
                     )

for base_name in base_names_with_mult_vers:
    to_plot = list()
    for name in names:
        if name.split('_')[0] == base_name:
            to_plot.append(name)
    plt.figure()
    AD.plot_versus_rank(results,
                        to_plot,
                     'CAMI_high',
                     'filtered',
                     'Sensitivity: TP/(TP+FN)',
                     ['superkingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species', 'strain']
                     )

for base_name in base_names_with_mult_vers:
    to_plot = list()
    for name in names:
        if name.split('_')[0] == base_name:
            to_plot.append(name)
    plt.figure()
    AD.plot_versus_rank(results,
                        to_plot,
                     'CAMI_high',
                     'filtered',
                     'False Positives',
                     ['superkingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species', 'strain']
                     )

for base_name in base_names_with_mult_vers:
    to_plot = list()
    for name in names:
        if name.split('_')[0] == base_name:
            to_plot.append(name)
    plt.figure()
    AD.plot_versus_rank(results,
                        to_plot,
                     'CAMI_HIGH_S005',
                     'filtered',
                     'False Positives',
                     ['superkingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species', 'strain']
                     )


################################
# Fix taxonomic ranks
#for rank in ['superkingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species', 'strain']:
#    plt.figure()
#    AD.plot_bar_at_rank(results,
#                        results.keys(),
#                        'CAMI_low_S001',
#                        'filtered',
#                        'False Positives',
#                        rank
#                        )
colors = np.array([[0.000000,0.000000,1.000000],[1.000000,0.000000,0.000000],[0.000000,1.000000,0.000000],[0.000000,0.000000,0.172414],[1.000000,0.103448,0.724138],[1.000000,0.827586,0.000000],[0.000000,0.344828,0.000000],[0.517241,0.517241,1.000000],[0.620690,0.310345,0.275862],[0.000000,1.000000,0.758621],[0.000000,0.517241,0.586207],[0.000000,0.000000,0.482759],[0.586207,0.827586,0.310345],[0.965517,0.620690,0.862069],[0.827586,0.068966,1.000000],[0.482759,0.103448,0.413793],[0.965517,0.068966,0.379310],[1.000000,0.758621,0.517241],[0.137931,0.137931,0.034483],[0.551724,0.655172,0.482759],[0.965517,0.517241,0.034483]])
AD.spider_plot(results,
            ['L1norm'],
            ['L1norm'],
            results.keys(),
            'CAMI_low_S001',
            'filtered',
            ['phylum', 'class', 'order', 'family', 'genus', 'species'],
            colors,
            2,
            3,
            grid_points=[.4,.8,1.2,1.6,2.0],
            label_grid='y',
            normalize='n',
            legend_loc=(-.5, 1.1),
            fill='y',
            max_plot=2)


AD.spider_plot(results,
            ['Precision: TP/(TP+FP)'],
            ['Precision'],
            results.keys(),
            'CAMI_MED_S001',
            'filtered',
            ['phylum', 'class', 'order', 'family', 'genus', 'species'],
            [colors[1]],
            2,
            3,
            grid_points=[.2,.4,.6,.8],
            label_grid='y',
            normalize='n',
            legend_loc=(-.5, 1.1),
            fill='y',
            max_plot=1)

AD.spider_plot(results,
            ['Sensitivity: TP/(TP+FN)'],
            ['Sensitivity'],
            results.keys(),
            'CAMI_HIGH_S001',
            'filtered',
            ['phylum', 'class', 'order', 'family', 'genus', 'species'],
            [colors[2]],
            2,
            3,
            grid_points=[.2,.4,.6,.8],
            label_grid='y',
            normalize='n',
            legend_loc=(-.5, 1.1),
            fill='y',
            max_plot=1)

###################
# With binning.
# NOTE: RUN THE QUICK HACK add_binning BEFORE EVALUATING THE FOLLOWING TO INCLUDE THE BINNING METHODS
colors = np.array([[0.000000,0.000000,1.000000],[1.000000,0.000000,0.000000],[0.000000,1.000000,0.000000],[0.000000,0.000000,0.172414],[1.000000,0.103448,0.724138],[1.000000,0.827586,0.000000],[0.000000,0.344828,0.000000],[0.517241,0.517241,1.000000],[0.620690,0.310345,0.275862],[0.000000,1.000000,0.758621],[0.000000,0.517241,0.586207],[0.000000,0.000000,0.482759],[0.586207,0.827586,0.310345],[0.965517,0.620690,0.862069],[0.827586,0.068966,1.000000],[0.482759,0.103448,0.413793],[0.965517,0.068966,0.379310],[1.000000,0.758621,0.517241],[0.137931,0.137931,0.034483],[0.551724,0.655172,0.482759],[0.965517,0.517241,0.034483]])

#Low complexity
AD.spider_plot(results,
            ['L1norm'],
            ['L1norm'],
            results.keys(),
            'CAMI_low_S001',
            'filtered',
            ['phylum', 'class', 'order', 'family', 'genus', 'species'],
            colors,
            2,
            3,
            grid_points=[.4,.8,1.2,1.6,2.0],
            label_grid='y',
            normalize='n',
            legend_loc=(-.5, 1.1),
            fill='y',
            max_plot=2)

AD.spider_plot(results,
            ['Precision: TP/(TP+FP)'],
            ['Precision'],
            results.keys(),
            'CAMI_low_S001',
            'filtered',
            ['phylum', 'class', 'order', 'family', 'genus', 'species'],
            [colors[1]],
            2,
            3,
            grid_points=[.2,.4,.6,.8],
            label_grid='y',
            normalize='n',
            legend_loc=(-.5, 1.1),
            fill='y',
            max_plot=1)

AD.spider_plot(results,
            ['Sensitivity: TP/(TP+FN)'],
            ['Sensitivity'],
            results.keys(),
            'CAMI_low_S001',
            'filtered',
            ['phylum', 'class', 'order', 'family', 'genus', 'species'],
            [colors[2]],
            2,
            3,
            grid_points=[.2,.4,.6,.8],
            label_grid='y',
            normalize='n',
            legend_loc=(-.5, 1.1),
            fill='y',
            max_plot=1)

#Medium complexity
AD.spider_plot(results,
            ['L1norm'],
            ['L1norm'],
            results.keys(),
            'CAMI_medium',
            'filtered',
            ['phylum', 'class', 'order', 'family', 'genus', 'species'],
            colors,
            2,
            3,
            grid_points=[.4,.8,1.2,1.6,2.0],
            label_grid='y',
            normalize='n',
            legend_loc=(-.5, 1.1),
            fill='y',
            max_plot=2)

AD.spider_plot(results,
            ['Precision: TP/(TP+FP)'],
            ['Precision'],
            results.keys(),
            'CAMI_medium',
            'filtered',
            ['phylum', 'class', 'order', 'family', 'genus', 'species'],
            [colors[1]],
            2,
            3,
            grid_points=[.2,.4,.6,.8],
            label_grid='y',
            normalize='n',
            legend_loc=(-.5, 1.1),
            fill='y',
            max_plot=1)

AD.spider_plot(results,
            ['Sensitivity: TP/(TP+FN)'],
            ['Sensitivity'],
            results.keys(),
            'CAMI_medium',
            'filtered',
            ['phylum', 'class', 'order', 'family', 'genus', 'species'],
            [colors[2]],
            2,
            3,
            grid_points=[.2,.4,.6,.8],
            label_grid='y',
            normalize='n',
            legend_loc=(-.5, 1.1),
            fill='y',
            max_plot=1)



#High complexity
AD.spider_plot(results,
            ['L1norm'],
            ['L1norm'],
            results.keys(),
            'CAMI_high',
            'filtered',
            ['phylum', 'class', 'order', 'family', 'genus', 'species'],
            colors,
            2,
            3,
            grid_points=[.4,.8,1.2,1.6,2.0],
            label_grid='y',
            normalize='n',
            legend_loc=(-.5, 1.1),
            fill='y',
            max_plot=2)

AD.spider_plot(results,
            ['Precision: TP/(TP+FP)'],
            ['Precision'],
            results.keys(),
            'CAMI_high',
            'filtered',
            ['phylum', 'class', 'order', 'family', 'genus', 'species'],
            [colors[1]],
            2,
            3,
            grid_points=[.2,.4,.6,.8],
            label_grid='y',
            normalize='n',
            legend_loc=(-.5, 1.1),
            fill='y',
            max_plot=1)

AD.spider_plot(results,
            ['Sensitivity: TP/(TP+FN)'],
            ['Sensitivity'],
            results.keys(),
            'CAMI_high',
            'filtered',
            ['phylum', 'class', 'order', 'family', 'genus', 'species'],
            [colors[2]],
            2,
            3,
            grid_points=[.2,.4,.6,.8],
            label_grid='y',
            normalize='n',
            legend_loc=(-.5, 1.1),
            fill='y',
            max_plot=1)


##############################
# Filtering
plt.figure()
AD.plot_versus_rank(results,
                    results.keys(),
                     'CAMI_high',
                     'filtered',
                     'False Positives',
                     ['superkingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species', 'strain']
                     )

plt.figure()
AD.plot_versus_rank(results,
                    results.keys(),
                     'CAMI_high',
                     'all',
                     'False Positives',
                     ['superkingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species', 'strain']
                     )

plt.figure()
AD.plot_bar_at_rank(results,
                    sorted(results.keys()),
                    'CAMI_low_S001',
                    'all',
                    'L1norm',
                    'superkingdom',
                    sort='n',
                    lim=[0,.4])

plt.figure()
AD.plot_bar_at_rank(results,
                    sorted(results.keys()),
                    'CAMI_low_S001',
                    'filtered',
                    'L1norm',
                    'superkingdom',
                    sort='n',
                    lim=[0,.4])

plt.figure()
AD.plot_bar_at_rank(results,
                    sorted(results.keys()),
                    'CAMI_low_S001',
                    'all',
                    'Unifrac',
                    'rank independent',
                    sort='n',
                    lim=[0,16])

plt.figure()
AD.plot_bar_at_rank(results,
                    sorted(results.keys()),
                    'CAMI_low_S001',
                    'filtered',
                    'Unifrac',
                    'rank independent',
                    sort='n',
                    lim=[0,16])

################################
# Sensitivity/specificity etc.


AD.metric1_vs_metric2(results,
                       'CAMI_MED_S001',
                       'filtered',
                       ['phylum', 'class', 'order', 'family', 'genus', 'species'],
                       ['Sensitivity: TP/(TP+FN)', 'Precision: TP/(TP+FP)'],
                       ['Sensitivity', 'Precision'],
                       results.keys(),
                       2,
                       3)

AD.metric1_vs_metric2(results,
                       'CAMI_MED_S002',
                       'filtered',
                       ['phylum', 'class', 'order', 'family', 'genus', 'species'],
                       ['Sensitivity: TP/(TP+FN)', 'Precision: TP/(TP+FP)'],
                       ['Sensitivity', 'Precision'],
                       results.keys(),
                       2,
                       3)

AD.metric1_vs_metric2(results,
                       'CAMI_HIGH_S001',
                       'filtered',
                       ['phylum', 'class', 'order', 'family', 'genus', 'species'],
                       ['Sensitivity: TP/(TP+FN)', 'Precision: TP/(TP+FP)'],
                       ['Sensitivity', 'Precision'],
                       results.keys(),
                       2,
                       3)

# Gustav_s FP
plot_ranks = ['superkingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species', 'strain']
plt.plot([results['Gustav_s']['CAMI Challenge']['CAMI_HIGH_S001']['filtered']['False Positives'][rank] for rank in plot_ranks], linewidth=2)
plt.plot([AD.get_TPs('CAMI_HIGH_S001')[rank] for rank in plot_ranks], linewidth=2)
plt.xticks(range(len(plot_ranks)), plot_ranks, rotation=-45)
plt.tick_params(axis='both', which='major', labelsize=16)
plt.subplots_adjust(bottom=0.3)
plt.xlabel('Rank', fontsize=16)
plt.ylabel('False Positives', fontsize=16)
plt.legend(['Gustav_s', 'Ground Truth Positives'], loc=2)
plt.title('CAMI_HIGH_S001' + ", " + 'filtered', fontsize=16)
plt.show()

AD.spider_plot(results,
            ['Precision: TP/(TP+FP)'],
            ['Precision'],
            results.keys(),
            'CAMI_HIGH_S001',
            'filtered',
            ['genus'],
            [[1.,0.,0.]],
            1,
            1,
            grid_points=[.2,.4,.6,.8,1.],
            label_grid='y',
            normalize='n',
            legend_loc=(-.5, 1.1),
            fill='y',
            max_plot=1)




################################
# Spider plots at each rank

colors = np.array([[0.000000,0.000000,1.000000],[1.000000,0.000000,0.000000],[0.000000,1.000000,0.000000],[0.000000,0.000000,0.172414],[1.000000,0.103448,0.724138],[1.000000,0.827586,0.000000],[0.000000,0.344828,0.000000],[0.517241,0.517241,1.000000],[0.620690,0.310345,0.275862],[0.000000,1.000000,0.758621],[0.000000,0.517241,0.586207],[0.000000,0.000000,0.482759],[0.586207,0.827586,0.310345],[0.965517,0.620690,0.862069],[0.827586,0.068966,1.000000],[0.482759,0.103448,0.413793],[0.965517,0.068966,0.379310],[1.000000,0.758621,0.517241],[0.137931,0.137931,0.034483],[0.551724,0.655172,0.482759],[0.965517,0.517241,0.034483]])
AD.spider_plot(results,
            ['Unifrac', 'Sensitivity: TP/(TP+FN)', 'L1norm', 'Precision: TP/(TP+FP)', 'False Positives'],
            ['Unifrac error', 'Sensitivity', 'L1norm error', 'Precision', 'False Positives'],
            results.keys(),
            'CAMI_low_S001',
            'filtered',
            ['phylum', 'class', 'order', 'family', 'genus', 'species'],
            colors,
            2,
            3,
            grid_points=[.2,.4,.6,.8],
            label_grid='n',
            normalize='y',
            legend_loc=(-.5, 1.1),
            fill='n',
            max_plot=1)


AD.spider_plot(results,
            ['Unifrac', 'Sensitivity: TP/(TP+FN)', 'L1norm', 'Precision: TP/(TP+FP)', 'False Positives'],
            ['Unifrac error', 'Sensitivity', 'L1norm error', 'Precision', 'False Positives'],
            results.keys(),
            'CAMI_low_S001',
            'all',
            ['phylum', 'class', 'order', 'family', 'genus', 'species'],
            colors,
            2,
            3,
            grid_points=[.2,.4,.6,.8],
            label_grid='n',
            normalize='y',
            legend_loc=(-.5, 1.1),
            fill='n',
            max_plot=1)

AD.spider_plot(results,
            ['Unifrac', 'Sensitivity: TP/(TP+FN)', 'L1norm', 'Precision: TP/(TP+FP)', 'False Positives'],
            ['Unifrac error', 'Sensitivity', 'L1norm error', 'Precision', 'False Positives'],
            results.keys(),
            'CAMI_MED_S001',
            'filtered',
            ['phylum', 'class', 'order', 'family', 'genus', 'species'],
            colors,
            2,
            3,
            grid_points=[.2,.4,.6,.8],
            label_grid='n',
            normalize='y',
            legend_loc=(-.5, 1.1),
            fill='n',
            max_plot=1)

AD.spider_plot(results,
            ['Unifrac', 'Sensitivity: TP/(TP+FN)', 'L1norm', 'Precision: TP/(TP+FP)', 'False Positives'],
            ['Unifrac error', 'Sensitivity', 'L1norm error', 'Precision', 'False Positives'],
            results.keys(),
            'CAMI_medium',
            'filtered',
            ['phylum', 'class', 'order', 'family', 'genus', 'species'],
            colors,
            2,
            3,
            grid_points=[.2,.4,.6,.8],
            label_grid='n',
            normalize='y',
            legend_loc=(-.5, 1.1),
            fill='n',
            max_plot=1)

AD.spider_plot(results,
            ['Unifrac', 'Sensitivity: TP/(TP+FN)', 'L1norm', 'Precision: TP/(TP+FP)', 'False Positives'],
            ['Unifrac error', 'Sensitivity', 'L1norm error', 'Precision', 'False Positives'],
            results.keys(),
            'CAMI_HIGH_S001',
            'filtered',
            ['phylum', 'class', 'order', 'family', 'genus', 'species'],
            colors,
            2,
            3,
            grid_points=[.2,.4,.6,.8],
            label_grid='n',
            normalize='y',
            legend_loc=(-.5, 1.1),
            fill='n',
            max_plot=1)

AD.spider_plot(results,
            ['Unifrac', 'Sensitivity: TP/(TP+FN)', 'L1norm', 'Precision: TP/(TP+FP)', 'False Positives'],
            ['Unifrac error', 'Sensitivity', 'L1norm error', 'Precision', 'False Positives'],
            results.keys(),
            'CAMI_high',
            'filtered',
            ['phylum', 'class', 'order', 'family', 'genus', 'species'],
            colors,
            2,
            3,
            grid_points=[.2,.4,.6,.8],
            label_grid='n',
            normalize='y',
            legend_loc=(-.5, 1.1),
            fill='n',
            max_plot=1)


#####################
# Who wins at which rank
# Press "w", then trim with: ls fig* | xargs -I{} convert {} -trim {}
colors = np.array([[0.000000,0.000000,1.000000],[1.000000,0.000000,0.000000],[0.000000,1.000000,0.000000],[0.000000,0.000000,0.172414],[1.000000,0.103448,0.724138],[1.000000,0.827586,0.000000],[0.000000,0.344828,0.000000],[0.517241,0.517241,1.000000],[0.620690,0.310345,0.275862],[0.000000,1.000000,0.758621],[0.000000,0.517241,0.586207],[0.000000,0.000000,0.482759],[0.586207,0.827586,0.310345],[0.965517,0.620690,0.862069],[0.827586,0.068966,1.000000],[0.482759,0.103448,0.413793],[0.965517,0.068966,0.379310],[1.000000,0.758621,0.517241],[0.137931,0.137931,0.034483],[0.551724,0.655172,0.482759],[0.965517,0.517241,0.034483],[0.517241,0.448276,0.000000],[0.448276,0.965517,1.000000],[0.620690,0.758621,1.000000],[0.448276,0.379310,0.482759],[0.620690,0.000000,0.000000],[0.000000,0.310345,1.000000],[0.000000,0.275862,0.586207],[0.827586,1.000000,0.000000],[0.724138,0.310345,0.827586],[0.241379,0.000000,0.103448],[0.931034,1.000000,0.689655],[1.000000,0.482759,0.379310],[0.275862,1.000000,0.482759],[0.068966,0.655172,0.379310],[0.827586,0.655172,0.655172]])
name_to_color = dict()
it = 0
for name in results.keys():
    name_to_color[name] = colors[it]
    it+=1

name_to_color[''] = [1,1,1]

table_text = AD.rank_table(results,
           'True Positives',
           'TP',
           'CAMI_low_S001',
           ['phylum', 'class', 'order', 'family', 'genus', 'species'],
           results.keys(),
           'filtered',
           name_to_color,
           metric_label='n',
           table_label='y'
           )
AD.winners(table_text)

all_samples = []
for sample_name in ['CAMI_low_S001', 'CAMI_MED_S001', 'CAMI_HIGH_S001']:
    table_text = AD.rank_table(results,
               'True Positives',
               'True Positives',
               sample_name,
               ['phylum', 'class', 'order', 'family', 'genus', 'species'],
               results.keys(),
               'filtered',
               name_to_color,
               metric_label='n',
               table_label='y'
               )
    for item in AD.winners(table_text):
        all_samples.append(item)
    print(AD.winners(table_text))

winner_winners = []
for name in list(set([x[1] for x in all_samples])):
    indicies = [ind for ind, val in enumerate(all_samples) if val[1] == name]
    if len(indicies) == 3:
        winner_winners.append((sum([all_samples[ind][0] for ind in indicies]), name))

print(sorted(winner_winners))  # total ranks across three samples.

all_samples = []
for sample_name in ['CAMI_low_S001', 'CAMI_MED_S001', 'CAMI_HIGH_S001']:
    table_text = AD.rank_table(results,
               'Sensitivity: TP/(TP+FN)',
               'Sensitivity',
               sample_name,
               ['phylum', 'class', 'order', 'family', 'genus', 'species'],
               results.keys(),
               'filtered',
               name_to_color,
               metric_label='n',
               table_label='y'
               )
    for item in AD.winners(table_text):
        all_samples.append(item)
    print(AD.winners(table_text))

winner_winners = []
for name in list(set([x[1] for x in all_samples])):
    indicies = [ind for ind, val in enumerate(all_samples) if val[1] == name]
    if len(indicies) == 3:
        winner_winners.append((sum([all_samples[ind][0] for ind in indicies]), name))

print(sorted(winner_winners))  # total ranks across three samples.

all_samples = []
for sample_name in ['CAMI_low_S001', 'CAMI_MED_S001', 'CAMI_HIGH_S001']:
    table_text = AD.rank_table(results,
               'Precision: TP/(TP+FP)',
               'Precision',
               sample_name,
               ['phylum', 'class', 'order', 'family', 'genus', 'species'],
               results.keys(),
               'filtered',
               name_to_color,
               metric_label='n',
               table_label='y'
               )
    for item in AD.winners(table_text):
        all_samples.append(item)
    print(AD.winners(table_text))

winner_winners = []
for name in list(set([x[1] for x in all_samples])):
    indicies = [ind for ind, val in enumerate(all_samples) if val[1] == name]
    if len(indicies) == 3:
        winner_winners.append((sum([all_samples[ind][0] for ind in indicies]), name))

print(sorted(winner_winners))  # total ranks across three samples. The top one is "chicken dinner". Get it? Winner winner chicken dinner. Boy am I tired.

all_samples = []
for sample_name in ['CAMI_low_S001', 'CAMI_MED_S001', 'CAMI_HIGH_S001']:
    table_text = AD.rank_table(results,
               'False Positives',
               'False Positives',
               sample_name,
               ['phylum', 'class', 'order', 'family', 'genus', 'species'],
               results.keys(),
               'filtered',
               name_to_color,
               metric_label='n',
               table_label='y'
               )
    for item in AD.winners(table_text):
        all_samples.append(item)
    print(AD.winners(table_text))

winner_winners = []
for name in list(set([x[1] for x in all_samples])):
    indicies = [ind for ind, val in enumerate(all_samples) if val[1] == name]
    if len(indicies) == 3:
        winner_winners.append((sum([all_samples[ind][0] for ind in indicies]), name))

print(sorted(winner_winners))  # total ranks across three samples.

all_samples = []
for sample_name in ['CAMI_low_S001', 'CAMI_MED_S001', 'CAMI_HIGH_S001']:
    table_text = AD.rank_table(results,
               'L1norm',
               'L1norm',
               sample_name,
               ['phylum', 'class', 'order', 'family', 'genus', 'species'],
               results.keys(),
               'filtered',
               name_to_color,
               metric_label='n',
               table_label='y'
               )
    for item in AD.winners(table_text):
        all_samples.append(item)
    print(AD.winners(table_text))

winner_winners = []
for name in list(set([x[1] for x in all_samples])):
    indicies = [ind for ind, val in enumerate(all_samples) if val[1] == name]
    if len(indicies) == 3:
        winner_winners.append((sum([all_samples[ind][0] for ind in indicies]), name))

print(sorted(winner_winners))  # total ranks across three samples.

all_samples = []
for sample_name in ['CAMI_low_S001', 'CAMI_MED_S001', 'CAMI_HIGH_S001']:
    table_text = AD.rank_table(results,
               'Unifrac',
               'Unifrac',
               sample_name,
               ['rank independent'],
               results.keys(),
               'filtered',
               name_to_color,
               metric_label='n',
               table_label='y'
               )
    for item in AD.winners(table_text):
        all_samples.append(item)
    print(AD.winners(table_text))

winner_winners = []
for name in list(set([x[1] for x in all_samples])):
    indicies = [ind for ind, val in enumerate(all_samples) if val[1] == name]
    if len(indicies) == 3:
        winner_winners.append((sum([all_samples[ind][0] for ind in indicies]), name))

print(sorted(winner_winners))  # total ranks across three samples.
