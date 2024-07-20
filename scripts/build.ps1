# Define the paths
$projectDir = (Get-Location).Path
$distDir = "$projectDir\lambda\dist"
$zipFile = "$projectDir\lambda\function.zip"

# Ensure the dist directory exists and is not locked
if (Test-Path $distDir) {
  Remove-Item -Recurse -Force $distDir
}
New-Item -ItemType Directory -Path $distDir

cd lambda

# Install node modules
yarn install

# Build the app
yarn run build
cd ..

# Copy necessary files to the dist directory
Copy-Item "$projectDir\lambda\src\index.ts" -Destination $distDir
Copy-Item "$projectDir\lambda\package.json" -Destination $distDir

# Copy node_modules to the dist directory
Copy-Item "$projectDir\lambda\node_modules" -Destination $distDir -Recurse

# Ensure the zip file is not in use and delete if it exists
if (Test-Path $zipFile) {
    try {
        Remove-Item $zipFile -Force -ErrorAction Stop
    } catch {
        Write-Error "Failed to delete zipFile"
        exit 1
    }
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
try {
    [System.IO.Compression.ZipFile]::CreateFromDirectory($distDir, $zipFile)
} catch {
    Write-Error "Failed to create zip file: $_"
    exit 1
}

Write-Host "Build and zip process completed successfully."