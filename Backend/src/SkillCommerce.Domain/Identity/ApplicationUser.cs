using Microsoft.AspNetCore.Identity;
using SkillCommerce.Domain.Common;

namespace SkillCommerce.Domain.Identity;

/// <summary>
/// Platform user, extending ASP.NET Core Identity's IdentityUser.
/// IsActive = false means the account is banned by admin; login is refused.
/// </summary>
public sealed class ApplicationUser : IdentityUser
{
    public string FullName { get; private set; } = string.Empty;
    public string? ProfilePhotoUrl { get; private set; }
    public bool IsActive { get; private set; } = true;
    public DateTime CreatedAtUtc { get; set; }
    public DateTime UpdatedAtUtc { get; set; }

    /// <summary>Navigation to the provider profile if the user is a Professional.</summary>
    public Providers.ProviderProfile? ProviderProfile { get; private set; }

    // For EF Core
    private ApplicationUser() { }

    public static ApplicationUser Create(string fullName, string email, string? phone = null)
    {
        return new ApplicationUser
        {
            FullName = Guard.NotNullOrWhiteSpace(fullName, nameof(fullName)),
            Email = Guard.NotNullOrWhiteSpace(email, nameof(email)),
            UserName = email,
            PhoneNumber = phone,
            NormalizedEmail = email.ToUpperInvariant(),
            NormalizedUserName = email.ToUpperInvariant(),
            IsActive = true,
            SecurityStamp = Guid.NewGuid().ToString()
        };
    }

    public void UpdateProfile(string fullName, string? phone, string? photoUrl)
    {
        FullName = Guard.NotNullOrWhiteSpace(fullName, nameof(fullName));
        PhoneNumber = phone;
        ProfilePhotoUrl = photoUrl;
    }

    public void Deactivate() => IsActive = false;
    public void Activate() => IsActive = true;
}
