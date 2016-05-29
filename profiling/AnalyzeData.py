import os, re
import numpy as np
import matplotlib as mpl
#mpl.use('TkAgg')
import matplotlib.pyplot as plt
from matplotlib.path import Path
from matplotlib.spines import Spine
from matplotlib.projections.polar import PolarAxes
from matplotlib.projections import register_projection

# Format is:
# results[method][version][competition][sample_name][truth_type] = metrics_content
# with
# metrics_content[metric][rank] = value


def name_to_anonymous_name(name, version):
    if name == 'Common Kmers' and version == '':
        return 'Adam_s_1'
    elif name == 'Common Kmers' and version == 'Sensitive Unnormalized':
        return 'Adam_s_2'
    elif name == 'commonkmers' and version == 'sjanssen':
        return 'Adam_d'
    elif name == 'FOCUS' and version == 'cfk8bd':
        return 'Brian_s_1'
    elif name == 'FOCUS' and version == 'cfk7bd':
        return 'Brian_s_2'
    elif name == 'FOCUS' and version == 'cfk7d':
        return 'Brian_s_3'
    elif name == 'FOCUS' and version == 'cfk7b':
        return 'Brian_s_4'
    elif name == 'FOCUS' and version == 'cfk8b':
        return 'Brian_s_5'
    elif name == 'FOCUS' and version == 'cfk8d':
        return 'Brian_s_6'
    elif name == 'FOCUS' and version == 'sjanssen':
        return 'Brian_d'
    elif name == 'DUDes' and version == 'old':
        return 'Cesar_s_2'
    elif name == 'DUDes' and version == '':
        return 'Cesar_s_1'
    elif name == 'Taxy-Pro' and version == 'sjanssen':
        return 'Donald_d'
    elif name == 'Taxy-Pro' and version == '':
        return 'Donald_s'
    elif name == 'MetaPhyler' and version == 'V1.25':
        return 'Edd_d'
    elif name == 'mOTU' and version == '1.1.1':
        return 'Frank_d'
    elif name == 'CLARK' and version == 'v1.1.3':
        return 'Gustav_s'
    elif name == 'MetaPhlAn2.0' and version == 'db_v20':
        return 'Hank_d'
    elif name == 'TIPP' and version == '1.1':
        return 'Isaac_d'
    elif name == 'mpipe' and version == '':
        return 'Jack_s'
    elif name == 'Quickr' and version == 'sjanssen':
        return 'Kirk_d'
    else:
        output = name
        if version != '':
            output = output + "_" + version
        output = output.replace(" ", "")
        return output

