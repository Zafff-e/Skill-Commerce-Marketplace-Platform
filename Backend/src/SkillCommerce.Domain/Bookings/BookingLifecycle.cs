namespace SkillCommerce.Domain.Bookings;

public static class BookingLifecycle
{
    public const string StatusRequested = "REQUESTED";
    public const string StatusAccepted = "ACCEPTED";
    public const string StatusEnRoute = "EN_ROUTE";
    public const string StatusOnTheWay = "ON_THE_WAY";
    public const string StatusArrived = "ARRIVED";
    public const string StatusInProgress = "IN_PROGRESS";
    public const string StatusCompleted = "COMPLETED";
    public const string StatusCancelled = "CANCELLED";

    private static readonly Dictionary<string, HashSet<string>> AllowedTransitions = new(StringComparer.OrdinalIgnoreCase)
    {
        [StatusRequested] = new(StringComparer.OrdinalIgnoreCase) { StatusAccepted, StatusEnRoute, StatusOnTheWay, StatusCancelled },
        [StatusAccepted] = new(StringComparer.OrdinalIgnoreCase) { StatusEnRoute, StatusOnTheWay, StatusCancelled },
        [StatusEnRoute] = new(StringComparer.OrdinalIgnoreCase) { StatusArrived, StatusCancelled },
        [StatusOnTheWay] = new(StringComparer.OrdinalIgnoreCase) { StatusArrived, StatusCancelled },
        [StatusArrived] = new(StringComparer.OrdinalIgnoreCase) { StatusInProgress, StatusCancelled },
        [StatusInProgress] = new(StringComparer.OrdinalIgnoreCase) { StatusCompleted, StatusCancelled },
        [StatusCompleted] = new HashSet<string>(StringComparer.OrdinalIgnoreCase), // Terminal state
        [StatusCancelled] = new HashSet<string>(StringComparer.OrdinalIgnoreCase)  // Terminal state
    };

    public static bool CanTransition(string currentStatus, string nextStatus)
    {
        if (string.IsNullOrWhiteSpace(currentStatus) || string.IsNullOrWhiteSpace(nextStatus))
            return false;

        var normalizedCurrent = currentStatus.Trim().ToUpperInvariant();
        var normalizedNext = nextStatus.Trim().ToUpperInvariant();

        if (normalizedCurrent == normalizedNext)
            return true;

        if (AllowedTransitions.TryGetValue(normalizedCurrent, out var allowed))
        {
            return allowed.Contains(normalizedNext);
        }

        return false;
    }

    public static bool IsTerminal(string status)
    {
        if (string.IsNullOrWhiteSpace(status)) return false;
        var s = status.Trim().ToUpperInvariant();
        return s == StatusCompleted || s == StatusCancelled;
    }
}
