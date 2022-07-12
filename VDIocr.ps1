function Get-ScreenCapture
{

    begin {
        Add-Type -AssemblyName System.Drawing
        $jpegCodec = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
            Where-Object { $_.FormatDescription -eq "JPEG" }
    }
    process {
        Start-Sleep -Milliseconds 250
            $viewProc = Get-Process -Name 'vmware-view'
            
            [void] [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
            [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
            [Microsoft.VisualBasic.Interaction]::AppActivate($viewProc.MainWindowTitle)
            [Windows.Forms.Sendkeys]::SendWait("%{PrtSc}")

        Start-Sleep -Milliseconds 250
        $bitmap = [Windows.Forms.Clipboard]::GetImage()
        $ep = New-Object Drawing.Imaging.EncoderParameters
        $ep.Param[0] = New-Object Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality, [long]100)
        $screenCapturePathBase = "$HOME\ScreenCapture"
        $c = 0
        while (Test-Path "${screenCapturePathBase}${c}.jpg") {
            $c++
        }
        $bitmap.Save("${screenCapturePathBase}${c}.jpg", $jpegCodec, $ep)
    }
}
Get-ScreenCapture

Install-Module -Name PsOcr -Scope CurrentUser
(Convert-PsoImageToText -Path $HOME\ScreenCapture0.jpg -Language en-US).text

rm $HOME\ScreenCapture0.jpg