def get_TPs(sample_name, truth_type='filtered'):
    """
    This function returns a dictionary giving the true number of taxa ranks for each sample. Obtained via:
    cd /Users/dkoslicki/Dropbox/Repositories/firstchallenge_evaluation/profiling/MyAnalysis/GroundTruth/low
    filename='goldstandard_low_1.profile'; paste -d' ' <(paste -d' ' <(for word in \"superkingdom\"\: \"phylum\"\: \"class\"\: \"order\"\: \"family\"\: \"genus\"\: \"species\"\: \"strain\"\:; do echo $word; done) <(for word in superkingdom phylum class order family genus species strain; do echo $word; done | xargs -I{} grep -F -w -c {} $filename)) <(for it in `seq 1 8`; do echo ,; done)
    etc.
    """
    if truth_type == 'filtered':
        if sample_name == 'CAMI_low_S001':
            return {"superkingdom": 2, "phylum": 7 ,"class": 13 ,"order": 15 ,"family": 17 ,"genus": 23 ,"species": 22 ,"strain": 41}
        elif sample_name == 'CAMI_HIGH_S005':
            return {"superkingdom": 3, "phylum": 13 ,"class": 22 ,"order": 41 ,"family": 89 ,"genus": 195 ,"species": 242 ,"strain": 597}
        elif sample_name == 'CAMI_HIGH_S004':
            return {"superkingdom": 3, "phylum": 13 ,"class": 22 ,"order": 41 ,"family": 89 ,"genus": 195 ,"species": 242 ,"strain": 597}
        elif sample_name == 'CAMI_HIGH_S003':
            return {"superkingdom": 3, "phylum": 13 ,"class": 22 ,"order": 41 ,"family": 89 ,"genus": 195 ,"species": 242 ,"strain": 597}
        elif sample_name == 'CAMI_HIGH_S002':
            return {"superkingdom": 3, "phylum": 13 ,"class": 22 ,"order": 41 ,"family": 89 ,"genus": 195 ,"species": 242 ,"strain": 597}
        elif sample_name == 'CAMI_HIGH_S001':
            return {"superkingdom": 3 , "phylum": 13 , "class": 22 , "order": 41 , "family": 89 , "genus": 195 , "species": 242 , "strain": 597}
        elif sample_name == 'CAMI_MED_S001':
            return {"superkingdom": 3, "phylum": 7 ,"class": 16 ,"order": 30 ,"family": 54 ,"genus": 72 ,"species": 71 ,"strain": 133}
        elif sample_name == 'CAMI_MED_S002':
            return {"superkingdom": 3, "phylum": 7 ,"class": 16 ,"order": 30 ,"family": 54 ,"genus": 72 ,"species": 71 ,"strain": 133}
        elif sample_name == 'CAMI_low':
            return {"superkingdom": 2, "phylum": 7 ,"class": 13 ,"order": 15 ,"family": 17 ,"genus": 23 ,"species": 22 ,"strain": 41}
        elif sample_name == 'CAMI_medium':
            return {"superkingdom": 3 ,"phylum": 7 ,"class": 16 ,"order": 30 ,"family": 54 ,"genus": 72 ,"species": 71 ,"strain": 133}
        elif sample_name == 'CAMI_high':
            return {"superkingdom": 3 ,"phylum": 13 ,"class": 22 ,"order": 41 ,"family": 89 ,"genus": 195 ,"species": 242 ,"strain": 597}
        else:
            raise Exception("Unknown sample name: %s" % sample_name)
    elif truth_type == 'all':
        if sample_name == 'CAMI_low_S001':
            return {"superkingdom": 3 , "phylum": 7 , "class": 13 , "order": 15 , "family": 17 , "genus": 23 , "species": 24 , "strain": 61 }
        elif sample_name == 'CAMI_HIGH_S005':
            return {"superkingdom": 3 , "phylum": 13 , "class": 22 , "order": 41 , "family": 89 , "genus": 195 , "species": 244 , "strain": 1075}
        elif sample_name == 'CAMI_HIGH_S004':
            return {"superkingdom": 3 , "phylum": 13 , "class": 22 , "order": 41 , "family": 89 , "genus": 195 , "species": 244 , "strain": 1075 }
        elif sample_name == 'CAMI_HIGH_S003':
            return {"superkingdom": 3 , "phylum": 13 , "class": 22 , "order": 41 , "family": 89 , "genus": 195 , "species": 244 , "strain": 1075 }
        elif sample_name == 'CAMI_HIGH_S002':
            return {"superkingdom": 3 , "phylum": 13 , "class": 22 , "order": 41 , "family": 89 , "genus": 195 , "species": 244 , "strain": 1075 }
        elif sample_name == 'CAMI_HIGH_S001':
            return {"superkingdom": 3 , "phylum": 13 , "class": 22 , "order": 41 , "family": 89 , "genus": 195 , "species": 244 , "strain": 1075}
        elif sample_name == 'CAMI_MED_S001':
            return {"superkingdom": 4 , "phylum": 7 , "class": 16 , "order": 30 , "family": 54 , "genus": 72 , "species": 73 , "strain": 233}
        elif sample_name == 'CAMI_MED_S002':
            return {"superkingdom": 4 , "phylum": 7 , "class": 16 , "order": 30 , "family": 54 , "genus": 72 , "species": 73 , "strain": 233}
        elif sample_name == 'CAMI_low':
            return {"superkingdom": 3 , "phylum": 7 , "class": 13 , "order": 15 , "family": 17 , "genus": 23 , "species": 24 , "strain": 61 }
        elif sample_name == 'CAMI_medium':
            return {"superkingdom": 4 , "phylum": 7 , "class": 16 , "order": 30 , "family": 54 , "genus": 72 , "species": 73 , "strain": 233 }
        elif sample_name == 'CAMI_high':
            return {"superkingdom": 3 , "phylum": 13 , "class": 22 , "order": 41 , "family": 89 , "genus": 195 , "species": 244 , "strain": 1075}
        else:
            raise Exception("Unknown sample name: %s" % sample_name)
    else:
        raise Exception("Unknown truth type: %s" % truth_type)

