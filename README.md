<table align="center" border="0">

<tr><td colspan=2 align="center">

# DeepFaceLab  

> This branch adds maintained RTX 5090 / RTX 50-series support, a native
> Windows training console, and a complete two-column workflow workbench.

<a href="https://arxiv.org/abs/2005.05535">

<img src="https://static.arxiv.org/static/browse/0.3.0/images/icons/favicon.ico" width=14></img>
https://arxiv.org/abs/2005.05535</a>

</td></tr>
<tr><td colspan=2 align="center">

<p align="center">

![](doc/logo_tensorflow.png)
![](doc/logo_cuda.png)
![](doc/logo_directx.png)

</p>

DeepFaceLab is used by such popular youtube channels as

|![](doc/tiktok_icon.png) [deeptomcruise](https://www.tiktok.com/@deeptomcruise)|![](doc/tiktok_icon.png) [1facerussia](https://www.tiktok.com/@1facerussia)|![](doc/tiktok_icon.png) [arnoldschwarzneggar](https://www.tiktok.com/@arnoldschwarzneggar)
|---|---|---|

|![](doc/tiktok_icon.png) [mariahcareyathome?](https://www.tiktok.com/@mariahcareyathome?)|![](doc/tiktok_icon.png) [diepnep](https://www.tiktok.com/@diepnep)|![](doc/tiktok_icon.png) [mr__heisenberg](https://www.tiktok.com/@mr__heisenberg)|![](doc/tiktok_icon.png) [deepcaprio](https://www.tiktok.com/@deepcaprio)
|---|---|---|---|

|![](doc/youtube_icon.png) [VFXChris Ume](https://www.youtube.com/channel/UCGf4OlX_aTt8DlrgiH3jN3g/videos)|![](doc/youtube_icon.png) [Sham00k](https://www.youtube.com/channel/UCZXbWcv7fSZFTAZV4beckyw/videos)|
|---|---|

|![](doc/youtube_icon.png) [Collider videos](https://www.youtube.com/watch?v=A91P2qtPT54&list=PLayt6616lBclvOprvrC8qKGCO-mAhPRux)|![](doc/youtube_icon.png) [iFake](https://www.youtube.com/channel/UCC0lK2Zo2BMXX-k1Ks0r7dg/videos)|![](doc/youtube_icon.png) [NextFace](https://www.youtube.com/channel/UCFh3gL0a8BS21g-DHvXZEeQ/videos)|
|---|---|---|

|![](doc/youtube_icon.png) [Futuring Machine](https://www.youtube.com/channel/UCC5BbFxqLQgfnWPhprmQLVg)|![](doc/youtube_icon.png) [RepresentUS](https://www.youtube.com/channel/UCRzgK52MmetD9aG8pDOID3g)|![](doc/youtube_icon.png) [Corridor Crew](https://www.youtube.com/c/corridorcrew/videos)|
|---|---|---|

|![](doc/youtube_icon.png) [DeepFaker](https://www.youtube.com/channel/UCkHecfDTcSazNZSKPEhtPVQ)|![](doc/youtube_icon.png) [DeepFakes in movie](https://www.youtube.com/c/DeepFakesinmovie/videos)|
|---|---|

|![](doc/youtube_icon.png) [DeepFakeCreator](https://www.youtube.com/channel/UCkNFhcYNLQ5hr6A6lZ56mKA)|![](doc/youtube_icon.png) [Jarkan](https://www.youtube.com/user/Jarkancio/videos)|
|---|---|

</td></tr>

<tr><td colspan=2 align="center">

# What can I do using DeepFaceLab?

</td></tr>
<tr><td colspan=2 align="center">

## Replace the face

<img src="doc/replace_the_face.jpg" align="center">

</td></tr>

<tr><td colspan=2 align="center">

## De-age the face

</td></tr>

<tr><td align="center" width="50%">

<img src="doc/deage_0_1.jpg" align="center">

</td>
<td align="center" width="50%">

<img src="doc/deage_0_2.jpg" align="center">

</td></tr>

<tr><td colspan=2 align="center">

![](doc/youtube_icon.png) https://www.youtube.com/watch?v=Ddx5B-84ebo

</td></tr>

<tr><td colspan=2 align="center">

## Replace the head

</td></tr>

<tr><td align="center" width="50%">

<img src="doc/head_replace_1_1.jpg" align="center">

</td>
<td align="center" width="50%">

<img src="doc/head_replace_1_2.jpg" align="center">

</td></tr>

<tr><td colspan=2 align="center">

![](doc/youtube_icon.png) https://www.youtube.com/watch?v=RTjgkhMugVw

</td></tr>

<tr><td colspan=2 align="center">

# Native resolution progress

</td></tr>
<tr><td colspan=2 align="center">

<img src="doc/deepfake_progress.png" align="center">

</td></tr>
<tr><td colspan=2 align="center">

<img src="doc/make_everything_ok.png" align="center">

Unfortunately, there is no "make everything ok" button in DeepFaceLab. You should spend time studying the workflow and growing your skills. A skill in programs such as *AfterEffects* or *Davinci Resolve* is also desirable.

</td></tr>
<tr><td colspan=2 align="center">

## Mini tutorial

<a href="https://www.youtube.com/watch?v=kOIMXt8KK8M">

<img src="doc/mini_tutorial.jpg" align="center">

</a>

</td></tr>
<tr><td colspan=2 align="center">

## RTX 5090 / RTX 50-series (Blackwell)

This branch keeps the original DeepFaceLab workflow while adding a reproducible
Blackwell compute runtime and native Windows management interfaces. GPU-heavy
training and batch processing run in Docker/WSL2. Tasks that need direct mouse
interaction use the proven native Windows tools.

### Runtime architecture

| Component | Responsibility |
|---|---|
| Blackwell container | RTX 50-series training, extraction, XSeg processing, enhancement, and video jobs |
| Training Console | Model selection, start/stop, GPU telemetry, logs, environment tools, and preview control |
| Workflow Workbench | Material, SRC, DST, XSeg, training/export, and merge/output operations |
| One-click DFM Pipeline | Recoverable media-to-DFM workflow with quality screening, two-phase training, export, and validation |
| Local AI Assistant | Read-only material quality checks, training diagnosis, and RTX 5090-aware configuration guidance |
| Native interactive runtime | Manual face extraction, XSeg editor, sorting prompts, DFM export, and interactive merger |
| Windows preview window | Periodically refreshed training preview without relying on a WSLg copy-mode window |

The workbench uses a fixed two-column action grid on every page. Destructive
actions use a distinct warning style and require confirmation. The Training
Console and Workbench switch to the existing window instead of opening duplicate
instances.

### Requirements

- Windows 11 with WSL2 enabled.
- A current NVIDIA Windows driver that exposes the RTX 50-series GPU to WSL2.
- Docker Desktop with the WSL2 engine and Docker Compose v2.
- The reference Windows runtime at `D:\DFL_RTX5000_series_2025` for interactive
  legacy tools. The path is intentionally kept out of the normal user interface.
- A workspace containing `data_src`, `data_dst`, and `model`.

### Quick start

1. Enable WSL2 from an Administrator PowerShell and restart Windows if requested:

   ```powershell
   .\enable_wsl2_admin.ps1
   ```

   To install both WSL2/Ubuntu and Docker Desktop automatically instead:

   ```powershell
   .\install_blackwell_prereqs_admin.ps1
   ```

2. Start Docker Desktop and enable its WSL2 engine.

3. Double-click `DeepFaceLab-GUI.vbs` for a console-free launch. The
   `DeepFaceLab-GUI.cmd` compatibility entry delegates to the same hidden
   launcher, but Windows may briefly show a command window while opening any
   `.cmd` file. The blue dashboard icon identifies the Training Console in
   the taskbar; the purple face-and-arrow icon identifies the one-click DFM
   workflow.

4. In the Training Console:

   - Select the workspace, model type, and saved model.
   - Use **Install / Update Environment** after runtime changes.
   - Use **Environment Check** to verify native Blackwell execution.
   - Start training and use **Save and Stop** for a graceful shutdown.
   - Use **Show Preview** to restore the native preview window.

5. Use **Open Workbench** for the complete material-to-output workflow.

6. Use **AI Assistant** from either window for local diagnostics and guidance.

7. Use **One-click DFM Training** for a guided project that ends with a
   validated DeepFaceLive model.

### One-click DFM training

Double-click `DeepFaceLab-OneClick.vbs` for a console-free launch, or open
**One-click DFM Training**
from the Training Console. Select a project directory and choose
**Create / Check Project**. The pipeline creates this recoverable layout:

```text
dfm-project/
|-- input_src/             # Identity that the DFM should render
|-- input_dst/             # DeepFaceLive driver/target face material
|-- data_src/
|   `-- aligned/
|-- data_dst/
|   `-- aligned/
|-- model/
|-- output/                # Final <model-name>.dfm
`-- .dfl-pipeline/
    |-- state.json         # Resume state and selected settings
    |-- rejected/          # Recoverable quality-screening quarantine
    |-- model-backups/     # Model metadata backup before refinement
    `-- dfm-report.json    # Size, SHA-256 and ONNX I/O validation
```

Place photos and videos in both input folders, then choose **Prepare and Start
Training**. The standard workflow is:

1. Import still images and sample video frames at the selected FPS.
2. Detect with S3FD and align 512-pixel whole-face crops.
3. Conservatively quarantine unreadable, severely exposed, blurry, and
   perceptually duplicate faces. Files are moved, never deleted.
4. Optionally enhance SRC and/or DST faces.
5. Apply the bundled generic whole-face XSeg masks.
6. Create a reproducible RTX 5090 SAEHD profile.
7. Run a generalization phase with random warp and GAN disabled.
8. Back up model metadata, then refine with LR dropout, random warp disabled,
   gradient clipping, and low-strength GAN.
9. Save, export the named model as DFM, validate the ONNX graph, and publish it
   to `output/`.

The default deployment-oriented profile is 256 pixels, `df-ud`, AE 320,
encoder/decoder 64/64, batch 8, with base and final targets of 300,000 and
500,000 iterations. It balances source identity detail with a DFM size and
runtime suitable for DeepFaceLive; larger networks are not automatically
treated as higher quality.

**Safe Pause** waits for the current preprocessing stage to finish. During
training it sends SIGINT so DeepFaceLab saves before stopping. Starting again
uses `.dfl-pipeline/state.json` to continue completed stages. Automatic
screening is intentionally conservative: inspect the quarantine before a long
run, especially when either faceset is small.

### Local AI assistant

`DeepFaceLab-AI.ps1` provides three focused actions:

- **Check Current Workspace** samples SRC and DST aligned faces, including
  `faceset.pak`, and reports image count, resolution, sharpness, exposure,
  likely duplicates, and dataset balance.
- **Analyze Training Status** combines the material report with model summaries,
  the latest preview image, container state, and recent training logs.
- **Generate Recommended Configuration** reads the local NVIDIA GPU and free
  VRAM, then proposes a conservative SAEHD starting point. Existing model
  structure is never changed automatically.

All analysis runs locally through `dfl_ai_assistant.py` in the Blackwell
container. Face images and logs are not uploaded, and the assistant only reads
the workspace. Its recommendations are diagnostics rather than automatic file
cleanup or unattended training changes.

### Workspace layout

```text
workspace/
|-- data_src/
|   `-- aligned/
|-- data_dst/
|   |-- aligned/
|   |-- merged/
|   `-- merged_mask/
|-- model/
|-- .dfl-assets/          # Prepared automatically when an operation needs it
`-- .dfl-preview.jpg      # Published atomically while preview is enabled
```

The default workspace is the repository's `workspace` directory. Both Windows
interfaces can select another compatible directory and pass it to the container
through `DFL_WORKSPACE_PATH`.

### Command-line use and verification

The command launcher works even when Windows PowerShell script execution is
disabled:

```powershell
.\run_blackwell.cmd
.\run_blackwell.cmd main.py --help
.\run_blackwell.cmd main.py train --help
```

With no additional arguments, `run_blackwell.cmd` builds the image and performs
a real small DeepFaceLab forward/backward training step on GPU 0.

The maintained Blackwell runtime uses the published TensorFlow 2.21.0 wheel from
[TensorflowDockerBuilder](https://github.com/Syraxius/TensorflowDockerBuilder).
The CUDA 12.8.1 build contains native `sm_120` cubins for RTX 50-series cards
plus `compute_120` PTX fallback code. Its release URL and SHA-256 are pinned in
`Dockerfile.blackwell`; `requirements-blackwell-cuda.txt` locks the matching
CUDA 12.8.1 and cuDNN 9.8 packages.

The image build inspects the wheel with NVIDIA `cuobjdump` and fails if its
shared libraries contain no real `sm_120` cubin. Runtime verification also fails
unless TensorFlow detects the GPU, reports CUDA 12.8 or newer, and completes the
actual forward/backward step. Docker BuildKit caches the wheel and dependencies
for subsequent builds.

The repository is also tested against the stock upstream TensorFlow 2.21 API.
From an Ubuntu WSL2 shell, `bash setup_modern_wsl.sh` creates that development
environment. Stock wheels are an API-compatibility lane and are not accepted as
proof of native `sm_120` support; the digest-pinned container is the production
Blackwell runtime. TensorFlow, CUDA and cuDNN must not be mixed with the legacy
native-Windows runtime in this mode.

## Releases

</td></tr>

<tr><td align="right">
<a href="https://tinyurl.com/2p9cvt25">Windows (magnet link)</a>
</td><td align="center">Last release. Use torrent client to download.</td></tr>

<tr><td align="right">
<a href="https://mega.nz/folder/Po0nGQrA#dbbttiNWojCt8jzD4xYaPw">Windows (Mega.nz)</a>
</td><td align="center">Contains new and prev releases.</td></tr>

<tr><td align="right">
<a href="https://disk.yandex.ru/d/7i5XTKIKVg5UUg">Windows (yandex.ru)</a>
</td><td align="center">Contains new and prev releases.</td></tr>

<tr><td align="right">
<a href="https://github.com/nagadit/DeepFaceLab_Linux">Linux (github)</a>
</td><td align="center">by @nagadit</td></tr>

<tr><td align="right">
<a href="https://github.com/elemantalcode/dfl">CentOS Linux (github)</a>
</td><td align="center">May be outdated. By @elemantalcode</td></tr>

</table>

<table align="center" border="0">

<tr><td colspan=2 align="center">

### Communication groups

</td></tr>

<tr><td align="right">
<a href="https://discord.gg/rxa7h9M6rH">Discord</a>
</td><td align="center">Official discord channel. English / Russian.</td></tr>

<tr><td colspan=2 align="center">

## Related works

</td></tr>

<tr><td align="right">
<a href="https://github.com/iperov/DeepFaceLive">DeepFaceLive</a>
</td><td align="center">Real-time face swap for PC streaming or video calls</td></tr>

</td></tr>
</table>

<table align="center" border="0">

<tr><td colspan=2 align="center">

## How I can help the project?

</td></tr>

<tr><td colspan=2 align="center">

### Star this repo

</td></tr>

<tr><td colspan=2 align="center">

Register github account and push "Star" button.

</td></tr>

</table>

<table align="center" border="0">
<tr><td colspan=2 align="center">

## Meme zone

</td></tr>

<tr><td align="center" width="50%">

<img src="doc/meme1.jpg" align="center">

</td>

<td align="center" width="50%">

<img src="doc/meme2.jpg" align="center">

</td></tr>

<tr><td colspan=2 align="center">

<sub>#deepfacelab #faceswap #face-swap #deep-learning #deeplearning #deep-neural-networks #deepface #deep-face-swap #neural-networks #neural-nets #tensorflow #cuda #nvidia</sub>

</td></tr>



</table>
