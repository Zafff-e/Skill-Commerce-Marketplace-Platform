namespace SkillCommerce.Domain.Common;

/// <summary>
/// Guard clauses used throughout Domain to enforce preconditions.
/// All methods throw <see cref="ArgumentException"/> or <see cref="DomainException"/>.
/// </summary>
public static class Guard
{
    public static string NotNullOrWhiteSpace(string? value, string paramName)
    {
        if (string.IsNullOrWhiteSpace(value))
            throw new ArgumentException($"{paramName} must not be null or whitespace.", paramName);
        return value;
    }

    public static T NotNull<T>(T? value, string paramName) where T : class
    {
        if (value is null)
            throw new ArgumentNullException(paramName);
        return value;
    }

    public static decimal PositiveOrZero(decimal value, string paramName)
    {
        if (value < 0)
            throw new DomainException("guard.negative_amount", $"{paramName} must be >= 0. Got: {value}");
        return value;
    }

    public static int Between(int value, int min, int max, string paramName)
    {
        if (value < min || value > max)
            throw new DomainException("guard.out_of_range", $"{paramName} must be between {min} and {max}. Got: {value}");
        return value;
    }
}
