# Stateless OOP with DI in C#/.NET

## Folder Structure

```text
{Service}.Domain/         # Pure class library
  User/
    UserRecord.cs
    User.cs
    IUserServiceLogger.cs
    IUserService.cs
    IUserRepository.cs
    UserService.cs

{Service}.App/            # ASP.NET/Console — DI wiring, adapters
  Adapters/
    MicrosoftLoggerAdapter.cs
  Repos/
    PostgresUserRepo.cs
  Controllers/
  Program.cs              # DI registration

{Service}.UnitTest/       # Unit + functional tests
{Service}.IntTest/        # Integration tests
```

## Structures (Records)

```csharp
// {Service}.Domain/User/UserRecord.cs
public record UserRecord
{
    public required string Name { get; init; }
    public required string Email { get; init; }
}

public record UserPrincipal
{
    public required string Id { get; init; }
    public required UserRecord Record { get; init; }
}
```

## Interfaces

```csharp
// {Service}.Domain/User/IUserRepository.cs
public interface IUserRepository
{
    Task<UserPrincipal?> FindById(string id);
    Task<UserPrincipal> Save(UserRecord record);
}

// {Service}.Domain/User/IUserServiceLogger.cs
// Domain-defined logger abstraction to avoid infrastructure dependency
public interface IUserServiceLogger
{
    void LogInformation(string message, params object?[] args);
}

// {Service}.Domain/User/IUserService.cs
public interface IUserService
{
    Task<UserPrincipal> Create(UserRecord record);
}
```

## Stateless Service

```csharp
// {Service}.Domain/User/UserService.cs
// Note: ILogger is a domain-defined abstraction, not Microsoft.Extensions.Logging
// This keeps the domain layer free of external infrastructure dependencies
public class UserService(IUserRepository repo, IUserServiceLogger logger) : IUserService
{
    public async Task<UserPrincipal> Create(UserRecord record)
    {
        logger.LogInformation("Creating user: {Name}", record.Name);
        return await repo.Save(record);
    }
}
```

## Adapter (App layer)

```csharp
// {Service}.App/Adapters/MicrosoftLoggerAdapter.cs
// Adapter that connects domain logger to infrastructure logging
public class MicrosoftLoggerAdapter(ILogger<UserService> logger) : IUserServiceLogger
{
    public void LogInformation(string message, params object?[] args) =>
        logger.LogInformation(message, args);
}
```

## DI Registration (App layer)

```csharp
// {Service}.App/Program.cs
// Wire domain logger to infrastructure logging implementation
builder.Services.AddScoped<IUserServiceLogger, MicrosoftLoggerAdapter>();
builder.Services.AddScoped<IUserRepository, PostgresUserRepo>();
builder.Services.AddScoped<IUserService, UserService>();
```

## Model (Complete Pattern)

```csharp
// {Service}.Domain/User/User.cs
// Full Model combining principal with related data
public record User
{
    public required UserPrincipal Principal { get; init; }
    // Add related principals here as needed for the Model view
}
```
