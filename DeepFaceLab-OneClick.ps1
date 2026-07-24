param(
    [string] $Project = '',
    [string] $LegacyRoot = 'D:\DFL_RTX5000_series_2025'
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Keep this file ASCII for Windows PowerShell 5.1.
$T = @'
{
  "title": "DeepFaceLab DFM \u4e00\u952e\u8bad\u7ec3",
  "subtitle": "\u6807\u51c6\u9ad8\u8d28\u91cf\u6d41\u6c34\u7ebf \u00b7 RTX 5090 \u00b7 \u53ef\u6062\u590d \u00b7 DeepFaceLive",
  "project": "\u9879\u76ee\u76ee\u5f55",
  "browse": "\u6d4f\u89c8\u2026",
  "initialize": "\u521b\u5efa / \u68c0\u67e5\u9879\u76ee",
  "open": "\u6253\u5f00\u9879\u76ee",
  "settings": "\u8bad\u7ec3\u65b9\u6848",
  "modelName": "\u6a21\u578b\u540d\u79f0\uff08\u82f1\u6587/\u6570\u5b57\uff09",
  "resolution": "\u8bad\u7ec3\u5206\u8fa8\u7387",
  "batch": "Batch",
  "baseIter": "\u57fa\u7840\u8bad\u7ec3\u76ee\u6807",
  "finalIter": "\u7cbe\u4fee\u8bad\u7ec3\u76ee\u6807",
  "srcFps": "SRC \u62bd\u5e27 FPS",
  "dstFps": "DST \u62bd\u5e27 FPS",
  "enhanceSrc": "SRC \u4eba\u8138\u9ad8\u6e05\u589e\u5f3a",
  "enhanceDst": "DST \u4eba\u8138\u9ad8\u6e05\u589e\u5f3a\uff08\u8f83\u6162\uff09",
  "xseg": "\u5e94\u7528\u901a\u7528 XSeg \u906e\u7f69",
  "autoFinish": "\u8fbe\u6807\u540e\u81ea\u52a8\u7cbe\u4fee\u5e76\u5bfc\u51fa DFM",
  "start": "\u4e00\u952e\u51c6\u5907\u5e76\u5f00\u59cb\u8bad\u7ec3",
  "pause": "\u5b89\u5168\u6682\u505c",
  "resumeButton": "\u7ee7\u7eed\u6d41\u7a0b",
  "paused": "\u5df2\u6682\u505c\uff0c\u8fdb\u5ea6\u5df2\u4fdd\u5b58",
  "stopExport": "\u4fdd\u5b58\u505c\u6b62\u5e76\u5bfc\u51fa DFM",
  "review": "\u68c0\u67e5\u7b5b\u9009\u7ed3\u679c",
  "output": "\u6253\u5f00 DFM \u8f93\u51fa",
  "stages": "\u6d41\u7a0b\u9636\u6bb5",
  "preview": "\u8bad\u7ec3\u9884\u89c8",
  "log": "\u6267\u884c\u65e5\u5fd7",
  "pending": "\u7b49\u5f85",
  "running": "\u8fdb\u884c\u4e2d",
  "done": "\u5df2\u5b8c\u6210",
  "failed": "\u5931\u8d25",
  "ready": "\u5c31\u7eea",
  "inputHelp": "\u9879\u76ee\u521b\u5efa\u540e\uff0c\u5c06\u6700\u7ec8\u8981\u5448\u73b0\u7684\u8eab\u4efd\u7d20\u6750\u653e\u5165 input_src\uff1b\u5c06 DeepFaceLive \u9a71\u52a8\u8005/\u76ee\u6807\u8138\u7d20\u6750\u653e\u5165 input_dst\u3002",
  "inputMissing": "input_src \u548c input_dst \u90fd\u9700\u8981\u81f3\u5c11\u4e00\u4e2a\u7167\u7247\u6216\u89c6\u9891\u3002\u5df2\u4e3a\u4f60\u6253\u5f00\u9879\u76ee\u76ee\u5f55\u3002",
  "invalidProject": "\u8bf7\u5148\u9009\u62e9\u6216\u521b\u5efa\u9879\u76ee\u76ee\u5f55\u3002",
  "dockerMissing": "\u672a\u627e\u5230 Docker\uff0c\u8bf7\u5148\u542f\u52a8 Docker Desktop\u3002",
  "busy": "\u5f53\u524d\u6709\u6d41\u7a0b\u4efb\u52a1\u6b63\u5728\u6267\u884c\u3002",
  "trainingRunning": "\u8bad\u7ec3\u6b63\u5728\u540e\u53f0\u8fd0\u884c\u3002",
  "exportWarning": "\u5f53\u524d\u6a21\u578b\u53ef\u80fd\u5c1a\u672a\u8fbe\u5230\u9ad8\u6e05\u76ee\u6807\u3002\u4ecd\u7136\u8981\u4fdd\u5b58\u3001\u505c\u6b62\u5e76\u5bfc\u51fa\u5417\uff1f",
  "confirm": "\u8bf7\u786e\u8ba4",
  "xsegMissing": "\u672a\u627e\u5230\u901a\u7528 XSeg \u6a21\u578b\u8d44\u6e90\u3002\u53ef\u53d6\u6d88 XSeg \u9009\u9879\u540e\u7ee7\u7eed\u3002",
  "completed": "\u6d41\u6c34\u7ebf\u5df2\u5b8c\u6210\uff0cDFM \u5df2\u901a\u8fc7 ONNX \u6821\u9a8c\u3002",
  "resume": "\u5df2\u8bfb\u53d6\u4e0a\u6b21\u8fdb\u5ea6\uff0c\u53ef\u7ee7\u7eed\u6267\u884c\u3002",
  "closeBusy": "\u5f53\u524d\u9884\u5904\u7406\u4efb\u52a1\u4ecd\u5728\u8fd0\u884c\uff0c\u786e\u5b9a\u5173\u95ed\u5417\uff1f\u5df2\u542f\u52a8\u7684\u6a21\u578b\u8bad\u7ec3\u4e0d\u4f1a\u88ab\u505c\u6b62\u3002"
}
'@ | ConvertFrom-Json

$singleInstanceCreated = $false
$script:singleInstanceMutex = [Threading.Mutex]::new(
    $true, 'Local\DeepFaceLabOneClickGui', [ref]$singleInstanceCreated)
if (-not $singleInstanceCreated) {
    $windowShell = New-Object -ComObject WScript.Shell
    [void]$windowShell.AppActivate([string]$T.title)
    $script:singleInstanceMutex.Dispose()
    exit 0
}

$Stages = @'
[
  {"id":"project","title":"01 \u9879\u76ee\u68c0\u67e5","desc":"\u521b\u5efa\u6807\u51c6\u76ee\u5f55\u5e76\u4fdd\u5b58\u8fdb\u5ea6"},
  {"id":"media","title":"02 \u5a92\u4f53\u62bd\u5e27","desc":"\u5bfc\u5165\u7167\u7247\u5e76\u6309 FPS \u62bd\u53d6\u89c6\u9891\u5e27"},
  {"id":"extract-src","title":"03 SRC \u4eba\u8138\u88c1\u526a","desc":"S3FD \u68c0\u6d4b\u4e0e 512px whole-face \u5bf9\u9f50"},
  {"id":"extract-dst","title":"04 DST \u4eba\u8138\u88c1\u526a","desc":"\u68c0\u6d4b\u9a71\u52a8\u8138\u5e76\u4fdd\u7559 debug \u7ed3\u679c"},
  {"id":"screen","title":"05 \u8d28\u91cf\u7b5b\u9009","desc":"\u6a21\u7cca\u3001\u66dd\u5149\u548c\u91cd\u590d\u8138\u53ef\u6062\u590d\u9694\u79bb"},
  {"id":"enhance","title":"06 \u9ad8\u6e05\u589e\u5f3a","desc":"\u5bf9\u9009\u5b9a\u8138\u96c6\u8fdb\u884c\u7ec6\u8282\u6062\u590d"},
  {"id":"xseg","title":"07 XSeg \u906e\u7f69","desc":"\u5e94\u7528\u901a\u7528 whole-face \u906e\u7f69"},
  {"id":"preset","title":"08 5090 \u6a21\u578b\u914d\u7f6e","desc":"\u751f\u6210\u53ef\u590d\u73b0\u7684 SAEHD \u9ad8\u8d28\u91cf\u9884\u8bbe"},
  {"id":"train-base","title":"09 \u57fa\u7840\u8bad\u7ec3","desc":"\u5148\u5b66\u4e60\u8eab\u4efd\u3001\u8868\u60c5\u548c\u59ff\u6001\u6cdb\u5316"},
  {"id":"train-refine","title":"10 \u7ec6\u8282\u7cbe\u4fee","desc":"LR dropout + \u4f4e\u5f3a\u5ea6 GAN \u63d0\u5347\u6e05\u6670\u5ea6"},
  {"id":"export","title":"11 \u5bfc\u51fa DFM","desc":"\u5b89\u5168\u4fdd\u5b58\u5e76\u751f\u6210 DeepFaceLive \u6a21\u578b"},
  {"id":"verify","title":"12 DFM \u9a8c\u8bc1","desc":"ONNX \u7ed3\u6784\u3001\u8f93\u5165\u8f93\u51fa\u548c\u6587\u4ef6\u5b8c\u6574\u6027"}
]
'@ | ConvertFrom-Json

Add-Type -TypeDefinition @'
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;
using System.Runtime.InteropServices;

namespace DflOneClick {
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

        [DllImport("user32.dll")]
        public static extern bool SetForegroundWindow(IntPtr hWnd);
        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, int command);
    }
}
'@ -Language CSharp

