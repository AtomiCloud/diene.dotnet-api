namespace AtomiCloud.DotnetBase.Lib.Note;

/// <summary>
/// Persistence boundary for notes. The domain owns this contract; concrete
/// adapters live in the App layer (see <c>App/Adapters/Redis</c>).
/// </summary>
public interface INoteRepository
{
    /// <summary>Persist a note and return it with its newly assigned identity.</summary>
    Task<NotePrincipal> Save(NoteRecord record, CancellationToken cancellationToken = default);

    /// <summary>Look up a note by id, or <c>null</c> when it does not exist.</summary>
    Task<NotePrincipal?> Find(string id, CancellationToken cancellationToken = default);
}
