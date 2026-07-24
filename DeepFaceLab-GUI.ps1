Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Keep this source file ASCII so Windows PowerShell 5.1 reads it consistently.
# ConvertFrom-Json expands the Unicode escapes into Simplified Chinese at runtime.
$T = @'
{
  "title": "DeepFaceLab \u8bad\u7ec3\u63a7\u5236\u53f0",
  "workspace": "\u5de5\u4f5c\u533a",
  "browse": "\u6d4f\u89c8\u2026",
  "settings": "\u8bad\u7ec3\u8bbe\u7f6e",
  "tools": "\u73af\u5883\u5de5\u5177",
  "modelType": "\u6a21\u578b\u7c7b\u578b",
  "modelName": "\u6a21\u578b\u540d\u79f0",
  "preview": "\u81ea\u52a8\u663e\u793a\u5b9e\u65f6\u9884\u89c8",
  "silent": "\u6cbf\u7528\u5df2\u6709\u6a21\u578b\u8bbe\u7f6e",
  "cpu": "\u4ec5 CPU \u6a21\u5f0f",
  "workflow": "\u6253\u5f00\u5de5\u4f5c\u53f0",
  "workbenchTitle": "DeepFaceLab \u5de5\u4f5c\u53f0",
  "oneClick": "\u4e00\u952e DFM \u8bad\u7ec3",
  "oneClickTitle": "DeepFaceLab DFM \u4e00\u952e\u8bad\u7ec3",
  "aiAssistant": "AI \u667a\u80fd\u4e2d\u5fc3",
  "aiLaunch": "AI \u4e00\u952e\u5206\u6790",
  "aiTitle": "DeepFaceLab AI \u52a9\u624b",
  "logTab": "\u8bad\u7ec3\u65e5\u5fd7",
  "aiPrivacy": "\u672c\u5730 AI \u00b7 \u7d20\u6750\u4e0d\u4e0a\u4e91 \u00b7 \u5efa\u8bae\u53ef\u4e00\u952e\u5e94\u7528",
  "aiWorkspace": "\u7d20\u6750\u4f53\u68c0",
  "aiTraining": "\u8bad\u7ec3\u8bca\u65ad",
  "aiRecommend": "\u63a8\u8350\u914d\u7f6e",
  "aiApply": "\u5e94\u7528\u5230\u65b0\u6a21\u578b",
  "aiCopy": "\u590d\u5236\u62a5\u544a",
  "aiIdle": "\u9009\u62e9\u4e00\u9879\u5206\u6790\uff0cAI \u4f1a\u8bfb\u53d6\u5f53\u524d\u7d20\u6750\u3001\u6a21\u578b\u3001\u9884\u89c8\u548c\u8fd0\u884c\u65e5\u5fd7\u3002",
  "aiRunning": "AI \u6b63\u5728\u672c\u5730\u5206\u6790\u2026",
  "aiComplete": "AI \u5206\u6790\u5b8c\u6210",
  "aiFailed": "AI \u5206\u6790\u5931\u8d25",
  "aiImageMissing": "\u672a\u627e\u5230 Blackwell \u8fd0\u884c\u955c\u50cf\uff0c\u8bf7\u5148\u70b9\u51fb\u201c\u5b89\u88c5 / \u66f4\u65b0\u73af\u5883\u201d\u3002",
  "aiNoRecommendation": "\u8bf7\u5148\u751f\u6210\u63a8\u8350\u914d\u7f6e\u3002",
  "aiSaeOnly": "\u76ee\u524d\u53ea\u652f\u6301\u5c06 AI \u63a8\u8350\u5e94\u7528\u5230\u65b0 SAEHD \u6a21\u578b\u3002",
  "aiInvalidModelName": "\u6a21\u578b\u540d\u79f0\u53ea\u80fd\u5305\u542b\u82f1\u6587\u5b57\u6bcd\u3001\u6570\u5b57\u3001\u70b9\u3001\u4e0b\u5212\u7ebf\u548c\u77ed\u6a2a\u7ebf\u3002",
  "aiExistingModel": "\u8fd9\u4e2a\u540d\u79f0\u7684 SAEHD \u6a21\u578b\u5df2\u5b58\u5728\u3002AI \u4e0d\u4f1a\u6539\u5199\u5df2\u8bad\u7ec3\u6a21\u578b\uff0c\u8bf7\u8f93\u5165\u4e00\u4e2a\u65b0\u540d\u79f0\u3002",
  "aiApplied": "AI \u63a8\u8350\u5df2\u5e94\u7528\uff1a\u65b0\u6a21\u578b\u4f1a\u6cbf\u7528 RTX 5090 \u9884\u8bbe\uff0c\u73b0\u5728\u53ef\u4ee5\u5f00\u59cb\u8bad\u7ec3\u3002",
  "aiApplyFailed": "\u63a8\u8350\u914d\u7f6e\u5e94\u7528\u5931\u8d25",
  "aiCopied": "AI \u62a5\u544a\u5df2\u590d\u5236\u3002",
  "start": "\u5f00\u59cb\u8bad\u7ec3",
  "stop": "\u4fdd\u5b58\u5e76\u505c\u6b62",
  "showPreview": "\u663e\u793a\u9884\u89c8",
  "previewNotFound": "\u6682\u672a\u627e\u5230\u9884\u89c8\u7a97\u53e3\uff0c\u8bf7\u7b49\u6a21\u578b\u52a0\u8f7d\u5b8c\u6210\u540e\u518d\u8bd5\u3002",
  "build": "\u5b89\u88c5 / \u66f4\u65b0\u73af\u5883",
  "verify": "\u73af\u5883\u68c0\u6d4b",
  "open": "\u6253\u5f00\u5de5\u4f5c\u533a",
  "log": "\u8bad\u7ec3\u65e5\u5fd7",
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
  "previewHelp": "\u9884\u89c8\u6bcf 10 \u79d2\u81ea\u52a8\u5237\u65b0\uff1b\u5173\u95ed\u540e\u53ef\u70b9\u201c\u663e\u793a\u9884\u89c8\u201d\u91cd\u65b0\u6253\u5f00\u3002\u8bf7\u7528\u201c\u4fdd\u5b58\u5e76\u505c\u6b62\u201d\u5b89\u5168\u9000\u51fa\u8bad\u7ec3\u3002",
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

$singleInstanceCreated = $false
$script:singleInstanceMutex = [Threading.Mutex]::new(
    $true, 'Local\DeepFaceLabTrainingConsole', [ref]$singleInstanceCreated)
if (-not $singleInstanceCreated) {
    $windowShell = New-Object -ComObject WScript.Shell
    [void]$windowShell.AppActivate([string]$T.title)
    $script:singleInstanceMutex.Dispose()
    exit 0
}

Add-Type -TypeDefinition @'
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;

namespace DflGui {
    public static class AppIdentity {
        [System.Runtime.InteropServices.DllImport(
            "shell32.dll", CharSet = System.Runtime.InteropServices.CharSet.Unicode)]
        public static extern int SetCurrentProcessExplicitAppUserModelID(
            string appId);
    }

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

    public static class WindowTools {
        [System.Runtime.InteropServices.DllImport("user32.dll")]
        public static extern bool SetForegroundWindow(IntPtr hWnd);
        [System.Runtime.InteropServices.DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    }

}
'@ -Language CSharp

[void][DflGui.AppIdentity]::SetCurrentProcessExplicitAppUserModelID(
    'lulin88588.DeepFaceLab.TrainingConsole')

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

$background = [Drawing.Color]::FromArgb(11, 15, 20)
$surface = [Drawing.Color]::FromArgb(20, 26, 34)
$panel = [Drawing.Color]::FromArgb(23, 30, 40)
$surfaceRaised = [Drawing.Color]::FromArgb(28, 37, 50)
$input = [Drawing.Color]::FromArgb(29, 38, 50)
$text = [Drawing.Color]::FromArgb(242, 245, 249)
$muted = [Drawing.Color]::FromArgb(143, 157, 177)
$accent = [Drawing.Color]::FromArgb(75, 141, 248)
$success = [Drawing.Color]::FromArgb(55, 211, 153)
$danger = [Drawing.Color]::FromArgb(240, 82, 98)
$dangerSurface = [Drawing.Color]::FromArgb(55, 30, 38)
$dangerText = [Drawing.Color]::FromArgb(255, 191, 199)
$dangerBorder = [Drawing.Color]::FromArgb(119, 52, 65)
$border = [Drawing.Color]::FromArgb(43, 55, 72)
$font = New-Object Drawing.Font('Microsoft YaHei UI', 9)

$form = New-Object Windows.Forms.Form
$form.Text = $T.title
$script:appIcon = $null
$appIconPath = Join-Path $repoRoot 'assets\dfl-console.ico'
if (Test-Path -LiteralPath $appIconPath) {
    $script:appIcon = New-Object Drawing.Icon($appIconPath)
    $form.Icon = $script:appIcon
}
$form.ClientSize = New-Object Drawing.Size(1280, 800)
$form.MinimumSize = New-Object Drawing.Size(1120, 820)
$form.StartPosition = 'CenterScreen'
$form.BackColor = $background
$form.ForeColor = $text
$form.Font = $font
$form.AutoScaleMode = 'Dpi'
$form.SuspendLayout()

$previewForm = New-Object Windows.Forms.Form
$previewForm.Text = 'DeepFaceLab - ' + $T.showPreview
$previewForm.ClientSize = New-Object Drawing.Size(1100, 820)
$previewForm.MinimumSize = New-Object Drawing.Size(720, 540)
$previewForm.StartPosition = 'CenterScreen'
$previewForm.BackColor = $background
$previewForm.KeyPreview = $true
$previewPicture = New-Object Windows.Forms.PictureBox
$previewPicture.Dock = 'Fill'
$previewPicture.BackColor = $background
$previewPicture.SizeMode = 'Zoom'
$previewForm.Controls.Add($previewPicture)

$title = New-Object Windows.Forms.Label
$title.Text = $T.title
$title.Font = New-Object Drawing.Font('Microsoft YaHei UI', 21, [Drawing.FontStyle]::Bold)
$title.ForeColor = $text
$title.SetBounds(24, 14, 600, 42)
$form.Controls.Add($title)

$gpuLabel = New-Object Windows.Forms.Label
$gpuLabel.TextAlign = 'MiddleRight'
$gpuLabel.ForeColor = $muted
$gpuLabel.Anchor = 'Top,Right'
$gpuLabel.SetBounds(790, 12, 466, 44)
$form.Controls.Add($gpuLabel)

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
    $Button.FlatAppearance.MouseOverBackColor = [Drawing.Color]::FromArgb(84, 151, 255)
    $Button.FlatAppearance.MouseDownBackColor = [Drawing.Color]::FromArgb(55, 107, 195)
    $Button.BackColor = $Color
    $Button.ForeColor = [Drawing.Color]::White
    $Button.Cursor = 'Hand'
    $Button.Font = New-Object Drawing.Font('Microsoft YaHei UI', 9, [Drawing.FontStyle]::Bold)
    $Button.UseVisualStyleBackColor = $false
}

function Style-DangerButton($Button) {
    $Button.FlatStyle = 'Flat'
    $Button.FlatAppearance.BorderSize = 1
    $Button.FlatAppearance.BorderColor = $dangerBorder
    $Button.FlatAppearance.MouseOverBackColor = [Drawing.Color]::FromArgb(78, 39, 49)
    $Button.FlatAppearance.MouseDownBackColor = [Drawing.Color]::FromArgb(94, 42, 53)
    $Button.BackColor = $dangerSurface
    $Button.ForeColor = $dangerText
    $Button.Cursor = 'Hand'
    $Button.Font = New-Object Drawing.Font('Microsoft YaHei UI', 9, [Drawing.FontStyle]::Bold)
    $Button.UseVisualStyleBackColor = $false
}

$workspacePanel = New-Object Windows.Forms.Panel
$workspacePanel.BackColor = $surface
$workspacePanel.SetBounds(20, 66, 1240, 60)
$workspacePanel.Anchor = 'Top,Left,Right'
$form.Controls.Add($workspacePanel)

Add-Label $workspacePanel $T.workspace 16 20 76 | Out-Null
$workspaceBox = New-Object Windows.Forms.TextBox
$workspaceBox.Text = Join-Path $repoRoot 'workspace'
$workspaceBox.BackColor = $input
$workspaceBox.ForeColor = $text
$workspaceBox.BorderStyle = 'FixedSingle'
$workspaceBox.SetBounds(92, 16, 932, 29)
$workspaceBox.Anchor = 'Top,Left,Right'
$workspacePanel.Controls.Add($workspaceBox)

$browseButton = New-Object Windows.Forms.Button
$browseButton.Text = $T.browse
$browseButton.SetBounds(1034, 14, 88, 33)
$browseButton.Anchor = 'Top,Right'
Style-Button $browseButton $border
$workspacePanel.Controls.Add($browseButton)

$openButton = New-Object Windows.Forms.Button
$openButton.Text = $T.open
$openButton.SetBounds(1132, 14, 92, 33)
$openButton.Anchor = 'Top,Right'
Style-Button $openButton $accent
$workspacePanel.Controls.Add($openButton)

$configPanel = New-Object Windows.Forms.Panel
$configPanel.BackColor = $surface
$configPanel.SetBounds(20, 142, 390, 638)
$configPanel.Anchor = 'Top,Bottom,Left'
$form.Controls.Add($configPanel)

$configTitle = New-Object Windows.Forms.Label
$configTitle.Text = $T.settings
$configTitle.Font = New-Object Drawing.Font('Microsoft YaHei UI', 13, [Drawing.FontStyle]::Bold)
$configTitle.SetBounds(20, 14, 300, 30)
$configPanel.Controls.Add($configTitle)

Add-Label $configPanel $T.modelType 20 52 160 | Out-Null
Add-Label $configPanel $T.modelName 200 52 170 | Out-Null
$modelTypeBox = New-Object Windows.Forms.ComboBox
$modelTypeBox.DropDownStyle = 'DropDownList'
$modelTypeBox.BackColor = $input
$modelTypeBox.ForeColor = $text
$modelTypeBox.FlatStyle = 'Flat'
$modelTypeBox.Items.AddRange(@('AMP', 'SAEHD', 'Quick96', 'XSeg'))
$modelTypeBox.SelectedItem = 'SAEHD'
$modelTypeBox.SetBounds(20, 76, 160, 30)
$configPanel.Controls.Add($modelTypeBox)

$modelNameBox = New-Object Windows.Forms.ComboBox
$modelNameBox.DropDownStyle = 'DropDown'
$modelNameBox.BackColor = $input
$modelNameBox.ForeColor = $text
$modelNameBox.FlatStyle = 'Flat'
$modelNameBox.SetBounds(200, 76, 170, 30)
$configPanel.Controls.Add($modelNameBox)

$previewCheck = New-Object Windows.Forms.CheckBox
$previewCheck.Text = $T.preview
$previewCheck.Checked = $true
$previewCheck.ForeColor = $text
$previewCheck.SetBounds(20, 124, 350, 26)
$configPanel.Controls.Add($previewCheck)

$silentCheck = New-Object Windows.Forms.CheckBox
$silentCheck.Text = $T.silent
$silentCheck.Checked = $true
$silentCheck.ForeColor = $text
$silentCheck.SetBounds(20, 154, 350, 26)
$configPanel.Controls.Add($silentCheck)

$cpuOnlyCheck = New-Object Windows.Forms.CheckBox
$cpuOnlyCheck.Text = $T.cpu
$cpuOnlyCheck.Checked = $false
$cpuOnlyCheck.ForeColor = $text
$cpuOnlyCheck.SetBounds(20, 184, 350, 26)
$configPanel.Controls.Add($cpuOnlyCheck)

$startButton = New-Object Windows.Forms.Button
$startButton.Text = $T.start
$startButton.SetBounds(20, 222, 350, 48)
Style-Button $startButton $accent
$configPanel.Controls.Add($startButton)

$stopButton = New-Object Windows.Forms.Button
$stopButton.Text = $T.stop
$stopButton.Enabled = $false
$stopButton.SetBounds(20, 282, 216, 42)
Style-DangerButton $stopButton
$configPanel.Controls.Add($stopButton)

$showPreviewButton = New-Object Windows.Forms.Button
$showPreviewButton.Text = $T.showPreview
$showPreviewButton.Enabled = $false
$showPreviewButton.SetBounds(246, 282, 124, 42)
Style-Button $showPreviewButton $surfaceRaised
$configPanel.Controls.Add($showPreviewButton)

$workflowButton = New-Object Windows.Forms.Button
$workflowButton.Text = $T.workflow
$workflowButton.SetBounds(190, 342, 180, 42)
Style-Button $workflowButton $surfaceRaised
$configPanel.Controls.Add($workflowButton)

$oneClickButton = New-Object Windows.Forms.Button
$oneClickButton.Text = $T.oneClick
$oneClickButton.SetBounds(20, 342, 160, 42)
Style-Button $oneClickButton $accent
$configPanel.Controls.Add($oneClickButton)

$toolsLabel = Add-Label $configPanel $T.tools 20 400 350
$toolsLabel.Font = New-Object Drawing.Font('Microsoft YaHei UI', 9, [Drawing.FontStyle]::Bold)

$buildButton = New-Object Windows.Forms.Button
$buildButton.Text = $T.build
$buildButton.SetBounds(20, 424, 350, 38)
Style-Button $buildButton $surfaceRaised
$configPanel.Controls.Add($buildButton)

$verifyButton = New-Object Windows.Forms.Button
$verifyButton.Text = $T.verify
$verifyButton.SetBounds(20, 472, 350, 38)
Style-Button $verifyButton $surfaceRaised
$configPanel.Controls.Add($verifyButton)

$helpLabel = New-Object Windows.Forms.Label
$helpLabel.Text = $T.previewHelp
$helpLabel.ForeColor = $muted
$helpLabel.SetBounds(20, 520, 350, 46)
$helpLabel.AutoEllipsis = $true
$configPanel.Controls.Add($helpLabel)

$runtimeLabel = New-Object Windows.Forms.Label
$runtimeLabel.Text = $T.runtime + ': ' + $T.notRunning
$runtimeLabel.ForeColor = $success
$runtimeLabel.TextAlign = 'MiddleLeft'
$runtimeLabel.SetBounds(20, 594, 350, 26)
$runtimeLabel.Anchor = 'Left,Right,Bottom'
$configPanel.Controls.Add($runtimeLabel)

$logPanel = New-Object Windows.Forms.Panel
$logPanel.BackColor = $surface
$logPanel.SetBounds(430, 142, 830, 638)
$logPanel.Anchor = 'Top,Bottom,Left,Right'
$form.Controls.Add($logPanel)

$logTitle = New-Object Windows.Forms.Label
$logTitle.Text = $T.aiAssistant
$logTitle.Font = New-Object Drawing.Font('Microsoft YaHei UI', 13, [Drawing.FontStyle]::Bold)
$logTitle.SetBounds(20, 14, 300, 30)
$logPanel.Controls.Add($logTitle)

$logTabButton = New-Object Windows.Forms.Button
$logTabButton.Text = $T.logTab
$logTabButton.SetBounds(570, 12, 110, 34)
$logTabButton.Anchor = 'Top,Right'
Style-Button $logTabButton $surfaceRaised
$logPanel.Controls.Add($logTabButton)

$aiButton = New-Object Windows.Forms.Button
$aiButton.Text = $T.aiLaunch
$aiButton.SetBounds(690, 12, 120, 34)
$aiButton.Anchor = 'Top,Right'
Style-Button $aiButton $accent
$logPanel.Controls.Add($aiButton)

$logBox = New-Object Windows.Forms.RichTextBox
$logBox.ReadOnly = $true
$logBox.BackColor = $background
$logBox.ForeColor = [Drawing.Color]::FromArgb(205, 211, 222)
$logBox.BorderStyle = 'None'
$logBox.Font = New-Object Drawing.Font('Cascadia Mono', 9)
$logBox.DetectUrls = $false
$logBox.WordWrap = $false
$logBox.SetBounds(20, 52, 790, 566)
$logBox.Anchor = 'Top,Bottom,Left,Right'
$logBox.Visible = $false
$logPanel.Controls.Add($logBox)

$aiPanel = New-Object Windows.Forms.Panel
$aiPanel.BackColor = $surface
$aiPanel.SetBounds(20, 52, 790, 566)
$aiPanel.Anchor = 'Top,Bottom,Left,Right'
$aiPanel.Visible = $true
$logPanel.Controls.Add($aiPanel)

$aiPrivacyLabel = New-Object Windows.Forms.Label
$aiPrivacyLabel.Text = $T.aiPrivacy
$aiPrivacyLabel.ForeColor = $muted
$aiPrivacyLabel.SetBounds(0, 0, 570, 24)
$aiPanel.Controls.Add($aiPrivacyLabel)

$aiStatusLabel = New-Object Windows.Forms.Label
$aiStatusLabel.Text = $T.ready
$aiStatusLabel.ForeColor = $success
$aiStatusLabel.TextAlign = 'MiddleRight'
$aiStatusLabel.SetBounds(590, 0, 200, 24)
$aiStatusLabel.Anchor = 'Top,Right'
$aiPanel.Controls.Add($aiStatusLabel)

$aiSummaryLabel = New-Object Windows.Forms.Label
$aiSummaryLabel.Text = $T.aiIdle
$aiSummaryLabel.ForeColor = $text
$aiSummaryLabel.Font =
    New-Object Drawing.Font('Microsoft YaHei UI', 9, [Drawing.FontStyle]::Bold)
$aiSummaryLabel.SetBounds(0, 26, 790, 30)
$aiSummaryLabel.Anchor = 'Top,Left,Right'
$aiSummaryLabel.AutoEllipsis = $true
$aiPanel.Controls.Add($aiSummaryLabel)

$aiWorkspaceButton = New-Object Windows.Forms.Button
$aiWorkspaceButton.Text = $T.aiWorkspace
$aiWorkspaceButton.Tag = 'workspace'
$aiWorkspaceButton.SetBounds(0, 64, 116, 36)
Style-Button $aiWorkspaceButton $surfaceRaised
$aiPanel.Controls.Add($aiWorkspaceButton)

$aiTrainingButton = New-Object Windows.Forms.Button
$aiTrainingButton.Text = $T.aiTraining
$aiTrainingButton.Tag = 'training'
$aiTrainingButton.SetBounds(126, 64, 116, 36)
Style-Button $aiTrainingButton $surfaceRaised
$aiPanel.Controls.Add($aiTrainingButton)

$aiRecommendButton = New-Object Windows.Forms.Button
$aiRecommendButton.Text = $T.aiRecommend
$aiRecommendButton.Tag = 'recommend'
$aiRecommendButton.SetBounds(252, 64, 116, 36)
Style-Button $aiRecommendButton $accent
$aiPanel.Controls.Add($aiRecommendButton)

$aiApplyButton = New-Object Windows.Forms.Button
$aiApplyButton.Text = $T.aiApply
$aiApplyButton.Enabled = $false
$aiApplyButton.SetBounds(378, 64, 176, 36)
Style-Button $aiApplyButton $success
$aiPanel.Controls.Add($aiApplyButton)

$aiCopyButton = New-Object Windows.Forms.Button
$aiCopyButton.Text = $T.aiCopy
$aiCopyButton.Enabled = $false
$aiCopyButton.SetBounds(564, 64, 112, 36)
Style-Button $aiCopyButton $surfaceRaised
$aiPanel.Controls.Add($aiCopyButton)

$aiReportBox = New-Object Windows.Forms.RichTextBox
$aiReportBox.ReadOnly = $true
$aiReportBox.BackColor = $background
$aiReportBox.ForeColor = [Drawing.Color]::FromArgb(215, 222, 233)
$aiReportBox.BorderStyle = 'None'
$aiReportBox.Font = New-Object Drawing.Font('Microsoft YaHei UI', 9)
$aiReportBox.WordWrap = $true
$aiReportBox.Text = $T.aiIdle
$aiReportBox.SetBounds(0, 112, 790, 454)
$aiReportBox.Anchor = 'Top,Bottom,Left,Right'
$aiPanel.Controls.Add($aiReportBox)

$form.ResumeLayout($false)

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

function Show-AiView([bool] $ShowAi) {
    $aiPanel.Visible = $ShowAi
    $logBox.Visible = -not $ShowAi
    if ($ShowAi) {
        $logTitle.Text = $T.aiAssistant
        $aiButton.BackColor = $accent
        $logTabButton.BackColor = $surfaceRaised
        $aiPanel.BringToFront()
    }
    else {
        $logTitle.Text = $T.logTab
        $logTabButton.BackColor = $accent
        $aiButton.BackColor = $surfaceRaised
        $logBox.BringToFront()
    }
}

function Test-AiProperty($Object, [string] $Name) {
    return $null -ne $Object -and
           $Object.PSObject.Properties.Name -contains $Name
}

function Set-AiBusy([bool] $Busy) {
    $analysisBusy = $Busy -or $commandRunner.Active
    foreach ($button in @(
        $aiWorkspaceButton, $aiTrainingButton, $aiRecommendButton
    )) {
        $button.Enabled = -not $analysisBusy
    }
    $canApply = $false
    if (-not $Busy -and -not $script:aiApplied -and
        $null -ne $script:aiPayload -and
        (Test-AiProperty $script:aiPayload 'mode') -and
        [string]$script:aiPayload.mode -eq 'recommend' -and
        (Test-AiProperty $script:aiPayload 'can_apply') -and
        (Test-AiProperty $script:aiPayload 'recommended_options') -and
        [bool]$script:aiPayload.can_apply -and
        [string]$modelTypeBox.SelectedItem -eq 'SAEHD' -and
        -not $script:training -and -not $commandRunner.Active) {
        $canApply = $true
    }
    $aiApplyButton.Enabled = $canApply
    $aiCopyButton.Enabled =
        (-not $Busy) -and
        (-not [string]::IsNullOrWhiteSpace($aiReportBox.Text)) -and
        $aiReportBox.Text -ne $T.aiIdle
}

function Get-AiRecentLogBase64 {
    $result = Get-Docker ('logs --tail 160 ' + $containerName) 3500
    if ($result.ExitCode -ne 0 -or
        [string]::IsNullOrWhiteSpace($result.Output)) {
        return ''
    }
    return [Convert]::ToBase64String(
        [Text.Encoding]::UTF8.GetBytes($result.Output))
}

function Save-AiPayload($Payload) {
    try {
        $directory = Join-Path $workspaceBox.Text '.dfl-ai'
        [IO.Directory]::CreateDirectory($directory) | Out-Null
        $path = Join-Path $directory 'last-report.json'
        $temporary = $path + '.tmp'
        $Payload | ConvertTo-Json -Depth 10 |
            Set-Content -LiteralPath $temporary -Encoding UTF8
        Move-Item -LiteralPath $temporary -Destination $path -Force
    }
    catch {
        Add-Log ('AI report persistence: ' + $_.Exception.Message)
    }
}

function Load-AiPayload {
    $script:aiPayload = $null
    $script:aiApplied = $false
    $aiReportBox.Text = $T.aiIdle
    $aiSummaryLabel.Text = $T.aiIdle
    $aiStatusLabel.Text = $T.ready
    $aiStatusLabel.ForeColor = $success
    Set-AiBusy $false
    $path = Join-Path $workspaceBox.Text '.dfl-ai\last-report.json'
    if (-not (Test-Path -LiteralPath $path)) { return }
    try {
        $payload = Get-Content -LiteralPath $path -Raw -Encoding UTF8 |
            ConvertFrom-Json
        $script:aiPayload = $payload
        $script:aiApplied = $false
        $aiReportBox.Text = ([string]$payload.report).Replace(
            '/workspace', [IO.Path]::GetFullPath($workspaceBox.Text))
        Update-AiSummary $payload
        $aiStatusLabel.Text = $T.aiComplete
        $aiStatusLabel.ForeColor = $success
        Set-AiBusy $false
    }
    catch {
        Add-Log ('AI report restore: ' + $_.Exception.Message)
    }
}

function Start-AiAnalysis([string] $Mode) {
    if ($aiRunner.Active -or $commandRunner.Active) {
        [Windows.Forms.MessageBox]::Show(
            $T.busy, $T.aiAssistant, 'OK', 'Information') | Out-Null
        return
    }
    if (-not (Test-Workspace $workspaceBox.Text)) {
        [Windows.Forms.MessageBox]::Show(
            $T.invalidWorkspace, $T.aiAssistant, 'OK', 'Warning') | Out-Null
        return
    }
    $image = Get-Docker 'image inspect deepfacelab:blackwell' 3500
    if ($image.ExitCode -ne 0) {
        [Windows.Forms.MessageBox]::Show(
            $T.aiImageMissing, $T.aiAssistant, 'OK', 'Warning') | Out-Null
        return
    }

    $state = Get-ContainerState
    $logBase64 = if ($Mode -eq 'training' -and $state) {
        Get-AiRecentLogBase64
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
        $arguments += ' --model-type ' +
                      (Quote-Arg ([string]$modelTypeBox.SelectedItem))
    }

    Show-AiView $true
    $script:aiOutputLines.Clear()
    $script:aiMode = $Mode
    $script:aiPayload = $null
    $script:aiApplied = $false
    $aiStatusLabel.Text = $T.aiRunning
    $aiStatusLabel.ForeColor = $accent
    $aiSummaryLabel.Text = $T.aiRunning
    $aiReportBox.Text = $T.aiRunning
    Set-AiBusy $true
    $aiRunner.Start(
        $docker, $arguments, $repoRoot,
        (New-DockerEnvironment $workspaceBox.Text))
}

function Update-AiSummary($Payload) {
    $nextAction = ''
    if (Test-AiProperty $Payload 'next_action') {
        $nextAction = [string]$Payload.next_action
    }
    switch ([string]$Payload.mode) {
        'workspace' {
            $aiSummaryLabel.Text =
                ('SRC {0} / DST {1} | {2}/100 | {3}' -f
                    $Payload.src.count, $Payload.dst.count,
                    $Payload.score, $nextAction)
        }
        'training' {
            $aiSummaryLabel.Text =
                ('{0} | {1}' -f $Payload.state, $nextAction)
        }
        'recommend' {
            $batch = '?'
            if (Test-AiProperty $Payload 'batch_recommended') {
                $batch = [string]$Payload.batch_recommended
            }
            $aiSummaryLabel.Text =
                ('{0} | {1}px | Batch {2} | {3}' -f
                    $Payload.gpu.name, $Payload.resolution,
                    $batch, $nextAction)
        }
        default { $aiSummaryLabel.Text = $T.aiIdle }
    }
}

function Complete-AiOperation {
    foreach ($line in $aiRunner.Drain()) {
        $script:aiOutputLines.Add($line)
    }
    $exitCode = $aiRunner.ExitCode
    $mode = $script:aiMode
    $script:aiMode = ''

    if ($mode -eq 'apply') {
        if ($exitCode -eq 0) {
            $script:aiApplied = $true
            $aiReportBox.AppendText(
                [Environment]::NewLine + [Environment]::NewLine + $T.aiApplied)
            $aiSummaryLabel.Text = $T.aiApplied
            $aiStatusLabel.Text = $T.aiComplete
            $aiStatusLabel.ForeColor = $success
            Refresh-Models
        }
        else {
            $aiReportBox.AppendText(
                [Environment]::NewLine + $T.aiApplyFailed +
                [Environment]::NewLine +
                ($script:aiOutputLines -join [Environment]::NewLine))
            $aiStatusLabel.Text = $T.aiApplyFailed
            $aiStatusLabel.ForeColor = $danger
        }
        Set-AiBusy $false
        return
    }

    $begin = $script:aiOutputLines.IndexOf('DFL_AI_JSON_BEGIN')
    $end = $script:aiOutputLines.IndexOf('DFL_AI_JSON_END')
    if ($exitCode -eq 0 -and $begin -ge 0 -and $end -gt $begin) {
        try {
            $jsonLines = $script:aiOutputLines.GetRange(
                $begin + 1, $end - $begin - 1)
            $payload = ($jsonLines -join [Environment]::NewLine) |
                ConvertFrom-Json
            $script:aiPayload = $payload
            $aiReportBox.Text = ([string]$payload.report).Replace(
                '/workspace', [IO.Path]::GetFullPath($workspaceBox.Text))
            Update-AiSummary $payload
            Save-AiPayload $payload
            $aiStatusLabel.Text = $T.aiComplete
            $aiStatusLabel.ForeColor = $success
        }
        catch {
            $aiReportBox.Text = $_.Exception.Message
            $aiStatusLabel.Text = $T.aiFailed
            $aiStatusLabel.ForeColor = $danger
        }
    }
    else {
        $aiReportBox.Text = $T.aiFailed + [Environment]::NewLine +
            ($script:aiOutputLines -join [Environment]::NewLine)
        $aiStatusLabel.Text = $T.aiFailed
        $aiStatusLabel.ForeColor = $danger
    }
    Set-AiBusy $false
}

function Apply-AiRecommendation {
    if ($null -eq $script:aiPayload -or
        -not (Test-AiProperty $script:aiPayload 'mode') -or
        [string]$script:aiPayload.mode -ne 'recommend') {
        [Windows.Forms.MessageBox]::Show(
            $T.aiNoRecommendation, $T.aiAssistant, 'OK', 'Information') |
            Out-Null
        return
    }
    if (-not (Test-AiProperty $script:aiPayload 'can_apply') -or
        -not (Test-AiProperty $script:aiPayload 'recommended_options') -or
        -not [bool]$script:aiPayload.can_apply -or
        [string]$modelTypeBox.SelectedItem -ne 'SAEHD') {
        [Windows.Forms.MessageBox]::Show(
            $T.aiSaeOnly, $T.aiAssistant, 'OK', 'Information') | Out-Null
        return
    }
    if ($script:training -or $commandRunner.Active -or $aiRunner.Active) {
        [Windows.Forms.MessageBox]::Show(
            $T.busy, $T.aiAssistant, 'OK', 'Information') | Out-Null
        return
    }

    $modelName = $modelNameBox.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($modelName)) {
        $modelName = 'ai-dfm'
        $modelNameBox.Text = $modelName
    }
    if ($modelName -notmatch '^[A-Za-z0-9_.-]+$') {
        [Windows.Forms.MessageBox]::Show(
            $T.aiInvalidModelName, $T.aiAssistant, 'OK', 'Warning') |
            Out-Null
        return
    }
    $existingModel = Join-Path $workspaceBox.Text (
        'model\' + $modelName + '_SAEHD_data.dat')
    if (Test-Path -LiteralPath $existingModel) {
        [Windows.Forms.MessageBox]::Show(
            $T.aiExistingModel, $T.aiAssistant, 'OK', 'Warning') | Out-Null
        return
    }

    $options = $script:aiPayload.recommended_options
    $arguments = 'compose --ansi never -f ' + (Quote-Arg $composeFile) +
                 ' run --rm -T deepfacelab dfl_pipeline.py' +
                 ' --workspace /workspace preset' +
                 ' --model-name ' + (Quote-Arg $modelName) +
                 ' --resolution ' + [int]$options.resolution +
                 ' --batch-size ' + [int]$options.batch_size +
                 ' --base-iter ' + [int]$options.base_iterations +
                 ' --final-iter ' + [int]$options.final_iterations
    if ([bool]$options.use_xseg) { $arguments += ' --use-xseg' }

    $modelTypeBox.SelectedItem = 'SAEHD'
    $silentCheck.Checked = $true
    $script:aiOutputLines.Clear()
    $script:aiMode = 'apply'
    $aiStatusLabel.Text = $T.aiRunning
    $aiStatusLabel.ForeColor = $accent
    Set-AiBusy $true
    $aiRunner.Start(
        $docker, $arguments, $repoRoot,
        (New-DockerEnvironment $workspaceBox.Text))
}

function Update-NativePreview([switch] $Show) {
    $previewPath = Join-Path $workspaceBox.Text '.dfl-preview.jpg'
    if (-not (Test-Path -LiteralPath $previewPath)) { return $false }

    try {
        $item = Get-Item -LiteralPath $previewPath
        if ($item.LastWriteTimeUtc.Ticks -ne $script:lastPreviewTicks) {
            $bytes = [IO.File]::ReadAllBytes($previewPath)
            $stream = New-Object IO.MemoryStream(,$bytes)
            $sourceImage = [Drawing.Image]::FromStream($stream)
            $newImage = New-Object Drawing.Bitmap($sourceImage)
            $sourceImage.Dispose()
            $stream.Dispose()
            $oldImage = $previewPicture.Image
            $previewPicture.Image = $newImage
            if ($null -ne $oldImage) { $oldImage.Dispose() }
            $script:lastPreviewTicks = $item.LastWriteTimeUtc.Ticks
        }
        if ($Show -or -not $previewForm.Visible) {
            if (-not $previewForm.Visible) { $previewForm.Show($form) }
            $previewForm.WindowState = 'Normal'
            $previewForm.BringToFront()
            $previewForm.Activate()
        }
        return $true
    }
    catch {
        return $false
    }
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
    $cpuOnlyCheck.Enabled = $canConfigure
    $previewCheck.Enabled = $canConfigure
    $silentCheck.Enabled = $canConfigure
    $workflowButton.Enabled = -not $Busy
    $oneClickButton.Enabled = -not $Busy
    $showPreviewButton.Enabled = $script:training
    Set-AiBusy $aiRunner.Active
}

$commandRunner = New-Object DflGui.ProcessMonitor
$logRunner = New-Object DflGui.ProcessMonitor
$aiRunner = New-Object DflGui.ProcessMonitor
$script:aiOutputLines = New-Object Collections.Generic.List[string]
$script:aiMode = ''
$script:aiPayload = $null
$script:aiApplied = $false
$script:operation = ''
$script:training = $false
$script:closeAfterStop = $false
$script:tickCount = 0
$script:lastContainerState = ''
$script:nativePreviewShownForSession = $false
$script:lastPreviewTicks = 0L
$script:applicationClosing = $false

function Start-Operation([string] $Name, [string] $Arguments, [string] $Status) {
    if ($commandRunner.Active) {
        [Windows.Forms.MessageBox]::Show($T.busy, $T.title, 'OK', 'Information') | Out-Null
        return
    }
    Show-AiView $false
    $script:operation = $Name
    $runtimeLabel.Text = $T.runtime + ': ' + $Status
    $runtimeLabel.ForeColor = $accent
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
        Load-AiPayload
    }
    $dialog.Dispose()
})
$modelTypeBox.Add_SelectedIndexChanged({
    Refresh-Models
    Set-AiBusy $aiRunner.Active
})
$workspaceBox.Add_Leave({
    Refresh-Models
    Load-AiPayload
})