def parse_results(description_files, mac='y'):
    results = dict()
    methods = set()
    versions = set()
    competitions = set()
    sample_names = set()
    truth_types = set()
    metrics = set()
    ranks = set()
    for description_file in description_files:
        description_contents = []
        if mac == 'y':
            metrics_file = os.path.join(os.path.dirname(description_file), 'output/metrics.txt')  # Mac
        else:
            metrics_file = os.path.join(os.path.dirname(description_file), 'output\\metrics.txt')  # Windows
        metrics_content = dict()
        fid = open(metrics_file, 'r')
        metrics_names = fid.readline().strip().split('\t')[1:]
        for metric_name in metrics_names:
            metrics_content[metric_name] = dict()
            metrics.add(metric_name)
        for line in fid.readlines():
            line_split = line.strip().split('\t')
            rank = line_split[0]
            ranks.add(rank)
            for i in range(1, len(line_split)):
                metrics_content[metrics_names[i - 1]][rank] = line_split[i]
        fid.close()
        fid = open(description_file, 'r')
        for line in fid.readlines():
            description_contents.append(line.strip())
        # look for method name
        for line in description_contents:
            if re.search('method_name', line, re.I):
                method = line.split('=')[1]
        if method not in results:
            results[method] = dict()
        # look for version
        for line in description_contents:
            if re.search('version', line, re.I):
                version = line.split('=')[1]
        if version not in results[method]:
            results[method][version] = dict()
        # look for competition
        for line in description_contents:
            if re.search('competition_name', line, re.I):
                competition = line.split('=')[1]
        if competition not in results[method][version]:
            results[method][version][competition] = dict()
        # look for sample name
        for line in description_contents:
            if re.search('sample_name', line, re.I):
                sample_name = line.split('=')[1]
        if sample_name == '':
            for line in description_contents:
                if re.search('pool_name', line, re.I):
                    sample_name = line.split('=')[1]
                    sample_name = sample_name.split()[-1]
        if sample_name not in results[method][version][competition]:
            results[method][version][competition][sample_name] = dict()
        # look for _truth_type
        for line in description_contents:
            if re.search('_truth_type', line, re.I):
                truth_type = line.split('=')[1]
        if truth_type not in results[method][version][competition][sample_name]:
            results[method][version][competition][sample_name][truth_type] = dict()
        # Put all the error metrics in
        results[method][version][competition][sample_name][truth_type] = metrics_content
        methods.add(method)
        versions.add(version)
        competitions.add(competition)
        sample_names.add(sample_name)
        truth_types.add(truth_type)
        fid.close()
    results2 = dict()
    for method in results:
        i = 0
        for version in results[method]:
            name = name_to_anonymous_name(method, version)
            if len(results[method])>1:
                name = method + "_v" + str(i)
            else:
                name = method
            if name == 'Common Kmers':
                name = 'Common Kmers_v0'
            elif name == 'commonkmers':
                name = 'Common Kmers_v1'
            i+=1
            results2[name] = results[method][version]
    names = results2.keys()
    return (results2, names, list(competitions), list(sample_names), list(truth_types), list(metrics), list(ranks))

    #return (results,methods,versions,competitions,sample_names,truth_types,metrics,ranks)

