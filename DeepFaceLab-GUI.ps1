Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Keep this source file ASCII so Windows PowerShell 5.1 reads it consistently.
# ConvertFrom-Json expands the Unicode escapes into Simplified Chinese at runtime.
$T = @'
{
  "title": "DeepFaceLab RTX 5090 \u63a7\u5236\u53f0",
  "subtitle": "\u672c\u673a\u539f\u751f\u63a7\u5236 \u00b7 Docker/WSL2 \u8ba1\u7b97 \u00b7 WSLg \u5b9e\u65f6\u9884\u89c8",
  "workspace": "\u5de5\u4f5c\u533a",
  "browse": "\u6d4f\u89c8\u2026",
  "modelType": "\u6a21\u578b\u7c7b\u578b",
  "modelName": "\u6a21\u578b\u540d\u79f0",
  "preview": "\u663e\u793a\u5b9e\u65f6\u9884\u89c8\u7a97\u53e3\uff08\u63a8\u8350\uff09",
  "silent": "\u4f7f\u7528\u5df2\u6709\u8bbe\u7f6e\u76f4\u63a5\u542f\u52a8",
  "start": "\u5f00\u59cb\u8bad\u7ec3",
  "stop": "\u4fdd\u5b58\u5e76\u505c\u6b62",
  "showPreview": "\u663e\u793a\u9884\u89c8",
  "previewNotFound": "\u6682\u672a\u627e\u5230\u9884\u89c8\u7a97\u53e3\uff0c\u8bf7\u7b49\u6a21\u578b\u52a0\u8f7d\u5b8c\u6210\u540e\u518d\u8bd5\u3002",
  "build": "\u5b89\u88c5 / \u66f4\u65b0\u8fd0\u884c\u73af\u5883",
  "verify": "\u73af\u5883\u68c0\u6d4b",
  "open": "\u6253\u5f00\u5de5\u4f5c\u533a",
  "log": "\u8fd0\u884c\u65e5\u5fd7",
  "ready": "\u5c31\u7eea",
  "gpu": "\u663e\u5361",
  "runtime": "\u8bad\u7ec3\u72b6\u6001",
  "notRunning": "\u672a\u8fd0\u884c",
  "running": "\u8fd0\u884c\u4e2d",
  "building": "\u6b63\u5728\u6784\u5efa\u8fd0\u884c\u73af\u5883\u2026",
  "verifying": "\u6b63\u5728\u68c0\u6d4b\u73af\u5883\u2026",
  "starting": "\u6b63\u5728\u542f\u52a8\u8bad\u7ec3\u2026",
  "saving": "\u6b63\u5728\u4fdd\u5b58\u6a21\u578b\u5e76\u505c\u6b62\u2026",
  "selectWorkspace": "\u9009\u62e9 DeepFaceLab workspace",
  "invalidWorkspace": "\u5de5\u4f5c\u533a\u5fc5\u987b\u5305\u542b data_src\u3001data_dst \u548c model \u76ee\u5f55\u3002",
  "cannotStart": "\u65e0\u6cd5\u542f\u52a8",
  "previewHelp": "\u9884\u89c8\u7a97\u53e3\u5feb\u6377\u952e\uff1aP \u5237\u65b0\uff0c\u7a7a\u683c\u5207\u6362\uff0cS \u4fdd\u5b58\uff0cB \u5907\u4efd\uff0cEnter \u4fdd\u5b58\u5e76\u9000\u51fa\u3002",
  "closePrompt": "\u8bad\u7ec3\u4ecd\u5728\u8fd0\u884c\u3002\\n\\n\u662f\uff1a\u4fdd\u5b58\u5e76\u505c\u6b62\u540e\u5173\u95ed\\n\u5426\uff1a\u8ba9\u8bad\u7ec3\u5728\u540e\u53f0\u7ee7\u7eed\u5e76\u5173\u95ed\\n\u53d6\u6d88\uff1a\u8fd4\u56de\u63a7\u5236\u53f0",
  "closeTitle": "\u8bad\u7ec3\u4ecd\u5728\u8fd0\u884c",
  "started": "\u8bad\u7ec3\u5bb9\u5668\u5df2\u542f\u52a8\uff0c\u6a21\u578b\u52a0\u8f7d\u5b8c\u6210\u540e\u4f1a\u51fa\u73b0\u9884\u89c8\u7a97\u53e3\u3002",
  "stopped": "\u8bad\u7ec3\u5df2\u505c\u6b62\uff0c\u6a21\u578b\u5df2\u4fdd\u5b58\u3002",
  "operationFailed": "\u64cd\u4f5c\u5931\u8d25\uff0c\u9000\u51fa\u4ee3\u7801\uff1a",
  "imageReady": "\u8fd0\u884c\u73af\u5883\u5df2\u5c31\u7eea\u3002",
  "verifyDone": "\u73af\u5883\u68c0\u6d4b\u5b8c\u6210\u3002",
  "dockerMissing": "\u672a\u627e\u5230 Docker\u3002\u8bf7\u5b89\u88c5\u5e76\u542f\u52a8 Docker Desktop\u3002",
  "busy": "\u5f53\u524d\u6709\u64cd\u4f5c\u6b63\u5728\u6267\u884c\u3002",
  "refresh": "\u5237\u65b0\u6a21\u578b"
}
'@ | ConvertFrom-Json