$openButton.Add_Click({
    if (Test-Path -LiteralPath $workspaceBox.Text) {
        Start-Process explorer.exe -ArgumentList (Quote-Arg $workspaceBox.Text)
    }
})

$workflowButton.Add_Click({
    $workbench = Get-Process -Name powershell -ErrorAction SilentlyContinue |
        Where-Object { $_.MainWindowTitle -eq $T.workbenchTitle } |
        Select-Object -First 1
    if ($null -ne $workbench) {
        [DflGui.WindowTools]::ShowWindow($workbench.MainWindowHandle, 9) | Out-Null
        [DflGui.WindowTools]::SetForegroundWindow($workbench.MainWindowHandle) | Out-Null
    }
    else {
        $workflowScript = Join-Path $repoRoot 'DeepFaceLab-Workflow.ps1'
        if (Test-Path -LiteralPath $workflowScript) {
            $arguments = '-NoLogo -NoProfile -STA -ExecutionPolicy Bypass -File ' +
                         (Quote-Arg $workflowScript) +
                         ' -Workspace ' + (Quote-Arg $workspaceBox.Text) +
                         ' -LegacyRoot ' + (Quote-Arg 'D:\DFL_RTX5000_series_2025')
            Start-Process -FilePath 'powershell.exe' -ArgumentList $arguments `
                -WorkingDirectory $repoRoot -WindowStyle Hidden | Out-Null
        }
    }
})

$oneClickButton.Add_Click({
    $oneClick = Get-Process -Name powershell -ErrorAction SilentlyContinue |
        Where-Object { $_.MainWindowTitle -eq $T.oneClickTitle } |
        Select-Object -First 1
    if ($null -ne $oneClick) {
        [DflGui.WindowTools]::ShowWindow($oneClick.MainWindowHandle, 9) | Out-Null
        [DflGui.WindowTools]::SetForegroundWindow(
            $oneClick.MainWindowHandle) | Out-Null
    }
    else {
        $oneClickScript = Join-Path $repoRoot 'DeepFaceLab-OneClick.ps1'
        if (Test-Path -LiteralPath $oneClickScript) {
            $arguments = '-NoLogo -NoProfile -STA -ExecutionPolicy Bypass -File ' +
                         (Quote-Arg $oneClickScript) +
                         ' -Project ' + (Quote-Arg $workspaceBox.Text) +
                         ' -LegacyRoot ' +
                         (Quote-Arg 'D:\DFL_RTX5000_series_2025')
            Start-Process -FilePath 'powershell.exe' -ArgumentList $arguments `
                -WorkingDirectory $repoRoot -WindowStyle Hidden | Out-Null
        }
    }
})

