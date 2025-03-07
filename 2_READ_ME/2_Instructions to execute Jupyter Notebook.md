### Instructions to Execute Jupyter Notebook

This guide provides steps to execute code segments within `.ipynb` files locally using Jupyter Notebook.

#### **Executing Jupyter Notebook Locally**
1. **Install Git (If Not Installed)**
   - If you encounter the error `'git' is not recognized as an internal or external command, operable program or batch file.`, install Git by downloading it from [Git for Windows](https://git-scm.com/downloads).
   - After installation, add Git to the system PATH manually:
     1. Open **Start Menu** and search for "Environment Variables."
     2. Click **Edit the system environment variables**.
     3. In the **System Properties** window, click **Environment Variables**.
     4. Under **System Variables**, find and select **Path**, then click **Edit**.
     5. Click **New** and add the path to the Git `bin` and `cmd` directories (e.g., `C:\Program Files\Git\bin` and `C:\Program Files\Git\cmd`).
     6. Click **OK** to save the changes and restart your terminal.
   - Verify the installation by running:
   ```bash
   git --version
   ```

2. **Clone the Repository**
   - Open a terminal or command prompt and clone the repository to your local system.
   ```bash
   git clone https://github.com/cni-iisc/wlan-module/tree/main
   ```

3. **Navigate to the Experiment Directory**
   - Change into the specific experiment folder containing the Jupyter Notebook files.
   ```bash
   cd /path/to/experiment
   ```

4. **Launch Jupyter Notebook**
   - Run the following command in a terminal to start Jupyter Notebook:
   ```bash
   jupyter notebook
   ```
   - This will open the Jupyter Notebook interface in your default web browser.

5. **Open a Notebook**
   - In the Jupyter interface, navigate to the desired `.ipynb` file and click on it to open.

6. **Execute Code Cells**
   - Run code cells by clicking **Run** or using the shortcut `Shift + Enter`.

#### **Troubleshooting**
- **Jupyter Command Not Found:** Ensure Jupyter is installed properly.
  ```bash
  pip install jupyter
  ```
- **'git' is not recognized as an internal or external command:** Install Git from [Git for Windows](https://git-scm.com/downloads) and ensure it's added to the system PATH using the steps above.
- **Kernel Error:** Restart the kernel and rerun the cells.
- **Package Not Found:** Install missing dependencies.
  ```bash
  pip install -r requirements.txt
  ```

Now, you are ready to execute Jupyter Notebook files locally.
