<table align="center" border="0">

<tr><td colspan=2 align="center">

# DeepFaceLab  

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

The maintained Blackwell runtime uses WSL2 and the published TensorFlow 2.21.0
wheel from [TensorflowDockerBuilder](https://github.com/Syraxius/TensorflowDockerBuilder).
That CUDA 12.8.1 build contains native `sm_120` cubins for RTX 50-series cards
plus `compute_120` PTX fallback code. The release URL and its GitHub-recorded
SHA-256 are pinned in `Dockerfile.blackwell`. Install WSL2 plus Docker Desktop's
WSL2 backend, while `requirements-blackwell-cuda.txt` locks the matching CUDA
12.8.1 and cuDNN 9.8 runtime packages. Then run from PowerShell:

```powershell
# Run once from an Administrator PowerShell, then restart if requested.
.\enable_wsl2_admin.ps1
```

After installing Docker Desktop and enabling its WSL2 engine, use the command
launcher (it works even when Windows PowerShell script execution is disabled):

```powershell
.\run_blackwell.cmd
```

To install both WSL2/Ubuntu and Docker Desktop automatically, run the following
from an Administrator PowerShell and restart Windows if requested:

```powershell
.\install_blackwell_prereqs_admin.ps1
```

The first build downloads the pinned wheel and dependencies; Docker BuildKit
caches subsequent builds. With no arguments the command runs an actual small
SAEHD forward/backward step on GPU 0 and fails unless the TensorFlow wheel
reports CUDA 12.8+ and native `sm_120` kernels.

The image build also inspects the generated wheel with NVIDIA `cuobjdump` and
fails if its shared libraries contain no real `sm_120` cubin. This separates
native Blackwell code from a PTX-only build before the runtime GPU test begins.
Pass a DeepFaceLab command after the script name, for example:

```powershell
.\run_blackwell.cmd main.py --help
.\run_blackwell.cmd main.py train --help
```

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
