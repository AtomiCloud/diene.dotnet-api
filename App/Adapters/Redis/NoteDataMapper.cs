using AtomiCloud.DotnetBase.Lib.Note;

namespace AtomiCloud.DotnetBase.App.Adapters.Redis;

/// <summary>
/// Pure Data ↔ Domain mappers for notes. Keeps the Redis storage shape
/// (<see cref="NoteData" />) isolated from the domain <see cref="NotePrincipal" />.
/// </summary>
internal static class NoteDataMapper
{
    public static NoteData ToData(this NotePrincipal principal) => new()
    {
        Id = principal.Id,
        Title = principal.Record.Title,
        Body = principal.Record.Body,
    };

    public static NotePrincipal ToDomain(this NoteData data) => new()
    {
        Id = data.Id,
        Record = new NoteRecord { Title = data.Title, Body = data.Body },
    };
}
