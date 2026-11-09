namespace SkillCommerce.Domain.Common;

/// <summary>
/// Base class for all auditable entities, tracking creation and modification metadata.
/// Timestamps are always UTC; columns end in Utc.
/// </summary>
public abstract class AuditableEntity
{
    public DateTime CreatedAtUtc { get; set; }
    public DateTime UpdatedAtUtc { get; set; }
}