def add_binning(path, binning_names, all_results, sample_name):
    """
    Quick and hacky way to add the binning results.
    First do something like:
    Davids-MacBook-Air:bbx-profiling-evaluation-dk dkoslicki$ python ProfilingMetrics.py -c y -g ../firstchallenge_evaluation/profiling/MyAnalysis/GroundTruth/filtered/CAMI_low_S001_truth.profile -r ../firstchallenge_evaluation/profiling/MyAnalysis/BinnerResults/modest_babbage_5 -o ../firstchallenge_evaluation/profiling/MyAnalysis/BinnerResults/modest_babbage_5_metrics.txt -e 0 -n y
    Run all at once: Davids-MacBook-Air:bbx-profiling-evaluation-dk dkoslicki$ ls /Users/dkoslicki/Dropbox/Repositories/firstchallenge_evaluation/profiling/MyAnalysis/BinnerResults/medium | grep -v .txt | xargs -I {} python ProfilingMetrics.py -c y -g ../firstchallenge_evaluation/profiling/MyAnalysis/GroundTruth/filtered/CAMI_medium_truth.profile -r /Users/dkoslicki/Dropbox/Repositories/firstchallenge_evaluation/profiling/MyAnalysis/BinnerResults/medium/{} -o /Users/dkoslicki/Dropbox/Repositories/firstchallenge_evaluation/profiling/MyAnalysis/BinnerResults/medium/{}_metrics.txt -e 0 -n y
    This should be made better...
    :param path:
    :param binning_names:
    :param results:
    :return:
    """
    results = dict()
    methods = set()
    versions = set()
    competitions = set()
    sample_names = set()
    truth_types = set()
    metrics = set()
    ranks = set()

    for binning_name in binning_names:
        metrics_file = os.path.join(path,binning_name + "_metrics.txt")
        #description_file = os.path.join(path,binning_name + "_description.txt")
        description_contents = []
        metrics_content = dict()
        fid = open(metrics_file, 'r')
        metrics_names = fid.readline().strip().split('\t')[1:]
        for metric_name in metrics_names:
            metrics_content[metric_name] = dict()
            metrics.add(metric_name)
        for line in fid.readlines():
            line_split = line.strip().split('\t')
            rank = line_split[0]
            ranks.add(rank)
            for i in range(1, len(line_split)):
                metrics_content[metrics_names[i - 1]][rank] = line_split[i]
        fid.close()
        #fid = open(description_file, 'r')
        #for line in fid.readlines():
        #    description_contents.append(line.strip())
        # look for method name
        #for line in description_contents:
        #    if re.search('method_name', line, re.I):
        #        method = line.split('=')[1]
        method = binning_name
        if method not in results:
            results[method] = dict()
        # look for version
        #for line in description_contents:
        #    if re.search('version', line, re.I):
        #        version = line.split('=')[1]
        version = ''
        if version not in results[method]:
            results[method][version] = dict()
        # look for competition
        #for line in description_contents:
        #    if re.search('competition_name', line, re.I):
        #        competition = line.split('=')[1]
        competition = 'CAMI Challenge'
        if competition not in results[method][version]:
            results[method][version][competition] = dict()
        # look for sample name
        #for line in description_contents:
        #    if re.search('sample_name', line, re.I):
        #        sample_name = line.split('=')[1]
        ##sample_name = 'CAMI_low_S001'
        #if sample_name == '':
        #    for line in description_contents:
        #        if re.search('pool_name', line, re.I):
        #            sample_name = line.split('=')[1]
        #            sample_name = sample_name.split()[-1]
        if sample_name not in results[method][version][competition]:
            results[method][version][competition][sample_name] = dict()
        # look for _truth_type
        #for line in description_contents:
        #    if re.search('_truth_type', line, re.I):
        #        truth_type = line.split('=')[1]
        truth_type = 'filtered'
        if truth_type not in results[method][version][competition][sample_name]:
            results[method][version][competition][sample_name][truth_type] = dict()
        # Put all the error metrics in
        results[method][version][competition][sample_name][truth_type] = metrics_content
        methods.add(method)
        versions.add(version)
        competitions.add(competition)
        sample_names.add(sample_name)
        truth_types.add(truth_type)
        fid.close()
    results2 = dict()
    for method in results:
        for version in results[method]:
            name = name_to_anonymous_name(method, version)
            results2[name] = results[method][version]
    names = results2.keys()
    for key in results2:
        all_results[key] = results2[key]
    return (results2, names, list(competitions), list(sample_names), list(truth_types), list(metrics), list(ranks))


#Check if a string is a number
def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False

def ave_over_rank(inputs):
    """
    This function gives the raw average of a metric.
    :param inputs: Something like results['Common Kmers']['']['CAMI Challenge']['CAMI_low_S001']['filtered']['False Positives']
    :return:
    """
    ranks = {'superkingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species'}
    total = 0
    for rank in ranks:
        total += float(inputs[rank])

    return total / float(len(ranks))


