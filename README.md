# Persistent memory in single node reservoir computing

This repository contains the code used in the scientific paper [Persistent Memory in Single Node Delay-Coupled Reservoir Computing](http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0165170), published on October 26, 2016 in [PLOS|One](http://dx.doi.org/10.1371/journal.pone.0165170).

The complete code is shared here so that the discussed simulations and plots may be reproduced by anyone interested. Instructions on how to run the simulations may be found below.

#### Example plot

It shows the desired vs. the observed signal of the trained reservoir on the simple task to switch between outputting a sine wave upon a first trigger, and reverting to outputting a constant value upon a second trigger.

![example_plot](https://cloud.githubusercontent.com/assets/1945462/15800954/2173aa22-2a87-11e6-9263-98f009ed4818.jpg)

## Run

1. Clone the repository

		git clone https://github.com/Andruschenko/reservoir-persistent-memory.git

2. MATLAB
	* Open MATLAB
	* Make the `src` folder inside the cloned folder (i.e. `reservoir-persistent-memory/src`) the current folder (i.e. navigate to that folder in MATLAB and double click it, so that its contents are directly visible in the 'Current Folder' window on the left.
	* Run the script `main.m` 

## Dependencies

* Next to MATLAB, you additionally need the following MATLAB add-ons to run the simulations: 
	* [Statistics and Machine Learning Toolbox](http://uk.mathworks.com/products/statistics/)
	* [Signal Processing Toolbox](http://uk.mathworks.com/products/signal/)
	* `dashline.m` which can be freely downloaded [from MATLAB Central](http://www.mathworks.com/matlabcentral/fileexchange/1892-dashline)
	
Please see the chart in the [Structure section](#structure) below to see exactly where dependencies to these two packages occur in the code.

## Additional information

* `main.m` is the starting point. Uncomment the appropriate section to run the simulation with the other tasks.
* When using the provided default values, the script will take about 30 seconds to execute (tested on a Macbook Pro late 2013)
* The width of plots depends on the screen-size of your computer screen. Thus, your plots might be scaled by some factor as compared to the figures in the publication.
* Default values are used. Alternatives are usually described in a comment at the particular location in the code.
* Details to this project may be found in the [PLOS|ONE paper](http://dx.doi.org/10.1371/journal.pone.0165170).

## Structure

The call-structure of the project. Nested functions signify that the daughter function is called by the mother function. Thus, the mother function depends on the existence of the daughter function in order to execute properly.

This project depends on some functions from the MATLAB Statistics and Machine Learning Toolbox. This is indicated next to the corresponding functions. 

	├── main
		├── main_fct_task_with_fdb
			
			├── fctTask
				├── normpdf 			// statistics toolbox
		
			├── fullMasks
			├── randomMasks
			├── subsetMasks
			
			├── initializeReservoir	
				├── createReservoirTheta
				├── createRerservoirO
				├── createReservoirInput
			├── simulateReservoir
			├── trainOnReservoir
				├── designMatrix
				├── ridge				// statistics toolbox
				├── glmfit				// statistics toolbox
				├── robustfit			// statistics toolbox
			├── simulateReservoir
			├── trainOnReservoir
			├── generateResults
				├── designMatrix
				├── xcov 				// signal processing toolbox
				
		├── plotResults_fctTask_WITH_Fdb_TASKS
			├── dashline 				// http://www.mathworks.com/matlabcentral/fileexchange/1892-dashline
			
			... other plot functions
		
		├── main_fct_task_without_fdb
			├── fctTask
		├── main_linear_nonLinearTask
			├── linear_nonLinearTask_rand
		├── main_rampingTask_with_fdb
			├── rampingTask
		├── main_rampingTask_without_fdb
			├── rampingTask


## Authors of the paper

* [André David Kovac](https://github.com/Andruschenko) *
* Maximilian Koall *
* [Gordon Pipa](http://www.pipa.biz/)
* [Hazem Toutounji](https://scholar.google.de/citations?user=agTxa24AAAAJ&hl=en)

\* : Equal project contributors and creators of the code in this repository.

Thanks go to [Johannes Schumacher](http://loop.frontiersin.org/people/18276/overview) for an initial implementation of the reservoir simulation.