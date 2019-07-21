# tsp-dp-gpu

This is an implementation of the Dynamic Programming (DP) algorithm for the Graphics Processing Unit (GPU). The DP algorithm is described in the following research paper:
M. Held  and R.M.Karp,. A dynamic programming approach to sequencing problems, Journal of the Society for Industrial and Applied Mathematics 10: 1962.  pp. 196--210.
DOI: https://doi.org/10.1145/800029.808532

In this project, the DP is implemented for solving two sequencing problems. The first one is the well known Traveling Salesman Problem (TSP, see subfolder DP_GPU_TSP). 

The second problem is one variant of a One-Unit Multiproduct Production Scheduling problem (see subfolder DP_GPU_PROD_SCHED)). The description can be found at http://math.nsc.ru/AP/benchmarks/MSP/msp.html.

The code was compiled with MS Visual Studio Express 2008 with CUDA libraries and tested on GTS 450 device with 1Gb of GDDR5 memory. The solvable sizes and the running time for the TSP are the following.

N=23, time=0,33 sec., GPU memory = 250M

N=24, time=0.75 sec.  GPU memory = 500M

N=25, time=1.56 sec.  GPU memory = 1GB

For solving larger instances, a GPU with more memory is required.

The code can be used as a subroutine in exact of heuristic algorithms. The following paper desribes a Branch and Bound algorithm for the Multi-Unit Production Scheduling problem.

Borisovsky P. (2018) Exact Solution of One Production Scheduling Problem. In: Eremeev A., Khachay M., Kochetov Y., Pardalos P. (eds) Optimization Problems and Their Applications. OPTA 2018. Communications in Computer and Information Science, vol 871. Springer, Cham. DOI: https://doi.org/10.1007/978-3-319-93800-4_5

In this paper, the DP is used in the Genetic Algorithm for the Multi-Unit Production Scheduling problem for impoving its performance.
Borisovsky P.A.,  Eremeev A.V., and  Kallrath J., Multi-product continuous plant scheduling: combination of decomposition, genetic algorithm, and constructive heuristic. International Journal of Production Research. To appear. DOI: https://doi.org/10.1080/00207543.2019.1630764

The code of this project is free to use in any research, educational, or commertial purpose. In research papers or public presentations using this code please refer to the aforementioned papers. This code is offered as-is without warranty, the author is not responsible for any losses or damages resulting from using the projects. 