def radar_factory(num_vars, frame='circle'):
    """Create a radar chart with `num_vars` axes.

    This function creates a RadarAxes projection and registers it.

    Parameters
    ----------
    num_vars : int
        Number of variables for radar chart.
    frame : {'circle' | 'polygon'}
        Shape of frame surrounding axes.

    """
    # calculate evenly-spaced axis angles
    theta = np.linspace(0, 2*np.pi, num_vars, endpoint=False)
    # rotate theta such that the first axis is at the top
    theta += np.pi/2

    def draw_poly_patch(self):
        verts = unit_poly_verts(theta)
        return plt.Polygon(verts, closed=True, edgecolor='k')

    def draw_circle_patch(self):
        # unit circle centered on (0.5, 0.5)
        return plt.Circle((0.5, 0.5), 0.5)

    patch_dict = {'polygon': draw_poly_patch, 'circle': draw_circle_patch}
    if frame not in patch_dict:
        raise ValueError('unknown value for `frame`: %s' % frame)

    class RadarAxes(PolarAxes):

        name = 'radar'
        # use 1 line segment to connect specified points
        RESOLUTION = 1
        # define draw_frame method
        draw_patch = patch_dict[frame]

        def fill(self, *args, **kwargs):
            """Override fill so that line is closed by default"""
            closed = kwargs.pop('closed', True)
            return super(RadarAxes, self).fill(closed=closed, *args, **kwargs)

        def plot(self, *args, **kwargs):
            """Override plot so that line is closed by default"""
            lines = super(RadarAxes, self).plot(*args, **kwargs)
            for line in lines:
                self._close_line(line)

        def _close_line(self, line):
            x, y = line.get_data()
            # FIXME: markers at x[0], y[0] get doubled-up
            if x[0] != x[-1]:
                x = np.concatenate((x, [x[0]]))
                y = np.concatenate((y, [y[0]]))
                line.set_data(x, y)

        def set_varlabels(self, labels, fontsize='small'):
            self.set_thetagrids(np.degrees(theta), labels, fontsize=fontsize)

        def _gen_axes_patch(self):
            return self.draw_patch()

        def _gen_axes_spines(self):
            if frame == 'circle':
                return PolarAxes._gen_axes_spines(self)
            # The following is a hack to get the spines (i.e. the axes frame)
            # to draw correctly for a polygon frame.

            # spine_type must be 'left', 'right', 'top', 'bottom', or `circle`.
            spine_type = 'circle'
            verts = unit_poly_verts(theta)
            # close off polygon by repeating first vertex
            verts.append(verts[0])
            path = Path(verts)

            spine = Spine(self, spine_type, path)
            spine.set_transform(self.transAxes)
            return {'polar': spine}

    register_projection(RadarAxes)
    return theta


def unit_poly_verts(theta):
    """Return vertices of polygon for subplot axes.

    This polygon is circumscribed by a unit circle centered at (0.5, 0.5)
    """
    x0, y0, r = [0.5] * 3
    verts = [(r*np.cos(t) + x0, r*np.sin(t) + y0) for t in theta]
    return verts

