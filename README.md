

# Bayesian estimation of photosynthetic parameters in a Farquhar-von Caemmerer-Berry model

With concurrent measurements of An-Ci and Y(II)-Ci data, posterior distribution of photosynthetic parameters in a Farquhar-von Caemmerer-Berry (FvCB) model is calculated with software called [JAGS (Just Another Gibbs Sampler).](http://mcmc-jags.sourceforge.net/) This note book provides the entire workflow for the implementation of the Bayesian estimation.

**[Reference]**
Xiao Y, Hepworth C, Sloan J, Fleming AJ, Chen XY, Zhu X-G. (2019) Uncertainty of photosynthetic parameter estimation of C3 leaves: a Bayesian approach. (under preparation)

## Getting Started

This workflow is written in [Jupyter notebook](https://jupyter.org/) which is an open-source software to support interactive data science. Both Python and R can be used as the coding language (here we use R), meanwhile instructions or comments along with the workflow is written in Markdown.

### Prerequisites
Here we used a laptop with windows 10 system. A similar installation pipeline should work with MacOS and Linux.

1. R-3.6.1:
Download R from [https://www.r-project.org/](https://www.r-project.org/) and install.

2. Jupyter notebook:
A recommended distribution of Jupyter notebook is [Anaconda](https://www.anaconda.com/).

3. Link Anaconda to installed R:
- Open Anaconda prompt (not anaconda navigator), change the directory to where R is installed, e.g,  ```cd "C:\DevTools\R\R-3.6.1\bin"```, hit the enter key.
- Type ```R``` and hit the enter key.
- Type ```install.packages('IRkernel')```, hit the enter key.
- Then type  ```IRkernel::installspec()```, hit the enter key.

4. JAGS (Just Another Gibbs Sampler):
Go to [http://mcmc-jags.sourceforge.net/](http://mcmc-jags.sourceforge.net/), download and install it.

### Installing

1. Click the "Clone or download" button on this github webpage, choose "Download ZIP".
2. Unzip the file in your computer.
3. Reopen Anaconda prompt, change directory to the unzipped folder. e.g. ```cd "C:\Users\xiaoy\Documents\JAGSFvCB"```, hit the enter key.
4. Type ```jupyter notebook```, hit the enter key.
5. Automatically, your brower (IE, Chrome or Firefox etc) will open a new tab at ```http://localhost:8888/tree```.
6. Click ```FvCB_JAGS.ipynb``` to open the demo

## Running the demos

Two sets of data are included in the folder.
- "syntheticdata0827.csv" is the synthetic data from FvCB model used in the manuscript
- "expdata0827.csv" is the experimental measurements of IR64 used in the manuscript 
- Demo "FvCB_JAGS.ipynb" illustrate the Bayesian estimation with "expdata0827.csv". The input data file can be changed in *Step 1.1 Load data*.
- Users can run this note book cell by cell. Just left click the cell with the code, and then click the "Run" button on the top.
- Users can also run this note book at once, using "Cell -> Run All".

## Built With

* [R]([https://www.r-project.org/) - The coding language used
* [Anaconda](https://www.anaconda.com/) - Distribution of Jupyter notebook used
* [JAGS](http://mcmc-jags.sourceforge.net/) - Software of Bayesian estimation used

## Versioning

This is version 1 released on Sep. 21th 2019.

## Authors

* code by **Yi Xiao** - *xiaoyi@sippe.ac.cn* - [https://github.com/xiaoyizz78](https://github.com/xiaoyizz78)
* data by **Chris Hepworth & Jen Sloan**

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE.md](LICENSE.md) file for details