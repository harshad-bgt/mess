Add-Type -AssemblyName System.Drawing

function Draw-AppIcon([int]$size, [string]$outputPath) {
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

    # Background: Forest green rounded rectangle / circle
    $bgColor = [System.Drawing.Color]::FromArgb(255, 0x14, 0x53, 0x2D)
    $bgBrush = New-Object System.Drawing.SolidBrush($bgColor)
    $g.FillEllipse($bgBrush, 0, 0, $size, $size)

    # Outer decorative ring
    $ringColor = [System.Drawing.Color]::FromArgb(60, 0x22, 0xC5, 0x5E)
    $ringPen = New-Object System.Drawing.Pen($ringColor, ($size * 0.04))
    $g.DrawEllipse($ringPen, ($size * 0.06), ($size * 0.06), ($size * 0.88), ($size * 0.88))

    # Center Plate (White circle)
    $plateColor = [System.Drawing.Color]::FromArgb(255, 255, 255, 255)
    $plateBrush = New-Object System.Drawing.SolidBrush($plateColor)
    $plateMargin = $size * 0.22
    $plateSize = $size - ($plateMargin * 2)
    $g.FillEllipse($plateBrush, $plateMargin, $plateMargin, $plateSize, $plateSize)

    # Plate Inner Rim (Soft off-white / light green)
    $innerRimColor = [System.Drawing.Color]::FromArgb(255, 0xDC, 0xFC, 0xE7)
    $innerRimBrush = New-Object System.Drawing.SolidBrush($innerRimColor)
    $innerMargin = $size * 0.28
    $innerSize = $size - ($innerMargin * 2)
    $g.FillEllipse($innerRimBrush, $innerMargin, $innerMargin, $innerSize, $innerSize)

    # Left: Fork
    $cutleryColor = [System.Drawing.Color]::FromArgb(255, 0x14, 0x53, 0x2D)
    $cutleryPen = New-Object System.Drawing.Pen($cutleryColor, [Math]::Max(2, ($size * 0.025)))
    $cutleryPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $cutleryPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

    $forkX = $size * 0.15
    # Fork handle
    $g.DrawLine($cutleryPen, $forkX, ($size * 0.42), $forkX, ($size * 0.72))
    # Fork head
    $g.DrawLine($cutleryPen, ($forkX - $size * 0.035), ($size * 0.32), ($forkX - $size * 0.035), ($size * 0.42))
    $g.DrawLine($cutleryPen, $forkX, ($size * 0.30), $forkX, ($size * 0.42))
    $g.DrawLine($cutleryPen, ($forkX + $size * 0.035), ($size * 0.32), ($forkX + $size * 0.035), ($size * 0.42))
    $g.DrawLine($cutleryPen, ($forkX - $size * 0.035), ($size * 0.42), ($forkX + $size * 0.035), ($size * 0.42))

    # Right: Spoon
    $spoonX = $size * 0.85
    # Spoon handle
    $g.DrawLine($cutleryPen, $spoonX, ($size * 0.44), $spoonX, ($size * 0.72))
    # Spoon bowl
    $cutleryBrush = New-Object System.Drawing.SolidBrush($cutleryColor)
    $g.FillEllipse($cutleryBrush, ($spoonX - $size * 0.035), ($size * 0.30), ($size * 0.07), ($size * 0.15))

    # Center: Vibrant Fresh Green Checkmark (Meal Tracking)
    $checkColor = [System.Drawing.Color]::FromArgb(255, 0x22, 0xC5, 0x5E)
    $checkPen = New-Object System.Drawing.Pen($checkColor, [Math]::Max(3, ($size * 0.065)))
    $checkPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $checkPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $checkPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

    $p1 = New-Object System.Drawing.PointF(($size * 0.40), ($size * 0.50))
    $p2 = New-Object System.Drawing.PointF(($size * 0.48), ($size * 0.59))
    $p3 = New-Object System.Drawing.PointF(($size * 0.62), ($size * 0.42))

    $g.DrawLine($checkPen, $p1, $p2)
    $g.DrawLine($checkPen, $p2, $p3)

    $dir = [System.IO.Path]::GetDirectoryName($outputPath)
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    $bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Output "Generated: $outputPath ($sizex$size)"
}

Draw-AppIcon 512 "D:\mess\assets\icons\app_logo.png"
Draw-AppIcon 512 "D:\mess\assets\images\splash_logo.png"
Draw-AppIcon 48  "D:\mess\android\app\src\main\res\mipmap-mdpi\ic_launcher.png"
Draw-AppIcon 72  "D:\mess\android\app\src\main\res\mipmap-hdpi\ic_launcher.png"
Draw-AppIcon 96  "D:\mess\android\app\src\main\res\mipmap-xhdpi\ic_launcher.png"
Draw-AppIcon 144 "D:\mess\android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png"
Draw-AppIcon 192 "D:\mess\android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png"
