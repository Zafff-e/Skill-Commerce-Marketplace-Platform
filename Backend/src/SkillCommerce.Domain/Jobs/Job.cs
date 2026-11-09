using NetTopologySuite.Geometries;
using SkillCommerce.Domain.Common;
using SkillCommerce.Domain.Enums;

namespace SkillCommerce.Domain.Jobs;

/// <summary>
/// A customer's service request. TargetProfileId null = open job; set = direct request.
/// Status transitions: Open → Matched | Cancelled | Expired.
/// RowVersion prevents concurrent acceptance races.
/// ExpiresAtUtc enforced by JobExpiryWorker (48h open, 30min urgent direct request).
/// </summary>
public sealed class Job : AuditableEntity
{
    public int Id { get; private set; }
    public string CustomerId { get; private set; } = string.Empty;
    public int SkillId { get; private set; }
    public string Title { get; private set; } = string.Empty;
    public string? Description { get; private set; }
    public string? VoiceNoteKey { get; private set; }
    public decimal? Budget { get; private set; }
    public Point ServiceLocation { get; private set; } = null!;
    public string AddressText { get; private set; } = string.Empty;
    public DateTime ScheduledAtUtc { get; private set; }
    public bool IsUrgent { get; private set; }
    public int? TargetProfileId { get; private set; }
    public JobStatus Status { get; private set; } = JobStatus.Open;
    public DateTime ExpiresAtUtc { get; private set; }
    public byte[]? RowVersion { get; private set; }

    // Navigation
    public IReadOnlyCollection<Proposal> Proposals => _proposals.AsReadOnly();
    private readonly List<Proposal> _proposals = [];

    // For EF Core
    private Job() { }

    public static Job Create(string customerId, int skillId, string title, string? description,
        string? voiceNoteKey, decimal? budget, double latitude, double longitude,
        string addressText, DateTime scheduledAtUtc, bool isUrgent, int? targetProfileId,
        DateTime utcNow)
    {
        var expiresAt = isUrgent && targetProfileId.HasValue
            ? utcNow.AddMinutes(30)
            : utcNow.AddHours(48);

        return new Job
        {
            CustomerId = Guard.NotNullOrWhiteSpace(customerId, nameof(customerId)),
            SkillId = skillId,
            Title = Guard.NotNullOrWhiteSpace(title, nameof(title)),
            Description = description,
            VoiceNoteKey = voiceNoteKey,
            Budget = budget.HasValue ? Guard.PositiveOrZero(budget.Value, nameof(budget)) : null,
            ServiceLocation = GeoPoint.Create(latitude, longitude),
            AddressText = Guard.NotNullOrWhiteSpace(addressText, nameof(addressText)),
            ScheduledAtUtc = scheduledAtUtc,
            IsUrgent = isUrgent,
            TargetProfileId = targetProfileId,
            Status = JobStatus.Open,
            ExpiresAtUtc = expiresAt
        };
    }

    public void MarkMatched()
    {
        if (Status != JobStatus.Open)
            throw new DomainException("job.invalid_transition",
                $"Cannot match a job in status {Status}.");
        Status = JobStatus.Matched;
    }

    public void Cancel()
    {
        if (Status != JobStatus.Open)
            throw new DomainException("job.invalid_transition",
                $"Cannot cancel a job in status {Status}.");
        Status = JobStatus.Cancelled;
    }

    public void Expire()
    {
        if (Status != JobStatus.Open)
            throw new DomainException("job.invalid_transition",
                $"Cannot expire a job in status {Status}.");
        Status = JobStatus.Expired;
    }

    public bool IsDirectRequest => TargetProfileId.HasValue;
}
