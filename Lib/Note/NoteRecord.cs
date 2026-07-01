namespace AtomiCloud.DotnetBase.Lib.Note;

/// <summary>The content of a note, without identity. Immutable by construction.</summary>
public record NoteRecord
{
    public required string Title { get; init; }

    public required string Body { get; init; }
}
