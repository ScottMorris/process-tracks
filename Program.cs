using System;
using System.IO;
using System.Linq;
using CommandLine;

namespace process_tracks
{
    public class Options
    {
        internal const string DefaultOutputName = "timecodes.txt";

        [Option('v', "verbose", Required = false, HelpText = "Set output to verbose messages.")]
        public bool Verbose { get; set; }

        [Option('t', "tracklist", Required = true, HelpText = "Tracklist to parse.")]
        public string TracklistFilePath { get; set; }

        [Option('l', "track-length", Required = true, HelpText = "Length of track in hh:mm:ss.ff format.")]
        public string TrackLength { get; set; }

        [Option('o', "output", Required = false, HelpText = "Output File", Default = DefaultOutputName)]
        public string OutputFileName { get; set; }

        [Option('d', "dry-run", Required = false, HelpText = "Perform a dry-run", Default = false)]
        public bool doDryRun { get; set; }
    }

    class Program
    {
        static Options Options;
        static void Main(string[] args)
        {
            Parser.Default.ParseArguments<Options>(args)
                .WithParsed<Options>(o =>
                {
                    Options = o;
                    ProcessTacklist(o.TracklistFilePath, o.TrackLength, o.OutputFileName);
                });
        }

        static void ProcessTacklist(string tracklistFilePath, string trackLength, string outputFile)
        {
            FileInfo inputFileInfo = new FileInfo(tracklistFilePath);
            var baseInputPath = inputFileInfo?.DirectoryName;
            Log($"Processing: {inputFileInfo.Name}");
            var file = File.ReadAllLines(inputFileInfo.FullName);

            var trackTimes = file.Select(x => new
            {
                TimeCode = "0" + string.Join("", x.Take(7)).Trim() + ".00",
                Name = string.Join("", x.Skip(7)).Trim()
            })
                .ToList();

            Log($"Generating Timecodes");
            var trackTimeCodesWithNames = trackTimes.Select((x, i) => $"{x.TimeCode} {trackTimes.ElementAtOrDefault(i + 1)?.TimeCode ?? trackLength} {x.Name}");

            var outputFileFileInfo = new FileInfo(outputFile);
            var outputFileFullName = outputFileFileInfo.DirectoryName == baseInputPath ? outputFileFileInfo.FullName : outputFile;
            string contents = string.Join("\n", trackTimeCodesWithNames);

            if (Options.doDryRun)
            {
                Console.WriteLine("Output File Contents");
				Console.WriteLine("---------");
				Console.WriteLine(contents);
            }
            else
            {
                Log($"Writing: {outputFileFileInfo.Name}");
                File.WriteAllText(outputFileFullName, contents);
            }
        }

        static void Log(string message)
        {
            if (Options.Verbose)
            {
                Console.WriteLine(message);
            }
        }
    }
}
