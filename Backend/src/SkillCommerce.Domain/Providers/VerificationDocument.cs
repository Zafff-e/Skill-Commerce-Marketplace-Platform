using SkillCommerce.Domain.Common;
using SkillCommerce.Domain.Enums;

namespace SkillCommerce.Domain.Providers;

/// <summary>
/// A verification document uploaded by a provider.
/// ReviewStatus tracks the admin review lifecycle.
/// FileKey is the storage key (never the path) — served via authorized endpoint only.
/// </summary>
public sealed class VerificationDocument : AuditableEntity
{
    public int Id { get; private set; }
    public int ProfileId { get; private set; }
    public DocumentType DocType { get; private set; }
    public string? DocNumber { get; private set; }
    public string FileKey { get; private set; } = string.Empty;
    public ReviewStatus ReviewStatus { get; private set; } = ReviewStatus.Pending;
    public string? ReviewedByUserId { get; private set; }
    public DateTime? ReviewedAtUtc { get; private set; }
    public string? ReviewNote { get; private set; }

    // Navigation
    public ProviderProfile? Profile { get; private set; }

    // For EF Core
    private VerificationDocument() { }

    public static VerificationDocument Create(int profileId, DocumentType docType,
        string? docNumber, string fileKey)
    {
        return new VerificationDocument
        {
            ProfileId = profileId,
            DocType = docType,
            DocNumber = docNumber,
            FileKey = Guard.NotNullOrWhiteSpace(fileKey, nameof(fileKey)),
            ReviewStatus = ReviewStatus.Pending
        };
    }

    public void Approve(string reviewedByUserId, DateTime reviewedAtUtc, string? note = null)
    {
        ReviewStatus = ReviewStatus.Approved;
        ReviewedByUserId = reviewedByUserId;
        ReviewedAtUtc = reviewedAtUtc;
        ReviewNote = note;
    }

    public void Reject(string reviewedByUserId, DateTime reviewedAtUtc, string note)
    {
        ReviewStatus = ReviewStatus.Rejected;
        ReviewedByUserId = reviewedByUserId;
        ReviewedAtUtc = reviewedAtUtc;
        ReviewNote = Guard.NotNullOrWhiteSpace(note, nameof(note));
    }
}
