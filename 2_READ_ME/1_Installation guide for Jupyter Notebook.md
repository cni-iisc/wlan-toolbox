**Installation Guide for Jupyter Notebook, MATLAB Proxy, and Related Tools:**

This guide will walk you through the steps to install Jupyter Notebook, set up MATLAB as a proxy, and MATLAB Engine API for Python.

You should have the following installed on your system:

1) Python 3.7, 3.8, 3.9, 3.10. (Supported Python Versions for R2023a)

2) MATLAB (if you intend to use MATLAB functionality in Jupyter)

You also need access to the internet to install necessary packages.

**Table of Contents:**

1.Installing Python

2.Setting up Jupyter Notebook

3.Installing MATLAB Engine API for Python

4.Configuring MATLAB Proxy

5.Launching Jupyter Notebook


**1. Installing Python**

To run Jupyter Notebook, Python needs to be installed on your system. Follow these steps:

**Windows:**

Download Python from the official website: https://www.python.org/downloads/

Run the installer and make sure to check the box that says "Add Python to PATH".

Click "Install Now" and follow the prompts.

**macOS:**

You can install Python using Homebrew (if Homebrew is installed) by running:
```bash
brew install python
```
Alternatively, download it directly from https://www.python.org/downloads/.

**Linux:**

Install Python using your package manager:
```bash
sudo apt update
sudo apt install python3
```

**2. Setting up Jupyter Notebook**

Once Python is installed, you need to install Jupyter Notebook.

Step 1: Install pip (if not already installed)

Python usually comes with pip, the package installer. You can check if pip is installed by running:
```bash
pip --version
```
If it's not installed, you can install it by running:
```bash
python -m ensurepip --upgrade
```


Step 2: Install Jupyter Notebook

Use the following command to install Jupyter via pip:
```bash
pip install jupyter
```


Step 3: Verify Installation

To confirm that Jupyter Notebook is installed correctly, run:
```bash
jupyter --version
```


You should see the version of Jupyter that is installed.


**3. Installing MATLAB Engine API for Python**

To use MATLAB functionality inside Jupyter, you will need to install the MATLAB Engine API for Python. Here's how to install it:

Step 1: Locate MATLAB Engine API Installation Directory

Open MATLAB.

Run the following command to find the path to the MATLAB Engine API installation:
```bash
matlabroot
```

This will give you the directory path where MATLAB is installed.

Step 2: Install the MATLAB Engine API for Python

From the terminal/command prompt, navigate to the python folder within your MATLAB installation directory (e.g., matlabroot/extern/engines/python), and run:
```bash
cd <MATLAB_ROOT>/extern/engines/python
python setup.py install
```
Replace <MATLAB_ROOT> with directory path.

This command installs the MATLAB Engine API for Python.

**4. Configuring MATLAB Proxy**

To run MATLAB code inside Jupyter, you need to configure the MATLAB proxy for Python to allow interaction with the MATLAB environment.

Step 1: Create a Python Kernel for MATLAB

Once the MATLAB Engine API is installed, you need to create a Python kernel that can execute MATLAB commands:
```bash
matlab -batch "matlab.engine.shareEngine"
```
This opens a shared MATLAB engine that Python will connect to.

Step 2: Install the matlab_kernel (Recommended: since we verified the code segments running on .ipynb file using Matlab kernel)

To make the integration between Jupyter and MATLAB easier, install the matlab_kernel, a Jupyter kernel that allows MATLAB commands to run in a Jupyter notebook.

First, install the kernel:
```bash
pip install matlab_kernel
```
Then, enable the MATLAB kernel in Jupyter:
```bash
python -m matlab_kernel.install
```
After this, you should be able to select the MATLAB kernel from the Jupyter interface when you start a new notebook.

**5. Launching Jupyter Notebook**

Once everything is set up, you can launch Jupyter Notebook by running the following command:
```bash
jupyter notebook
```
This command will open Jupyter in your default web browser. You can now create new notebooks, and if you've installed and configured the MATLAB kernel, you can select MATLAB as the kernel for running code.

**Troubleshooting:**

**1. MATLAB Not Found in Jupyter**
Ensure that the matlab_kernel is installed and properly configured.
Ensure that the MATLAB Engine API is correctly installed and the MATLAB Engine is running.

**2. Issues with Python Packages**

Ensure that pip is up-to-date by running:
```bash
pip install --upgrade pip
```
If you encounter permission issues during package installation, try using sudo (on macOS/Linux) or run the command prompt as Administrator (on Windows).'

**3. MATLAB Path Issue Resolution**

If a file is not found in the current folder or on the MATLAB path, but exists in another folder, then you need to either change the MATLAB current folder to the directory containing the file or add that folder to the MATLAB path.
```bash
addpath('Path_to_your_missing_file')
```
If you want the file to be included in the MATLAB path every time MATLAB starts, you need to save the updated path by running:
```bash
savepath
```
