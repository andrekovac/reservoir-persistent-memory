# MG Feedback

This is the code for paper `Persistent Memory in Single Node Delay-Coupled Reservoir Computing` which is currently in review.

## Run

1. Clone the repository

		git clone

2. Open Matlab, make the cloned folder the current folder and run the file `main.m`.


## Additional information

* When using the provided default values, the script will take about 30 seconds to execute (tested on a Macbook Pro late 2013
* The width of plots depends on the screen-size of your computer screen. Thus, your plots might be scaled by some factor as compared to the figures in the publication.

## Structure and dependencies

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
				├── ridge 				// statistics toolbox
				├── glmfit				// statistics toolbox
				├── robustfit			// statistics toolbox
			├── simulateReservoir
			├── trainOnReservoir
			├── generateResults
				├── designMatrix
				├── xcov 				// signal processing toolbox
				
		├── A_publish_plotResults_fctTask_WITH_Fdb_TASKS
			├── dashline 				// http://www.mathworks.com/matlabcentral/fileexchange/1892-dashline
		
		├── main_fct_task_without_fdb
			├── fctTask
		├── main_linear_nonLinearTask
			├── linear_nonLinearTask_rand
		├── main_rampingTask_with_fdb
			├── rampingTask
		├── main_rampingTask_without_fdb
			├── rampingTask


## Authors

* [André David Kovac](https://github.com/Andruschenko) *
* Maximilian Koall *
* [Hazem Toutounji](https://scholar.google.de/citations?user=agTxa24AAAAJ&hl=en)
* [Gordon Pipa](http://www.pipa.biz/)

\* : Equal contribution