param(
    [string] $Workspace = '',
    [string] $LegacyRoot = 'D:\DFL_RTX5000_series_2025'
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Keep this source file ASCII so Windows PowerShell 5.1 decodes it reliably.
$T = @'
{
  "title": "DeepFaceLab \u5b8c\u6574\u5de5\u4f5c\u6d41",
  "subtitle": "57 \u4e2a\u65e7\u7248\u547d\u4ee4\u5165\u53e3 \u00b7 RTX 5090 \u6279\u5904\u7406 \u00b7 Windows \u539f\u751f\u4ea4\u4e92\u7a97\u53e3",
  "workspace": "\u5de5\u4f5c\u533a",
  "legacy": "\u53c2\u8003\u5305\u8def\u5f84",
  "browse": "\u6d4f\u89c8\u2026",
  "options": "\u5e38\u7528\u53c2\u6570",
  "cpu": "\u4ec5 CPU \u6a21\u5f0f",
  "debug": "\u751f\u6210 aligned_debug",
  "merge": "\u5904\u7406\u540e\u5408\u5e76\u56de\u539f\u76ee\u5f55",
  "faceType": "\u9762\u90e8\u7c7b\u578b",
  "imageSize": "\u56fe\u50cf\u5c3a\u5bf8",
  "jpeg": "JPEG \u8d28\u91cf",
  "maxFaces": "\u5355\u5e27\u6700\u591a\u9762\u90e8\uff080=\u4e0d\u9650\uff09",
  "format": "\u62bd\u5e27\u683c\u5f0f",
  "fps": "\u62bd\u5e27 FPS\uff080=\u5168\u5e27\u7387\uff09",
  "sort": "\u6392\u5e8f\u65b9\u5f0f",
  "denoise": "\u964d\u566a\u5f3a\u5ea6",
  "bitrate": "\u89c6\u9891\u7801\u7387 Mbps",
  "modelName": "\u6a21\u578b\u540d\u79f0\uff08\u53ef\u7559\u7a7a\uff09",
  "existing": "\u5df2\u6709 aligned \u5904\u7406",
  "log": "\u4efb\u52a1\u65e5\u5fd7",
  "ready": "\u5c31\u7eea",
  "running": "\u6b63\u5728\u6267\u884c",
  "training": "\u8bad\u7ec3\u5bb9\u5668\u6b63\u5728\u8fd0\u884c",
  "busy": "\u5f53\u524d\u5df2\u6709\u4efb\u52a1\u5728\u6267\u884c\u3002",
  "invalidWorkspace": "\u5de5\u4f5c\u533a\u5fc5\u987b\u5305\u542b data_src\u3001data_dst \u548c model \u76ee\u5f55\u3002",
  "legacyMissing": "\u672a\u627e\u5230\u53c2\u8003\u5305\u539f\u751f\u8fd0\u884c\u65f6\uff0c\u8bf7\u68c0\u67e5\u53c2\u8003\u5305\u8def\u5f84\u3002",
  "confirm": "\u786e\u8ba4\u64cd\u4f5c",
  "clearPrompt": "\u5c06\u6e05\u7a7a SRC/DST aligned \u548c model \u76ee\u5f55\u3002\u8be5\u64cd\u4f5c\u4e0d\u53ef\u64a4\u9500\uff0c\u662f\u5426\u7ee7\u7eed\uff1f",
  "removePrompt": "\u8be5\u64cd\u4f5c\u4f1a\u4fee\u6539 faceset \u5143\u6570\u636e\u3002\u662f\u5426\u7ee7\u7eed\uff1f",
  "fetchPrompt": "\u6293\u53d6\u5df2\u6807\u6ce8\u9762\u90e8\u540e\uff0c\u662f\u5426\u4ece\u539f\u76ee\u5f55\u5220\u9664\u5df2\u590d\u5236\u7684\u6587\u4ef6\uff1f\\n\\n\u662f\uff1a\u590d\u5236\u5e76\u5220\u9664\u539f\u6587\u4ef6\\n\u5426\uff1a\u4ec5\u590d\u5236\\n\u53d6\u6d88\uff1a\u4e0d\u6267\u884c",
  "cpuChanged": "\u5df2\u5207\u6362\u8fd0\u884c\u6a21\u5f0f\u3002\u65b0\u4efb\u52a1\u5c06\u6309\u53f3\u4fa7\u7684\u201c\u4ec5 CPU \u6a21\u5f0f\u201d\u8bbe\u7f6e\u6267\u884c\u3002",
  "nativeStarted": "\u5df2\u6253\u5f00 Windows \u539f\u751f\u4ea4\u4e92\u7a97\u53e3",
  "completed": "\u4efb\u52a1\u5b8c\u6210",
  "failed": "\u4efb\u52a1\u5931\u8d25\uff0c\u9000\u51fa\u4ee3\u7801",
  "videoMissing": "\u5de5\u4f5c\u533a\u4e2d\u672a\u627e\u5230\u5bf9\u5e94\u7684 data_src.* \u6216 data_dst.* \u89c6\u9891\u3002",
  "assetReady": "\u53c2\u8003\u5305\u6a21\u578b\u8d44\u6e90\u5df2\u51c6\u5907\u3002",
  "openMain": "\u56de\u5230\u8bad\u7ec3\u63a7\u5236\u53f0"
}
'@ | ConvertFrom-Json

$Groups = @'
[
  {"id":"workspace","label":"\u5de5\u4f5c\u533a / \u89c6\u9891\uff087\uff09"},
  {"id":"src","label":"SRC \u5904\u7406\uff0813\uff09"},
  {"id":"dst","label":"DST \u5904\u7406\uff0811\uff09"},
  {"id":"xseg","label":"XSeg \u906e\u7f69\uff0813\uff09"},
  {"id":"train","label":"\u8bad\u7ec3 / \u5bfc\u51fa\uff086\uff09"},
  {"id":"merge","label":"\u5408\u6210 / \u8f93\u51fa\uff087\uff09"}
]
'@ | ConvertFrom-Json

$Catalog = @'
[
  {"group":"workspace","id":"clear-workspace","label":"1) \u6e05\u7406\u5de5\u4f5c\u7a7a\u95f4  clear workspace","danger":true},
  {"group":"workspace","id":"start-ebsynth","label":"10.misc) \u542f\u52a8 EBS  start EBSynth"},
  {"group":"workspace","id":"cpu-only","label":"10.misc) \u8f6c\u4e3a\u4ec5 CPU \u6a21\u5f0f  make CPU only"},
  {"group":"workspace","id":"video-src","label":"2) src \u89c6\u9891\u63d0\u53d6\u56fe\u50cf  extract images from video data_src"},
  {"group":"workspace","id":"video-dst","label":"3) dst \u89c6\u9891\u63d0\u53d6\u56fe\u50cf\uff08\u5168\u5e27\u7387\uff09"},
  {"group":"workspace","id":"video-cut","label":"3) \u526a\u8f91\u89c6\u9891  cut video"},
  {"group":"workspace","id":"video-denoise","label":"3.optional) dst \u56fe\u50cf\u964d\u566a  denoise data_dst images"},

  {"group":"src","id":"src-manual","label":"4) src \u624b\u52a8\u63d0\u53d6\u9762\u90e8  MANUAL"},
  {"group":"src","id":"src-manual-reextract","label":"4) src \u624b\u52a8\u91cd\u65b0\u63d0\u53d6\u5df2\u5220 debug"},
  {"group":"src","id":"src-auto","label":"4) src \u81ea\u52a8\u63d0\u53d6\u9762\u90e8  S3FD"},
  {"group":"src","id":"src-view","label":"4.1) src \u67e5\u770b\u5bf9\u9f50\u7ed3\u679c"},
  {"group":"src","id":"src-resize","label":"4.2) src \u9762\u90e8\u8c03\u6574  faceset resize"},
  {"group":"src","id":"src-sort","label":"4.2) src \u9762\u90e8\u6392\u5e8f"},
  {"group":"src","id":"src-pack","label":"4.2) src \u9762\u90e8\u6587\u4ef6\u6253\u5305"},
  {"group":"src","id":"src-unpack","label":"4.2) src \u9762\u90e8\u6587\u4ef6\u89e3\u5305"},
  {"group":"src","id":"src-meta-save","label":"4.2) src \u9762\u90e8\u5143\u6570\u636e\u50a8\u5b58"},
  {"group":"src","id":"src-meta-restore","label":"4.2) src \u9762\u90e8\u5143\u6570\u636e\u6062\u590d"},
  {"group":"src","id":"src-enhance","label":"4.2) src \u9762\u90e8\u589e\u5f3a"},
  {"group":"src","id":"src-landmarks","label":"4.2) src \u751f\u6210\u5e26\u6807\u6ce8 debug \u56fe\u7247"},
  {"group":"src","id":"src-recover","label":"4.2) src \u539f\u59cb\u6587\u4ef6\u540d\u6062\u590d"},

  {"group":"dst","id":"dst-manual","label":"5) dst \u624b\u52a8\u63d0\u53d6\u9762\u90e8  MANUAL"},
  {"group":"dst","id":"dst-manual-reextract","label":"5) dst \u624b\u52a8\u91cd\u65b0\u63d0\u53d6\u5df2\u5220 debug"},
  {"group":"dst","id":"dst-auto-fix","label":"5) dst \u81ea\u52a8\u63d0\u53d6 + \u624b\u52a8\u4fee\u590d"},
  {"group":"dst","id":"dst-auto","label":"5) dst \u81ea\u52a8\u63d0\u53d6\u9762\u90e8  S3FD"},
  {"group":"dst","id":"dst-view","label":"5.1) dst \u67e5\u770b\u5bf9\u9f50\u7ed3\u679c"},
  {"group":"dst","id":"dst-view-debug","label":"5.1) dst \u67e5\u770b aligned_debug \u7ed3\u679c"},
  {"group":"dst","id":"dst-resize","label":"5.2) dst \u9762\u90e8\u8c03\u6574  faceset resize"},
  {"group":"dst","id":"dst-sort","label":"5.2) dst \u9762\u90e8\u6392\u5e8f"},
  {"group":"dst","id":"dst-pack","label":"5.2) dst \u9762\u90e8\u6587\u4ef6\u6253\u5305"},
  {"group":"dst","id":"dst-unpack","label":"5.2) dst \u9762\u90e8\u6587\u4ef6\u89e3\u5305"},
  {"group":"dst","id":"dst-recover","label":"5.2) dst \u539f\u59cb\u6587\u4ef6\u540d\u6062\u590d"},

  {"group":"xseg","id":"xseg-src-edit","label":"5.XSeg.1) src \u906e\u7f69\u7f16\u8f91"},
  {"group":"xseg","id":"xseg-src-label-remove","label":"5.XSeg.1) src \u906e\u7f69\u6807\u7b7e\u79fb\u9664","danger":true},
  {"group":"xseg","id":"xseg-src-fetch","label":"5.XSeg.1) src \u906e\u7f69\u6293\u53d6"},
  {"group":"xseg","id":"xseg-dst-edit","label":"5.XSeg.2) dst \u906e\u7f69\u7f16\u8f91"},
  {"group":"xseg","id":"xseg-dst-label-remove","label":"5.XSeg.2) dst \u906e\u7f69\u6807\u7b7e\u79fb\u9664","danger":true},
  {"group":"xseg","id":"xseg-dst-fetch","label":"5.XSeg.2) dst \u906e\u7f69\u6293\u53d6"},
  {"group":"xseg","id":"xseg-train","label":"5.XSeg.3) \u8bad\u7ec3\u906e\u7f69"},
  {"group":"xseg","id":"xseg-src-trained-remove","label":"5.XSeg.3.1) src \u8bad\u7ec3\u906e\u7f69 - \u79fb\u9664","danger":true},
  {"group":"xseg","id":"xseg-src-trained-apply","label":"5.XSeg.3.1) src \u8bad\u7ec3\u906e\u7f69 - \u5e94\u7528"},
  {"group":"xseg","id":"xseg-dst-trained-remove","label":"5.XSeg.3.2) dst \u8bad\u7ec3\u906e\u7f69 - \u79fb\u9664","danger":true},
  {"group":"xseg","id":"xseg-dst-trained-apply","label":"5.XSeg.3.2) dst \u8bad\u7ec3\u906e\u7f69 - \u5e94\u7528"},
  {"group":"xseg","id":"xseg-src-generic","label":"5.XSeg.Generic.1) src \u6574\u8138\u906e\u7f69\u5e94\u7528"},
  {"group":"xseg","id":"xseg-dst-generic","label":"5.XSeg.Generic.2) dst \u6574\u8138\u906e\u7f69\u5e94\u7528"},

  {"group":"train","id":"train-amp-srcsrc","label":"6) \u8bad\u7ec3 AMP SRC-SRC"},
  {"group":"train","id":"train-amp","label":"6) \u8bad\u7ec3 AMP"},
  {"group":"train","id":"train-quick96","label":"6) \u8bad\u7ec3 Quick96"},
  {"group":"train","id":"train-saehd","label":"6) \u8bad\u7ec3 SAEHD"},
  {"group":"train","id":"export-amp","label":"6.optional) \u5bfc\u51fa AMP \u4e3a DFM"},
  {"group":"train","id":"export-saehd","label":"6.optional) \u5bfc\u51fa SAEHD \u4e3a DFM"},

  {"group":"merge","id":"merge-amp","label":"7) \u5e94\u7528 AMP  merge"},
  {"group":"merge","id":"merge-quick96","label":"7) \u5e94\u7528 Quick96  merge"},
  {"group":"merge","id":"merge-saehd","label":"7) \u5e94\u7528 SAEHD  merge"},
  {"group":"merge","id":"output-avi","label":"8) \u5408\u6210 AVI \u89c6\u9891"},
  {"group":"merge","id":"output-mov-lossless","label":"8) \u5408\u6210 MOV\uff08\u65e0\u635f\uff09\u89c6\u9891"},
  {"group":"merge","id":"output-mp4-lossless","label":"8) \u5408\u6210 MP4\uff08\u65e0\u635f\uff09\u89c6\u9891"},
  {"group":"merge","id":"output-mp4","label":"8) \u5408\u6210 MP4 \u89c6\u9891"}
]
'@ | ConvertFrom-Json

Add-Type -TypeDefinition @'
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;

namespace DflWorkflow {
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
        [DllImport("user32.dll")]
        public static extern bool SetForegroundWindow(IntPtr hWnd);
        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    }
}
'@ -Language CSharp

