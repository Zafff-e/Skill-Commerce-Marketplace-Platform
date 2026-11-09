namespace SkillCommerce.Domain.Identity;

/// <summary>
/// Refresh token record. Only the SHA-256 hash is stored — never the raw token.
/// Family ID enables theft detection: presenting a revoked token revokes the whole family.
/// </summary>
public sealed class RefreshToken
{
    public int Id { get; private set; }
    public string UserId { get; private set; } = string.Empty;
    public string TokenHash { get; private set; } = string.Empty;
    public Guid FamilyId { get; private set; }
    public DateTime ExpiresAtUtc { get; private set; }
    public DateTime? RevokedAtUtc { get; private set; }
    public string? ReplacedByTokenHash { get; private set; }

    public bool IsActive => RevokedAtUtc is null && ExpiresAtUtc > DateTime.UtcNow;

    // Navigation
    public ApplicationUser? User { get; private set; }

    // For EF Core
    private RefreshToken() { }

    public static RefreshToken Create(string userId, string tokenHash, Guid familyId, DateTime expiresAtUtc)
    {
        return new RefreshToken
        {
            UserId = userId,
            TokenHash = tokenHash,
            FamilyId = familyId,
            ExpiresAtUtc = expiresAtUtc
        };
    }

    public RefreshToken Rotate(string newTokenHash)
    {
        ReplacedByTokenHash = newTokenHash;
        RevokedAtUtc = DateTime.UtcNow;
        return Create(UserId, newTokenHash, FamilyId, ExpiresAtUtc);
    }

    public void Revoke(DateTime utcNow)
    {
        RevokedAtUtc = utcNow;
    }
}
