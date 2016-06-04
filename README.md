# MG Feedback

This is the code for paper `Persistent Memory in Single Node Delay-Coupled Reservoir Computing` which is currently in review.

The code in this repository runs the simulation and creates the plots in the paper

## Run

1. Clone the repository

		git clone https://github.com/Andruschenko/reservoir-persistent-memory.git

2. Matlab
	* Open Matlab
	* Make the `src` folder inside the cloned folder (i.e. `reservoir-persistent-memory/src`) the current folder (i.e. navigate to that folder in Matlab and double click it, so that its contents are directly visible in the 'Current Folder' window on the left.
	* Run the script `main.m` 

## Dependencies

* Next to Matlab, you need the following to run the simulations: 
	* [Statistics and Machine Learning Toolbox](http://uk.mathworks.com/products/statistics/)
	* [Signal Processing Toolbox](http://uk.mathworks.com/products/signal/)
	* `dashline.m` which can be downloaded [here](http://www.mathworks.com/matlabcentral/fileexchange/1892-dashline)
	
Please see the chart in the [Structure section](#structure) below to see exactly where dependencies to these two packages occur.

## Additional information

* `main.m` is the starting point. Uncomment the appropriate section to run the simulation with the other tasks.
* When using the provided default values, the script will take about 30 seconds to execute (tested on a Macbook Pro late 2013)
* The width of plots depends on the screen-size of your computer screen. Thus, your plots might be scaled by some factor as compared to the figures in the publication.
* Default values are used. Alternatives are usually described in a comment at the particular location in the code.
* Details to this project may be found in the soon to be published paper. 

## Structure

The call-structure of the project. Nested functions signify that the daughter function is called by the mother function. Thus, the mother function depends on the existence of the daughter function in order to execute properly.

This project depends on some functions from the Matlab Statistics and Machine Learning Toolbox. This is indicated next to the corresponding functions. 

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
* [Hazem Toutounji](https://scholar.google.de/citations?user=agTxa24AAAAJ&hl=en)
* [Gordon Pipa](http://www.pipa.biz/)

\* : Equal project contributors and creators of the code in this repository.

Thanks go to [Johannes Schumacher](http://loop.frontiersin.org/people/18276/overview) for an initial implementation of the reservoir simulation.