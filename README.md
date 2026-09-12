```markdown
# GhostLedger

GhostLedger is a high-end, 100% RAM-isolated Linux Terminal simulation built as a standalone Windows Forms Pop-up. It simulates a secure FinTech environment, isolated virtual filesystem, and dynamic visual styling layers without writing any files to the host hard drive. 

Once closed, all volatile structures, active theme states, command history pointers, and runtime caches vanish instantly from system memory.

## 🚀 Key Features

- **Zero-Footprint Architecture:** Operates entirely within the volatile RAM layer. No local configuration files, logs, or traces are ever written to the physical storage disk.
- **Dynamic Theme Switcher Engine:** Real-time visual re-rendering supporting custom color configurations (Classic Terminal green-on-black, Retro Amber monochromatic tones).
- **Virtual RAM File System (vFS):** Fully sandboxed nested directory layout (`~` root containing the `sys` system directory) holding simulated configuration manifests and status logs.
- **Interactive Command Line History:** Fully operational history buffer supporting `Up` and `Down` arrow key navigation to quickly cycle through previously executed terminal inputs.
- **Total Operating System Sandboxing:** Complete process isolation from your actual host operating system files and environment variables.

## 💻 How to Launch

1. Open Windows PowerShell.
2. Navigate to the directory containing the simulation script:
   ```powershell
   cd "C:\Pfad\zu\deinem\Ordner"

```

3. Execute the script:
```powershell
.\app.ps1

```



---

## 🛠️ Comprehensive Terminal Command Reference (v4.2.0)

GhostLedger features a built-in shell interpreter designed to process standard command tokens and arguments in real time.

### 1. File & Directory Navigation

* **`ls`**
* **Description:** Lists all contents of the currently active virtual directory. Distinguishes visually between directories (`[DIR]`) and files (`[FILE]`).
* **Usage:** `ls`


* **`cd [directory]`**
* **Description:** Changes the working directory inside the virtual RAM structure. Use `cd ..` to navigate back up to the root directory (`~`).
* **Usage:** `cd sys` or `cd ..`


* **`cat [filename]`**
* **Description:** Reads and streams the raw text content of a virtual file located in the current working directory directly to the terminal output panel.
* **Usage:** `cat config.json` or `cat status.log`



### 2. Interface & System Control

* **`theme [1-2]`**
* **Description:** Dynamically switches the graphical user interface color profile on the fly without restarting the application.
* `1` = Classic Terminal (Deep black background with sharp contrasting text and classic green prompt highlights).
* `2` = Retro Amber (Deep dark-brown amber phosphor layout with warm golden-orange textual feedback).


* **Usage:** `theme 2`


* **`clear`**
* **Description:** Clears all previous lines from the terminal output box, providing a clean workspace.
* **Usage:** `clear`


* **`help`**
* **Description:** Renders an overview box listing all primary operational commands supported by the current stable build.
* **Usage:** `help`


* **`exit`**
* **Description:** Gracefully terminates the Windows Forms event loop, closes the pop-up window, and purges all volatile runtime instances from RAM.
* **Usage:** `exit`



```
