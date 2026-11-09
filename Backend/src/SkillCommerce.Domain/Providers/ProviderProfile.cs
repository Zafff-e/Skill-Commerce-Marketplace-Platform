using NetTopologySuite.Geometries;
using SkillCommerce.Domain.Common;
using SkillCommerce.Domain.Enums;

namespace SkillCommerce.Domain.Providers;

/// <summary>
/// Provider profile. Status is admin-controlled; IsActive is the provider's own availability toggle.
/// Approved + IsActive = appears in search and can receive bookings.
/// RowVersion enables optimistic concurrency for profile updates.
/// </summary>
public sealed class ProviderProfile : AuditableEntity
{
    public int Id { get; private set; }
    public string UserId { get; private set; } = string.Empty;
    public string? NIDNumber { get; private set; }
    public string? Bio { get; private set; }
    public int ExperienceYears { get; private set; }
    public Point? BaseLocation { get; private set; }
    public double MaxRadiusKm { get; private set; } = 10.0;
    public ProviderStatus Status { get; private set; } = ProviderStatus.Pending;
    public bool IsActive { get; private set; } = false;
    public decimal OverallRating { get; private set; } = 0m;
    public int RatingCount { get; private set; } = 0;
    public string? PayoutAccount { get; private set; }
    public byte[]? RowVersion { get; private set; }

    // Navigation properties
    public Identity.ApplicationUser? User { get; private set; }
    public IReadOnlyCollection<ProviderSkill> Skills => _skills.AsReadOnly();
    public IReadOnlyCollection<VerificationDocument> Documents => _documents.AsReadOnly();

    private readonly List<ProviderSkill> _skills = [];
    private readonly List<VerificationDocument> _documents = [];

    // For EF Core
    private ProviderProfile() { }

    public static ProviderProfile Create(string userId, string? nidNumber, string? bio, int experienceYears,
        double latitude, double longitude, double maxRadiusKm)
    {
        return new ProviderProfile
        {
            UserId = Guard.NotNullOrWhiteSpace(userId, nameof(userId)),
            NIDNumber = nidNumber,
            Bio = bio,
            ExperienceYears = experienceYears,
            BaseLocation = latitude != 0 || longitude != 0
                ? GeoPoint.Create(latitude, longitude)
                : null,
            MaxRadiusKm = maxRadiusKm > 0 ? maxRadiusKm : 10.0,
            Status = ProviderStatus.Pending,
            IsActive = false
        };
    }

    public void UpdateDetails(string? bio, int experienceYears, double latitude, double longitude,
        double maxRadiusKm, string? payoutAccount)
    {
        Bio = bio;
        ExperienceYears = experienceYears;
        BaseLocation = GeoPoint.Create(latitude, longitude);
        MaxRadiusKm = maxRadiusKm > 0 ? maxRadiusKm : MaxRadiusKm;
        PayoutAccount = payoutAccount;
    }

    public void ToggleAvailability(bool isActive)
    {
        // Provider can only toggle availability; cannot undo an admin suspension
        if (Status is ProviderStatus.Suspended or ProviderStatus.Deactivated)
            throw new DomainException("provider.suspended",
                "Cannot change availability while account is suspended or deactivated.");
        IsActive = isActive;
    }

    public void Approve(string adminId)
    {
        if (Status == ProviderStatus.Approved)
            throw new DomainException("provider.already_approved", "Provider is already approved.");
        Status = ProviderStatus.Approved;
    }

    public void Suspend(string adminId, string reason)
    {
        if (Status == ProviderStatus.Suspended)
            throw new DomainException("provider.already_suspended", "Provider is already suspended.");
        Status = ProviderStatus.Suspended;
        IsActive = false; // Cannot accept new bookings when suspended
    }

    public void Reinstate(string adminId)
    {
        if (Status != ProviderStatus.Suspended)
            throw new DomainException("provider.not_suspended", "Provider is not suspended.");
        Status = ProviderStatus.Approved;
    }

    public void UpdateRating(decimal overallRating, int ratingCount)
    {
        OverallRating = overallRating;
        RatingCount = ratingCount;
    }

    public bool IsEligibleForBookings =>
        Status == ProviderStatus.Approved && IsActive;
}
