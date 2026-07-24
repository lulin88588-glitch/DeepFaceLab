param(
    [string] $OutputDirectory = ''
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $repoRoot 'assets'
}
[IO.Directory]::CreateDirectory($OutputDirectory) | Out-Null

function New-RoundedRectanglePath(
    [single] $X, [single] $Y, [single] $Width, [single] $Height,
    [single] $Radius
) {
    $path = New-Object Drawing.Drawing2D.GraphicsPath
    $diameter = $Radius * 2
    $path.AddArc($X, $Y, $diameter, $diameter, 180, 90)
    $path.AddArc($X + $Width - $diameter, $Y, $diameter, $diameter, 270, 90)
    $path.AddArc(
        $X + $Width - $diameter, $Y + $Height - $diameter,
        $diameter, $diameter, 0, 90)
    $path.AddArc($X, $Y + $Height - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    return $path
}

function New-IconBitmap([int] $Size, [string] $Kind) {
    $bitmap = New-Object Drawing.Bitmap(
        $Size, $Size, [Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.CompositingQuality =
        [Drawing.Drawing2D.CompositingQuality]::HighQuality
    $graphics.Clear([Drawing.Color]::Transparent)
    $scale = [single]$Size / 256.0
    $graphics.ScaleTransform($scale, $scale)

    $backgroundPath = New-RoundedRectanglePath 10 10 236 236 48
    $backgroundBrush = New-Object Drawing.Drawing2D.LinearGradientBrush(
        (New-Object Drawing.PointF(24, 18)),
        (New-Object Drawing.PointF(230, 238)),
        [Drawing.Color]::FromArgb(255, 21, 29, 42),
        [Drawing.Color]::FromArgb(255, 7, 11, 18))
    $graphics.FillPath($backgroundBrush, $backgroundPath)

    if ($Kind -eq 'console') {
        $accent = [Drawing.Color]::FromArgb(255, 75, 141, 248)
        $cyan = [Drawing.Color]::FromArgb(255, 64, 210, 255)
        $panelBrush = New-Object Drawing.SolidBrush(
            [Drawing.Color]::FromArgb(255, 29, 43, 64))
        $accentBrush = New-Object Drawing.SolidBrush($accent)
        $cyanBrush = New-Object Drawing.SolidBrush($cyan)
        $whiteBrush = New-Object Drawing.SolidBrush(
            [Drawing.Color]::FromArgb(235, 244, 248, 255))

        $panel = New-RoundedRectanglePath 42 47 172 162 24
        $graphics.FillPath($panelBrush, $panel)
        $graphics.FillRectangle($accentBrush, 42, 47, 172, 35)
        $graphics.FillEllipse($whiteBrush, 58, 60, 8, 8)
        $graphics.FillEllipse($whiteBrush, 73, 60, 8, 8)
        $graphics.FillEllipse($whiteBrush, 88, 60, 8, 8)
        $graphics.FillRectangle($accentBrush, 60, 105, 42, 34)
        $graphics.FillRectangle($cyanBrush, 115, 105, 79, 14)
        $graphics.FillRectangle($whiteBrush, 115, 126, 58, 10)
        $graphics.FillRectangle($cyanBrush, 60, 153, 42, 34)
        $graphics.FillRectangle($whiteBrush, 115, 153, 79, 10)
        $graphics.FillRectangle($accentBrush, 115, 174, 64, 10)

        $panel.Dispose()
        $panelBrush.Dispose()
        $accentBrush.Dispose()
        $cyanBrush.Dispose()
        $whiteBrush.Dispose()
    }
    else {
        $purple = [Drawing.Color]::FromArgb(255, 157, 103, 255)
        $cyan = [Drawing.Color]::FromArgb(255, 55, 215, 246)
        $softWhite = [Drawing.Color]::FromArgb(240, 246, 248, 255)
        $faceBrush = New-Object Drawing.SolidBrush(
            [Drawing.Color]::FromArgb(255, 46, 35, 78))
        $purplePen = New-Object Drawing.Pen($purple, 14)
        $purplePen.StartCap = [Drawing.Drawing2D.LineCap]::Round
        $purplePen.EndCap = [Drawing.Drawing2D.LineCap]::Round
        $cyanPen = New-Object Drawing.Pen($cyan, 18)
        $cyanPen.StartCap = [Drawing.Drawing2D.LineCap]::Round
        $cyanPen.EndCap = [Drawing.Drawing2D.LineCap]::Round
        $whiteBrush = New-Object Drawing.SolidBrush($softWhite)
        $cyanBrush = New-Object Drawing.SolidBrush($cyan)

        $graphics.FillEllipse($faceBrush, 39, 48, 132, 158)
        $graphics.DrawArc($purplePen, 50, 57, 111, 136, 32, 296)
        $graphics.FillEllipse($whiteBrush, 78, 105, 15, 15)
        $graphics.FillEllipse($whiteBrush, 119, 105, 15, 15)
        $graphics.DrawArc($purplePen, 83, 123, 47, 42, 20, 140)
        $graphics.DrawLine($cyanPen, 157, 128, 209, 128)
        $graphics.DrawLine($cyanPen, 190, 105, 214, 128)
        $graphics.DrawLine($cyanPen, 190, 151, 214, 128)
        $graphics.FillEllipse($cyanBrush, 148, 119, 18, 18)

        $faceBrush.Dispose()
        $purplePen.Dispose()
        $cyanPen.Dispose()
        $whiteBrush.Dispose()
        $cyanBrush.Dispose()
    }

    $backgroundBrush.Dispose()
    $backgroundPath.Dispose()
    $graphics.Dispose()
    return $bitmap
}

function Convert-BitmapToIconDib([Drawing.Bitmap] $Bitmap) {
    $width = $Bitmap.Width
    $height = $Bitmap.Height
    $maskRowBytes = [int]([Math]::Ceiling($width / 32.0) * 4)
    $stream = New-Object IO.MemoryStream
    $writer = New-Object IO.BinaryWriter($stream)
    try {
        # BITMAPINFOHEADER. ICO stores the XOR bitmap followed by the AND
        # transparency mask, so the declared height is doubled.
        $writer.Write([uint32]40)
        $writer.Write([int32]$width)
        $writer.Write([int32]($height * 2))
        $writer.Write([uint16]1)
        $writer.Write([uint16]32)
        $writer.Write([uint32]0)
        $writer.Write([uint32]($width * $height * 4))
        $writer.Write([int32]0)
        $writer.Write([int32]0)
        $writer.Write([uint32]0)
        $writer.Write([uint32]0)

        # BGRA pixels, bottom row first.
        for ($y = $height - 1; $y -ge 0; $y--) {
            for ($x = 0; $x -lt $width; $x++) {
                $color = $Bitmap.GetPixel($x, $y)
                $writer.Write([byte]$color.B)
                $writer.Write([byte]$color.G)
                $writer.Write([byte]$color.R)
                $writer.Write([byte]$color.A)
            }
        }

        # 1-bit AND mask, also bottom-up and padded to a 32-bit row boundary.
        for ($y = $height - 1; $y -ge 0; $y--) {
            $mask = New-Object byte[] $maskRowBytes
            for ($x = 0; $x -lt $width; $x++) {
                if ($Bitmap.GetPixel($x, $y).A -eq 0) {
                    $byteIndex = [int][Math]::Floor($x / 8.0)
                    $bit = 7 - ($x % 8)
                    $mask[$byteIndex] = $mask[$byteIndex] -bor (1 -shl $bit)
                }
            }
            $writer.Write([byte[]]$mask)
        }
        return $stream.ToArray()
    }
    finally {
        $writer.Dispose()
        $stream.Dispose()
    }
}

function Write-MultiSizeIcon([string] $Path, [string] $Kind) {
    $sizes = @(16, 24, 32, 48, 64, 128, 256)
    $images = New-Object Collections.Generic.List[object]
    foreach ($size in $sizes) {
        $bitmap = New-IconBitmap $size $Kind
        $images.Add([pscustomobject]@{
            Size = $size
            Bytes = Convert-BitmapToIconDib $bitmap
        })
        $bitmap.Dispose()
    }

    $file = [IO.File]::Open(
        $Path, [IO.FileMode]::Create, [IO.FileAccess]::Write,
        [IO.FileShare]::None)
    $writer = New-Object IO.BinaryWriter($file)
    try {
        $writer.Write([uint16]0)
        $writer.Write([uint16]1)
        $writer.Write([uint16]$images.Count)
        $offset = 6 + (16 * $images.Count)
        foreach ($image in $images) {
            $dimension = if ($image.Size -eq 256) { 0 } else { $image.Size }
            $writer.Write([byte]$dimension)
            $writer.Write([byte]$dimension)
            $writer.Write([byte]0)
            $writer.Write([byte]0)
            $writer.Write([uint16]1)
            $writer.Write([uint16]32)
            $writer.Write([uint32]$image.Bytes.Length)
            $writer.Write([uint32]$offset)
            $offset += $image.Bytes.Length
        }
        foreach ($image in $images) {
            $writer.Write([byte[]]$image.Bytes)
        }
    }
    finally {
        $writer.Dispose()
        $file.Dispose()
    }
}

Write-MultiSizeIcon (Join-Path $OutputDirectory 'dfl-console.ico') 'console'
Write-MultiSizeIcon (Join-Path $OutputDirectory 'dfl-oneclick.ico') 'oneclick'
Write-Host "GUI icons written to $OutputDirectory"
