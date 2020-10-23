# Running

## C#
```bash
$ dotnet run -- -v -t <path-to-tracklist> -l <length-of-track-in-hh:mm:ss.ff-format>
```

## PowerShell

```powershell
PS> ./splitFile.ps1 -timecodeFileName ./timecodes.txt -inputFile "<path-to-audio-file>" -album_artist "<artist-name>" -album "<album-name>"
```