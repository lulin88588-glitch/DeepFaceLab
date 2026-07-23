param(
    [string] $Workspace = '',
    [string] $ModelType = 'SAEHD'
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Keep this source ASCII so Windows PowerShell 5.1 decodes it reliably.
$T = @'
{
  "title": "DeepFaceLab AI \u52a9\u624b",
  "privacy": "\u672c\u5730\u5206\u6790 \u00b7 \u4e0d\u4e0a\u4f20\u4eba\u8138\u7d20\u6750 \u00b7 \u4e0d\u81ea\u52a8\u4fee\u6539\u6587\u4ef6",
  "workspace": "\u5de5\u4f5c\u533a",
  "browse": "\u6d4f\u89c8\u2026",
  "open": "\u6253\u5f00\u5de5\u4f5c\u533a",
  "actions": "\u667a\u80fd\u5206\u6790",
  "workspaceCheck": "\u68c0\u67e5\u5f53\u524d\u5de5\u4f5c\u533a",
  "workspaceHint": "\u7edf\u8ba1 SRC/DST \u6570\u91cf\u3001\u6e05\u6670\u5ea6\u3001\u66dd\u5149\u3001\u91cd\u590d\u5ea6\u548c\u5e73\u8861\u6027\u3002",
  "trainingCheck": "\u5206\u6790\u8bad\u7ec3\u72b6\u6001",
  "trainingHint": "\u7ed3\u5408\u6a21\u578b\u6458\u8981\u3001\u9884\u89c8\u56fe\u3001\u5bb9\u5668\u72b6\u6001\u548c\u6700\u8fd1\u65e5\u5fd7\u8bca\u65ad\u3002",
  "recommend": "\u751f\u6210\u63a8\u8350\u914d\u7f6e",
  "recommendHint": "\u6839\u636e\u672c\u673a GPU\u3001\u663e\u5b58\u3001\u7d20\u6750\u89c4\u6a21\u548c\u73b0\u6709\u6a21\u578b\u7ed9\u51fa\u4fdd\u5b88\u8d77\u70b9\u3002",
  "report": "\u5206\u6790\u62a5\u544a",
  "copy": "\u590d\u5236\u62a5\u544a",
  "ready": "\u5c31\u7eea",
  "running": "\u6b63\u5728\u672c\u5730\u5206\u6790\u2026",
  "complete": "\u5206\u6790\u5b8c\u6210",
  "failed": "\u5206\u6790\u5931\u8d25",
  "invalidWorkspace": "\u5de5\u4f5c\u533a\u5fc5\u987b\u5305\u542b data_src\u3001data_dst \u548c model \u76ee\u5f55\u3002",
  "dockerMissing": "\u672a\u627e\u5230 Docker\u3002\u8bf7\u5148\u542f\u52a8 Docker Desktop\u3002",
  "imageMissing": "\u672a\u627e\u5230 Blackwell \u8fd0\u884c\u955c\u50cf\u3002\u8bf7\u5148\u5728\u8bad\u7ec3\u63a7\u5236\u53f0\u5b89\u88c5\u8fd0\u884c\u73af\u5883\u3002",
  "noReport": "\u5c1a\u672a\u751f\u6210\u62a5\u544a\u3002",
  "copied": "\u62a5\u544a\u5df2\u590d\u5236\u5230\u526a\u8d34\u677f\u3002"
}
'@ | ConvertFrom-Json

Add-Type -TypeDefinition @'
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;

namespace DflAi {
    public sealed class CaptureResult {
        public int ExitCode;
        public string Output;
    }

    public sealed class ProcessMonitor : IDisposable {
        private Process process;
        private readonly ConcurrentQueue<string> lines =
            new ConcurrentQueue<string>();

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
            if (!process.Start()) throw new InvalidOperationException("Unable to start process.");
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
}
'@ -Language CSharp

[Windows.Forms.Application]::EnableVisualStyles()

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($Workspace)) {
    $Workspace = Join-Path $repoRoot 'workspace'
}
$composeFile = Join-Path $repoRoot 'compose.blackwell.yml'
$containerName = 'dfl-blackwell-trainer'
$dockerCommand = Get-Command docker.exe -ErrorAction SilentlyContinue
if (-not $dockerCommand) {
    [Windows.Forms.MessageBox]::Show(
        $T.dockerMissing, $T.title, 'OK', 'Error') | Out-Null
    exit 1
}
$docker = $dockerCommand.Source

function Quote-Arg([string] $Value) {
    if ($null -eq $Value -or $Value.Length -eq 0) { return '""' }
    return '"' + $Value.Replace('"', '\"') + '"'
}

function Test-Workspace([string] $Path) {
    try {
        $fullPath = [IO.Path]::GetFullPath($Path)
        return (Test-Path -LiteralPath (Join-Path $fullPath 'data_src')) -and
               (Test-Path -LiteralPath (Join-Path $fullPath 'data_dst')) -and
               (Test-Path -LiteralPath (Join-Path $fullPath 'model'))
    }
    catch {
        return $false
    }
}

function New-DockerEnvironment {
    $environment = New-Object 'System.Collections.Generic.Dictionary[string,string]'
    $environment['DFL_WORKSPACE_PATH'] =
        ([IO.Path]::GetFullPath($workspaceBox.Text)).Replace('\', '/')
    return $environment
}

function Get-ContainerState {
    $result = [DflAi.ProcessMonitor]::Capture(
        $docker, ('inspect --format "{{.State.Status}}" ' + $containerName),
        $repoRoot, 2500)
    if ($result.ExitCode -eq 0) { return $result.Output.Trim() }
    return ''
}

function Get-RecentLogBase64 {
    $result = [DflAi.ProcessMonitor]::Capture(
        $docker, ('logs --tail 160 ' + $containerName), $repoRoot, 3500)
    if ($result.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($result.Output)) {
        return ''
    }
    return [Convert]::ToBase64String(
        [Text.Encoding]::UTF8.GetBytes($result.Output))
}

$background = [Drawing.Color]::FromArgb(11, 15, 20)
$surface = [Drawing.Color]::FromArgb(20, 26, 34)
$surfaceRaised = [Drawing.Color]::FromArgb(28, 37, 50)
$input = [Drawing.Color]::FromArgb(29, 38, 50)
$text = [Drawing.Color]::FromArgb(242, 245, 249)
$muted = [Drawing.Color]::FromArgb(143, 157, 177)
$accent = [Drawing.Color]::FromArgb(75, 141, 248)
$success = [Drawing.Color]::FromArgb(55, 211, 153)
$danger = [Drawing.Color]::FromArgb(240, 82, 98)
$border = [Drawing.Color]::FromArgb(43, 55, 72)

function Style-Button($Button, [Drawing.Color] $Color) {
    $Button.FlatStyle = 'Flat'
    $Button.FlatAppearance.BorderSize = 0
    $Button.FlatAppearance.MouseOverBackColor =
        [Drawing.Color]::FromArgb(84, 151, 255)
    $Button.FlatAppearance.MouseDownBackColor =
        [Drawing.Color]::FromArgb(55, 107, 195)
    $Button.BackColor = $Color
    $Button.ForeColor = [Drawing.Color]::White
    $Button.Cursor = 'Hand'
    $Button.Font =
        New-Object Drawing.Font('Microsoft YaHei UI', 9, [Drawing.FontStyle]::Bold)
    $Button.UseVisualStyleBackColor = $false
}

function Add-HintLabel(
    $Parent, [string] $Caption, [int] $X, [int] $Y, [int] $Width, [int] $Height
) {
    $label = New-Object Windows.Forms.Label
    $label.Text = $Caption
    $label.ForeColor = $muted
    $label.SetBounds($X, $Y, $Width, $Height)
    $Parent.Controls.Add($label)
    return $label
}

$form = New-Object Windows.Forms.Form
$form.Text = $T.title
$form.ClientSize = New-Object Drawing.Size(1240, 780)
$form.MinimumSize = New-Object Drawing.Size(1060, 720)
$form.StartPosition = 'CenterScreen'
$form.BackColor = $background
$form.ForeColor = $text
$form.Font = New-Object Drawing.Font('Microsoft YaHei UI', 9)
$form.AutoScaleMode = 'Dpi'
$form.SuspendLayout()

$title = New-Object Windows.Forms.Label
$title.Text = $T.title
$title.Font =
    New-Object Drawing.Font('Microsoft YaHei UI', 21, [Drawing.FontStyle]::Bold)
$title.SetBounds(24, 14, 500, 42)
$form.Controls.Add($title)

$privacyLabel = New-Object Windows.Forms.Label
$privacyLabel.Text = $T.privacy
$privacyLabel.ForeColor = $muted
$privacyLabel.TextAlign = 'MiddleRight'
$privacyLabel.Anchor = 'Top,Right'
$privacyLabel.SetBounds(600, 18, 616, 32)
$form.Controls.Add($privacyLabel)

$workspacePanel = New-Object Windows.Forms.Panel
$workspacePanel.BackColor = $surface
$workspacePanel.SetBounds(20, 66, 1200, 60)
$workspacePanel.Anchor = 'Top,Left,Right'
$form.Controls.Add($workspacePanel)

Add-HintLabel $workspacePanel $T.workspace 16 20 76 22 | Out-Null
$workspaceBox = New-Object Windows.Forms.TextBox
$workspaceBox.Text = [IO.Path]::GetFullPath($Workspace)
$workspaceBox.BackColor = $input
$workspaceBox.ForeColor = $text
$workspaceBox.BorderStyle = 'FixedSingle'
$workspaceBox.SetBounds(92, 16, 894, 29)
$workspaceBox.Anchor = 'Top,Left,Right'
$workspacePanel.Controls.Add($workspaceBox)

$browseButton = New-Object Windows.Forms.Button
$browseButton.Text = $T.browse
$browseButton.SetBounds(996, 14, 88, 33)
$browseButton.Anchor = 'Top,Right'
Style-Button $browseButton $border
$workspacePanel.Controls.Add($browseButton)

$openButton = New-Object Windows.Forms.Button
$openButton.Text = $T.open
$openButton.SetBounds(1094, 14, 90, 33)
$openButton.Anchor = 'Top,Right'
Style-Button $openButton $accent
$workspacePanel.Controls.Add($openButton)

$actionPanel = New-Object Windows.Forms.Panel
$actionPanel.BackColor = $surface
$actionPanel.SetBounds(20, 142, 350, 618)
$actionPanel.Anchor = 'Top,Bottom,Left'
$form.Controls.Add($actionPanel)

$actionTitle = New-Object Windows.Forms.Label
$actionTitle.Text = $T.actions
$actionTitle.Font =
    New-Object Drawing.Font('Microsoft YaHei UI', 13, [Drawing.FontStyle]::Bold)
$actionTitle.SetBounds(20, 14, 250, 30)
$actionPanel.Controls.Add($actionTitle)

$workspaceButton = New-Object Windows.Forms.Button
$workspaceButton.Text = $T.workspaceCheck
$workspaceButton.Tag = 'workspace'
$workspaceButton.SetBounds(20, 54, 310, 44)
Style-Button $workspaceButton $accent
$actionPanel.Controls.Add($workspaceButton)
Add-HintLabel $actionPanel $T.workspaceHint 20 105 310 48 | Out-Null

$trainingButton = New-Object Windows.Forms.Button
$trainingButton.Text = $T.trainingCheck
$trainingButton.Tag = 'training'
$trainingButton.SetBounds(20, 170, 310, 44)
Style-Button $trainingButton $surfaceRaised
$actionPanel.Controls.Add($trainingButton)
Add-HintLabel $actionPanel $T.trainingHint 20 221 310 48 | Out-Null

$recommendButton = New-Object Windows.Forms.Button
$recommendButton.Text = $T.recommend
$recommendButton.Tag = 'recommend'
$recommendButton.SetBounds(20, 286, 310, 44)
Style-Button $recommendButton $surfaceRaised
$actionPanel.Controls.Add($recommendButton)
Add-HintLabel $actionPanel $T.recommendHint 20 337 310 52 | Out-Null

$statusLabel = New-Object Windows.Forms.Label
$statusLabel.Text = $T.ready
$statusLabel.ForeColor = $success
$statusLabel.SetBounds(20, 574, 310, 26)
$statusLabel.Anchor = 'Left,Right,Bottom'
$actionPanel.Controls.Add($statusLabel)

$reportPanel = New-Object Windows.Forms.Panel
$reportPanel.BackColor = $surface
$reportPanel.SetBounds(390, 142, 830, 618)
$reportPanel.Anchor = 'Top,Bottom,Left,Right'
$form.Controls.Add($reportPanel)

$reportTitle = New-Object Windows.Forms.Label
$reportTitle.Text = $T.report
$reportTitle.Font =
    New-Object Drawing.Font('Microsoft YaHei UI', 13, [Drawing.FontStyle]::Bold)
$reportTitle.SetBounds(20, 14, 300, 30)
$reportPanel.Controls.Add($reportTitle)

$copyButton = New-Object Windows.Forms.Button
$copyButton.Text = $T.copy
$copyButton.SetBounds(690, 12, 120, 34)
$copyButton.Anchor = 'Top,Right'
Style-Button $copyButton $surfaceRaised
$reportPanel.Controls.Add($copyButton)

$reportBox = New-Object Windows.Forms.RichTextBox
$reportBox.ReadOnly = $true
$reportBox.BackColor = $background
$reportBox.ForeColor = [Drawing.Color]::FromArgb(215, 222, 233)
$reportBox.BorderStyle = 'None'
$reportBox.Font = New-Object Drawing.Font('Microsoft YaHei UI', 10)
$reportBox.WordWrap = $true
$reportBox.Text = $T.noReport
$reportBox.SetBounds(20, 56, 790, 542)
$reportBox.Anchor = 'Top,Bottom,Left,Right'
$reportPanel.Controls.Add($reportBox)

$form.ResumeLayout($false)

$runner = New-Object DflAi.ProcessMonitor
$script:outputLines = New-Object Collections.Generic.List[string]
$script:activeMode = ''

function Set-Busy([bool] $Busy) {
    foreach ($button in @($workspaceButton, $trainingButton, $recommendButton)) {
        $button.Enabled = -not $Busy
    }
    $workspaceBox.Enabled = -not $Busy
    $browseButton.Enabled = -not $Busy
}

function Start-Analysis([string] $Mode) {
    if ($runner.Active) { return }
    if (-not (Test-Workspace $workspaceBox.Text)) {
        [Windows.Forms.MessageBox]::Show(
            $T.invalidWorkspace, $T.title, 'OK', 'Warning') | Out-Null
        return
    }
    $image = [DflAi.ProcessMonitor]::Capture(
        $docker, 'image inspect deepfacelab:blackwell', $repoRoot, 3500)
    if ($image.ExitCode -ne 0) {
        [Windows.Forms.MessageBox]::Show(
            $T.imageMissing, $T.title, 'OK', 'Warning') | Out-Null
        return
    }

    $state = Get-ContainerState
    $logBase64 = if ($Mode -eq 'training' -and $state) {
        Get-RecentLogBase64
    }
    else { '' }

    $arguments = 'compose --ansi never -f ' + (Quote-Arg $composeFile) +
                 ' run --rm -T'
    if ($state) {
        $arguments += ' -e DFL_AI_CONTAINER_STATE=' + (Quote-Arg $state)
    }
    if ($logBase64) {
        $arguments += ' -e DFL_AI_LOG_B64=' + (Quote-Arg $logBase64)
    }
    $arguments += ' deepfacelab dfl_ai_assistant.py' +
                  ' --mode ' + $Mode +
                  ' --workspace /workspace --sample-limit 120'
    if ($Mode -eq 'recommend') {
        $arguments += ' --model-type ' + (Quote-Arg $ModelType)
    }

    $script:outputLines.Clear()
    $script:activeMode = $Mode
    $statusLabel.Text = $T.running
    $statusLabel.ForeColor = $accent
    $reportBox.Text = $T.running
    Set-Busy $true
    $runner.Start($docker, $arguments, $repoRoot, (New-DockerEnvironment))
}

foreach ($button in @($workspaceButton, $trainingButton, $recommendButton)) {
    $button.Add_Click({
        param($sender, $eventArgs)
        Start-Analysis ([string]$sender.Tag)
    })
}

$browseButton.Add_Click({
    $dialog = New-Object Windows.Forms.FolderBrowserDialog
    $dialog.Description = $T.workspace
    $dialog.SelectedPath = $workspaceBox.Text
    if ($dialog.ShowDialog($form) -eq 'OK') {
        $workspaceBox.Text = $dialog.SelectedPath
    }
    $dialog.Dispose()
})

$openButton.Add_Click({
    if (Test-Path -LiteralPath $workspaceBox.Text) {
        Start-Process explorer.exe -ArgumentList (
            Quote-Arg ([IO.Path]::GetFullPath($workspaceBox.Text))) | Out-Null
    }
})

$copyButton.Add_Click({
    if (-not [string]::IsNullOrWhiteSpace($reportBox.Text) -and
        $reportBox.Text -ne $T.noReport) {
        [Windows.Forms.Clipboard]::SetText($reportBox.Text)
        $statusLabel.Text = $T.copied
        $statusLabel.ForeColor = $success
    }
})

$timer = New-Object Windows.Forms.Timer
$timer.Interval = 300
$timer.Add_Tick({
    foreach ($line in $runner.Drain()) {
        $script:outputLines.Add($line)
    }
    if ($script:activeMode -and $runner.Complete) {
        foreach ($line in $runner.Drain()) {
            $script:outputLines.Add($line)
        }
        $exitCode = $runner.ExitCode
        $begin = $script:outputLines.IndexOf('DFL_AI_JSON_BEGIN')
        $end = $script:outputLines.IndexOf('DFL_AI_JSON_END')
        if ($exitCode -eq 0 -and $begin -ge 0 -and $end -gt $begin) {
            try {
                $jsonLines = $script:outputLines.GetRange(
                    $begin + 1, $end - $begin - 1)
                $payload = ($jsonLines -join [Environment]::NewLine) |
                    ConvertFrom-Json
                $reportBox.Text = ([string]$payload.report).Replace(
                    '/workspace', [IO.Path]::GetFullPath($workspaceBox.Text))
                $statusLabel.Text = $T.complete
                $statusLabel.ForeColor = $success
            }
            catch {
                $reportBox.Text = $_.Exception.Message
                $statusLabel.Text = $T.failed
                $statusLabel.ForeColor = $danger
            }
        }
        else {
            $reportBox.Text = $T.failed + [Environment]::NewLine +
                ($script:outputLines -join [Environment]::NewLine)
            $statusLabel.Text = $T.failed
            $statusLabel.ForeColor = $danger
        }
        $script:activeMode = ''
        Set-Busy $false
    }
})

$form.Add_Shown({
    $form.ActiveControl = $workspaceButton
    $timer.Start()
})

$form.Add_FormClosing({
    $timer.Stop()
    if ($runner.Active) { $runner.StopMonitor() }
})

[void]$form.ShowDialog()
$timer.Dispose()
$runner.Dispose()
$form.Dispose()
