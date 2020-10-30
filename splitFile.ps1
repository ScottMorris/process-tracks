[CmdletBinding()]
param (
	[Parameter(Mandatory=$true)][string]$timecodeFileName,
	[Parameter(Mandatory=$true)][string]$inputFile,
	[Parameter()][string]$album_artist,
	[Parameter()][string]$album,
	[Parameter()][string]$album_art,
	[Parameter()][string]$genre
)

function CheckIfDirectoryExistsAndCreateIfNot {
	param (
		$DirectoryToCreate
	)
	if (-not (Test-Path -LiteralPath $DirectoryToCreate)) {
    
		try {
			New-Item -Path $DirectoryToCreate -ItemType Directory -ErrorAction Stop | Out-Null #-Force
		}
		catch {
			Write-Error -Message "Unable to create directory '$DirectoryToCreate'. Error was: $_" -ErrorAction Stop
		}
		"Successfully created directory '$DirectoryToCreate'."
	}
	else {
		"Directory already existed"
	}
}

$trackNumberCount = 1

$inputFileInfo = Get-Item $inputFile
$inputFileDir = $inputFileInfo.DirectoryName
$inputFileExtention = $inputFileInfo.Extension.Replace(".", "")
$inFile = $inputFileInfo.FullName

$outputAlbumName = ![string]::IsNullOrWhiteSpace($album) ? $album : "splitOutput"
$outputBasePath = "$inputFileDir/$outputAlbumName"

CheckIfDirectoryExistsAndCreateIfNot($outputBasePath)

foreach($line in Get-Content $timecodeFileName) {
	$startTime = $line.Substring(0, 11)
	$endTime = $line.Substring(12, 11)

	$name = $line.Substring(23).Trim()
	$split = $name.Split("–")
	$title = ($split.Length -gt 1) ? $split[1].Trim() : $null ?? $split[0].Trim()
	$artist = ($split.Length -gt 1)  ? $split[0].Trim() : ""

	$currentTrack = $trackNumberCount++
	$outFile = "$outputBasePath/{0:d2} $name.$inputFileExtention" -f $currentTrack

	Write-Output "------"
	Write-Output "Title: $title Artist: $artist"
	Write-Output "Album Artist: $album_artist Album: $album"
	Write-Output "------"
   
	if (![string]::IsNullOrWhiteSpace($album_art)) {
		Write-Output "Album Art Not Implemented Yet, Please Remove this Parameter."
		exit -1
		##&ffmpeg -hide_banner -i "$inFile" -i $album_art -map 0:0 -map 1:0 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" -metadata title="$title" -metadata artist="$artist" -metadata album_artist="$album_artist" -metadata album="$album" -c copy -ss "$startTime" -to "$endTime" "$outFile"
	} else {
		&ffmpeg -hide_banner -i "$inFile" -metadata track="$currentTrack" -metadata title="$title" -metadata artist="$artist" -metadata album_artist="$album_artist" -metadata album="$album" -metadata genre="$genre" -c:a copy -ss "$startTime" -to "$endTime" "$outFile"
	}
}