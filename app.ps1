Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Start-LinuxPopupSimulator {
    $script:lang = "de"
    $script:currentThemeIndex = 1
    $script:currentTeam = "Default-SecOps"
    $script:version = "4.2.0-ENTERPRISE"

    # Native In-Memory SQL-Database Engine
    $script:dbTables = @{}
    $script:dbTables["audit_logs"] = [System.Collections.Generic.List[PSCustomObject]]::new()
    $script:dbTables["audit_logs"].Add([PSCustomObject]@{ id = 1; timestamp = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'); command = "SYSTEM_INIT"; status = "SUCCESS" })

    # 5 Unique Themes (1 = Classic Linux Terminal, 5 = Overkill Cyberpunk)
    $script:themes = @(
        # 1: Klassisches Linux Terminal (Klassisch, Standard, jedem bekannt)
        @{
            "name"   = "Classic Linux Terminal"
            "bg"     = [System.Drawing.Color]::FromArgb(0, 0, 0)
            "output" = [System.Drawing.Color]::FromArgb(0, 0, 0)
            "text"   = [System.Drawing.Color]::FromArgb(192, 192, 192)
            "prompt" = [System.Drawing.Color]::FromArgb(0, 255, 0)
            "accent" = [System.Drawing.Color]::White
        },
        # 2: Retro Amber (Bernstein / Vintage Monochrom)
        @{
            "name"   = "Retro Amber"
            "bg"     = [System.Drawing.Color]::FromArgb(20, 10, 0)
            "output" = [System.Drawing.Color]::FromArgb(15, 8, 0)
            "text"   = [System.Drawing.Color]::FromArgb(255, 176, 0)
            "prompt" = [System.Drawing.Color]::FromArgb(255, 140, 0)
            "accent" = [System.Drawing.Color]::FromArgb(255, 200, 100)
        },
        # 3: Nordic Frost (Kühles Blau / Modern Dark)
        @{
            "name"   = "Nordic Frost"
            "bg"     = [System.Drawing.Color]::FromArgb(35, 48, 68)
            "output" = [System.Drawing.Color]::FromArgb(46, 52, 64)
            "text"   = [System.Drawing.Color]::FromArgb(216, 222, 233)
            "prompt" = [System.Drawing.Color]::FromArgb(136, 192, 208)
            "accent" = [System.Drawing.Color]::FromArgb(129, 161, 193)
        },
        # 4: Matrix Rain (Helles Giftgrün auf Tiefschwarz)
        @{
            "name"   = "Matrix Rain"
            "bg"     = [System.Drawing.Color]::FromArgb(5, 15, 5)
            "output" = [System.Drawing.Color]::FromArgb(0, 5, 0)
            "text"   = [System.Drawing.Color]::FromArgb(0, 255, 65)
            "prompt" = [System.Drawing.Color]::FromArgb(50, 205, 50)
            "accent" = [System.Drawing.Color]::FromArgb(144, 238, 144)
        },
        # 5: Overkill Cyberpunk (Neon-Pink, Neon-Cyan & Tiefschwarz Voll-Eskalation)
        @{
            "name"   = "Overkill Cyberpunk"
            "bg"     = [System.Drawing.Color]::FromArgb(12, 0, 24)
            "output" = [System.Drawing.Color]::FromArgb(8, 0, 16)
            "text"   = [System.Drawing.Color]::FromArgb(0, 240, 255)
            "prompt" = [System.Drawing.Color]::FromArgb(255, 0, 127)
            "accent" = [System.Drawing.Color]::FromArgb(255, 230, 0)
        }
    )

    $script:teamsList = @("Default-SecOps", "RedTeam-Offensive", "BlueTeam-Defense", "DevOps-Core", "AI-Research")

    $script:dict = @{
        "de" = @{
            "welcome" = " Tippe 'help' für die Befehlsübersicht.`n";
            "help_header" = " ╔══ ENTERPRISE COMMAND PALETTE (v4.2) ════════════════════╗";
            "cmd_ls" = "  ls               - Virtuellen RAM-Inhalt auflisten";
            "cmd_cd" = "  cd [Ordner]      - Verzeichnis wechseln";
            "cmd_cat" = "  cat [Datei]      - Datei auslesen";
            "cmd_sys" = "  sysinfo          - Hardware- & IP-Informationen";
            "cmd_db" = "  db-query [sql]   - SQL-Befehl ausführen";
            "cmd_http" = "  httpd [start|stop] - Webserver-Oberfläche simulieren";
            "cmd_apt" = "  apt-sim [pkg]    - Bibliotheksinstallation emulieren";
            "cmd_team" = "  team [Name]      - Team wechseln (z.B. RedTeam-Offensive)";
            "cmd_theme" = "  theme [1-5]      - Design wählen (1=Klassisch ... 5=Cyberpunk Overkill)";
            "cmd_lang" = "  lang [de|en]     - Sprache umschalten";
            "cmd_clear" = "  clear            - Terminal leeren";
            "cmd_exit" = "  exit             - System schließen";
        }
        "en" = @{
            "welcome" = " Type 'help' for the enterprise command palette.`n";
            "help_header" = " ╔══ ENTERPRISE COMMAND PALETTE (v4.2) ════════════════════╗";
            "cmd_ls" = "  ls               - List virtual RAM content";
            "cmd_cd" = "  cd [folder]      - Change directory";
            "cmd_cat" = "  cat [file]       - Read file";
            "cmd_sys" = "  sysinfo          - Hardware & IP information";
            "cmd_db" = "  db-query [sql]   - Execute SQL command";
            "cmd_http" = "  httpd [start|stop] - Simulate web server interface";
            "cmd_apt" = "  apt-sim [pkg]    - Emulate library installation";
            "cmd_team" = "  team [name]      - Switch team profile";
            "cmd_theme" = "  theme [1-5]      - Select design (1=Classic ... 5=Cyberpunk Overkill)";
            "cmd_lang" = "  lang [de|en]     - Switch language";
            "cmd_clear" = "  clear            - Clear terminal";
            "cmd_exit" = "  exit             - Close system";
        }
    }

    $script:rootFS = @{
        "sys" = @{
            "config.json" = '{ "env": "PRODUCTION", "node_id": "FX-ENTERPRISE-01", "db": "memory-engine" }';
            "status.log"   = "[2026-09-12] INFO: Web daemon online.`n[2026-09-12] INFO: Native DB active."
        };
        "www" = @{
            "index.html" = "<html><body><h1>GHOST-LEDGER Web Gateway v4.2</h1><p>Status: RUNNING</p></body></html>"
        };
        "readme.txt" = "GHOST-LEDGER ENTERPRISE v4.2`nTeams & 1-5 Theme Switcher Integration"
    }

    $script:currentFolder = $script:rootFS
    $script:currentDirName = "~"
    $script:cmdHistory = @()
    $script:historyIndex = 0
    $script:webServerActive = $false

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "GHOST-LEDGER // Enterprise Mainframe v4.2"
    $form.Size = New-Object System.Drawing.Size(860, 560)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedSingle"
    $form.MaximizeBox = $false

    $outputBox = New-Object System.Windows.Forms.RichTextBox
    $outputBox.Location = New-Object System.Drawing.Point(12, 12)
    $outputBox.Size = New-Object System.Drawing.Size(820, 440)
    $outputBox.Font = New-Object System.Drawing.Font("Consolas", 10)
    $outputBox.ReadOnly = $true
    $outputBox.Multiline = $true
    $outputBox.ScrollBars = "ForcedVertical"
    $form.Controls.Add($outputBox)

    $promptLabel = New-Object System.Windows.Forms.Label
    $promptLabel.Location = New-Object System.Drawing.Point(12, 470)
    $promptLabel.Size = New-Object System.Drawing.Size(260, 25)
    $promptLabel.Font = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Bold)
    $promptLabel.Text = "[$script:currentTeam]@ledger:(~)$"
    $form.Controls.Add($promptLabel)

    $inputBox = New-Object System.Windows.Forms.TextBox
    $inputBox.Location = New-Object System.Drawing.Point(275, 467)
    $inputBox.Size = New-Object System.Drawing.Size(555, 25)
    $inputBox.Font = New-Object System.Drawing.Font("Consolas", 10)
    $inputBox.BorderStyle = "FixedSingle"
    $form.Controls.Add($inputBox)

    function Apply-ThemeByIndex($index) {
        if ($index -ge 1 -and $index -le 5) {
            $script:currentThemeIndex = $index
            $t = $script:themes[$index - 1]
            $form.BackColor = $t["bg"]
            $outputBox.BackColor = $t["output"]
            $outputBox.ForeColor = $t["text"]
            $inputBox.BackColor = $t["output"]
            $inputBox.ForeColor = $t["text"]
            $promptLabel.ForeColor = $t["prompt"]
            return $true
        }
        return $false
    }

    Apply-ThemeByIndex $script:currentThemeIndex

    function Append-Text($text, $color) {
        if (-not $color) { $color = $script:themes[$script:currentThemeIndex - 1]["text"] }
        $outputBox.SelectionStart = $outputBox.TextLength
        $outputBox.SelectionLength = 0
        $outputBox.SelectionColor = $color
        $outputBox.AppendText($text + "`n")
        $outputBox.ScrollToCaret()
    }

    function Run-Bootloader {
        $outputBox.Clear()
        $steps = @(
            "Mounting virtual memory partitions...",
            "Loading native in-memory database engine...",
            "Initializing network stack & IP bindings...",
            "Starting HTTP web daemon simulation..."
        )
        foreach ($s in $steps) {
            Append-Text " [BOOT] $s" ([System.Drawing.Color]::Gray)
            [System.Windows.Forms.Application]::DoEvents()
            Start-Sleep -Milliseconds 50
        }
        Append-Text "`n  GHOST-LEDGER ENTERPRISE CORE v$script:version" ($script:themes[$script:currentThemeIndex - 1]["accent"])
        Append-Text " ────────────────────────────────────────────────────────" ([System.Drawing.Color]::Gray)
        Append-Text $script:dict[$script:lang]["welcome"] ([System.Drawing.Color]::DarkGray)
    }

    Run-Bootloader

    $inputBox.Add_KeyDown({
        if ($_.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
            $_.SuppressKeyPress = $true
            $rawInput = $inputBox.Text
            $inputBox.Text = ""
            if ([string]::IsNullOrWhiteSpace($rawInput)) { return }

            $script:cmdHistory += $rawInput
            $script:historyIndex = $script:cmdHistory.Length

            try {
                $newLog = [PSCustomObject]@{
                    id        = $script:dbTables["audit_logs"].Count + 1
                    timestamp = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
                    command   = $rawInput
                    status    = "SUCCESS"
                }
                $script:dbTables["audit_logs"].Add($newLog)
            } catch {}

            Append-Text "[$script:currentTeam]@ledger:($script:currentDirName)$ $rawInput" ($script:themes[$script:currentThemeIndex - 1]["prompt"])
            $parts = $rawInput.Trim() -split "\s+"
            $cmd = $parts[0].ToLower()
            $arg = $parts[1]

            switch ($cmd) {
                "exit" { $form.Close() }
                "clear" { $outputBox.Clear() }
                "theme" {
                    if ($arg -match "^[1-5]$") {
                        $idx = [int]$arg
                        Apply-ThemeByIndex $idx
                        $activeName = $script:themes[$idx - 1]["name"]
                        Append-Text " [THEME] Gewechselt zu Design #$idx: $activeName" ($script:themes[$script:currentThemeIndex - 1]["accent"])
                    } else {
                        Append-Text " [HINWEIS] Bitte eine Zahl von 1 bis 5 angeben!" ([System.Drawing.Color]::Yellow)
                        Append-Text "   1 = Classic Linux Terminal" ([System.Drawing.Color]::Gray)
                        Append-Text "   2 = Retro Amber" ([System.Drawing.Color]::Gray)
                        Append-Text "   3 = Nordic Frost" ([System.Drawing.Color]::Gray)
                        Append-Text "   4 = Matrix Rain" ([System.Drawing.Color]::Gray)
                        Append-Text "   5 = Overkill Cyberpunk" ([System.Drawing.Color]::Gray)
                    }
                }
                "team" {
                    if ($arg) {
                        $script:currentTeam = $arg
                        $promptLabel.Text = "[$script:currentTeam]@ledger:($script:currentDirName)$"
                        Append-Text " [TEAM] Team-Kontext erfolgreich gewechselt zu: '$arg'" ($script:themes[$script:currentThemeIndex - 1]["accent"])
                    } else {
                        Append-Text " [TEAM] Aktuelles Team: $script:currentTeam" ([System.Drawing.Color]::Cyan)
                        Append-Text " Verfügbare Teams: $($script:teamsList -join ', ')" ([System.Drawing.Color]::Gray)
                        Append-Text " Verwendung: team [Teamname]" ([System.Drawing.Color]::Yellow)
                    }
                }
                "lang" {
                    if ($arg -eq "en" -or $arg -eq "de") {
                        $script:lang = $arg
                        Append-Text " Language: $($arg.ToUpper())" ([System.Drawing.Color]::LimeGreen)
                    } else {
                        Append-Text " Usage: lang de / lang en" ([System.Drawing.Color]::Yellow)
                    }
                }
                "sysinfo" {
                    $ip = (Test-Connection -ComputerName (hostname) -Count 1 -ErrorAction SilentlyContinue).IPv4Address.IPAddressToString
                    if (-not $ip) { $ip = "127.0.0.1 (Loopback)" }
                    Append-Text "`n ┌── SYSTEM & TEAM METRICS ──────────────────────────┐" ($script:themes[$script:currentThemeIndex - 1]["accent"])
                    Append-Text "  Active Team    : $script:currentTeam"
                    Append-Text "  Active Theme   : #$script:currentThemeIndex - $($script:themes[$script:currentThemeIndex - 1]['name'])"
                    Append-Text "  Local IP       : $ip"
                    Append-Text "  Database Engine: Native In-Memory Relational DB"
                    Append-Text "  Web Server     : $(if($script:webServerActive){'RUNNING (:8080)'}else{'STOPPED'})"
                    Append-Text " ─────────────────────────────────────────────────────┘`n" ($script:themes[$script:currentThemeIndex - 1]["accent"])
                }
                "db-query" {
                    $sql = $rawInput.Substring(8).Trim()
                    if ($sql -match "^SELECT\s+\*\s+FROM\s+(\w+)$") {
                        $tableName = $Matches[1]
                        if ($script:dbTables.ContainsKey($tableName)) {
                            Append-Text " [DB-QUERY] Table: $tableName" ([System.Drawing.Color]::LimeGreen)
                            foreach ($row in $script:dbTables[$tableName]) {
                                $rowStr = ($row.psobject.properties | ForEach-Object { "$($_.Name)=$($_.Value)" }) -join " | "
                                Append-Text "   [$rowStr]"
                            }
                        } else {
                            Append-Text " [DB-ERROR] Table '$tableName' not found." ([System.Drawing.Color]::Red)
                        }
                    } else {
                        Append-Text " [DB-SUCCESS] Statement executed." ([System.Drawing.Color]::LimeGreen)
                    }
                }
                "httpd" {
                    if ($arg -eq "start") {
                        $script:webServerActive = $true
                        Append-Text " [HTTPD] Web daemon started on http://localhost:8080" ([System.Drawing.Color]::LimeGreen)
                    } elseif ($arg -eq "stop") {
                        $script:webServerActive = $false
                        Append-Text " [HTTPD] Web daemon stopped." ([System.Drawing.Color]::Yellow)
                    } else {
                        Append-Text " Usage: httpd start / httpd stop" ([System.Drawing.Color]::Yellow)
                    }
                }
                "apt-sim" {
                    if (-not $arg) { Append-Text " Usage: apt-sim [package-name]" ([System.Drawing.Color]::Red); return }
                    Append-Text " Reading package lists... Done" ([System.Drawing.Color]::Gray)
                    Append-Text " Unpacking $arg ... Done" ([System.Drawing.Color]::Gray)
                    Append-Text " Setting up $arg ... [SUCCESS]" ([System.Drawing.Color]::LimeGreen)
                }
                "help" {
                    $d = $script:dict[$script:lang]
                    Append-Text $d["help_header"] ($script:themes[$script:currentThemeIndex - 1]["accent"])
                    Append-Text $d["cmd_ls"]
                    Append-Text $d["cmd_cd"]
                    Append-Text $d["cmd_cat"]
                    Append-Text $d["cmd_sys"]
                    Append-Text $d["cmd_db"]
                    Append-Text $d["cmd_http"]
                    Append-Text $d["cmd_apt"]
                    Append-Text $d["cmd_team"]
                    Append-Text $d["cmd_theme"]
                    Append-Text $d["cmd_lang"]
                    Append-Text $d["cmd_clear"]
                    Append-Text $d["cmd_exit"]
                    Append-Text " ╚═════════════════════════════════════════════════════════╝" ($script:themes[$script:currentThemeIndex - 1]["accent"])
                }
                "ls" {
                    Append-Text "`n Directory listing for $script:currentDirName:" ([System.Drawing.Color]::Gray)
                    foreach ($key in $script:currentFolder.Keys) {
                        if ($script:currentFolder[$key] -is [hashtable]) { Append-Text "   ├── [DIR]   $key" ([System.Drawing.Color]::DeepSkyBlue) }
                        else { Append-Text "   └── [FILE]  $key" }
                    }
                    Append-Text ""
                }
                "cd" {
                    if (-not $arg) { Append-Text " Error: Missing folder." ([System.Drawing.Color]::Red) }
                    elseif ($arg -eq "..") {
                        $script:currentFolder = $script:rootFS
                        $script:currentDirName = "~"
                        $promptLabel.Text = "[$script:currentTeam]@ledger:($script:currentDirName)$"
                    } else {
                        $target = $script:currentFolder[$arg]
                        if ($target -and ($target -is [hashtable])) {
                            $script:currentFolder = $target
                            $script:currentDirName = "~/$arg"
                            $promptLabel.Text = "[$script:currentTeam]@ledger:($script:currentDirName)$"
                        } else { Append-Text " Error: Folder '$arg' not found." ([System.Drawing.Color]::Red) }
                    }
                }
                "cat" {
                    if (-not $arg) { Append-Text " Error: Missing filename." ([System.Drawing.Color]::Red); return }
                    $content = $script:currentFolder[$arg]
                    if ($content -and ($content -isnot [hashtable])) {
                        Append-Text " ─── FILE CONTENT ($arg) ──────────────────────────" ([System.Drawing.Color]::DarkGray)
                        Append-Text $content
                        Append-Text " ────────────────────────────────────────────────────`n" ([System.Drawing.Color]::DarkGray)
                    } else { Append-Text " Error: File '$arg' not found." ([System.Drawing.Color]::Red) }
                }
                default { 
                    Append-Text " Unknown command '$cmd'. Type 'help'." ([System.Drawing.Color]::Red) 
                }
            }
        }
        elseif ($_.KeyCode -eq [System.Windows.Forms.Keys]::Up) {
            if ($script:cmdHistory.Length -gt 0) {
                if ($script:historyIndex -gt 0) { $script:historyIndex-- }
                $inputBox.Text = $script:cmdHistory[$script:historyIndex]
                $inputBox.Select($inputBox.Text.Length, 0)
                $_.SuppressKeyPress = $true
            }
        }
        elseif ($_.KeyCode -eq [System.Windows.Forms.Keys]::Down) {
            if ($script:cmdHistory.Length -gt 0) {
                if ($script:historyIndex -lt $script:cmdHistory.Length - 1) {
                    $script:historyIndex++
                    $inputBox.Text = $script:cmdHistory[$script:historyIndex]
                } else {
                    $script:historyIndex = $script:cmdHistory.Length
                    $inputBox.Text = ""
                }
                $inputBox.Select($inputBox.Text.Length, 0)
                $_.SuppressKeyPress = $true
            }
        }
    })

    $form.ShowDialog()
}

Start-LinuxPopupSimulator
