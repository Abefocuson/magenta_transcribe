function MakeDir {
    param($Dir)
    if (-not (Test-Path $Dir)) {
        mkdir -Path $Dir | Out-Null
    }
}

function UnpackUrl {
    param($Url,$File,$UnpackDir,$TestPath)
    if (-not $File) {
        $File = $Url.Substring($Url.LastIndexOf("/") + 1)
        $Output = "dist\downloads\$File"
    }
    if (-not $TestPath) {
        $TestPath = $UnpackDir
    }
    if (-not (Test-Path "$TestPath")) {
        Write-Host "UnpackUrl: $Url -> $UnpackDir"
        if (-not (Test-Path $Output)) {
            Import-Module BitsTransfer
            Start-BitsTransfer -Description "Downloading $File from $Url" -Source $Url -Destination $Output
        }
        switch ((Get-Item $Output).Extension) {
            '.zip' {
                $shell = New-Object -com shell.application
                $shell.Namespace([IO.Path]::Combine($pwd, $UnpackDir)).CopyHere($shell.Namespace([IO.Path]::Combine($pwd, $Output)).Items())
            }
            '.exe' {
                Start-Process $output -ArgumentList "/SILENT /NORESTART /DIR=$UnpackDir"
            }
        }
    }
}

MakeDir dist\downloads
MakeDir dist\MagentaTranscribe

UnpackUrl -Url https://storage.googleapis.com/magentadata/models/onsets_frames_transcription/maestro_checkpoint.zip -UnpackDir dist\MagentaTranscribe -TestPath dist\MagentaTranscribe\train

UnpackUrl -Url https://github.com/winpython/winpython/releases/download/1.11.20190223/Winpython64-3.6.8.0Zero.exe -UnpackDir dist\MagentaTranscribe -TestPath dist\MagentaTranscribe\settings

if (-not (Test-Path dist\MagentaTranscribe\settings)) {
    Write-Host
    Read-Host "Wait for WinPython install finish, and press enter to continue"
}

UnpackUrl -Url https://cfhcable.dl.sourceforge.net/project/sox/sox/14.4.2/sox-14.4.2-win32.zip -UnpackDir dist -TestPath dist\MagentaTranscribe\python-3.6.8.amd64\Scripts\sox.exe
if (Test-Path dist\sox-14.4.2) {
    mv dist\sox-14.4.2\*.exe, dist\sox-14.4.2\*.dll dist\MagentaTranscribe\python-3.6.8.amd64\Scripts
    rm -r dist\sox-14.4.2
}

if (-not (Test-Path dist\MagentaTranscribe\python-3.6.8.amd64\Scripts\onsets_frames_transcription_transcribe.exe)) {
    & dist\MagentaTranscribe\scripts\python.bat -m pip install magenta
}
cp README.md dist\MagentaTranscribe\README.txt
cp Transcribe.bat dist\MagentaTranscribe
cp transcribe.py dist\MagentaTranscribe\python-3.6.8.amd64\Scripts

rm -ErrorAction Ignore "dist\MagentaTranscribe\IPython Qt Console.exe", "dist\MagentaTranscribe\DLE (Python GUI).exe", "dist\MagentaTranscribe\IDLEX.exe", "dist\MagentaTranscribe\Jupyter Lab.exe", "dist\MagentaTranscribe\Jupyter Notebook.exe", "dist\MagentaTranscribe\Pyzo.exe", "dist\MagentaTranscribe\Qt Designer.exe", "dist\MagentaTranscribe\Qt Linguist.exe", "dist\MagentaTranscribe\Spyder.exe", "dist\MagentaTranscribe\Spyder reset.exe", "dist\MagentaTranscribe\WinPython Control Panel.exe", "dist\MagentaTranscribe\unins000.exe", "dist\MagentaTranscribe\unins000.dat"
rm -r -ErrorAction Ignore dist\MagentaTranscribe\notebooks, dist\MagentaTranscribe\t, dist\MagentaTranscribe\settings\.spyder-py3

if (-not (Test-Path dist\MagentaTranscribe.zip)) {
    Add-Type -assembly "system.io.compression.filesystem"
    [IO.Compression.ZipFile]::CreateFromDirectory([IO.Path]::Combine($pwd, "dist\MagentaTranscribe"), [IO.Path]::Combine($pwd, "dist\MagentaTranscribe.zip"))
}

Read-Host "Done, press enter to exit"