Add-Type -TypeDefinition @'
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;

namespace DflGui {
    public sealed class CaptureResult {
        public int ExitCode;
        public string Output;
    }

    public sealed class ProcessMonitor : IDisposable {
        private Process process;
        private readonly ConcurrentQueue<string> lines = new ConcurrentQueue<string>();

        public bool Active { get { return process != null && !process.HasExited; } }
        public bool Complete { get { return process != null && process.HasExited; } }
        public int ExitCode { get { return Complete ? process.ExitCode : -999; } }

        public void Start(string fileName, string arguments, string workingDirectory,
                          IDictionary<string, string> environment) {
            DisposeProcess();
            string discarded;
            while (lines.TryDequeue(out discarded)) { }

            ProcessStartInfo info = new ProcessStartInfo();
            info.FileName = fileName;
            info.Arguments = arguments;
            info.WorkingDirectory = workingDirectory;
            info.UseShellExecute = false;
            info.CreateNoWindow = true;
            info.RedirectStandardOutput = true;
            info.RedirectStandardError = true;
            info.StandardOutputEncoding = Encoding.UTF8;
            info.StandardErrorEncoding = Encoding.UTF8;
            if (environment != null) {
                foreach (KeyValuePair<string, string> item in environment)
                    info.EnvironmentVariables[item.Key] = item.Value;
            }

            process = new Process();
            process.StartInfo = info;
            process.OutputDataReceived += delegate(object sender, DataReceivedEventArgs e) {
                if (e.Data != null) lines.Enqueue(e.Data);
            };
            process.ErrorDataReceived += delegate(object sender, DataReceivedEventArgs e) {
                if (e.Data != null) lines.Enqueue(e.Data);
            };
            if (!process.Start()) throw new InvalidOperationException("Unable to start " + fileName);
            process.BeginOutputReadLine();
            process.BeginErrorReadLine();
        }

        public string[] Drain() {
            List<string> result = new List<string>();
            string line;
            while (lines.TryDequeue(out line)) result.Add(line);
            return result.ToArray();
        }

        public void StopMonitor() {
            if (process != null && !process.HasExited) process.Kill();
            DisposeProcess();
        }

        private void DisposeProcess() {
            if (process != null) {
                process.Dispose();
                process = null;
            }
        }

        public void Dispose() { StopMonitor(); }