def spider_plot(results,
                metrics,
                metrics_labels,
                method_names,
                sample_name,
                truth_type,
                ranks,
                colors,
                num_rows,
                num_cols,
                grid_points=None,
                label_grid='y',
                normalize='y',
                legend_loc=(-.5, 1.1),
                fill='y',
                max_plot=1):
    #def spider_data2(results, metrics, method_names, sample_name, truth_type, ranks):
    competition = 'CAMI Challenge'
    to_plot_method_names = []
    for method_name in method_names:
        if 'CAMI Challenge' in results[method_name]:
            if sample_name in results[method_name]['CAMI Challenge']:
                if truth_type in results[method_name]['CAMI Challenge'][sample_name]:
                    to_plot_method_names.append(method_name)
    to_plot_method_names.sort()
    data = [to_plot_method_names]
    for rank in ranks:
        values_array = []
        for metric in metrics:
            values = []
            for name in to_plot_method_names:
                if competition in results[name] and sample_name in results[name][competition]:
                    if metric == 'Unifrac':
                        val = results[name][competition][sample_name][truth_type][metric]['rank independent']
                        if is_number(val):
                            val = float(val)
                            #val = 1 - float(val) / 12  # This is the largest unifrac is in the dataset: np.nanmax(np.ndarray.flatten(np.array([np.array(val[1])[:,0] for val in data[0:]])))
                            # I could also set this to 16 (since this is the largest it could possibly be)
                    elif metric == 'L1norm':
                        val = results[name][competition][sample_name][truth_type][metric][rank]
                        if is_number(val):
                            val = float(val)
                            #val = 1 - float(val)/2.  # This is to keep it consistent with "larger is better"
                    else:
                        val = results[name][competition][sample_name][truth_type][metric][rank]
                    if not is_number(val) or float(val) < 0:
                        value = np.nan
                    else:
                        value = float(val)
                    values.append(value)
                else:
                    values.append(np.nan)
            values_array.append(values)
        data.append((rank, values_array))

    N = len(to_plot_method_names)
    theta = radar_factory(N, frame='polygon')
    dummy = data.pop(0)
    spoke_labels = to_plot_method_names
    fig = plt.figure()
    fig.subplots_adjust(wspace=0.25, hspace=0.20, top=0.85, bottom=0.05)
    # Plot the four cases from the example data on separate axes
    for n, (title, case_data) in enumerate(data):
        ax = fig.add_subplot(num_rows, num_cols, n + 1, projection='radar')
        if grid_points:
            if label_grid == 'y':
                plt.rgrids(grid_points)
            else:
                plt.rgrids(grid_points, ('', '', '', ''))  # This gets rid of the labels of the grid points since everything is relative
        ax.set_title(title, weight='bold', size='medium', position=(0.5, 1.07), horizontalalignment='center', verticalalignment='center')
        it = 1
        for d, color in zip(case_data, colors):    #NOTE: for each of the methods that didn't report a metric, put an astrisk next to the name to indicate this. Also put worst value of the metric as the value....
            spoke_labels = to_plot_method_names
            #nan_indicies = np.where(np.isnan(d))[0]
            #for nan_index in sorted(nan_indicies,reverse=True):
            #    del d[nan_index]
            #    del spoke_labels[nan_index]
            #N = len(spoke_labels)
            #theta = radar_factory(N, frame='polygon')
            nan_indicies = np.where(np.isnan(d))[0]
            for nan_index in sorted(nan_indicies,reverse=True):
                metric_name = metrics[it-1]
                if metric_name == 'L1norm':
                    d[nan_index] = 1
                elif metric_name == 'False Positives':
                    d[nan_index] = max(d)
                elif metric_name == 'Sensitivity: TP/(TP+FN)':
                    d[nan_index] = 0
                elif metric_name == 'False Negatives':
                    d[nan_index] = max(d)
                elif metric_name == 'Precision: TP/(TP+FP)':
                    d[nan_index] = 0
                elif metric == 'True Positives':
                    d[nan_index] = 0
                elif metric_name == 'L1norm':
                    d[nan_index] = 1
                elif metric_name == 'Unifrac':
                    d[nan_index] = 16
                spoke_labels[nan_index] = spoke_labels[nan_index]+"*"
            if normalize == 'y':
                max_val = max(d)
                for i in range(len(d)):
                    d[i] = d[i]/max_val
            ax.plot(theta, d,'--', color=color, linewidth=5, dashes=(it, 1))
            if fill=='y':
                ax.fill(theta, d, facecolor=color, alpha=0.25)
            ax.set_ylim([0, max_plot])
            ax.set_xlim([0, max_plot])
            it += 1
            ax.set_varlabels(spoke_labels, fontsize=10)
        #ax.set_varlabels(spoke_labels, fontsize=10)

    # Make the names with missing data red
    for subfig in fig.get_axes():
        ticklabels = subfig.get_xticklabels()
        for label in ticklabels:
            if '*' in label._text:
                label.set_color([1,0,0])
                label._text.replace('*','')
        # add legend relative to top-left plot
    labels = tuple(metrics_labels)
    legend = ax.legend(labels, loc='center left', bbox_to_anchor=legend_loc)
    plt.setp(legend.get_texts(), fontsize='small')
    plt.figtext(0.51, 0.965, sample_name + ", " + truth_type, ha='center', color='black', weight='bold', size='large')
    plt.show()
    #return fig
    return