[Windows.Forms.Application]::EnableVisualStyles()

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($Workspace)) {
    $Workspace = Join-Path $repoRoot 'workspace'
}
$script:legacyRoot = [IO.Path]::GetFullPath($LegacyRoot)
$composeFile = Join-Path $repoRoot 'compose.blackwell.yml'
$nativeLauncher = Join-Path $repoRoot 'run_native_interactive.cmd'
$containerName = 'dfl-blackwell-trainer'
$dockerCommand = Get-Command docker.exe -ErrorAction SilentlyContinue
if (-not $dockerCommand) {
    [Windows.Forms.MessageBox]::Show('Docker Desktop is required.', $T.title, 'OK', 'Error') | Out-Null
    exit 1
}
$docker = $dockerCommand.Source

function Quote-Arg([string] $Value) {
    if ($null -eq $Value -or $Value.Length -eq 0) { return '""' }
    return '"' + $Value.Replace('"', '\"') + '"'
}

function Add-ControlLabel($Parent, [string] $Caption, [int] $Y, [int] $Width = 380, [int] $X = 16) {
    $label = New-Object Windows.Forms.Label
    $label.Text = $Caption
    $label.ForeColor = [Drawing.Color]::FromArgb(155, 163, 179)
    $label.SetBounds($X, $Y, $Width, 21)
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

$background = [Drawing.Color]::FromArgb(18, 20, 25)
$panel = [Drawing.Color]::FromArgb(28, 31, 38)
$input = [Drawing.Color]::FromArgb(38, 42, 51)
$text = [Drawing.Color]::FromArgb(235, 238, 243)
$muted = [Drawing.Color]::FromArgb(150, 158, 174)
$accent = [Drawing.Color]::FromArgb(41, 196, 132)
$danger = [Drawing.Color]::FromArgb(231, 89, 99)
$border = [Drawing.Color]::FromArgb(58, 63, 74)

$form = New-Object Windows.Forms.Form
$form.Text = $T.title
$form.ClientSize = New-Object Drawing.Size(1450, 850)
$form.MinimumSize = New-Object Drawing.Size(1180, 720)
$form.StartPosition = 'CenterScreen'
$form.BackColor = $background
$form.ForeColor = $text
$form.Font = New-Object Drawing.Font('Microsoft YaHei UI', 9)
$form.AutoScaleMode = 'Dpi'

$title = New-Object Windows.Forms.Label
$title.Text = $T.title
$title.Font = New-Object Drawing.Font('Microsoft YaHei UI', 20, [Drawing.FontStyle]::Bold)
$title.ForeColor = $text
$title.SetBounds(22, 14, 700, 39)
$form.Controls.Add($title)

$subtitle = New-Object Windows.Forms.Label
$subtitle.Text = $T.subtitle
$subtitle.ForeColor = $muted
$subtitle.SetBounds(25, 52, 850, 24)
$form.Controls.Add($subtitle)

Add-ControlLabel $form $T.workspace 78 90 | Out-Null
$workspaceBox = New-Object Windows.Forms.TextBox
$workspaceBox.Text = [IO.Path]::GetFullPath($Workspace)
$workspaceBox.BackColor = $input
$workspaceBox.ForeColor = $text
$workspaceBox.BorderStyle = 'FixedSingle'
$workspaceBox.SetBounds(110, 75, 1105, 27)
$form.Controls.Add($workspaceBox)

$workspaceBrowse = New-Object Windows.Forms.Button
$workspaceBrowse.Text = $T.browse
$workspaceBrowse.SetBounds(1225, 73, 90, 31)
Style-Button $workspaceBrowse $border
$form.Controls.Add($workspaceBrowse)

$tabs = New-Object Windows.Forms.TabControl
$tabs.SetBounds(20, 120, 950, 680)
$tabs.Anchor = 'Top,Bottom,Left,Right'
$tabs.Font = New-Object Drawing.Font('Microsoft YaHei UI', 10, [Drawing.FontStyle]::Bold)
$form.Controls.Add($tabs)

$buttonList = New-Object Collections.Generic.List[Windows.Forms.Button]
foreach ($group in $Groups) {
    $page = New-Object Windows.Forms.TabPage
    $page.Text = $group.label
    $page.Name = [string]$group.id
    $page.BackColor = $panel

    $flow = New-Object Windows.Forms.FlowLayoutPanel
    $flow.Dock = 'Fill'
    $flow.FlowDirection = 'TopDown'
    $flow.WrapContents = $true
    $flow.AutoScroll = $true
    $flow.Padding = New-Object Windows.Forms.Padding(12)
    $page.Controls.Add($flow)

    foreach ($entry in @($Catalog | Where-Object { $_.group -eq $group.id })) {
        $button = New-Object Windows.Forms.Button
        $button.Text = $entry.label
        $button.Tag = [string]$entry.id
        $button.TextAlign = 'MiddleLeft'
        $button.Margin = New-Object Windows.Forms.Padding(6)
        $button.Size = New-Object Drawing.Size(435, 45)
        $isDanger = $entry.PSObject.Properties.Name -contains 'danger'
        Style-Button $button $(if ($isDanger) { $danger } else { $border })
        $button.Add_Click({
            param($sender, $eventArgs)
            Invoke-WorkflowAction ([string]$sender.Tag)
        })
        $flow.Controls.Add($button)
        $buttonList.Add($button)
    }
    $tabs.TabPages.Add($page)
}

$optionsPanel = New-Object Windows.Forms.Panel
$optionsPanel.BackColor = $panel
$optionsPanel.SetBounds(990, 120, 430, 680)
$optionsPanel.Anchor = 'Top,Bottom,Right'
$optionsPanel.AutoScroll = $true
$form.Controls.Add($optionsPanel)

$optionsTitle = New-Object Windows.Forms.Label
$optionsTitle.Text = $T.options
$optionsTitle.Font = New-Object Drawing.Font('Microsoft YaHei UI', 12, [Drawing.FontStyle]::Bold)
$optionsTitle.SetBounds(16, 12, 300, 28)
$optionsPanel.Controls.Add($optionsTitle)

$cpuOnlyCheck = New-Object Windows.Forms.CheckBox
$cpuOnlyCheck.Text = $T.cpu
$cpuOnlyCheck.ForeColor = $text
$cpuOnlyCheck.SetBounds(16, 47, 180, 25)
$optionsPanel.Controls.Add($cpuOnlyCheck)

$debugCheck = New-Object Windows.Forms.CheckBox
$debugCheck.Text = $T.debug
$debugCheck.Checked = $true
$debugCheck.ForeColor = $text
$debugCheck.SetBounds(210, 47, 200, 25)
$optionsPanel.Controls.Add($debugCheck)

$mergeCheck = New-Object Windows.Forms.CheckBox
$mergeCheck.Text = $T.merge
$mergeCheck.Checked = $true
$mergeCheck.ForeColor = $text
$mergeCheck.SetBounds(16, 76, 390, 25)
$optionsPanel.Controls.Add($mergeCheck)

Add-ControlLabel $optionsPanel $T.faceType 108 180 | Out-Null
$faceTypeBox = New-Object Windows.Forms.ComboBox
$faceTypeBox.DropDownStyle = 'DropDownList'
$faceTypeBox.Items.AddRange(@('whole_face', 'full_face', 'head', 'half_face', 'mid_full'))
$faceTypeBox.SelectedIndex = 0
$faceTypeBox.BackColor = $input
$faceTypeBox.ForeColor = $text
$faceTypeBox.FlatStyle = 'Flat'
$faceTypeBox.SetBounds(16, 132, 182, 28)
$optionsPanel.Controls.Add($faceTypeBox)

Add-ControlLabel $optionsPanel $T.imageSize 108 180 214 | Out-Null
$imageSizeBox = New-Object Windows.Forms.NumericUpDown
$imageSizeBox.Minimum = 256
$imageSizeBox.Maximum = 2048
$imageSizeBox.Increment = 32
$imageSizeBox.Value = 512
$imageSizeBox.BackColor = $input
$imageSizeBox.ForeColor = $text
$imageSizeBox.SetBounds(214, 132, 182, 28)
$optionsPanel.Controls.Add($imageSizeBox)

Add-ControlLabel $optionsPanel $T.jpeg 168 180 | Out-Null
$jpegBox = New-Object Windows.Forms.NumericUpDown
$jpegBox.Minimum = 1
$jpegBox.Maximum = 100
$jpegBox.Value = 90
$jpegBox.BackColor = $input
$jpegBox.ForeColor = $text
$jpegBox.SetBounds(16, 192, 182, 28)
$optionsPanel.Controls.Add($jpegBox)

Add-ControlLabel $optionsPanel $T.maxFaces 168 200 214 | Out-Null
$maxFacesBox = New-Object Windows.Forms.NumericUpDown
$maxFacesBox.Minimum = 0
$maxFacesBox.Maximum = 100
$maxFacesBox.Value = 0
$maxFacesBox.BackColor = $input
$maxFacesBox.ForeColor = $text
$maxFacesBox.SetBounds(214, 192, 182, 28)
$optionsPanel.Controls.Add($maxFacesBox)

Add-ControlLabel $optionsPanel $T.format 228 180 | Out-Null
$formatBox = New-Object Windows.Forms.ComboBox
$formatBox.DropDownStyle = 'DropDownList'
$formatBox.Items.AddRange(@('png', 'jpg'))
$formatBox.SelectedIndex = 0
$formatBox.BackColor = $input
$formatBox.ForeColor = $text
$formatBox.FlatStyle = 'Flat'
$formatBox.SetBounds(16, 252, 182, 28)
$optionsPanel.Controls.Add($formatBox)

Add-ControlLabel $optionsPanel $T.fps 228 200 214 | Out-Null
$fpsBox = New-Object Windows.Forms.NumericUpDown
$fpsBox.Minimum = 0
$fpsBox.Maximum = 240
$fpsBox.Value = 0
$fpsBox.BackColor = $input
$fpsBox.ForeColor = $text
$fpsBox.SetBounds(214, 252, 182, 28)
$optionsPanel.Controls.Add($fpsBox)

Add-ControlLabel $optionsPanel $T.sort 288 380 | Out-Null
$sortBox = New-Object Windows.Forms.ComboBox
$sortBox.DropDownStyle = 'DropDownList'
$sortBox.Items.AddRange(@('hist', 'blur', 'motion-blur', 'face-yaw', 'face-pitch',
    'face-source-rect-size', 'hist-dissim', 'brightness', 'hue', 'black',
    'origname', 'oneface', 'absdiff', 'final', 'final-fast'))
$sortBox.SelectedIndex = 0
$sortBox.BackColor = $input
$sortBox.ForeColor = $text
$sortBox.FlatStyle = 'Flat'
$sortBox.SetBounds(16, 312, 380, 28)
$optionsPanel.Controls.Add($sortBox)

Add-ControlLabel $optionsPanel $T.denoise 348 180 | Out-Null
$denoiseBox = New-Object Windows.Forms.NumericUpDown
$denoiseBox.Minimum = 1
$denoiseBox.Maximum = 20
$denoiseBox.Value = 7
$denoiseBox.BackColor = $input
$denoiseBox.ForeColor = $text
$denoiseBox.SetBounds(16, 372, 182, 28)
$optionsPanel.Controls.Add($denoiseBox)

Add-ControlLabel $optionsPanel $T.bitrate 348 180 214 | Out-Null
$bitrateBox = New-Object Windows.Forms.NumericUpDown
$bitrateBox.Minimum = 1
$bitrateBox.Maximum = 500
$bitrateBox.Value = 16
$bitrateBox.BackColor = $input
$bitrateBox.ForeColor = $text
$bitrateBox.SetBounds(214, 372, 182, 28)
$optionsPanel.Controls.Add($bitrateBox)

Add-ControlLabel $optionsPanel $T.modelName 408 380 | Out-Null
$modelNameBox = New-Object Windows.Forms.TextBox
$modelNameBox.BackColor = $input
$modelNameBox.ForeColor = $text
$modelNameBox.BorderStyle = 'FixedSingle'
$modelNameBox.SetBounds(16, 432, 380, 28)
$optionsPanel.Controls.Add($modelNameBox)

Add-ControlLabel $optionsPanel $T.existing 468 380 | Out-Null
$existingBox = New-Object Windows.Forms.ComboBox
$existingBox.DropDownStyle = 'DropDownList'
$existingBox.Items.AddRange(@('continue', 'replace'))
$existingBox.SelectedIndex = 0
$existingBox.BackColor = $input
$existingBox.ForeColor = $text
$existingBox.FlatStyle = 'Flat'
$existingBox.SetBounds(16, 492, 380, 28)
$optionsPanel.Controls.Add($existingBox)

$logTitle = New-Object Windows.Forms.Label
$logTitle.Text = $T.log
$logTitle.Font = New-Object Drawing.Font('Microsoft YaHei UI', 10, [Drawing.FontStyle]::Bold)
$logTitle.SetBounds(16, 532, 250, 24)
$optionsPanel.Controls.Add($logTitle)

$logBox = New-Object Windows.Forms.RichTextBox
$logBox.ReadOnly = $true
$logBox.BackColor = [Drawing.Color]::FromArgb(14, 16, 20)
$logBox.ForeColor = [Drawing.Color]::FromArgb(205, 211, 222)
$logBox.BorderStyle = 'None'
$logBox.Font = New-Object Drawing.Font('Cascadia Mono', 8)
$logBox.WordWrap = $false
$logBox.SetBounds(16, 558, 380, 48)
$optionsPanel.Controls.Add($logBox)

$mainButton = New-Object Windows.Forms.Button
$mainButton.Text = $T.openMain
$mainButton.SetBounds(16, 614, 380, 34)
Style-Button $mainButton $accent
$optionsPanel.Controls.Add($mainButton)

$statusLabel = New-Object Windows.Forms.Label
$statusLabel.Text = $T.ready
$statusLabel.ForeColor = $accent
$statusLabel.SetBounds(16, 652, 380, 24)
$optionsPanel.Controls.Add($statusLabel)

$runner = New-Object DflWorkflow.ProcessMonitor
$script:batchQueue = New-Object Collections.Queue
$script:activeName = ''
$script:nativeProcess = $null
$script:closing = $false
$script:tickCount = 0

function Add-Log([string] $Line) {
    if ([string]::IsNullOrWhiteSpace($Line)) { return }
    $logBox.AppendText(('[' + (Get-Date -Format 'HH:mm:ss') + '] ' + $Line + [Environment]::NewLine))
    if ($logBox.TextLength -gt 100000) {
        $logBox.Select(0, 40000)
        $logBox.SelectedText = ''
    }
    $logBox.SelectionStart = $logBox.TextLength
    $logBox.ScrollToCaret()
}

function Get-WorkspacePath {
    return [IO.Path]::GetFullPath($workspaceBox.Text)
}

function Test-Workspace {
    try {
        $path = Get-WorkspacePath
        return (Test-Path -LiteralPath (Join-Path $path 'data_src')) -and
               (Test-Path -LiteralPath (Join-Path $path 'data_dst')) -and
               (Test-Path -LiteralPath (Join-Path $path 'model'))
    }
    catch {
        return $false
    }
}

function New-DockerEnvironment {
    $environment = New-Object 'System.Collections.Generic.Dictionary[string,string]'
    $environment['DFL_WORKSPACE_PATH'] = (Get-WorkspacePath).Replace('\', '/')
    return $environment
}

function Get-ContainerState {
    $result = [DflWorkflow.ProcessMonitor]::Capture(
        $docker, ('inspect --format "{{.State.Status}}" ' + $containerName), $repoRoot, 2500)
    if ($result.ExitCode -eq 0) { return $result.Output.Trim() }
    return ''
}

function Test-Busy {
    if ($runner.Active) { return $true }
    if ($null -ne $script:nativeProcess -and -not $script:nativeProcess.HasExited) { return $true }
    return $false
}

function Set-ButtonsEnabled([bool] $Enabled) {
    foreach ($button in $buttonList) { $button.Enabled = $Enabled }
    $workspaceBox.Enabled = $Enabled
    $workspaceBrowse.Enabled = $Enabled
}

function New-BatchCommand([string] $PythonArguments) {
    $args = 'compose --ansi never -f ' + (Quote-Arg $composeFile) + ' run --rm -T'
    if ($cpuOnlyCheck.Checked) {
        $args += ' -e CUDA_VISIBLE_DEVICES=-1'
    }
    return $args + ' deepfacelab main.py ' + $PythonArguments
}

function Start-NextBatch {
    if ($script:batchQueue.Count -eq 0) { return }
    $arguments = [string]$script:batchQueue.Dequeue()
    $runner.Start($docker, $arguments, $repoRoot, (New-DockerEnvironment))
}

function Start-BatchSequence([string] $Name, [string[]] $Commands) {
    if (Test-Busy) {
        [Windows.Forms.MessageBox]::Show($T.busy, $T.title, 'OK', 'Information') | Out-Null
        return
    }
    if (-not (Test-Workspace)) {
        [Windows.Forms.MessageBox]::Show($T.invalidWorkspace, $T.title, 'OK', 'Warning') | Out-Null
        return
    }
    $script:batchQueue.Clear()
    foreach ($command in $Commands) { $script:batchQueue.Enqueue($command) }
    $script:activeName = $Name
    $statusLabel.Text = $T.running + ': ' + $Name
    $statusLabel.ForeColor = $accent
    Add-Log ($T.running + ': ' + $Name)
    Set-ButtonsEnabled $false
    Start-NextBatch
}

function Start-PythonBatch([string] $Name, [string] $PythonArguments) {
    Start-BatchSequence $Name @((New-BatchCommand $PythonArguments))
}

function Start-NativeDfl([string] $Name, [string] $Arguments) {
    if (Test-Busy) {
        [Windows.Forms.MessageBox]::Show($T.busy, $T.title, 'OK', 'Information') | Out-Null
        return
    }
    if (-not (Test-Workspace)) {
        [Windows.Forms.MessageBox]::Show($T.invalidWorkspace, $T.title, 'OK', 'Warning') | Out-Null
        return
    }
    $legacyInternal = Join-Path $script:legacyRoot '_internal'
    if (-not (Test-Path -LiteralPath (Join-Path $legacyInternal 'setenv.bat'))) {
        [Windows.Forms.MessageBox]::Show($T.legacyMissing, $T.title, 'OK', 'Warning') | Out-Null
        return
    }

    $oldValue = $env:DFL_GUI_LEGACY_INTERNAL
    try {
        $env:DFL_GUI_LEGACY_INTERNAL = $legacyInternal
        $script:nativeProcess = Start-Process -FilePath $nativeLauncher `
            -ArgumentList $Arguments -WorkingDirectory $repoRoot `
            -WindowStyle Normal -PassThru
    }
    finally {
        $env:DFL_GUI_LEGACY_INTERNAL = $oldValue
    }
    $script:activeName = $Name
    $statusLabel.Text = $T.nativeStarted + ': ' + $Name
    Add-Log ($T.nativeStarted + ': ' + $Name)
    Set-ButtonsEnabled $false
}

function Confirm-Change {
    return [Windows.Forms.MessageBox]::Show(
        $T.removePrompt, $T.confirm, 'YesNo', 'Warning') -eq 'Yes'
}

function Get-HostAligned([string] $Side) {
    return Join-Path (Get-WorkspacePath) ($Side + '\aligned')
}

function Get-ContainerAligned([string] $Side) {
    return '/workspace/' + $Side + '/aligned'
}

function Get-FaceTypeShort {
    switch ([string]$faceTypeBox.SelectedItem) {
        'half_face' { return 'h' }
        'mid_full' { return 'mf' }
        'full_face' { return 'f' }
        'head' { return 'head' }
        default { return 'wf' }
    }
}

function Get-ExtractFaceType {
    if ([string]$faceTypeBox.SelectedItem -eq 'mid_full') { return 'full_face' }
    return [string]$faceTypeBox.SelectedItem
}

function Get-ComputeArguments {
    if ($cpuOnlyCheck.Checked) { return ' --cpu-only' }
    return ' --force-gpu-idxs 0'
}

function Get-XSegComputeArguments {
    if ($cpuOnlyCheck.Checked) { return ' --cpu-only' }
    return ' --force-gpu-idx 0'
}

function Get-MergeArgument {
    if ($mergeCheck.Checked) { return ' --merge' }
    return ' --no-merge'
}

function Get-ExtractArguments([string] $Side, [switch] $ManualFix) {
    $path = '/workspace/' + $Side
    $args = 'extract --input-dir ' + $path +
            ' --output-dir ' + $path + '/aligned' +
            ' --detector s3fd' +
            ' --face-type ' + (Get-ExtractFaceType) +
            ' --max-faces-from-image ' + [int]$maxFacesBox.Value +
            ' --image-size ' + [int]$imageSizeBox.Value +
            ' --jpeg-quality ' + [int]$jpegBox.Value +
            ' --existing-output ' + [string]$existingBox.SelectedItem
    if ($debugCheck.Checked) { $args += ' --output-debug' }
    else { $args += ' --no-output-debug' }
    $args += Get-ComputeArguments
    if ($ManualFix) { $args += ' --manual-fix' }
    return $args
}

function Start-Viewer([string] $Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        [Windows.Forms.MessageBox]::Show($Path, $T.title, 'OK', 'Warning') | Out-Null
        return
    }
    $viewer = Join-Path $script:legacyRoot '_internal\XnViewMP\xnviewmp.exe'
    if (Test-Path -LiteralPath $viewer) {
        Start-Process -FilePath $viewer -ArgumentList (Quote-Arg $Path) `
            -WorkingDirectory (Split-Path -Parent $viewer) -WindowStyle Normal | Out-Null
    }
    else {
        Start-Process explorer.exe -ArgumentList (Quote-Arg $Path) | Out-Null
    }
}

function Ensure-LegacyAssets {
    $legacyInternal = Join-Path $script:legacyRoot '_internal'
    if (-not (Test-Path -LiteralPath $legacyInternal)) {
        throw $T.legacyMissing
    }
    $assetRoot = Join-Path (Get-WorkspacePath) '.dfl-assets'
    [void](New-Item -ItemType Directory -Path $assetRoot -Force)
    foreach ($name in @('pretrain_faces', 'pretrain_Quick96', 'model_generic_xseg')) {
        $source = Join-Path $legacyInternal $name
        $destination = Join-Path $assetRoot $name
        if (-not (Test-Path -LiteralPath $destination)) {
            [void](New-Item -ItemType Directory -Path $destination -Force)
        }
        if (Test-Path -LiteralPath $source) {
            Copy-Item -Path (Join-Path $source '*') -Destination $destination `
                -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    Add-Log $T.assetReady
}

function Start-Training([string] $Model, [switch] $SrcSrc, [switch] $UseQuickAssets) {
    if (Get-ContainerState) {
        [Windows.Forms.MessageBox]::Show($T.training, $T.title, 'OK', 'Information') | Out-Null
        return
    }
    if ($UseQuickAssets -or $Model -eq 'XSeg') {
        try { Ensure-LegacyAssets }
        catch {
            [Windows.Forms.MessageBox]::Show($_.Exception.Message, $T.title, 'OK', 'Warning') | Out-Null
            return
        }
    }

    $src = '/workspace/data_src/aligned'
    $dst = if ($SrcSrc) { $src } else { '/workspace/data_dst/aligned' }
    $args = 'compose --ansi never -f ' + (Quote-Arg $composeFile) +
            ' run --rm -d --name ' + $containerName
    if ($cpuOnlyCheck.Checked) { $args += ' -e CUDA_VISIBLE_DEVICES=-1' }
    $args += ' deepfacelab main.py train' +
             ' --training-data-src-dir ' + $src +
             ' --training-data-dst-dir ' + $dst +
             ' --model-dir /workspace/model' +
             ' --model ' + $Model +
             ' --silent-start --no-preview' +
             ' --preview-output-path /workspace/.dfl-preview.jpg'
    if ($cpuOnlyCheck.Checked) { $args += ' --cpu-only' }
    if (-not [string]::IsNullOrWhiteSpace($modelNameBox.Text)) {
        $args += ' --force-model-name ' + (Quote-Arg $modelNameBox.Text.Trim())
    }
    if ($UseQuickAssets) {
        $args += ' --pretraining-data-dir /workspace/.dfl-assets/pretrain_faces' +
                 ' --pretrained-model-dir /workspace/.dfl-assets/pretrain_Quick96'
    }
    if ($Model -eq 'XSeg') {
        $args += ' --pretraining-data-dir /workspace/.dfl-assets/pretrain_faces'
    }
    Start-BatchSequence ('train ' + $Model) @($args)
}

function Start-Merge([string] $Model) {
    $workspace = Get-WorkspacePath
    $args = 'merge' +
            ' --input-dir ' + (Quote-Arg (Join-Path $workspace 'data_dst')) +
            ' --output-dir ' + (Quote-Arg (Join-Path $workspace 'data_dst\merged')) +
            ' --output-mask-dir ' + (Quote-Arg (Join-Path $workspace 'data_dst\merged_mask')) +
            ' --aligned-dir ' + (Quote-Arg (Join-Path $workspace 'data_dst\aligned')) +
            ' --model-dir ' + (Quote-Arg (Join-Path $workspace 'model')) +
            ' --model ' + $Model
    if (-not [string]::IsNullOrWhiteSpace($modelNameBox.Text)) {
        $args += ' --force-model-name ' + (Quote-Arg $modelNameBox.Text.Trim())
    }
    if ($cpuOnlyCheck.Checked) { $args += ' --cpu-only' }
    else { $args += ' --force-gpu-idxs 0' }
    Start-NativeDfl ('merge ' + $Model) $args
}

function Start-VideoOutput([string] $Extension, [bool] $Lossless) {
    $losslessArg = if ($Lossless) { ' --lossless' } else { '' }
    $base = 'videoed video-from-sequence --input-dir /workspace/data_dst/merged' +
            ' --output-file /workspace/result.' + $Extension +
            ' --reference-file /workspace/data_dst.* --ext png' +
            ' --bitrate ' + [int]$bitrateBox.Value + ' --include-audio' + $losslessArg
    $mask = 'videoed video-from-sequence --input-dir /workspace/data_dst/merged_mask' +
            ' --output-file /workspace/result_mask.' + $Extension +
            ' --reference-file /workspace/data_dst.* --ext png --lossless'
    Start-BatchSequence ('video ' + $Extension) @(
        (New-BatchCommand $base),
        (New-BatchCommand $mask)
    )
}

function Clear-Workspace {
    if (Get-ContainerState) {
        [Windows.Forms.MessageBox]::Show($T.training, $T.title, 'OK', 'Warning') | Out-Null
        return
    }
    if ([Windows.Forms.MessageBox]::Show(
        $T.clearPrompt, $T.confirm, 'YesNo', 'Warning') -ne 'Yes') { return }

    $root = Get-WorkspacePath
    $prefix = $root.TrimEnd('\') + '\'
    $targets = @(
        (Join-Path $root 'data_src\aligned'),
        (Join-Path $root 'data_dst\aligned'),
        (Join-Path $root 'model')
    )
    foreach ($target in $targets) {
        $resolved = [IO.Path]::GetFullPath($target)
        if (-not $resolved.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
            throw 'Unsafe workspace target: ' + $resolved
        }
    }
    foreach ($target in $targets) {
        if (Test-Path -LiteralPath $target) {
            Remove-Item -LiteralPath $target -Recurse -Force
        }
        [void](New-Item -ItemType Directory -Path $target -Force)
    }
    Add-Log ($T.completed + ': clear workspace')
}

function Invoke-WorkflowAction([string] $Id) {
    try {
        $safeWhileTraining = @('start-ebsynth','cpu-only','src-view','dst-view','dst-view-debug')
        if ((Get-ContainerState) -and $Id -notin $safeWhileTraining) {
            [Windows.Forms.MessageBox]::Show($T.training, $T.title, 'OK', 'Warning') | Out-Null
            return
        }
        if ($Id -notin @('start-ebsynth','cpu-only','src-view','dst-view','dst-view-debug') -and
            -not (Test-Workspace)) {
            [Windows.Forms.MessageBox]::Show($T.invalidWorkspace, $T.title, 'OK', 'Warning') | Out-Null
            return
        }

        $workspace = Get-WorkspacePath
        switch ($Id) {
            'clear-workspace' { Clear-Workspace }
            'start-ebsynth' {
                $exe = Join-Path $script:legacyRoot '_internal\EbSynth\EbSynth.exe'
                $project = Join-Path $script:legacyRoot '_internal\EbSynth\SampleProject\sample.ebs'
                if (-not (Test-Path -LiteralPath $exe)) { throw $T.legacyMissing }
                Start-Process -FilePath $exe -ArgumentList (Quote-Arg $project) `
                    -WorkingDirectory (Split-Path -Parent $exe) -WindowStyle Normal | Out-Null
            }
            'cpu-only' {
                $cpuOnlyCheck.Checked = -not $cpuOnlyCheck.Checked
                [Windows.Forms.MessageBox]::Show($T.cpuChanged, $T.title, 'OK', 'Information') | Out-Null
            }
            'video-src' {
                Start-PythonBatch 'extract data_src video' (
                    'videoed extract-video --input-file /workspace/data_src.*' +
                    ' --output-dir /workspace/data_src --output-ext ' + [string]$formatBox.SelectedItem +
                    ' --fps ' + [int]$fpsBox.Value)
            }
            'video-dst' {
                Start-PythonBatch 'extract data_dst video' (
                    'videoed extract-video --input-file /workspace/data_dst.*' +
                    ' --output-dir /workspace/data_dst --output-ext ' + [string]$formatBox.SelectedItem +
                    ' --fps 0')
            }
            'video-cut' {
                $dialog = New-Object Windows.Forms.OpenFileDialog
                $dialog.Filter = 'Video files|*.mp4;*.mov;*.mkv;*.avi;*.webm|All files|*.*'
                if ($dialog.ShowDialog($form) -eq 'OK') {
                    Start-NativeDfl 'cut video' (
                        'videoed cut-video --input-file ' + (Quote-Arg $dialog.FileName))
                }
                $dialog.Dispose()
            }
            'video-denoise' {
                Start-PythonBatch 'denoise data_dst' (
                    'videoed denoise-image-sequence --input-dir /workspace/data_dst' +
                    ' --factor ' + [int]$denoiseBox.Value)
            }

            'src-manual' {
                Start-NativeDfl 'src manual extract' (
                    'extract --input-dir ' + (Quote-Arg (Join-Path $workspace 'data_src')) +
                    ' --output-dir ' + (Quote-Arg (Get-HostAligned 'data_src')) +
                    ' --detector manual')
            }
            'src-manual-reextract' {
                Start-NativeDfl 'src manual re-extract' (
                    'extract --input-dir ' + (Quote-Arg (Join-Path $workspace 'data_src')) +
                    ' --output-dir ' + (Quote-Arg (Get-HostAligned 'data_src')) +
                    ' --detector manual --max-faces-from-image 0 --output-debug' +
                    ' --manual-output-debug-fix')
            }
            'src-auto' { Start-PythonBatch 'src auto extract' (Get-ExtractArguments 'data_src') }
            'src-view' { Start-Viewer (Get-HostAligned 'data_src') }
            'src-resize' {
                Start-PythonBatch 'src resize' (
                    'facesettool resize --input-dir /workspace/data_src/aligned' +
                    ' --image-size ' + [int]$imageSizeBox.Value +
                    ' --face-type ' + (Get-FaceTypeShort) + (Get-MergeArgument))
            }
            'src-sort' {
                Start-NativeDfl 'src sort' (
                    'sort --input-dir ' + (Quote-Arg (Get-HostAligned 'data_src')) +
                    ' --by ' + [string]$sortBox.SelectedItem)
            }
            'src-pack' {
                Start-NativeDfl 'src pack' (
                    'util --input-dir ' + (Quote-Arg (Get-HostAligned 'data_src')) +
                    ' --pack-faceset')
            }
            'src-unpack' {
                Start-NativeDfl 'src unpack' (
                    'util --input-dir ' + (Quote-Arg (Get-HostAligned 'data_src')) +
                    ' --unpack-faceset')
            }
            'src-meta-save' {
                Start-PythonBatch 'src metadata save' (
                    'util --input-dir /workspace/data_src/aligned --save-faceset-metadata')
            }
            'src-meta-restore' {
                Start-PythonBatch 'src metadata restore' (
                    'util --input-dir /workspace/data_src/aligned --restore-faceset-metadata')
            }
            'src-enhance' {
                Start-PythonBatch 'src enhance' (
                    'facesettool enhance --input-dir /workspace/data_src/aligned' +
                    (Get-ComputeArguments) + (Get-MergeArgument))
            }
            'src-landmarks' {
                Start-PythonBatch 'src landmarks debug' (
                    'util --input-dir /workspace/data_src/aligned --add-landmarks-debug-images')
            }
            'src-recover' {
                Start-PythonBatch 'src recover names' (
                    'util --input-dir /workspace/data_src/aligned --recover-original-aligned-filename')
            }

            'dst-manual' {
                Start-NativeDfl 'dst manual extract' (
                    'extract --input-dir ' + (Quote-Arg (Join-Path $workspace 'data_dst')) +
                    ' --output-dir ' + (Quote-Arg (Get-HostAligned 'data_dst')) +
                    ' --detector manual')
            }
            'dst-manual-reextract' {
                Start-NativeDfl 'dst manual re-extract' (
                    'extract --input-dir ' + (Quote-Arg (Join-Path $workspace 'data_dst')) +
                    ' --output-dir ' + (Quote-Arg (Get-HostAligned 'data_dst')) +
                    ' --detector manual --max-faces-from-image 0 --output-debug' +
                    ' --manual-output-debug-fix')
            }
            'dst-auto-fix' {
                $inputPath = Join-Path $workspace 'data_dst'
                $outputPath = Join-Path $inputPath 'aligned'
                $hostArgs = 'extract --input-dir ' + (Quote-Arg $inputPath) +
                            ' --output-dir ' + (Quote-Arg $outputPath) +
                            ' --detector s3fd --face-type ' + (Get-ExtractFaceType) +
                            ' --max-faces-from-image ' + [int]$maxFacesBox.Value +
                            ' --image-size ' + [int]$imageSizeBox.Value +
                            ' --jpeg-quality ' + [int]$jpegBox.Value +
                            ' --existing-output ' + [string]$existingBox.SelectedItem +
                            ' --output-debug --manual-fix'
                if ($cpuOnlyCheck.Checked) { $hostArgs += ' --cpu-only' }
                else { $hostArgs += ' --force-gpu-idxs 0' }
                Start-NativeDfl 'dst auto extract + manual fix' $hostArgs
            }
            'dst-auto' { Start-PythonBatch 'dst auto extract' (Get-ExtractArguments 'data_dst') }
            'dst-view' { Start-Viewer (Get-HostAligned 'data_dst') }
            'dst-view-debug' { Start-Viewer (Join-Path $workspace 'data_dst\aligned_debug') }
            'dst-resize' {
                Start-PythonBatch 'dst resize' (
                    'facesettool resize --input-dir /workspace/data_dst/aligned' +
                    ' --image-size ' + [int]$imageSizeBox.Value +
                    ' --face-type ' + (Get-FaceTypeShort) + (Get-MergeArgument))
            }
            'dst-sort' {
                Start-NativeDfl 'dst sort' (
                    'sort --input-dir ' + (Quote-Arg (Get-HostAligned 'data_dst')) +
                    ' --by ' + [string]$sortBox.SelectedItem)
            }
            'dst-pack' {
                Start-NativeDfl 'dst pack' (
                    'util --input-dir ' + (Quote-Arg (Get-HostAligned 'data_dst')) +
                    ' --pack-faceset')
            }
            'dst-unpack' {
                Start-NativeDfl 'dst unpack' (
                    'util --input-dir ' + (Quote-Arg (Get-HostAligned 'data_dst')) +
                    ' --unpack-faceset')
            }
            'dst-recover' {
                Start-PythonBatch 'dst recover names' (
                    'util --input-dir /workspace/data_dst/aligned --recover-original-aligned-filename')
            }

            'xseg-src-edit' {
                Start-NativeDfl 'src XSeg editor' (
                    'xseg editor --input-dir ' + (Quote-Arg (Get-HostAligned 'data_src')))
            }
            'xseg-dst-edit' {
                Start-NativeDfl 'dst XSeg editor' (
                    'xseg editor --input-dir ' + (Quote-Arg (Get-HostAligned 'data_dst')))
            }
            { $_ -in @('xseg-src-label-remove','xseg-dst-label-remove') } {
                if (-not (Confirm-Change)) { return }
                $side = if ($Id -like '*src*') { 'data_src' } else { 'data_dst' }
                Start-PythonBatch ($side + ' remove XSeg labels') (
                    'xseg remove_labels --input-dir ' + (Get-ContainerAligned $side) +
                    ' --skip-confirmation')
            }
            { $_ -in @('xseg-src-fetch','xseg-dst-fetch') } {
                $choice = [Windows.Forms.MessageBox]::Show(
                    $T.fetchPrompt.Replace('\n', [Environment]::NewLine),
                    $T.confirm, 'YesNoCancel', 'Question')
                if ($choice -eq 'Cancel') { return }
                $side = if ($Id -like '*src*') { 'data_src' } else { 'data_dst' }
                $mode = if ($choice -eq 'Yes') { '--delete-original' } else { '--keep-original' }
                Start-PythonBatch ($side + ' fetch XSeg') (
                    'xseg fetch --input-dir ' + (Get-ContainerAligned $side) + ' ' + $mode)
            }
            'xseg-train' { Start-Training 'XSeg' }
            { $_ -in @('xseg-src-trained-remove','xseg-dst-trained-remove') } {
                if (-not (Confirm-Change)) { return }
                $side = if ($Id -like '*src*') { 'data_src' } else { 'data_dst' }
                Start-PythonBatch ($side + ' remove trained XSeg') (
                    'xseg remove --input-dir ' + (Get-ContainerAligned $side) +
                    ' --skip-confirmation')
            }
            { $_ -in @('xseg-src-trained-apply','xseg-dst-trained-apply') } {
                $side = if ($Id -like '*src*') { 'data_src' } else { 'data_dst' }
                Start-PythonBatch ($side + ' apply trained XSeg') (
                    'xseg apply --input-dir ' + (Get-ContainerAligned $side) +
                    ' --model-dir /workspace/model --face-type ' + (Get-FaceTypeShort) +
                    (Get-XSegComputeArguments))
            }
            { $_ -in @('xseg-src-generic','xseg-dst-generic') } {
                Ensure-LegacyAssets
                $side = if ($Id -like '*src*') { 'data_src' } else { 'data_dst' }
                Start-PythonBatch ($side + ' apply generic XSeg') (
                    'xseg apply --input-dir ' + (Get-ContainerAligned $side) +
                    ' --model-dir /workspace/.dfl-assets/model_generic_xseg' +
                    ' --face-type wf' + (Get-XSegComputeArguments))
            }

            'train-amp-srcsrc' { Start-Training 'AMP' -SrcSrc }
            'train-amp' { Start-Training 'AMP' }
            'train-quick96' { Start-Training 'Quick96' -UseQuickAssets }
            'train-saehd' { Start-Training 'SAEHD' }
            'export-amp' {
                Start-NativeDfl 'export AMP DFM' (
                    'exportdfm --model-dir ' + (Quote-Arg (Join-Path $workspace 'model')) +
                    ' --model AMP')
            }
            'export-saehd' {
                Start-NativeDfl 'export SAEHD DFM' (
                    'exportdfm --model-dir ' + (Quote-Arg (Join-Path $workspace 'model')) +
                    ' --model SAEHD')
            }

            'merge-amp' { Start-Merge 'AMP' }
            'merge-quick96' { Start-Merge 'Quick96' }
            'merge-saehd' { Start-Merge 'SAEHD' }
            'output-avi' { Start-VideoOutput 'avi' $false }
            'output-mov-lossless' { Start-VideoOutput 'mov' $true }
            'output-mp4-lossless' { Start-VideoOutput 'mp4' $true }
            'output-mp4' { Start-VideoOutput 'mp4' $false }
        }
    }
    catch {
        Add-Log ($T.failed + ': ' + $_.Exception.Message)
        [Windows.Forms.MessageBox]::Show($_.Exception.Message, $T.title, 'OK', 'Error') | Out-Null
    }
}

$workspaceBrowse.Add_Click({
    $dialog = New-Object Windows.Forms.FolderBrowserDialog
    $dialog.Description = $T.workspace
    $dialog.SelectedPath = $workspaceBox.Text
    if ($dialog.ShowDialog($form) -eq 'OK') { $workspaceBox.Text = $dialog.SelectedPath }
    $dialog.Dispose()
})

$mainButton.Add_Click({
    $main = Get-Process -Name powershell -ErrorAction SilentlyContinue |
        Where-Object { $_.MainWindowTitle -eq 'DeepFaceLab RTX 5090 ' + [char]0x63A7 + [char]0x5236 + [char]0x53F0 } |
        Select-Object -First 1
    if ($null -ne $main) {
        [DflWorkflow.WindowTools]::ShowWindow($main.MainWindowHandle, 9) | Out-Null
        [DflWorkflow.WindowTools]::SetForegroundWindow($main.MainWindowHandle) | Out-Null
    }
    else {
        $mainScript = Join-Path $repoRoot 'DeepFaceLab-GUI.ps1'
        Start-Process -FilePath 'powershell.exe' `
            -ArgumentList ('-NoLogo -NoProfile -STA -WindowStyle Hidden -ExecutionPolicy Bypass -File ' + (Quote-Arg $mainScript)) `
            -WorkingDirectory $repoRoot -WindowStyle Hidden | Out-Null
    }
})

$timer = New-Object Windows.Forms.Timer
$timer.Interval = 750
$timer.Add_Tick({
    foreach ($line in $runner.Drain()) { Add-Log $line }

    if ($runner.Complete) {
        foreach ($line in $runner.Drain()) { Add-Log $line }
        $exitCode = $runner.ExitCode
        if ($exitCode -eq 0 -and $script:batchQueue.Count -gt 0) {
            Start-NextBatch
        }
        else {
            if ($exitCode -eq 0) {
                Add-Log ($T.completed + ': ' + $script:activeName)
                $statusLabel.Text = $T.completed + ': ' + $script:activeName
                $statusLabel.ForeColor = $accent
            }
            else {
                Add-Log ($T.failed + ': ' + $exitCode)
                $statusLabel.Text = $T.failed + ': ' + $exitCode
                $statusLabel.ForeColor = $danger
            }
            $script:batchQueue.Clear()
            $script:activeName = ''
            Set-ButtonsEnabled $true
        }
    }

    if ($null -ne $script:nativeProcess -and $script:nativeProcess.HasExited) {
        $exitCode = $script:nativeProcess.ExitCode
        if ($exitCode -eq 0) {
            Add-Log ($T.completed + ': ' + $script:activeName)
            $statusLabel.Text = $T.completed + ': ' + $script:activeName
            $statusLabel.ForeColor = $accent
        }
        else {
            Add-Log ($T.failed + ': ' + $exitCode)
            $statusLabel.Text = $T.failed + ': ' + $exitCode
            $statusLabel.ForeColor = $danger
        }
        $script:nativeProcess.Dispose()
        $script:nativeProcess = $null
        $script:activeName = ''
        Set-ButtonsEnabled $true
    }

    $script:tickCount++
    if (($script:tickCount % 4) -eq 0 -and -not (Test-Busy)) {
        if (Get-ContainerState) {
            $statusLabel.Text = $T.training
            $statusLabel.ForeColor = $accent
        }
    }
})

$form.Add_Shown({
    Add-Log ('57 commands ready. Workspace: ' + $workspaceBox.Text)
    $timer.Start()
})

$form.Add_FormClosing({
    param($sender, $eventArgs)
    $timer.Stop()
    $script:closing = $true
    if ($runner.Active) { $runner.StopMonitor() }
})

[void]$form.ShowDialog()
$timer.Dispose()
$runner.Dispose()
if ($null -ne $script:nativeProcess) { $script:nativeProcess.Dispose() }
$form.Dispose()
