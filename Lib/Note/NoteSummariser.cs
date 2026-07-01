namespace AtomiCloud.DotnetBase.Lib.Note;

/// <summary>
/// Pure, deterministic <see cref="INoteSummariser" />. Collapses internal whitespace,
/// joins the non-empty title and body with an em dash, and truncates on a word boundary.
/// Holds no state and performs no IO, so it is unit-testable in isolation.
/// </summary>
/// <remarks>
/// Truncation is separator-aware: because the two parts are joined with exactly one
/// known separator, its offset is computed rather than guessed from the collapsed text.
/// This lets the clip distinguish the join separator from a content em dash that merely
/// looks like one. When the clip lands before any real body content survives, the body
/// and its separator are dropped so the preview reads as the title alone; a content em
/// dash inside a single field is preserved, never mistaken for the separator.
/// </remarks>
public class NoteSummariser : INoteSummariser
{
    private const string Ellipsis = "…";
    private const string Separator = " — ";

    public string Summarise(NoteRecord record, int maxLength)
    {
        ArgumentOutOfRangeException.ThrowIfNegativeOrZero(maxLength);

        // Collapse each part's whitespace and drop empty parts, so a missing title or
        // body never leaves a dangling separator (e.g. "Title —", "— Body", or "—").
        var parts = new[] { record.Title, record.Body }
            .Select(part => string.Join(
                ' ',
                part.Split((char[]?)null, StringSplitOptions.RemoveEmptyEntries)))
            .Where(part => part.Length > 0)
            .ToArray();

        var collapsed = string.Join(Separator, parts);
        if (collapsed.Length <= maxLength) return collapsed;

        // Reserve room for the ellipsis so the result never exceeds maxLength.
        var budget = maxLength - Ellipsis.Length;
        var window = collapsed[..budget];
        var lastSpace = window.LastIndexOf(' ');
        var clipped = (lastSpace > 0 ? window[..lastSpace] : window).TrimEnd();

        // Slicing is by UTF-16 code unit, so the budget can land between the two halves of
        // an astral-plane character's surrogate pair (e.g. an emoji). Drop the orphaned high
        // surrogate so the preview is never structurally invalid Unicode; the whole pair is
        // kept when it fits and clipped together when it does not.
        if (clipped.Length > 0 && char.IsHighSurrogate(clipped[^1]))
            clipped = clipped[..^1].TrimEnd();

        // With both parts present the join separator sits at exactly parts[0].Length, so
        // its em dash is known by position — string matching alone cannot tell it from a
        // content em dash. If the clip ran past the title but the only body characters to
        // survive are separator-like punctuation (e.g. the body's own leading em dash),
        // drop the body and its separator and keep the title; otherwise the clip already
        // ends on real body content and the separator is legitimately followed by text.
        if (parts.Length == 2 && clipped.Length > parts[0].Length)
        {
            var bodyStart = parts[0].Length + Separator.Length;
            var survivingBody = clipped.Length > bodyStart ? clipped[bodyStart..] : string.Empty;
            if (survivingBody.All(c => c is '—' or ' '))
                clipped = parts[0];
        }

        return clipped + Ellipsis;
    }
}