def metric1_vs_metric2(results,
                       plot_sample_name,
                       truth_type,
                       ranks,
                       metrics,
                       metrics_names,
                       method_names,
                       num_rows,
                       num_cols):
    names_to_plot = list()
    for name in method_names:
        if 'CAMI Challenge' in results[name]:
            names_to_plot.append(name)
    fig, axes = plt.subplots(num_rows, num_cols, sharex=True, sharey=True)
    for n,rank in enumerate(ranks):
        values = []
        good_names = []
        for name in names_to_plot:
            if 'CAMI Challenge' in results[name] and plot_sample_name in results[name]['CAMI Challenge'] and is_number(results[name]['CAMI Challenge'][plot_sample_name][truth_type][metrics[0]][rank]) and is_number(results[name]['CAMI Challenge'][plot_sample_name][truth_type][metrics[1]][rank]):
                if float(results[name]['CAMI Challenge'][plot_sample_name][truth_type][metrics[0]][rank])>=0 and float(results[name]['CAMI Challenge'][plot_sample_name][truth_type][metrics[1]][rank])>=0:
                    good_names.append(name)
        for name in good_names:
            values.append([float(results[name]['CAMI Challenge'][plot_sample_name][truth_type][metrics[0]][rank]), float(results[name]['CAMI Challenge'][plot_sample_name][truth_type][metrics[1]][rank])])

        ax = fig.add_subplot(num_rows, num_cols, n+1, autoscale_on=True, frameon=False)
        for name, value in zip(good_names, values):
            ax.scatter(value[0],value[1])
            ax.annotate(name, (value[0], value[1]))
            ax.plot([0,1],[0,1], 'k')
            ax.set_xlim([0,1])
            ax.set_ylim([0,1])
            ax.set_title(rank, weight='bold')
            if n==0 or n==3:
                ax.set_ylabel(metrics_names[0])
            if n>2:
                ax.set_xlabel(metrics_names[1])
            ax.tick_params(labelcolor='none', top='off', bottom='off', left='off', right='off')

    plt.figtext(0.5, 0.965, plot_sample_name + ", " + truth_type, ha='center', color='black', weight='bold', size='large')
    plt.show()
    return


def plot_bar_at_rank(results, names_to_plot, plot_sample_name, truth_type, metric, rank, sort='y', lim=[0,1]):
    values = []
    good_names = []
    for name in names_to_plot:
        if 'CAMI Challenge' in results[name] and plot_sample_name in results[name]['CAMI Challenge'] and is_number(results[name]['CAMI Challenge'][plot_sample_name][truth_type][metric][rank]):
            good_names.append(name)
    for name in good_names:
        values.append(float(results[name]['CAMI Challenge'][plot_sample_name][truth_type][metric][rank]))

    if sort == 'y':
        values = sorted(values)
        good_names = [s[1] for s in sorted(zip(values,good_names))]
    plt.bar(range(1,len(values)+1), values, align='center')
    plt.xticks(range(1,len(good_names)+1), good_names, rotation='vertical')
    plt.tick_params(axis='both', which='major', labelsize=16)
    plt.subplots_adjust(bottom=0.3)
    plt.xlabel('Method', fontsize=16)
    plt.ylabel(metric, fontsize=16)
    plt.title(plot_sample_name + ", " + rank + ", " + truth_type, fontsize=16)
    plt.ylim(lim)
    plt.show()


# Line plot with y-axis the metric, x-axis the taxonomic rank
def plot_versus_rank(results, names_to_plot, plot_sample_name, truth_type, metric, plot_ranks):
    names_to_plot.sort()
    good_names = []
    for key in names_to_plot:
        if 'CAMI Challenge' in results[key]:
            if plot_sample_name in results[key]['CAMI Challenge']:
                plt.plot([results[key]['CAMI Challenge'][plot_sample_name][truth_type][metric][rank] for rank in plot_ranks], linewidth=2)
                good_names.append(key)
    plt.xticks(range(len(plot_ranks)), plot_ranks, rotation=-45)
    plt.tick_params(axis='both', which='major', labelsize=16)
    plt.subplots_adjust(bottom=0.3)
    plt.xlabel('Rank', fontsize=16)
    plt.ylabel(metric, fontsize=16)
    plt.legend(good_names, loc=2)
    plt.title(plot_sample_name + ", " + truth_type, fontsize=16)
    plt.show()