[Windows.Forms.Application]::EnableVisualStyles()

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($Project)) {
    $Project = Join-Path $repoRoot 'dfm-project'
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

function Add-Label($Parent, [string] $Caption, [int] $X, [int] $Y,
                   [int] $Width, [int] $Height = 22) {
    $label = New-Object Windows.Forms.Label
    $label.Text = $Caption
    $label.SetBounds($X, $Y, $Width, $Height)
    $Parent.Controls.Add($label)
    return $label
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
$warning = [Drawing.Color]::FromArgb(244, 180, 64)
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

$form = New-Object Windows.Forms.Form
$form.Text = $T.title
$form.ClientSize = New-Object Drawing.Size(1480, 900)
$form.MinimumSize = New-Object Drawing.Size(1280, 800)
$form.StartPosition = 'CenterScreen'
$form.BackColor = $background
$form.ForeColor = $text
$form.Font = New-Object Drawing.Font('Microsoft YaHei UI', 9)
$form.AutoScaleMode = 'Dpi'
$form.SuspendLayout()

$title = Add-Label $form $T.title 28 14 650 42
$title.Font =
    New-Object Drawing.Font('Microsoft YaHei UI', 21, [Drawing.FontStyle]::Bold)
$subtitle = Add-Label $form $T.subtitle 30 56 760 26
$subtitle.ForeColor = $muted

$projectPanel = New-Object Windows.Forms.Panel
$projectPanel.BackColor = $surface
$projectPanel.SetBounds(20, 92, 1440, 64)
$projectPanel.Anchor = 'Top,Left,Right'
$form.Controls.Add($projectPanel)
$projectLabel = Add-Label $projectPanel $T.project 18 21 72
$projectLabel.ForeColor = $muted
$projectBox = New-Object Windows.Forms.TextBox
$projectBox.Text = $Project
$projectBox.BackColor = $input
$projectBox.ForeColor = $text
$projectBox.BorderStyle = 'FixedSingle'
$projectBox.SetBounds(90, 16, 1010, 30)
$projectBox.Anchor = 'Top,Left,Right'
$projectPanel.Controls.Add($projectBox)
$browseButton = New-Object Windows.Forms.Button
$browseButton.Text = $T.browse
$browseButton.SetBounds(1112, 15, 84, 32)
$browseButton.Anchor = 'Top,Right'
Style-Button $browseButton $surfaceRaised
$projectPanel.Controls.Add($browseButton)
$initButton = New-Object Windows.Forms.Button
$initButton.Text = $T.initialize
$initButton.SetBounds(1206, 15, 132, 32)
$initButton.Anchor = 'Top,Right'
Style-Button $initButton $accent
$projectPanel.Controls.Add($initButton)
$openProjectButton = New-Object Windows.Forms.Button
$openProjectButton.Text = $T.open
$openProjectButton.SetBounds(1348, 15, 74, 32)
$openProjectButton.Anchor = 'Top,Right'
Style-Button $openProjectButton $surfaceRaised
$projectPanel.Controls.Add($openProjectButton)

$settingsPanel = New-Object Windows.Forms.Panel
$settingsPanel.BackColor = $surface
$settingsPanel.SetBounds(20, 170, 330, 710)
$settingsPanel.Anchor = 'Top,Bottom,Left'
$form.Controls.Add($settingsPanel)
$settingsTitle = Add-Label $settingsPanel $T.settings 20 14 290 30
$settingsTitle.Font =
    New-Object Drawing.Font('Microsoft YaHei UI', 13, [Drawing.FontStyle]::Bold)

$modelNameLabel = Add-Label $settingsPanel $T.modelName 20 56 290
$modelNameLabel.ForeColor = $muted
$modelNameBox = New-Object Windows.Forms.TextBox
$modelNameBox.Text = 'dfm-model'
$modelNameBox.BackColor = $input
$modelNameBox.ForeColor = $text
$modelNameBox.BorderStyle = 'FixedSingle'
$modelNameBox.SetBounds(20, 80, 290, 28)
$settingsPanel.Controls.Add($modelNameBox)

$resolutionLabel = Add-Label $settingsPanel $T.resolution 20 120 135
$resolutionLabel.ForeColor = $muted
$batchLabel = Add-Label $settingsPanel $T.batch 170 120 140
$batchLabel.ForeColor = $muted
$resolutionBox = New-Object Windows.Forms.ComboBox
$resolutionBox.DropDownStyle = 'DropDownList'
$resolutionBox.Items.AddRange(@('224', '256', '320'))
$resolutionBox.SelectedItem = '256'
$resolutionBox.BackColor = $input
$resolutionBox.ForeColor = $text
$resolutionBox.FlatStyle = 'Flat'
$resolutionBox.SetBounds(20, 144, 135, 28)
$settingsPanel.Controls.Add($resolutionBox)
$batchBox = New-Object Windows.Forms.NumericUpDown
$batchBox.Minimum = 1
$batchBox.Maximum = 32
$batchBox.Value = 8
$batchBox.BackColor = $input
$batchBox.ForeColor = $text
$batchBox.SetBounds(170, 144, 140, 28)
$settingsPanel.Controls.Add($batchBox)

$baseLabel = Add-Label $settingsPanel $T.baseIter 20 184 135
$baseLabel.ForeColor = $muted
$finalLabel = Add-Label $settingsPanel $T.finalIter 170 184 140
$finalLabel.ForeColor = $muted
$baseIterBox = New-Object Windows.Forms.NumericUpDown
$baseIterBox.Minimum = 10000
$baseIterBox.Maximum = 10000000
$baseIterBox.Increment = 50000
$baseIterBox.Value = 300000
$baseIterBox.ThousandsSeparator = $true
$baseIterBox.BackColor = $input
$baseIterBox.ForeColor = $text
$baseIterBox.SetBounds(20, 208, 135, 28)
$settingsPanel.Controls.Add($baseIterBox)
$finalIterBox = New-Object Windows.Forms.NumericUpDown
$finalIterBox.Minimum = 20000
$finalIterBox.Maximum = 10000000
$finalIterBox.Increment = 50000
$finalIterBox.Value = 500000
$finalIterBox.ThousandsSeparator = $true
$finalIterBox.BackColor = $input
$finalIterBox.ForeColor = $text
$finalIterBox.SetBounds(170, 208, 140, 28)
$settingsPanel.Controls.Add($finalIterBox)

$srcFpsLabel = Add-Label $settingsPanel $T.srcFps 20 248 135
$srcFpsLabel.ForeColor = $muted
$dstFpsLabel = Add-Label $settingsPanel $T.dstFps 170 248 140
$dstFpsLabel.ForeColor = $muted
$srcFpsBox = New-Object Windows.Forms.NumericUpDown
$srcFpsBox.Minimum = 1
$srcFpsBox.Maximum = 60
$srcFpsBox.Value = 5
$srcFpsBox.BackColor = $input
$srcFpsBox.ForeColor = $text
$srcFpsBox.SetBounds(20, 272, 135, 28)
$settingsPanel.Controls.Add($srcFpsBox)
$dstFpsBox = New-Object Windows.Forms.NumericUpDown
$dstFpsBox.Minimum = 1
$dstFpsBox.Maximum = 60
$dstFpsBox.Value = 5
$dstFpsBox.BackColor = $input
$dstFpsBox.ForeColor = $text
$dstFpsBox.SetBounds(170, 272, 140, 28)
$settingsPanel.Controls.Add($dstFpsBox)

$enhanceSrcCheck = New-Object Windows.Forms.CheckBox
$enhanceSrcCheck.Text = $T.enhanceSrc
$enhanceSrcCheck.Checked = $true
$enhanceSrcCheck.ForeColor = $text
$enhanceSrcCheck.SetBounds(20, 316, 290, 25)
$settingsPanel.Controls.Add($enhanceSrcCheck)
$enhanceDstCheck = New-Object Windows.Forms.CheckBox
$enhanceDstCheck.Text = $T.enhanceDst
$enhanceDstCheck.Checked = $false
$enhanceDstCheck.ForeColor = $text
$enhanceDstCheck.SetBounds(20, 345, 290, 25)
$settingsPanel.Controls.Add($enhanceDstCheck)
$xsegCheck = New-Object Windows.Forms.CheckBox
$xsegCheck.Text = $T.xseg
$xsegCheck.Checked = $true
$xsegCheck.ForeColor = $text
$xsegCheck.SetBounds(20, 374, 290, 25)
$settingsPanel.Controls.Add($xsegCheck)
$autoFinishCheck = New-Object Windows.Forms.CheckBox
$autoFinishCheck.Text = $T.autoFinish
$autoFinishCheck.Checked = $true
$autoFinishCheck.ForeColor = $text
$autoFinishCheck.SetBounds(20, 403, 290, 25)
$settingsPanel.Controls.Add($autoFinishCheck)

$helpLabel = Add-Label $settingsPanel $T.inputHelp 20 440 290 68
$helpLabel.ForeColor = $muted

$startButton = New-Object Windows.Forms.Button
$startButton.Text = $T.start
$startButton.SetBounds(20, 520, 290, 46)
Style-Button $startButton $accent
$settingsPanel.Controls.Add($startButton)
$stopButton = New-Object Windows.Forms.Button
$stopButton.Text = $T.stopExport
$stopButton.SetBounds(170, 576, 140, 40)
Style-Button $stopButton $danger
$settingsPanel.Controls.Add($stopButton)
$pauseButton = New-Object Windows.Forms.Button
$pauseButton.Text = $T.pause
$pauseButton.SetBounds(20, 576, 140, 40)
Style-Button $pauseButton $surfaceRaised
$settingsPanel.Controls.Add($pauseButton)
$reviewButton = New-Object Windows.Forms.Button
$reviewButton.Text = $T.review
$reviewButton.SetBounds(20, 626, 140, 38)
Style-Button $reviewButton $surfaceRaised
$settingsPanel.Controls.Add($reviewButton)
$outputButton = New-Object Windows.Forms.Button
$outputButton.Text = $T.output
$outputButton.SetBounds(170, 626, 140, 38)
Style-Button $outputButton $surfaceRaised
$settingsPanel.Controls.Add($outputButton)
$progressBar = New-Object Windows.Forms.ProgressBar
$progressBar.Minimum = 0
$progressBar.Maximum = [int]$finalIterBox.Value
$progressBar.Value = 0
$progressBar.SetBounds(20, 674, 290, 10)
$progressBar.Anchor = 'Left,Right,Bottom'
$settingsPanel.Controls.Add($progressBar)
$iterationLabel = Add-Label $settingsPanel '0 / 500,000' 20 686 290 20
$iterationLabel.ForeColor = $muted
$iterationLabel.TextAlign = 'MiddleRight'
$iterationLabel.Anchor = 'Left,Right,Bottom'

$stagePanel = New-Object Windows.Forms.Panel
$stagePanel.BackColor = $surface
$stagePanel.SetBounds(362, 170, 650, 710)
$stagePanel.Anchor = 'Top,Bottom,Left'
$form.Controls.Add($stagePanel)
$stagesTitle = Add-Label $stagePanel $T.stages 20 14 610 30
$stagesTitle.Font =
    New-Object Drawing.Font('Microsoft YaHei UI', 13, [Drawing.FontStyle]::Bold)
$script:stageViews = @{}
for ($index = 0; $index -lt $Stages.Count; $index++) {
    $stage = $Stages[$index]
    $column = $index % 2
    $row = [Math]::Floor($index / 2)
    $card = New-Object Windows.Forms.Panel
    $card.BackColor = $surfaceRaised
    $card.SetBounds(20 + ($column * 305), 52 + ($row * 92), 295, 80)
    $stagePanel.Controls.Add($card)
    $stageTitle = Add-Label $card ([string]$stage.title) 14 10 190 24
    $stageTitle.Font =
        New-Object Drawing.Font('Microsoft YaHei UI', 9, [Drawing.FontStyle]::Bold)
    $stageStatus = Add-Label $card $T.pending 208 10 72 24
    $stageStatus.ForeColor = $muted
    $stageStatus.TextAlign = 'TopRight'
    $stageDesc = Add-Label $card ([string]$stage.desc) 14 38 266 34
    $stageDesc.ForeColor = $muted
    $script:stageViews[[string]$stage.id] = [pscustomobject]@{
        Panel = $card
        Status = $stageStatus
    }
}
$pipelineStatus = Add-Label $stagePanel $T.ready 20 620 610 36
$pipelineStatus.ForeColor = $success
$pipelineStatus.Font =
    New-Object Drawing.Font('Microsoft YaHei UI', 10, [Drawing.FontStyle]::Bold)
$pipelineStatus.Anchor = 'Left,Right,Bottom'

$rightPanel = New-Object Windows.Forms.Panel
$rightPanel.BackColor = $surface
$rightPanel.SetBounds(1024, 170, 436, 710)
$rightPanel.Anchor = 'Top,Bottom,Left,Right'
$form.Controls.Add($rightPanel)
$previewTitle = Add-Label $rightPanel $T.preview 18 14 380 28
$previewTitle.Font =
    New-Object Drawing.Font('Microsoft YaHei UI', 12, [Drawing.FontStyle]::Bold)
$previewPicture = New-Object Windows.Forms.PictureBox
$previewPicture.BackColor = $background
$previewPicture.SizeMode = 'Zoom'
$previewPicture.SetBounds(18, 48, 400, 285)
$previewPicture.Anchor = 'Top,Left,Right'
$rightPanel.Controls.Add($previewPicture)
$logTitle = Add-Label $rightPanel $T.log 18 346 380 28
$logTitle.Font =
    New-Object Drawing.Font('Microsoft YaHei UI', 12, [Drawing.FontStyle]::Bold)
$logBox = New-Object Windows.Forms.RichTextBox
$logBox.ReadOnly = $true
$logBox.BackColor = $background
$logBox.ForeColor = [Drawing.Color]::FromArgb(205, 211, 222)
$logBox.BorderStyle = 'None'
$logBox.Font = New-Object Drawing.Font('Cascadia Mono', 8.5)
$logBox.WordWrap = $false
$logBox.SetBounds(18, 380, 400, 310)
$logBox.Anchor = 'Top,Bottom,Left,Right'
$rightPanel.Controls.Add($logBox)

$form.ResumeLayout($false)

$runner = New-Object DflOneClick.ProcessMonitor
$logRunner = New-Object DflOneClick.ProcessMonitor
$script:queue = New-Object 'System.Collections.Generic.Queue[object]'
$script:activeJob = $null
$script:completed =
    New-Object 'System.Collections.Generic.HashSet[string]'
$script:activeStage = ''
$script:trainingPhase = ''
$script:trainingSeen = $false
$script:targetHandled = $false
$script:waitMode = ''
$script:pauseRequested = $false
$script:tickCount = 0
$script:lastPreviewTicks = 0L
$script:closing = $false

function Add-Log([string] $Line) {
    if ([string]::IsNullOrWhiteSpace($Line)) { return }
    $logBox.AppendText(
        ('[' + (Get-Date -Format 'HH:mm:ss') + '] ' + $Line +
         [Environment]::NewLine))
    if ($logBox.TextLength -gt 250000) {
        $logBox.Select(0, 100000)
        $logBox.SelectedText = ''
    }
    $logBox.SelectionStart = $logBox.TextLength
    $logBox.ScrollToCaret()
}

function Get-ProjectPath {
    return [IO.Path]::GetFullPath($projectBox.Text)
}

function Get-StatePath {
    return Join-Path (Get-ProjectPath) '.dfl-pipeline\state.json'
}

function Save-State {
    if ([string]::IsNullOrWhiteSpace($projectBox.Text)) { return }
    $root = Get-ProjectPath
    $stateDir = Join-Path $root '.dfl-pipeline'
    [void](New-Item -ItemType Directory -Path $stateDir -Force)
    $state = [ordered]@{
        version = 1
        updated_at = [DateTime]::UtcNow.ToString('o')
        completed = @($script:completed)
        active_stage = $script:activeStage
        phase = $script:trainingPhase
        config = [ordered]@{
            model_name = $modelNameBox.Text.Trim()
            resolution = [int][string]$resolutionBox.SelectedItem
            batch_size = [int]$batchBox.Value
            base_iter = [int]$baseIterBox.Value
            final_iter = [int]$finalIterBox.Value
            src_fps = [int]$srcFpsBox.Value
            dst_fps = [int]$dstFpsBox.Value
            enhance_src = [bool]$enhanceSrcCheck.Checked
            enhance_dst = [bool]$enhanceDstCheck.Checked
            xseg = [bool]$xsegCheck.Checked
            auto_finish = [bool]$autoFinishCheck.Checked
        }
    }
    $json = $state | ConvertTo-Json -Depth 6
    $path = Get-StatePath
    $temporary = $path + '.tmp'
    [IO.File]::WriteAllText(
        $temporary, $json, (New-Object Text.UTF8Encoding($false)))
    Move-Item -LiteralPath $temporary -Destination $path -Force
}

function Load-State {
    $script:completed.Clear()
    $path = Get-StatePath
    if (-not (Test-Path -LiteralPath $path)) {
        Refresh-Stages
        return
    }
    try {
        $state = Get-Content -LiteralPath $path -Raw -Encoding UTF8 |
            ConvertFrom-Json
        foreach ($stage in @($state.completed)) {
            [void]$script:completed.Add([string]$stage)
        }
        $script:trainingPhase = [string]$state.phase
        if ($null -ne $state.config) {
            $config = $state.config
            if ($config.model_name) { $modelNameBox.Text = [string]$config.model_name }
            if ($config.resolution) {
                $resolutionBox.SelectedItem = [string]$config.resolution
            }
            if ($config.batch_size) { $batchBox.Value = [decimal]$config.batch_size }
            if ($config.base_iter) { $baseIterBox.Value = [decimal]$config.base_iter }
            if ($config.final_iter) { $finalIterBox.Value = [decimal]$config.final_iter }
            if ($config.src_fps) { $srcFpsBox.Value = [decimal]$config.src_fps }
            if ($config.dst_fps) { $dstFpsBox.Value = [decimal]$config.dst_fps }
            $enhanceSrcCheck.Checked = [bool]$config.enhance_src
            $enhanceDstCheck.Checked = [bool]$config.enhance_dst
            $xsegCheck.Checked = [bool]$config.xseg
            $autoFinishCheck.Checked = [bool]$config.auto_finish
        }
        $pipelineStatus.Text = $T.resume
        Add-Log $T.resume
    }
    catch {
        Add-Log $_.Exception.Message
    }
    Refresh-Stages
}

function Refresh-Stages {
    foreach ($stage in $Stages) {
        $id = [string]$stage.id
        $view = $script:stageViews[$id]
        if ($script:completed.Contains($id)) {
            $view.Status.Text = $T.done
            $view.Status.ForeColor = $success
            $view.Panel.BackColor = [Drawing.Color]::FromArgb(24, 48, 46)
        }
        elseif ($script:activeStage -eq $id -or
                ($id -eq 'train-base' -and $script:trainingPhase -eq 'base') -or
                ($id -eq 'train-refine' -and $script:trainingPhase -eq 'refine')) {
            $view.Status.Text = $T.running
            $view.Status.ForeColor = $accent
            $view.Panel.BackColor = [Drawing.Color]::FromArgb(28, 44, 70)
        }
        else {
            $view.Status.Text = $T.pending
            $view.Status.ForeColor = $muted
            $view.Panel.BackColor = $surfaceRaised
        }
    }
}

function Mark-Completed([string] $Stage) {
    [void]$script:completed.Add($Stage)
    $script:activeStage = ''
    Save-State
    Refresh-Stages
}

function Mark-Failed([string] $Stage) {
    if ($script:stageViews.ContainsKey($Stage)) {
        $view = $script:stageViews[$Stage]
        $view.Status.Text = $T.failed
        $view.Status.ForeColor = $danger
        $view.Panel.BackColor = [Drawing.Color]::FromArgb(68, 28, 38)
    }
    $pipelineStatus.Text = $T.failed + ': ' + $Stage
    $pipelineStatus.ForeColor = $danger
}

function New-DockerEnvironment {
    $environment =
        New-Object 'System.Collections.Generic.Dictionary[string,string]'
    $environment['DFL_WORKSPACE_PATH'] =
        (Get-ProjectPath).Replace('\', '/')
    return $environment
}

function New-ComposeRun([string] $Command, [switch] $NonInteractive) {
    $arguments = 'compose --ansi never -f ' + (Quote-Arg $composeFile) +
                 ' run --rm -T'
    if ($NonInteractive) {
        $arguments += ' -e DFL_NON_INTERACTIVE=1'
    }
    return $arguments + ' deepfacelab ' + $Command
}

function Get-ContainerState {
    $result = [DflOneClick.ProcessMonitor]::Capture(
        $docker, ('inspect --format "{{.State.Status}}" ' + $containerName),
        $repoRoot, 2500)
    if ($result.ExitCode -eq 0) { return $result.Output.Trim() }
    return ''
}

function Initialize-Project {
    if ([string]::IsNullOrWhiteSpace($projectBox.Text)) {
        [Windows.Forms.MessageBox]::Show(
            $T.invalidProject, $T.title, 'OK', 'Warning') | Out-Null
        return $false
    }
    $root = Get-ProjectPath
    foreach ($relative in @(
        'input_src', 'input_dst', 'data_src', 'data_src\aligned',
        'data_dst', 'data_dst\aligned', 'model', 'output',
        '.dfl-pipeline', '.dfl-pipeline\rejected'
    )) {
        [void](New-Item -ItemType Directory -Path (Join-Path $root $relative) -Force)
    }
    [void]$script:completed.Add('project')
    Save-State
    Refresh-Stages
    Add-Log ($T.done + ': project')
    return $true
}

function Test-InputMedia {
    $extensions = @('.jpg','.jpeg','.png','.bmp','.webp','.mp4','.mkv',
                    '.mov','.avi','.webm','.m4v','.mpg','.mpeg')
    $root = Get-ProjectPath
    $src = @(Get-ChildItem -LiteralPath (Join-Path $root 'input_src') `
        -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension.ToLowerInvariant() -in $extensions }).Count
    $dst = @(Get-ChildItem -LiteralPath (Join-Path $root 'input_dst') `
        -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension.ToLowerInvariant() -in $extensions }).Count
    return $src -gt 0 -and $dst -gt 0
}

function Ensure-XSegAssets {
    if (-not $xsegCheck.Checked) { return }
    $source = Join-Path $LegacyRoot '_internal\model_generic_xseg'
    if (-not (Test-Path -LiteralPath $source)) {
        throw $T.xsegMissing
    }
    $destination = Join-Path (Get-ProjectPath) '.dfl-assets\model_generic_xseg'
    [void](New-Item -ItemType Directory -Path $destination -Force)
    Copy-Item -Path (Join-Path $source '*') -Destination $destination `
        -Recurse -Force
}

function Queue-Job([string] $Stage, [string] $Name, [string] $Arguments,
                   [string] $Kind = 'regular', [bool] $Last = $true,
                   [string] $Phase = '') {
    $script:queue.Enqueue([pscustomobject]@{
        Stage = $Stage
        Name = $Name
        Arguments = $Arguments
        Kind = $Kind
        Last = $Last
        Phase = $Phase
    })
}

function Queue-Training([string] $Phase) {
    $model = $modelNameBox.Text.Trim()
    $arguments = 'compose --ansi never -f ' + (Quote-Arg $composeFile) +
                 ' run --rm -d -T --name ' + $containerName +
                 ' -e DFL_NON_INTERACTIVE=1 deepfacelab main.py train' +
                 ' --training-data-src-dir /workspace/data_src/aligned' +
                 ' --training-data-dst-dir /workspace/data_dst/aligned' +
                 ' --model-dir /workspace/model --model SAEHD' +
                 ' --force-model-name ' + (Quote-Arg $model) +
                 ' --silent-start --no-preview' +
                 ' --preview-output-path /workspace/.dfl-preview.jpg'
    $stage = if ($Phase -eq 'base') { 'train-base' } else { 'train-refine' }
    Queue-Job $stage ('train ' + $Phase) $arguments 'training' $false $Phase
}

function Start-NextJob {
    if ($runner.Active -or $script:queue.Count -eq 0 -or
        $script:pauseRequested) { return }
    $script:activeJob = $script:queue.Dequeue()
    $script:activeStage = [string]$script:activeJob.Stage
    $pipelineStatus.Text = $T.running + ': ' + $script:activeJob.Name
    $pipelineStatus.ForeColor = $accent
    Add-Log ($T.running + ': ' + $script:activeJob.Name)
    Refresh-Stages
    Save-State
    $runner.Start(
        $docker, [string]$script:activeJob.Arguments, $repoRoot,
        (New-DockerEnvironment))
}

function Attach-TrainingLog {
    if (-not $logRunner.Active) {
        $logRunner.Start(
            $docker, ('logs --follow --tail 120 ' + $containerName),
            $repoRoot, $null)
    }
}

function Start-PreparationQueue {
    if (-not (Initialize-Project)) { return }
    if (-not (Test-InputMedia)) {
        Start-Process explorer.exe -ArgumentList (Quote-Arg (Get-ProjectPath)) |
            Out-Null
        [Windows.Forms.MessageBox]::Show(
            $T.inputMissing, $T.title, 'OK', 'Information') | Out-Null
        return
    }
    if ($runner.Active) {
        [Windows.Forms.MessageBox]::Show(
            $T.busy, $T.title, 'OK', 'Information') | Out-Null
        return
    }
    $state = Get-ContainerState
    if ($state -eq 'running') {
        $script:trainingSeen = $true
        Attach-TrainingLog
        $pipelineStatus.Text = $T.trainingRunning
        return
    }
    if ([int]$finalIterBox.Value -le [int]$baseIterBox.Value) {
        [Windows.Forms.MessageBox]::Show(
            $T.finalIter, $T.title, 'OK', 'Warning') | Out-Null
        return
    }
    try { Ensure-XSegAssets }
    catch {
        [Windows.Forms.MessageBox]::Show(
            $_.Exception.Message, $T.title, 'OK', 'Warning') | Out-Null
        return
    }
    Save-State
    $script:queue.Clear()

    if (-not $script:completed.Contains('media')) {
        $command = 'dfl_pipeline.py --workspace /workspace prepare' +
                   ' --src-fps ' + [int]$srcFpsBox.Value +
                   ' --dst-fps ' + [int]$dstFpsBox.Value
        Queue-Job 'media' 'media prepare' (New-ComposeRun $command)
    }
    if (-not $script:completed.Contains('extract-src')) {
        $command = 'main.py extract --input-dir /workspace/data_src' +
                   ' --output-dir /workspace/data_src/aligned --detector s3fd' +
                   ' --face-type whole_face --max-faces-from-image 1' +
                   ' --image-size 512 --jpeg-quality 96 --existing-output continue' +
                   ' --output-debug --force-gpu-idxs 0'
        Queue-Job 'extract-src' 'extract SRC' (New-ComposeRun $command)
    }
    if (-not $script:completed.Contains('extract-dst')) {
        $command = 'main.py extract --input-dir /workspace/data_dst' +
                   ' --output-dir /workspace/data_dst/aligned --detector s3fd' +
                   ' --face-type whole_face --max-faces-from-image 1' +
                   ' --image-size 512 --jpeg-quality 96 --existing-output continue' +
                   ' --output-debug --force-gpu-idxs 0'
        Queue-Job 'extract-dst' 'extract DST' (New-ComposeRun $command)
    }
    if (-not $script:completed.Contains('screen')) {
        $srcScreen = 'dfl_pipeline.py --workspace /workspace screen' +
                     ' --side data_src --min-keep 64'
        $dstScreen = 'dfl_pipeline.py --workspace /workspace screen' +
                     ' --side data_dst --min-keep 128'
        Queue-Job 'screen' 'screen SRC' (New-ComposeRun $srcScreen) 'regular' $false
        Queue-Job 'screen' 'screen DST' (New-ComposeRun $dstScreen)
    }
    if (-not $script:completed.Contains('enhance')) {
        $enhanceJobs = @()
        if ($enhanceSrcCheck.Checked) {
            $enhanceJobs += 'data_src'
        }
        if ($enhanceDstCheck.Checked) {
            $enhanceJobs += 'data_dst'
        }
        if ($enhanceJobs.Count -eq 0) {
            Mark-Completed 'enhance'
        }
        else {
            for ($i = 0; $i -lt $enhanceJobs.Count; $i++) {
                $side = $enhanceJobs[$i]
                $command = 'main.py facesettool enhance --input-dir /workspace/' +
                           $side + '/aligned --merge --force-gpu-idxs 0'
                Queue-Job 'enhance' ('enhance ' + $side) `
                    (New-ComposeRun $command) 'regular' ($i -eq $enhanceJobs.Count - 1)
            }
        }
    }
    if (-not $script:completed.Contains('xseg')) {
        if (-not $xsegCheck.Checked) {
            Mark-Completed 'xseg'
        }
        else {
            foreach ($side in @('data_src','data_dst')) {
                $command = 'main.py xseg apply --input-dir /workspace/' + $side +
                           '/aligned --model-dir /workspace/.dfl-assets/model_generic_xseg' +
                           ' --face-type wf --force-gpu-idx 0'
                Queue-Job 'xseg' ('XSeg ' + $side) (New-ComposeRun $command) `
                    'regular' ($side -eq 'data_dst')
            }
        }
    }
    if (-not $script:completed.Contains('preset')) {
        $command = 'dfl_pipeline.py --workspace /workspace preset' +
                   ' --model-name ' + (Quote-Arg $modelNameBox.Text.Trim()) +
                   ' --resolution ' + [string]$resolutionBox.SelectedItem +
                   ' --batch-size ' + [int]$batchBox.Value +
                   ' --base-iter ' + [int]$baseIterBox.Value +
                   ' --final-iter ' + [int]$finalIterBox.Value
        if ($xsegCheck.Checked) { $command += ' --use-xseg' }
        Queue-Job 'preset' 'write SAEHD preset' `
            (New-ComposeRun $command -NonInteractive)
    }
    if (-not $script:completed.Contains('train-base')) {
        Queue-Training 'base'
    }
    elseif (-not $script:completed.Contains('train-refine')) {
        Start-RefineSequence
        return
    }
    elseif (-not $script:completed.Contains('verify')) {
        Start-ExportSequence
        return
    }
    Start-NextJob
}

function Start-RefineSequence {
    $script:queue.Clear()
    $command = 'dfl_pipeline.py --workspace /workspace refine' +
               ' --model-name ' + (Quote-Arg $modelNameBox.Text.Trim()) +
               ' --final-iter ' + [int]$finalIterBox.Value
    Queue-Job 'train-refine' 'configure detail refinement' `
        (New-ComposeRun $command -NonInteractive) 'regular' $false
    Queue-Training 'refine'
    Start-NextJob
}

function Start-ExportSequence {
    $script:queue.Clear()
    $model = $modelNameBox.Text.Trim()
    if (-not $script:completed.Contains('export')) {
        $command = 'main.py exportdfm --model-dir /workspace/model' +
                   ' --model SAEHD --force-model-name ' + (Quote-Arg $model)
        Queue-Job 'export' 'export DFM' `
            (New-ComposeRun $command -NonInteractive)
    }
    if (-not $script:completed.Contains('verify')) {
        $command = 'dfl_pipeline.py --workspace /workspace validate' +
                   ' --model-name ' + (Quote-Arg $model)
        Queue-Job 'verify' 'validate DFM' `
            (New-ComposeRun $command -NonInteractive)
    }
    Start-NextJob
}

function Start-StopTransition([string] $Mode) {
    if ($runner.Active) { return }
    $state = Get-ContainerState
    if ($state -ne 'running') {
        $script:waitMode = $Mode
        Complete-StopTransition
        return
    }
    $script:waitMode = $Mode
    $script:activeJob = [pscustomobject]@{
        Stage = if ($script:trainingPhase -eq 'refine') {
            'train-refine'
        } else { 'train-base' }
        Name = 'save and stop'
        Arguments = 'kill --signal=SIGINT ' + $containerName
        Kind = 'stop'
        Last = $false
        Phase = $script:trainingPhase
    }
    $runner.Start(
        $docker, [string]$script:activeJob.Arguments, $repoRoot, $null)
    $pipelineStatus.Text = $T.stopExport
    $pipelineStatus.ForeColor = $warning
    Add-Log $T.stopExport
}

function Complete-StopTransition {
    $mode = $script:waitMode
    $script:waitMode = ''
    $logRunner.StopMonitor()
    if ($mode -eq 'pause-training') {
        $script:pauseRequested = $true
        $pauseButton.Text = $T.resumeButton
        $pipelineStatus.Text = $T.paused
        $pipelineStatus.ForeColor = $warning
        Save-State
    }
    elseif ($mode -eq 'base-refine') {
        Mark-Completed 'train-base'
        $script:trainingPhase = ''
        Save-State
        Start-RefineSequence
    }
    else {
        if ($script:trainingPhase -eq 'refine') {
            Mark-Completed 'train-refine'
        }
        elseif ($script:trainingPhase -eq 'base') {
            Mark-Completed 'train-base'
        }
        $script:trainingPhase = ''
        Save-State
        Start-ExportSequence
    }
}

function Update-Preview {
    $path = Join-Path (Get-ProjectPath) '.dfl-preview.jpg'
    if (-not (Test-Path -LiteralPath $path)) { return }
    try {
        $item = Get-Item -LiteralPath $path
        if ($item.LastWriteTimeUtc.Ticks -eq $script:lastPreviewTicks) { return }
        $bytes = [IO.File]::ReadAllBytes($path)
        $stream = New-Object IO.MemoryStream(,$bytes)
        $source = [Drawing.Image]::FromStream($stream)
        $image = New-Object Drawing.Bitmap($source)
        $source.Dispose()
        $stream.Dispose()
        $old = $previewPicture.Image
        $previewPicture.Image = $image
        if ($null -ne $old) { $old.Dispose() }
        $script:lastPreviewTicks = $item.LastWriteTimeUtc.Ticks
    }
    catch {
    }
}

$browseButton.Add_Click({
    $dialog = New-Object Windows.Forms.FolderBrowserDialog
    $dialog.Description = $T.project
    $dialog.SelectedPath = $projectBox.Text
    if ($dialog.ShowDialog($form) -eq 'OK') {
        $projectBox.Text = $dialog.SelectedPath
        Load-State
    }
    $dialog.Dispose()
})

$initButton.Add_Click({
    if (Initialize-Project) {
        Start-Process explorer.exe -ArgumentList (Quote-Arg (Get-ProjectPath)) |
            Out-Null
    }
})

$openProjectButton.Add_Click({
    if (Test-Path -LiteralPath $projectBox.Text) {
        Start-Process explorer.exe -ArgumentList (Quote-Arg (Get-ProjectPath)) |
            Out-Null
    }
})

$reviewButton.Add_Click({
    $path = Join-Path (Get-ProjectPath) '.dfl-pipeline\rejected'
    if (Test-Path -LiteralPath $path) {
        Start-Process explorer.exe -ArgumentList (Quote-Arg $path) | Out-Null
    }
})

$outputButton.Add_Click({
    $path = Join-Path (Get-ProjectPath) 'output'
    if (Test-Path -LiteralPath $path) {
        Start-Process explorer.exe -ArgumentList (Quote-Arg $path) | Out-Null
    }
})

$startButton.Add_Click({ Start-PreparationQueue })

$pauseButton.Add_Click({
    if ($script:pauseRequested) {
        $script:pauseRequested = $false
        $pauseButton.Text = $T.pause
        if ($script:trainingPhase -and
            (Get-ContainerState) -ne 'running') {
            $script:queue.Clear()
            Queue-Training $script:trainingPhase
        }
        elseif ($script:queue.Count -eq 0) {
            Start-PreparationQueue
            return
        }
        $pipelineStatus.Text = $T.running
        $pipelineStatus.ForeColor = $accent
        Start-NextJob
    }
    else {
        $script:pauseRequested = $true
        $pauseButton.Text = $T.resumeButton
        if ((Get-ContainerState) -eq 'running') {
            Start-StopTransition 'pause-training'
        }
        else {
            $pipelineStatus.Text = $T.paused
            $pipelineStatus.ForeColor = $warning
        }
    }
})

$stopButton.Add_Click({
    $answer = [Windows.Forms.MessageBox]::Show(
        $T.exportWarning, $T.confirm, 'YesNo', 'Warning')
    if ($answer -eq 'Yes') { Start-StopTransition 'manual-export' }
})

$finalIterBox.Add_ValueChanged({
    $progressBar.Maximum = [int]$finalIterBox.Value
})

$timer = New-Object Windows.Forms.Timer
$timer.Interval = 1000
$timer.Add_Tick({
    foreach ($line in $runner.Drain()) { Add-Log $line }
    foreach ($line in $logRunner.Drain()) {
        Add-Log $line
        if ($line -match '\[#(\d+)\]') {
            $iteration = [int64]$Matches[1]
            $maximum = [int64]$finalIterBox.Value
            $progressBar.Value = [int][Math]::Min($iteration, $maximum)
            $iterationLabel.Text =
                ('{0:N0} / {1:N0}' -f $iteration, $maximum)
        }
        if (-not $script:targetHandled -and
            ($line -like '*Reached target iteration*' -or
             $line -like '*already trained to target iteration*')) {
            $script:targetHandled = $true
            if ($autoFinishCheck.Checked) {
                if ($script:trainingPhase -eq 'base') {
                    Start-StopTransition 'base-refine'
                }
                elseif ($script:trainingPhase -eq 'refine') {
                    Start-StopTransition 'refine-export'
                }
            }
        }
    }

    if ($null -ne $script:activeJob -and $runner.Complete) {
        foreach ($line in $runner.Drain()) { Add-Log $line }
        $exitCode = $runner.ExitCode
        $job = $script:activeJob
        $script:activeJob = $null
        if ($exitCode -ne 0) {
            Add-Log ($T.failed + ': ' + $job.Name + ' (' + $exitCode + ')')
            Mark-Failed ([string]$job.Stage)
            $script:queue.Clear()
        }
        elseif ($job.Kind -eq 'training') {
            $script:trainingPhase = [string]$job.Phase
            $script:trainingSeen = $false
            $script:targetHandled = $false
            $script:activeStage = [string]$job.Stage
            Save-State
            Refresh-Stages
            Start-Sleep -Milliseconds 400
            Attach-TrainingLog
            $pipelineStatus.Text = $T.trainingRunning
            $pipelineStatus.ForeColor = $success
        }
        elseif ($job.Kind -eq 'stop') {
            Add-Log ($T.done + ': save signal')
        }
        else {
            if ([bool]$job.Last) {
                Mark-Completed ([string]$job.Stage)
            }
            Add-Log ($T.done + ': ' + $job.Name)
            if ($script:pauseRequested) {
                $pauseButton.Text = $T.resumeButton
                $pipelineStatus.Text = $T.paused
                $pipelineStatus.ForeColor = $warning
            }
            else {
                Start-NextJob
            }
        }
    }

    $script:tickCount++
    if (($script:tickCount % 2) -eq 0) {
        $state = Get-ContainerState
        if ($state -eq 'running') {
            $script:trainingSeen = $true
            if ($script:trainingPhase) { Attach-TrainingLog }
        }
        elseif ($script:waitMode -and -not $runner.Active) {
            Complete-StopTransition
        }
        elseif ($script:trainingPhase -and $script:trainingSeen -and
                -not $script:waitMode -and -not $runner.Active) {
            Add-Log ($T.failed + ': training container stopped')
            Mark-Failed(
                $(if ($script:trainingPhase -eq 'refine') {
                    'train-refine'
                } else { 'train-base' }))
            $script:trainingPhase = ''
            Save-State
        }
        Update-Preview
    }

    if ($script:completed.Contains('verify')) {
        $pipelineStatus.Text = $T.completed
        $pipelineStatus.ForeColor = $success
    }
})

$form.Add_Shown({
    Load-State
    if ((Get-ContainerState) -eq 'running') {
        $script:trainingSeen = $true
        if (-not $script:trainingPhase) { $script:trainingPhase = 'base' }
        Attach-TrainingLog
        Refresh-Stages
    }
})

$form.Add_FormClosing({
    param($sender, $eventArgs)
    if ($script:closing) { return }
    if ($runner.Active) {
        $answer = [Windows.Forms.MessageBox]::Show(
            $T.closeBusy, $T.confirm, 'YesNo', 'Warning')
        if ($answer -ne 'Yes') {
            $eventArgs.Cancel = $true
            return
        }
    }
    $script:closing = $true
    Save-State
    $timer.Stop()
    $logRunner.Dispose()
    $runner.Dispose()
    if ($null -ne $previewPicture.Image) {
        $previewPicture.Image.Dispose()
        $previewPicture.Image = $null
    }
})

$timer.Start()
[void]$form.ShowDialog()
$timer.Dispose()
$form.Dispose()
try { $script:singleInstanceMutex.ReleaseMutex() } catch { }
$script:singleInstanceMutex.Dispose()
