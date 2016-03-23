
low:

    read length: 150
    fragment size mean: 270
    fragment size standard_deviation: 27
    size: 15gb
    samples: 1
    real genomes: 28
    artificial genomes: 12
    circular elements: 20
    distribution: log
        mean: 1
        standard deviation: 2
        circular elements have 15 times higher abundance then genomes

medium:

    read length: 150 / 150
    fragment size mean: 270 / 5000
    fragment size standard_deviation: 27 / 500
    size: 15gb / 5gb each sample
    samples: 2 / 2
    real genomes: 119
    artificial genomes: 13
    circular elements: 100
    distribution: log ,differential (each sample from independent distribution)
        mean: 1
        standard deviation: 2
        circular elements have 15 times higher abundance then genomes


high:

    read length: 150
    fragment size mean: 270
    fragment size standard_deviation: 27
    size: 15gb each sample
    samples: 5
    real genomes: 542
    artificial genomes: 54
    circular elements: 478
    distribution: timeseries of log (https://github.com/CAMI-challenge/MetagenomeSimulationPipeline/wiki/Distribution-of-genomes#timeseries-lognormal)
        mean: 1
        standard deviation: 2
        circular elements have 15 times higher abundance then genomes