def rank_table(results, metric, metric_plot_name, sample_name, ranks, method_names, truth_type, name_to_color, metric_label='n',table_label='n'):
    values_array = []
    for rank in ranks:
        values = []
        for name in method_names:
            if 'CAMI Challenge' in results[name]:
                if sample_name in results[name]['CAMI Challenge']:
                    if truth_type in results[name]['CAMI Challenge'][sample_name]:
                        if metric in results[name]['CAMI Challenge'][sample_name][truth_type]:
                            val = results[name]['CAMI Challenge'][sample_name][truth_type][metric][rank]
                            if is_number(val):
                                values.append(float(val))
                            else:
                                values.append(np.nan)
                        else:
                            values.append(np.nan)
                    else:
                        values.append(np.nan)
                else:
                    values.append(np.nan)
            else:
                values.append(np.nan)
        values_array.append(values)

    values_array = np.array(values_array)
    names_sorted_array = []
    for i in range(len(values_array)):
        names_sorted = []
        if metric == 'True Positives' or metric == 'Sensitivity: TP/(TP+FN)' or metric == 'Precision: TP/(TP+FP)':
            temp_values_array = values_array[i]
            for j in range(len(temp_values_array)):
                if np.isnan(temp_values_array[j]):
                    temp_values_array[j] = -np.Inf
            sort_zip = sorted(zip(temp_values_array, method_names), reverse=True)  # High to low
        else:
            temp_values_array = values_array[i]
            for j in range(len(temp_values_array)):
                if np.isnan(temp_values_array[j]):
                    temp_values_array[j] = np.Inf
            sort_zip = sorted(zip(values_array[i], method_names))  # Low to high
        for value, name in sort_zip:
            if not np.isfinite(value):
                names_sorted.append('')
            else:
                names_sorted.append(name)
        names_sorted_array.append(names_sorted)

    names_sorted_array = np.array(names_sorted_array).transpose()
    plt.figure()
    #fig, axs = plt.subplots(1,1)
    collabel=tuple(ranks)
    #axs.axis('tight')
    #axs.axis('off')
    all_blanks = []
    for i in range(len(names_sorted_array[0])):
        all_blanks.append('')

    table_text = []
    for i in range(len(names_sorted_array)):
        if (names_sorted_array[i] != all_blanks).any():
            table_text.append(names_sorted_array[i])

    if table_text == []:
        raise Exception("Empty table, probably a typo in sample_name")

    #the_table = axs.table(cellText=table_text,colLabels=collabel,loc='center')
    #the_table = plt.table(cellText=table_text,colLabels=collabel,loc='center',bbox=[0, 0.5, 1, 0.5])
    #the_table = plt.table(cellText=table_text,colLabels=collabel,loc='center',bbox=[0, 0, 1, 1])
    #the_table = plt.table(cellText=table_text,colLabels=collabel,loc='center',bbox=[0, 0.5, 1, 1])
    #the_table = plt.table(cellText=table_text,colLabels=collabel,loc='center',bbox=[0, 0.25, 1, .75])
    #the_table = axs.table(cellText=table_text,colLabels=collabel,loc='upper center')
    the_table = plt.table(cellText=table_text,colLabels=collabel,loc='upper center')
    it=0
    for i in range(len(table_text)):
        for j in range(len(table_text[0])):
            the_table._cells[(i+1,j)]._text.set_color(name_to_color[the_table._cells[(i+1,j)]._text._text])
            the_table._cells[(i+1,j)].set_text_props(fontweight='bold')
            it +=1

    if table_label == 'y':
        #plt.figtext(0.5, 0.85, sample_name + ", " + truth_type, ha='center', color='black', weight='bold', size='large')
        #axs.set_title(sample_name + ", " + truth_type, color='black', weight='bold', size='large')
        plt.title(sample_name + ", " + truth_type, color='black', weight='bold', size='large')
        #plt.figtext(0.5,0.5,sample_name + ", " + truth_type, ha='center', va='center', color='black', weight='bold', size='large',transform=axs.transAxes)
    if metric_label == 'y':
        plt.figtext(0.1, 0.75, metric_plot_name, ha='center', color='black', weight='bold', size='large', rotation=90)

    #axs.set_title('TEST')
    #plt.tight_layout()
    plt.axis("tight")
    plt.axis("off")
    return table_text


def winners(table_text):
    unique_names = list(set(np.ndarray.flatten(np.array(table_text))))
    unique_counts = [0]*len(unique_names)
    for i in range(len(unique_names)):
        name = unique_names[i]
        iter = 0
        for row in table_text:
            indicies = [ind for ind, val in enumerate(row) if val == name]
            unique_counts[i] += len(indicies)*iter
            iter += 1
    return sorted(zip(unique_counts,unique_names))
