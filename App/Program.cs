using AtomiCloud.DotnetBase.App.Adapters.Redis;
using AtomiCloud.DotnetBase.Lib.Note;
using StackExchange.Redis;

namespace AtomiCloud.DotnetBase.App;

/// <summary>
/// Composition root for the base sample. It wires the concrete adapters behind their
/// domain interfaces and exercises one note round trip. A production service would
/// register these with a DI container; the sample keeps the graph explicit so the
/// wiring stays obvious.
/// </summary>
public static class Program
{
    public static async Task Main()
    {
        var connectionString = Environment.GetEnvironmentVariable("REDIS_CONNECTION");
        if (string.IsNullOrWhiteSpace(connectionString)) connectionString = "localhost:6379";

        INoteSummariser summariser = new NoteSummariser();
        await using var redis = await ConnectionMultiplexer.ConnectAsync(connectionString);
        INoteRepository notes = new RedisNoteRepository(redis);

        var saved = await notes.Save(new NoteRecord
        {
            Title = "Welcome",
            Body = "The first note stored through the Redis adapter.",
        });
        var found = await notes.Find(saved.Id);

        Console.WriteLine(found is null
            ? $"Note {saved.Id} could not be read back."
            : summariser.Summarise(found.Record, 80));
    }
}