        public static CaptureResult Capture(string fileName, string arguments,
                                            string workingDirectory, int timeoutMs) {
            ProcessStartInfo info = new ProcessStartInfo();
            info.FileName = fileName;
            info.Arguments = arguments;
            info.WorkingDirectory = workingDirectory;
            info.UseShellExecute = false;
            info.CreateNoWindow = true;
            info.RedirectStandardOutput = true;
            info.RedirectStandardError = true;
            info.StandardOutputEncoding = Encoding.UTF8;
            info.StandardErrorEncoding = Encoding.UTF8;
            using (Process p = Process.Start(info)) {
                string output = p.StandardOutput.ReadToEnd();
                string error = p.StandardError.ReadToEnd();
                if (!p.WaitForExit(timeoutMs)) {
                    p.Kill();
                    return new CaptureResult { ExitCode = 124, Output = "Command timed out." };
                }
                return new CaptureResult {
                    ExitCode = p.ExitCode,
                    Output = (output + Environment.NewLine + error).Trim()
                };
            }
        }
    }

    public static class PreviewWindow {
        private delegate bool EnumWindowsProc(IntPtr window, IntPtr state);

        [StructLayout(LayoutKind.Sequential)]
        private struct Rect { public int Left, Top, Right, Bottom; }

        [DllImport("user32.dll")]
        private static extern bool EnumWindows(EnumWindowsProc callback, IntPtr state);
        [DllImport("user32.dll", CharSet = CharSet.Unicode)]
        private static extern int GetWindowText(IntPtr window, StringBuilder text, int maxCount);
        [DllImport("user32.dll")]
        private static extern int GetWindowTextLength(IntPtr window);
        [DllImport("user32.dll")]
        private static extern bool IsWindowVisible(IntPtr window);
        [DllImport("user32.dll")]
        private static extern bool GetWindowRect(IntPtr window, out Rect rect);
        [DllImport("user32.dll")]
        private static extern bool ShowWindow(IntPtr window, int command);
        [DllImport("user32.dll")]
        private static extern bool SetWindowPos(IntPtr window, IntPtr insertAfter,
                                                int x, int y, int width, int height,
                                                uint flags);
        [DllImport("user32.dll")]
        private static extern bool SetForegroundWindow(IntPtr window);
        [DllImport("user32.dll")]
        private static extern bool BringWindowToTop(IntPtr window);
        [DllImport("user32.dll")]
        private static extern int GetSystemMetrics(int index);

        public static bool ShowTrainingPreview() {
            IntPtr preview = IntPtr.Zero;
            EnumWindows(delegate(IntPtr window, IntPtr state) {
                if (!IsWindowVisible(window)) return true;
                int length = GetWindowTextLength(window);
                if (length == 0) return true;
                StringBuilder title = new StringBuilder(length + 1);
                GetWindowText(window, title, title.Capacity);
                if (title.ToString().IndexOf("Training preview", StringComparison.OrdinalIgnoreCase) >= 0) {
                    preview = window;
                    return false;
                }
                return true;
            }, IntPtr.Zero);

            if (preview == IntPtr.Zero) return false;

            ShowWindow(preview, 9); // SW_RESTORE
            Rect current;
            GetWindowRect(preview, out current);
            int screenWidth = Math.Max(800, GetSystemMetrics(0));
            int screenHeight = Math.Max(600, GetSystemMetrics(1));
            int width = Math.Min(Math.Max(current.Right - current.Left, 800), screenWidth - 80);
            int height = Math.Min(Math.Max(current.Bottom - current.Top, 600), screenHeight - 80);
            int x = Math.Max(0, (screenWidth - width) / 2);
            int y = Math.Max(0, (screenHeight - height) / 2);
            SetWindowPos(preview, new IntPtr(-1), x, y, width, height, 0x0040); // TOPMOST + SHOW
            SetWindowPos(preview, new IntPtr(-2), x, y, width, height, 0x0040); // NOTOPMOST
            BringWindowToTop(preview);
            SetForegroundWindow(preview);
            return true;
        }
    }
}
'@ -Language CSharp

[System.Windows.Forms.Application]::EnableVisualStyles()

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$composeFile = Join-Path $repoRoot 'compose.blackwell.yml'
$containerName = 'dfl-blackwell-trainer'
$dockerCommand = Get-Command docker.exe -ErrorAction SilentlyContinue
if (-not $dockerCommand) {
    [System.Windows.Forms.MessageBox]::Show($T.dockerMissing, $T.cannotStart, 'OK', 'Error') | Out-Null
    exit 1
}
$docker = $dockerCommand.Source