$logTabButton.Add_Click({ Show-AiView $false })
$aiButton.Add_Click({
    Show-AiView $true
    Start-AiAnalysis 'recommend'
})
foreach ($button in @(
    $aiWorkspaceButton, $aiTrainingButton, $aiRecommendButton
)) {
    $button.Add_Click({
        param($sender, $eventArgs)
        Start-AiAnalysis ([string]$sender.Tag)
    })
}
$aiApplyButton.Add_Click({ Apply-AiRecommendation })
$aiCopyButton.Add_Click({
    if (-not [string]::IsNullOrWhiteSpace($aiReportBox.Text) -and
        $aiReportBox.Text -ne $T.aiIdle) {
        [Windows.Forms.Clipboard]::SetText($aiReportBox.Text)
        $aiStatusLabel.Text = $T.aiCopied
        $aiStatusLabel.ForeColor = $success
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
            ' run --rm -d --name ' + $containerName
    if ($cpuOnlyCheck.Checked) { $args += ' -e CUDA_VISIBLE_DEVICES=-1' }
    $args += ' deepfacelab main.py train' +
            ' --training-data-src-dir /workspace/data_src/aligned' +
            ' --training-data-dst-dir /workspace/data_dst/aligned' +
            ' --model-dir /workspace/model' +
            ' --model ' + (Quote-Arg $type)
    if (-not [string]::IsNullOrWhiteSpace($modelNameBox.Text)) {
        $args += ' --force-model-name ' + (Quote-Arg $modelNameBox.Text.Trim())
    }
    if ($silentCheck.Checked) { $args += ' --silent-start' }
    if ($cpuOnlyCheck.Checked) { $args += ' --cpu-only' }
    $args += ' --no-preview'
    if ($previewCheck.Checked) {
        $args += ' --preview-output-path /workspace/.dfl-preview.jpg'
    }
    Start-Operation 'start' $args $T.starting
})

$stopButton.Add_Click({
    if (-not $script:training -or $commandRunner.Active) { return }
    Start-Operation 'stop' ('kill --signal=SIGINT ' + $containerName) $T.saving
})

$showPreviewButton.Add_Click({
    if (-not (Update-NativePreview -Show)) {
        [Windows.Forms.MessageBox]::Show($T.previewNotFound, $T.title, 'OK', 'Information') | Out-Null
    }
})

$timer = New-Object Windows.Forms.Timer
$timer.Interval = 1000
$timer.Add_Tick({
    foreach ($line in $commandRunner.Drain()) { Add-Log $line }
    foreach ($line in $logRunner.Drain()) { Add-Log $line }
    foreach ($line in $aiRunner.Drain()) {
        $script:aiOutputLines.Add($line)
    }
    if ($script:aiMode -and $aiRunner.Complete) {
        Complete-AiOperation
    }

    if ($script:operation -and $commandRunner.Complete) {
        foreach ($line in $commandRunner.Drain()) { Add-Log $line }
        $exitCode = $commandRunner.ExitCode
        $finished = $script:operation
        $script:operation = ''
        if ($exitCode -ne 0) {
            Add-Log ($T.operationFailed + ' ' + $exitCode)
            $runtimeLabel.Text = $T.runtime + ': ' + $T.notRunning
            $runtimeLabel.ForeColor = $danger
        }
        elseif ($finished -eq 'build') {
            Add-Log $T.imageReady
            $runtimeLabel.Text = $T.runtime + ': ' + $T.ready
            $runtimeLabel.ForeColor = $success
        }
        elseif ($finished -eq 'verify') {
            Add-Log $T.verifyDone
            $runtimeLabel.Text = $T.runtime + ': ' + $T.ready
            $runtimeLabel.ForeColor = $success
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
            $runtimeLabel.ForeColor = $success
            $stopButton.Enabled = -not $commandRunner.Active
            $showPreviewButton.Enabled = $true
            $startButton.Enabled = $false
            if (-not $logRunner.Active -and $script:operation -ne 'start') { Attach-TrainingLog }
            if ($previewCheck.Checked -and -not $script:nativePreviewShownForSession -and
                (Update-NativePreview -Show)) {
                $script:nativePreviewShownForSession = $true
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
            $script:nativePreviewShownForSession = $false
            $script:lastPreviewTicks = 0L
            if (-not $commandRunner.Active) { Set-Busy $false }
        }
        Set-AiBusy $aiRunner.Active
        $script:lastContainerState = $state
    }

    if ($script:training -and $previewCheck.Checked -and
        $script:nativePreviewShownForSession) {
        [void](Update-NativePreview)
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

$previewForm.Add_FormClosing({
    param($sender, $eventArgs)
    if (-not $script:applicationClosing) {
        $eventArgs.Cancel = $true
        $previewForm.Hide()
    }
})

$form.Add_Shown({
    Refresh-Models
    Load-AiPayload
    $form.ActiveControl = $startButton
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
    $script:applicationClosing = $true
    $previewForm.Close()
    $logRunner.StopMonitor()
    if ($commandRunner.Active) { $commandRunner.StopMonitor() }
    if ($aiRunner.Active) { $aiRunner.StopMonitor() }
})

[void]$form.ShowDialog()
$timer.Dispose()
$commandRunner.Dispose()
$logRunner.Dispose()
$aiRunner.Dispose()
$oldPreviewImage = $previewPicture.Image
if ($null -ne $oldPreviewImage) { $oldPreviewImage.Dispose() }
$previewForm.Dispose()
$form.Dispose()
if ($null -ne $script:appIcon) { $script:appIcon.Dispose() }
try { $script:singleInstanceMutex.ReleaseMutex() } catch { }
$script:singleInstanceMutex.Dispose()
