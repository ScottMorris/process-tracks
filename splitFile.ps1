[CmdletBinding()]
param (
	[Parameter(Mandatory=$true)][string]$timecodeFileName,
	[Parameter(Mandatory=$true)][string]$inputFile,
	[Parameter()][string]$album_artist,
	[Parameter()][string]$album,
	[Parameter()][string]$album_art
	
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
foreach($line in Get-Content $timecodeFileName) {
	$inputFileInfo = Get-Item $inputFile
	$inputFileDir = $inputFileInfo.DirectoryName
	$startTime = $line.Substring(0, 11)
	$endTime = $line.Substring(12, 11)
	$name = $line.Substring(23).Trim()
	$split = $name.Split("–")
	$title = ($split.Length -gt 1) ? $split[1].Trim() : $null ?? $split[0].Trim()
	$artist = ($split.Length -gt 1)  ? $split[0].Trim() : ""
	$outputAlbumName = ![string]::IsNullOrWhiteSpace($album) ? $album : "splitOutput"
	$outputBasePath = "$inputFileDir/$outputAlbumName"
	$inputFileExtention = $inputFileInfo.Extension.Replace(".", "")
	$currentTrack = $trackNumberCount++
	$outFile = "$outputBasePath/{0:d2} $name.$inputFileExtention" -f $currentTrack
	$inFile = $inputFileInfo.FullName

	Write-Output "Title: $title Artist: $artist"
	Write-Output "Album Artist: $album_artist Album: $album"
   
	CheckIfDirectoryExistsAndCreateIfNot($outputBasePath)

	if (![string]::IsNullOrWhiteSpace($album_art)) {
		Write-Output "Album Art Not Implemented Yet"
		##&ffmpeg -hide_banner -i "$inFile" -i $album_art -map 0:0 -map 1:0 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" -metadata title="$title" -metadata artist="$artist" -metadata album_artist="$album_artist" -metadata album="$album" -c copy -ss "$startTime" -to "$endTime" "$outFile"
	} else {
		&ffmpeg -hide_banner -i "$inFile" -metadata track="$currentTrack" -metadata title="$title" -metadata artist="$artist" -metadata album_artist="$album_artist" -metadata album="$album" -c:a copy -ss "$startTime" -to "$endTime" "$outFile"
	}
}