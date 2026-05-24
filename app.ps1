Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Start-LinuxPopupSimulator {
    $script:vFS = @{
        "~" = @{
            "sys" = @{
                "config.json" = '{ "env": "PRODUCTION", "node_id": "FX-NOD-09X", "encryption": "AES-256-GCM" }';
                "status.log"   = "[2026-05-24] INFO: Core Engine active.`n[2026-05-24] WARN: High memory usage."
            };
            "audit" = @{
                "ledger_root.dat" = "0x8F3C99A1102EBEEF44321A77D8"
            };
            "readme.txt" = "GHOST-LEDGER CORE v2.5`nVerfuegbare Befehle: ls, cat, env, show-debug, clear, exit"
        }
    }
    $script:currentDir = "~"

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "GHOST-LEDGER // Volatile Mainframe Emulator"
    $form.Size = New-Object System.Drawing.Size(750, 500)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = [System.Drawing.Color]::Black
    $form.FormBorderStyle = "FixedSingle"
    $form.MaximizeBox = $false

    $outputBox = New-Object System.Windows.Forms.RichTextBox
    $outputBox.Location = New-Object System.Drawing.Point(10, 10)
    $outputBox.Size = New-Object System.Drawing.Size(715, 390)
    $outputBox.BackColor = [System.Drawing.Color]::FromArgb(15, 15, 15)
    $outputBox.ForeColor = [System.Drawing.Color]::White
    $outputBox.Font = New-Object System.Drawing.Font("Consolas", 10)
    $outputBox.ReadOnly = $true
    $outputBox.Multiline = $true
    $outputBox.ScrollBars = "ForcedVertical"
    $form.Controls.Add($outputBox)

    $promptLabel = New-Object System.Windows.Forms.Label
    $promptLabel.Location = New-Object System.Drawing.Point(10, 415)
    $promptLabel.Size = New-Object System.Drawing.Size(200, 25)
    $promptLabel.ForeColor = [System.Drawing.Color]::LimeGreen
    $promptLabel.Font = New-Object System.Drawing.Font("Consolas", 10)
    $promptLabel.Text = "ghost-user@ledger:(~)$"
    $form.Controls.Add($promptLabel)

    $inputBox = New-Object System.Windows.Forms.TextBox
    $inputBox.Location = New-Object System.Drawing.Point(210, 412)
    $inputBox.Size = New-Object System.Drawing.Size(515, 25)
    $inputBox.BackColor = [System.Drawing.Color]::Black
    $inputBox.ForeColor = [System.Drawing.Color]::White
    $inputBox.Font = New-Object System.Drawing.Font("Consolas", 10)
    $inputBox.BorderStyle = "FixedSingle"
    $form.Controls.Add($inputBox)

    function Append-Text($text, $color = [System.Drawing.Color]::White) {
        $outputBox.SelectionStart = $outputBox.TextLength
        $outputBox.SelectionLength = 0
        $outputBox.SelectionColor = $color
        $outputBox.AppendText($text + "`n")
        $outputBox.ScrollToCaret()
    }

    Append-Text "  ____ _               _   _             _                 " ([System.Drawing.Color]::Cyan)
    Append-Text " / ___| |__   ___  ___| |_| |    ___  __| | __ _  ___ _ __ " ([System.Drawing.Color]::Cyan)
    Append-Text "| |  _| '_ \ / _ \/ __| __| |   / _ \/ _` |/ _` |/ _ \ '__|" ([System.Drawing.Color]::Cyan)
    Append-Text "| |_| | | | | (_) \__ \ |_| |__|  __/ (_| | (_| |  __/ |   " ([System.Drawing.Color]::Cyan)
    Append-Text " \____|_| |_|\___/|___/\__|_____\___|\__,_|\__, |\___|_|   " ([System.Drawing.Color]::Cyan)
    Append-Text "                                           |___/           " ([System.Drawing.Color]::Cyan)
    Append-Text " ┌────────────────────────────────────────────────────────┐" ([System.Drawing.Color]::Gray)
    Append-Text "  SYSTEM: GHOST-LEDGER v2.5     │ MODE: 100% VOLATILE RAM " ([System.Drawing.Color]::White)
    Append-Text "  SUBSYSTEM: ENCRYPTED TUI      │ INTEGRITY: ISOLATED      " ([System.Drawing.Color]::White)
    Append-Text " └────────────────────────────────────────────────────────┘" ([System.Drawing.Color]::Gray)
    Append-Text " Tippe 'help' fuer die Master-Palette.`n" ([System.Drawing.Color]::DarkGray)

    $inputBox.Add_KeyDown({
        if ($_.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
            $rawInput = $inputBox.Text
            $inputBox.Text = ""
            if ([string]::IsNullOrWhiteSpace($rawInput)) { return }
            
            Append-Text "ghost-user@ledger:($script:currentDir)$ $rawInput" ([System.Drawing.Color]::LimeGreen)
            $parts = $rawInput.Trim() -split "\s+"
            $cmd = $parts[0].ToLower()
            $arg = $parts[1]

            switch ($cmd) {
                "exit" { $form.Close() }
                "clear" { $outputBox.Clear() }
                "help" {
                    Append-Text " ╔══ CORE COMMAND PALETTE ═════════════════════════════════╗" ([System.Drawing.Color]::White)
                    Append-Text "  ls             - Virtuellen RAM-Inhalt auflisten" ([System.Drawing.Color]::Cyan)
                    Append-Text "  cd [Ordner]    - Verzeichnis wechseln (z.B. cd sys)" ([System.Drawing.Color]::Cyan)
                    Append-Text "  cat [Datei]    - Datei aus flüchtigem RAM auslesen" ([System.Drawing.Color]::Cyan)
                    Append-Text "  env            - Geladene Umgebungsvariablen zeigen" ([System.Drawing.Color]::Cyan)
                    Append-Text "  show-debug     - Krypto-Audit & Pipeline-Simulation starten" ([System.Drawing.Color]::Cyan)
                    Append-Text "  clear          - Terminal leeren" ([System.Drawing.Color]::Cyan)
                    Append-Text "  exit           - System schliessen & RAM unwiderruflich leeren" ([System.Drawing.Color]::Cyan)
                    Append-Text " ╚═════════════════════════════════════════════════════════╝" ([System.Drawing.Color]::White)
                }
                "ls" {
                    $dir = $script:vFS[$script:currentDir]
                    Append-Text "`n Verzeichnisstruktur fuer $script:currentDir`:" ([System.Drawing.Color]::Gray)
                    foreach ($key in $dir.Keys) {
                        if ($dir[$key] -is [hashtable]) { Append-Text "  ├── [DIR]  $key" ([System.Drawing.Color]::DeepSkyBlue) }
                        else { Append-Text "  └── [FILE] $key" ([System.Drawing.Color]::White) }
                    }
                    Append-Text ""
                }
                "cd" {
                    if (-not $arg) { Append-Text " Fehler: Ziel-Ordner fehlt." ([System.Drawing.Color]::Red) }
                    elseif ($arg -eq "..") {
                        $script:currentDir = "~"
                        $promptLabel.Text = "ghost-user@ledger:($script:currentDir)$"
                    } else {
                        $target = $script:vFS[$script:currentDir][$arg]
                        if ($target -and ($target -is [hashtable])) {
                            $script:currentDir = $arg
                            $script:vFS[$script:currentDir] = $target
                            $promptLabel.Text = "ghost-user@ledger:($script:currentDir)$"
                        } else { Append-Text " Fehler: Ordner '$arg' existiert nicht im RAM." ([System.Drawing.Color]::Red) }
                    }
                }
                "cat" {
                    if (-not $arg) { Append-Text " Fehler: Dateiname fehlt." ([System.Drawing.Color]::Red); return }
                    $fileContent = $script:vFS[$script:currentDir][$arg]
                    if ($fileContent -and ($fileContent -isnot [hashtable])) {
                        Append-Text " ┌─── RAM-DATA-STREAM ($arg) ───────────────────────" ([System.Drawing.Color]::DarkGray)
                        Append-Text $fileContent ([System.Drawing.Color]::LightGray)
                        Append-Text " └────────────────────────────────────────────────────`n" ([System.Drawing.Color]::DarkGray)
                    } else { Append-Text " Fehler: Datei '$arg' nicht im RAM gefunden." ([System.Drawing.Color]::Red) }
                }
                "env" {
                    Append-Text "`n ┌── SECURE ENVIRONMENT VARIABLES ───────────────────┐" ([System.Drawing.Color]::Yellow)
                    Append-Text "  NODE_ENV         = GHOST_MAIN FRAME_PROD" ([System.Drawing.Color]::White)
                    Append-Text "  API_GATEWAY      = https://localhost:8443/v1/sim" ([System.Drawing.Color]::White)
                    Append-Text "  RAM_POINTER      = 0x00FF88A21" ([System.Drawing.Color]::White)
                    Append-Text "  PROTOCOL         = STRICT_ISO20022_COMPLIANT" ([System.Drawing.Color]::White)
                    Append-Text " └────────────────────────────────────────────────────┘`n" ([System.Drawing.Color]::Yellow)
                }
                "show-debug" {
                    Append-Text "`n ┌── INITIERE DEEP CRYPTO-DEBUG PIPELINE ─────────────" ([System.Drawing.Color]::Cyan)
                    Append-Text " ├── [OK] Allocating volatile memory segments..." ([System.Drawing.Color]::Gray)
                    Append-Text " ├── [OK] Establishing mock Central Bank TLS handshake..." ([System.Drawing.Color]::Gray)
                    Append-Text " ├── [OK] Verifying distributed ledger sharding hashes..." ([System.Drawing.Color]::Gray)
                    Append-Text " └── [SUCCESS] Pipeline execution complete.`n" ([System.Drawing.Color]::LimeGreen)
                    Append-Text " ╔═════════════════ SIMULATION REPORT ════════════════════╗" ([System.Drawing.Color]::LimeGreen)
                    Append-Text "   STATUS   : [||||||||||] 100% (SECURE)          " ([System.Drawing.Color]::LimeGreen)
                    Append-Text "   AUDIT    : PASSED / COMPLIANT / UNTRACEABLE           " ([System.Drawing.Color]::LimeGreen)
                    Append-Text "   SECURITY : ZERO HARD-DRIVE INTERACTION ATTAINED       " ([System.Drawing.Color]::White)
                    Append-Text " ╚════════════════════════════════════════════════════════╝`n" ([System.Drawing.Color]::LimeGreen)
                }
                default { Append-Text " Befehl '$cmd' unbekannt. Nutze 'help'." ([System.Drawing.Color]::Red) }
            }
        }
    })

    $form.ShowDialog()
}

Start-LinuxPopupSimulator
