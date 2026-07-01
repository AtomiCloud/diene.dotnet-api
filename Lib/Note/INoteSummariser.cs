namespace AtomiCloud.DotnetBase.Lib.Note;

/// <summary>Produces a short, single-line preview of a note for listings.</summary>
public interface INoteSummariser
{
    /// <summary>
    /// Build a "Title — body" preview, trimmed to <paramref name="maxLength" />
    /// characters on a word boundary with a trailing ellipsis when truncated.
    /// </summary>
    string Summarise(NoteRecord record, int maxLength);
}