function Quote-Arg([string] $Value) {
    if ($null -eq $Value -or $Value.Length -eq 0) { return '""' }
    return '"' + $Value.Replace('"', '\"') + '"'
}

function New-DockerEnvironment([string] $Workspace) {
    $environment = New-Object 'System.Collections.Generic.Dictionary[string,string]'
    $environment['DFL_WORKSPACE_PATH'] = $Workspace.Replace('\', '/')
    return $environment
}

function Get-Docker([string] $Arguments, [int] $Timeout = 4000) {
    return [DflGui.ProcessMonitor]::Capture($docker, $Arguments, $repoRoot, $Timeout)
}

$background = [Drawing.Color]::FromArgb(18, 20, 25)
$panel = [Drawing.Color]::FromArgb(28, 31, 38)
$input = [Drawing.Color]::FromArgb(38, 42, 51)
$text = [Drawing.Color]::FromArgb(235, 238, 243)
$muted = [Drawing.Color]::FromArgb(150, 158, 174)
$accent = [Drawing.Color]::FromArgb(41, 196, 132)
$danger = [Drawing.Color]::FromArgb(231, 89, 99)
$border = [Drawing.Color]::FromArgb(58, 63, 74)
$font = New-Object Drawing.Font('Microsoft YaHei UI', 9)

$form = New-Object Windows.Forms.Form
$form.Text = $T.title
$form.ClientSize = New-Object Drawing.Size(1120, 740)
$form.MinimumSize = New-Object Drawing.Size(980, 680)
$form.StartPosition = 'CenterScreen'
$form.BackColor = $background
$form.ForeColor = $text
$form.Font = $font
$form.AutoScaleMode = 'Dpi'

$title = New-Object Windows.Forms.Label
$title.Text = $T.title
$title.Font = New-Object Drawing.Font('Microsoft YaHei UI', 20, [Drawing.FontStyle]::Bold)
$title.ForeColor = $text
$title.SetBounds(24, 18, 600, 38)
$form.Controls.Add($title)

$subtitle = New-Object Windows.Forms.Label
$subtitle.Text = $T.subtitle
$subtitle.ForeColor = $muted
$subtitle.SetBounds(27, 57, 700, 24)
$form.Controls.Add($subtitle)

$gpuLabel = New-Object Windows.Forms.Label
$gpuLabel.TextAlign = 'MiddleRight'
$gpuLabel.ForeColor = $muted
$gpuLabel.Anchor = 'Top,Right'
$gpuLabel.SetBounds(700, 23, 390, 48)
$form.Controls.Add($gpuLabel)

$configPanel = New-Object Windows.Forms.Panel
$configPanel.BackColor = $panel
$configPanel.SetBounds(20, 94, 350, 610)
$configPanel.Anchor = 'Top,Bottom,Left'
$form.Controls.Add($configPanel)

function Add-Label($Parent, [string] $Caption, [int] $X, [int] $Y, [int] $Width = 300) {
    $label = New-Object Windows.Forms.Label
    $label.Text = $Caption
    $label.ForeColor = $muted
    $label.SetBounds($X, $Y, $Width, 23)
    $Parent.Controls.Add($label)
    return $label
}

function Style-Button($Button, [Drawing.Color] $Color) {
    $Button.FlatStyle = 'Flat'
    $Button.FlatAppearance.BorderSize = 0
    $Button.BackColor = $Color
    $Button.ForeColor = [Drawing.Color]::White
    $Button.Cursor = 'Hand'
    $Button.Font = New-Object Drawing.Font('Microsoft YaHei UI', 9, [Drawing.FontStyle]::Bold)
}

Add-Label $configPanel $T.workspace 18 20 | Out-Null
$workspaceBox = New-Object Windows.Forms.TextBox
$workspaceBox.Text = Join-Path $repoRoot 'workspace'
$workspaceBox.BackColor = $input
$workspaceBox.ForeColor = $text
$workspaceBox.BorderStyle = 'FixedSingle'
$workspaceBox.SetBounds(18, 47, 238, 29)
$configPanel.Controls.Add($workspaceBox)

$browseButton = New-Object Windows.Forms.Button
$browseButton.Text = $T.browse
$browseButton.SetBounds(266, 45, 66, 32)
Style-Button $browseButton $border
$configPanel.Controls.Add($browseButton)

Add-Label $configPanel $T.modelType 18 94 140 | Out-Null
Add-Label $configPanel $T.modelName 176 94 145 | Out-Null
$modelTypeBox = New-Object Windows.Forms.ComboBox
$modelTypeBox.DropDownStyle = 'DropDownList'
$modelTypeBox.BackColor = $input
$modelTypeBox.ForeColor = $text
$modelTypeBox.FlatStyle = 'Flat'
$modelTypeBox.Items.AddRange(@('SAEHD', 'Quick96', 'XSeg'))
$modelTypeBox.SelectedItem = 'SAEHD'
$modelTypeBox.SetBounds(18, 121, 140, 30)
$configPanel.Controls.Add($modelTypeBox)

$modelNameBox = New-Object Windows.Forms.ComboBox
$modelNameBox.DropDownStyle = 'DropDown'
$modelNameBox.BackColor = $input
$modelNameBox.ForeColor = $text
$modelNameBox.FlatStyle = 'Flat'
$modelNameBox.SetBounds(176, 121, 156, 30)
$configPanel.Controls.Add($modelNameBox)

$previewCheck = New-Object Windows.Forms.CheckBox
$previewCheck.Text = $T.preview
$previewCheck.Checked = $true
$previewCheck.ForeColor = $text
$previewCheck.SetBounds(18, 174, 310, 28)
$configPanel.Controls.Add($previewCheck)

$silentCheck = New-Object Windows.Forms.CheckBox
$silentCheck.Text = $T.silent
$silentCheck.Checked = $true
$silentCheck.ForeColor = $text
$silentCheck.SetBounds(18, 207, 310, 28)
$configPanel.Controls.Add($silentCheck)

$startButton = New-Object Windows.Forms.Button
$startButton.Text = $T.start
$startButton.SetBounds(18, 255, 314, 48)
Style-Button $startButton $accent
$configPanel.Controls.Add($startButton)

$stopButton = New-Object Windows.Forms.Button
$stopButton.Text = $T.stop
$stopButton.Enabled = $false
$stopButton.SetBounds(18, 313, 202, 42)
Style-Button $stopButton $danger
$configPanel.Controls.Add($stopButton)

$showPreviewButton = New-Object Windows.Forms.Button
$showPreviewButton.Text = $T.showPreview
$showPreviewButton.Enabled = $false
$showPreviewButton.SetBounds(230, 313, 102, 42)
Style-Button $showPreviewButton $border
$configPanel.Controls.Add($showPreviewButton)

$buildButton = New-Object Windows.Forms.Button
$buildButton.Text = $T.build
$buildButton.SetBounds(18, 384, 314, 38)
Style-Button $buildButton $border
$configPanel.Controls.Add($buildButton)

$verifyButton = New-Object Windows.Forms.Button
$verifyButton.Text = $T.verify
$verifyButton.SetBounds(18, 432, 151, 38)
Style-Button $verifyButton $border
$configPanel.Controls.Add($verifyButton)

$openButton = New-Object Windows.Forms.Button
$openButton.Text = $T.open
$openButton.SetBounds(181, 432, 151, 38)
Style-Button $openButton $border
$configPanel.Controls.Add($openButton)

$helpLabel = New-Object Windows.Forms.Label
$helpLabel.Text = $T.previewHelp
$helpLabel.ForeColor = $muted
$helpLabel.SetBounds(18, 500, 314, 70)
$helpLabel.AutoEllipsis = $true
$configPanel.Controls.Add($helpLabel)

$runtimeLabel = New-Object Windows.Forms.Label
$runtimeLabel.Text = $T.runtime + ': ' + $T.notRunning
$runtimeLabel.ForeColor = $muted
$runtimeLabel.SetBounds(18, 575, 314, 24)
$runtimeLabel.Anchor = 'Left,Bottom'
$configPanel.Controls.Add($runtimeLabel)

$logPanel = New-Object Windows.Forms.Panel
$logPanel.BackColor = $panel
$logPanel.SetBounds(390, 94, 710, 610)
$logPanel.Anchor = 'Top,Bottom,Left,Right'
$form.Controls.Add($logPanel)

$logTitle = New-Object Windows.Forms.Label
$logTitle.Text = $T.log
$logTitle.Font = New-Object Drawing.Font('Microsoft YaHei UI', 11, [Drawing.FontStyle]::Bold)
$logTitle.SetBounds(16, 13, 300, 28)
$logPanel.Controls.Add($logTitle)

$logBox = New-Object Windows.Forms.RichTextBox
$logBox.ReadOnly = $true
$logBox.BackColor = [Drawing.Color]::FromArgb(14, 16, 20)
$logBox.ForeColor = [Drawing.Color]::FromArgb(205, 211, 222)
$logBox.BorderStyle = 'None'
$logBox.Font = New-Object Drawing.Font('Cascadia Mono', 9)
$logBox.DetectUrls = $false
$logBox.WordWrap = $false
$logBox.SetBounds(16, 49, 678, 544)
$logBox.Anchor = 'Top,Bottom,Left,Right'
$logPanel.Controls.Add($logBox)

function Add-Log([string] $Line) {
    if ([string]::IsNullOrWhiteSpace($Line)) { return }
    $logBox.AppendText(('[' + (Get-Date -Format 'HH:mm:ss') + '] ' + $Line + [Environment]::NewLine))
    if ($logBox.TextLength -gt 250000) {
        $logBox.Select(0, 100000)
        $logBox.SelectedText = ''
    }
    $logBox.SelectionStart = $logBox.TextLength
    $logBox.ScrollToCaret()
}

function Test-Workspace([string] $Workspace) {
    return (Test-Path -LiteralPath (Join-Path $Workspace 'data_src')) -and
           (Test-Path -LiteralPath (Join-Path $Workspace 'data_dst')) -and
           (Test-Path -LiteralPath (Join-Path $Workspace 'model'))
}

function Refresh-Models {
    $selected = [string]$modelNameBox.Text
    $modelNameBox.Items.Clear()
    $modelDir = Join-Path $workspaceBox.Text 'model'
    if (Test-Path -LiteralPath $modelDir) {
        $typePattern = [Regex]::Escape([string]$modelTypeBox.SelectedItem)
        Get-ChildItem -LiteralPath $modelDir -File -Filter '*_data.dat' -ErrorAction SilentlyContinue |
            ForEach-Object {
                if ($_.Name -match ('^(.+)_' + $typePattern + '_data\.dat$')) {
                    [void]$modelNameBox.Items.Add($Matches[1])
                }
            }
    }
    if ($selected) { $modelNameBox.Text = $selected }
    elseif ($modelNameBox.Items.Count -gt 0) { $modelNameBox.SelectedIndex = 0 }
}

function Set-Busy([bool] $Busy) {
    $canConfigure = (-not $Busy) -and (-not $script:training)
    $buildButton.Enabled = $canConfigure
    $verifyButton.Enabled = $canConfigure
    $startButton.Enabled = $canConfigure
    $workspaceBox.Enabled = $canConfigure
    $browseButton.Enabled = $workspaceBox.Enabled
    $modelTypeBox.Enabled = $workspaceBox.Enabled
    $modelNameBox.Enabled = $workspaceBox.Enabled
    $showPreviewButton.Enabled = $script:training
}

$commandRunner = New-Object DflGui.ProcessMonitor
$logRunner = New-Object DflGui.ProcessMonitor
$script:operation = ''
$script:training = $false
$script:closeAfterStop = $false
$script:tickCount = 0
$script:lastContainerState = ''
$script:previewFocusedForSession = $false

function Start-Operation([string] $Name, [string] $Arguments, [string] $Status) {
    if ($commandRunner.Active) {
        [Windows.Forms.MessageBox]::Show($T.busy, $T.title, 'OK', 'Information') | Out-Null
        return
    }
    $script:operation = $Name
    $runtimeLabel.Text = $T.runtime + ': ' + $Status
    Set-Busy $true
    Add-Log $Status
    $commandRunner.Start($docker, $Arguments, $repoRoot, (New-DockerEnvironment $workspaceBox.Text))
}

function Attach-TrainingLog {
    if (-not $logRunner.Active) {
        $logRunner.Start($docker, ('logs --follow --tail 120 ' + $containerName), $repoRoot, $null)
    }
}

function Get-ContainerState {
    $result = Get-Docker ('inspect --format "{{.State.Status}}" ' + $containerName) 2500
    if ($result.ExitCode -eq 0) { return $result.Output.Trim() }
    return ''
}

$browseButton.Add_Click({
    $dialog = New-Object Windows.Forms.FolderBrowserDialog
    $dialog.Description = $T.selectWorkspace
    $dialog.SelectedPath = $workspaceBox.Text
    if ($dialog.ShowDialog($form) -eq 'OK') {
        $workspaceBox.Text = $dialog.SelectedPath
        Refresh-Models
    }
    $dialog.Dispose()
})
$modelTypeBox.Add_SelectedIndexChanged({ Refresh-Models })
$workspaceBox.Add_Leave({ Refresh-Models })

$openButton.Add_Click({
    if (Test-Path -LiteralPath $workspaceBox.Text) {
        Start-Process explorer.exe -ArgumentList (Quote-Arg $workspaceBox.Text)
    }
})

$buildButton.Add_Click({
    $args = 'compose --ansi never -f ' + (Quote-Arg $composeFile) + ' build'
    Start-Operation 'build' $args $T.building
})

$verifyButton.Add_Click({
    $args = 'compose --ansi never -f ' + (Quote-Arg $composeFile) +
            ' run --rm deepfacelab verify_blackwell_training.py'
    Start-Operation 'verify' $args $T.verifying
})

$startButton.Add_Click({
    $workspace = [IO.Path]::GetFullPath($workspaceBox.Text)
    if (-not (Test-Workspace $workspace)) {
        [Windows.Forms.MessageBox]::Show($T.invalidWorkspace, $T.cannotStart, 'OK', 'Warning') | Out-Null
        return
    }
    $existing = Get-ContainerState
    if ($existing) {
        $script:training = $true
        Attach-TrainingLog
        return
    }

    $type = [string]$modelTypeBox.SelectedItem
    $args = 'compose --ansi never -f ' + (Quote-Arg $composeFile) +
            ' run --rm -d --name ' + $containerName +
            ' deepfacelab main.py train' +
            ' --training-data-src-dir /workspace/data_src/aligned' +
            ' --training-data-dst-dir /workspace/data_dst/aligned' +
            ' --model-dir /workspace/model' +
            ' --model ' + (Quote-Arg $type)
    if (-not [string]::IsNullOrWhiteSpace($modelNameBox.Text)) {
        $args += ' --force-model-name ' + (Quote-Arg $modelNameBox.Text.Trim())
    }
    if ($silentCheck.Checked) { $args += ' --silent-start' }
    if (-not $previewCheck.Checked) { $args += ' --no-preview' }
    Start-Operation 'start' $args $T.starting
})

$stopButton.Add_Click({
    if (-not $script:training -or $commandRunner.Active) { return }
    Start-Operation 'stop' ('kill --signal=SIGINT ' + $containerName) $T.saving
})

$showPreviewButton.Add_Click({
    if (-not [DflGui.PreviewWindow]::ShowTrainingPreview()) {
        [Windows.Forms.MessageBox]::Show($T.previewNotFound, $T.title, 'OK', 'Information') | Out-Null
    }
})

$timer = New-Object Windows.Forms.Timer
$timer.Interval = 1000
$timer.Add_Tick({
    foreach ($line in $commandRunner.Drain()) { Add-Log $line }
    foreach ($line in $logRunner.Drain()) { Add-Log $line }

    if ($script:operation -and $commandRunner.Complete) {
        foreach ($line in $commandRunner.Drain()) { Add-Log $line }
        $exitCode = $commandRunner.ExitCode
        $finished = $script:operation
        $script:operation = ''
        if ($exitCode -ne 0) {
            Add-Log ($T.operationFailed + ' ' + $exitCode)
            $runtimeLabel.Text = $T.runtime + ': ' + $T.notRunning
        }
        elseif ($finished -eq 'build') {
            Add-Log $T.imageReady
            $runtimeLabel.Text = $T.runtime + ': ' + $T.ready
        }
        elseif ($finished -eq 'verify') {
            Add-Log $T.verifyDone
            $runtimeLabel.Text = $T.runtime + ': ' + $T.ready
        }
        elseif ($finished -eq 'start') {
            $script:training = $true
            Add-Log $T.started
            Attach-TrainingLog
        }
        Set-Busy $false
    }

    $script:tickCount++
    if (($script:tickCount % 2) -eq 0) {
        $state = Get-ContainerState
        if ($state) {
            $script:training = $true
            $runtimeLabel.Text = $T.runtime + ': ' + $T.running
            $runtimeLabel.ForeColor = $accent
            $stopButton.Enabled = -not $commandRunner.Active
            $showPreviewButton.Enabled = $true
            $startButton.Enabled = $false
            if (-not $logRunner.Active -and $script:operation -ne 'start') { Attach-TrainingLog }
            if (-not $script:previewFocusedForSession -and
                [DflGui.PreviewWindow]::ShowTrainingPreview()) {
                $script:previewFocusedForSession = $true
            }
        }
        else {
            if ($script:training -and $script:operation -ne 'start') {
                $script:training = $false
                $logRunner.StopMonitor()
                Add-Log $T.stopped
                if ($script:closeAfterStop) {
                    $script:closeAfterStop = $false
                    $form.Close()
                    return
                }
            }
            $runtimeLabel.Text = $T.runtime + ': ' + $T.notRunning
            $runtimeLabel.ForeColor = $muted
            $stopButton.Enabled = $false
            $showPreviewButton.Enabled = $false
            $script:previewFocusedForSession = $false
            if (-not $commandRunner.Active) { Set-Busy $false }
        }
        $script:lastContainerState = $state
    }

    if (($script:tickCount % 4) -eq 1) {
        $gpu = [DflGui.ProcessMonitor]::Capture('nvidia-smi.exe',
            '--query-gpu=name,temperature.gpu,utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits',
            $repoRoot, 2500)
        if ($gpu.ExitCode -eq 0) {
            $parts = $gpu.Output.Split(',') | ForEach-Object { $_.Trim() }
            if ($parts.Count -ge 5) {
                $gpuLabel.Text = $parts[0] + [Environment]::NewLine +
                    $parts[2] + '%  |  ' + $parts[1] + [char]0x00B0 + 'C  |  ' +
                    $parts[3] + ' / ' + $parts[4] + ' MiB'
            }
        }
    }
})

$form.Add_Shown({
    Refresh-Models
    Add-Log $T.ready
    $initialState = Get-ContainerState
    if ($initialState) {
        $script:training = $true
        Attach-TrainingLog
    }
    $timer.Start()
})

$form.Add_FormClosing({
    param($sender, $eventArgs)
    if ($script:closeAfterStop) {
        $eventArgs.Cancel = $true
        return
    }
    if ($script:training) {
        $choice = [Windows.Forms.MessageBox]::Show(
            $T.closePrompt.Replace('\n', [Environment]::NewLine),
            $T.closeTitle, 'YesNoCancel', 'Question')
        if ($choice -eq 'Cancel') {
            $eventArgs.Cancel = $true
            return
        }
        if ($choice -eq 'Yes') {
            $eventArgs.Cancel = $true
            $script:closeAfterStop = $true
            if (-not $commandRunner.Active) {
                Start-Operation 'stop' ('kill --signal=SIGINT ' + $containerName) $T.saving
            }
            return
        }
    }
    $timer.Stop()
    $logRunner.StopMonitor()
    if ($commandRunner.Active) { $commandRunner.StopMonitor() }
})

[void]$form.ShowDialog()
$timer.Dispose()
$commandRunner.Dispose()
$logRunner.Dispose()
$form.Dispose()
