namespace AtomiCloud.DotnetBase.App.Adapters.Redis;

/// <summary>
/// Storage model for a note as persisted in Redis. Flat by design: the data layer
/// owns its own shape, kept separate from the domain
/// <see cref="AtomiCloud.DotnetBase.Lib.Note.NotePrincipal" />
/// so a storage-format change never reaches the domain.
/// </summary>
internal sealed record NoteData
{
    public required string Id { get; init; }

    public required string Title { get; init; }

    public required string Body { get; init; }
}
