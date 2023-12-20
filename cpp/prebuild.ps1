$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

Get-ChildItem -Path "$scriptDir\x64\Debug" -Recurse | ForEach-Object {Remove-Item $_.FullName -Force -Confirm:$false}

rustup target add x86_64-pc-windows-msvc

Push-Location $scriptDir/../vlf_import
cargo build --release
Copy-Item "target\release\vlf_import.exe" -Destination "$scriptDir\x64\Debug\vlf_import.exe"
Pop-Location

Push-Location $scriptDir/../govarnam
.\windows-build.bat
gendef libgovarnam.dll
lib /def:libgovarnam.def /OUT:libgovarnam.lib /MACHINE:X64
Copy-Item "libgovarnam.dll" -Destination "$scriptDir\x64\Debug\libgovarnam.dll"
Copy-Item "libgovarnam.lib" -Destination "$scriptDir\x64\Debug\libgovarnam.lib"
Copy-Item -Path "schemes" -Destination "$scriptDir\x64\Debug" -Recurse
New-Item -ItemType Directory -Path "$scriptDir\x64\Debug\schemes\learnings"
New-Item -ItemType Directory -Path "$scriptDir\x64\Debug\schemes\vst"
New-Item -ItemType Directory -Path "$scriptDir\x64\Debug\schemes\vlf"
Get-ChildItem "$scriptDir\x64\Debug\schemes" -Filter *.vst -Recurse | Copy-Item -Destination "$scriptDir\x64\Debug\schemes\vst"
Get-ChildItem "$scriptDir\x64\Debug\schemes" -Filter *.vlf -Recurse | Copy-Item -Destination "$scriptDir\x64\Debug\schemes\vlf"
Get-ChildItem "$scriptDir\x64\Debug\schemes" -Recurse | Where-Object { $_.PSIsContainer -and $_.Name -notmatch '^(vst|learnings|vlf)$' } | Remove-Item -Recurse -Force
Get-ChildItem "$scriptDir\x64\Debug\schemes" -File | Remove-Item -Force
& "$scriptDir\x64\Debug\vlf_import.exe" "$scriptDir\x64\Debug\schemes"
New-Item -Path "$scriptDir\x64\Debug\debug.txt"
Pop-Location

Push-Location $scriptDir/../rust
cargo build --release --target=x86_64-pc-windows-msvc
cbindgen --crate composition_processor --output ../cpp/SampleIME/cbindgen/composition_processor.h
cbindgen --crate input_processor --output ../cpp/SampleIME/cbindgen/input_processor.h
cbindgen --crate itf_components --output ../cpp/SampleIME/cbindgen/itf_components.h
cbindgen --crate globals --output ../cpp/SampleIME/cbindgen/globals.h
cbindgen --crate ime --output ../cpp/SampleIME/cbindgen/ime.h
cbindgen --crate numberkey_windows --output ../cpp/SampleIME/cbindgen/numberkey_windows.h
cbindgen --crate ruststringrange --output ../cpp/SampleIME/cbindgen/ruststringrange.h
cbindgen --crate govarnam --output ../cpp/SampleIME/cbindgen/govarnam.h
Pop-Location
