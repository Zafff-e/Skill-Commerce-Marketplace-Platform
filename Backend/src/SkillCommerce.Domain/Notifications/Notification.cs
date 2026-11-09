using SkillCommerce.Domain.Common;
using SkillCommerce.Domain.Enums;

namespace SkillCommerce.Domain.Notifications;

/// <summary>
/// Persisted in-app notification for offline and event audit tracking.
/// </summary>
public sealed class Notification : AuditableEntity
{
    public int Id { get; private set; }
    public string UserId { get; private set; } = string.Empty;
    public NotificationType Type { get; private set; }
    public string PayloadJson { get; private set; } = "{}";
    public bool IsRead { get; private set; }

    // For EF Core
    private Notification() { }

    public static Notification Create(string userId, NotificationType type, string payloadJson)
    {
        return new Notification
        {
            UserId = Guard.NotNullOrWhiteSpace(userId, nameof(userId)),
            Type = type,
            PayloadJson = payloadJson,
            IsRead = false
        };
    }

    public void MarkRead() => IsRead = true;
}

