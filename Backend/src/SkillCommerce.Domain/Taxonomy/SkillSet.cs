using SkillCommerce.Domain.Common;
using SkillCommerce.Domain.Enums;

namespace SkillCommerce.Domain.Taxonomy;

/// <summary>
/// A concrete skill within a category (e.g., "Split AC Installation" in "Air Conditioning").
/// Custom skills proposed by professionals start with IsApproved = false.
/// BasicPrice is the platform's reference price; providers can override with CustomRate.
/// </summary>
public sealed class SkillSet : AuditableEntity
{
    public int Id { get; private set; }
    public int CategoryId { get; private set; }
    public string SkillName { get; private set; } = string.Empty;
    public decimal BasicPrice { get; private set; }
    public ServiceUnit ServiceUnit { get; private set; } = ServiceUnit.PerJob;
    public bool IsUserGenerated { get; private set; }
    public string? CreatedByUserId { get; private set; }
    public bool IsApproved { get; private set; } = true;
    public bool IsActive { get; private set; } = true;

    // Navigation
    public SkillCategory? Category { get; private set; }

    // For EF Core
    private SkillSet() { }

    /// <summary>Creates an admin-managed skill. IsApproved defaults to true.</summary>
    public static SkillSet Create(int categoryId, string skillName, decimal basicPrice, ServiceUnit unit)
    {
        return new SkillSet
        {
            CategoryId = categoryId,
            SkillName = Guard.NotNullOrWhiteSpace(skillName, nameof(skillName)),
            BasicPrice = Guard.PositiveOrZero(basicPrice, nameof(basicPrice)),
            ServiceUnit = unit,
            IsUserGenerated = false,
            IsApproved = true,
            IsActive = true
        };
    }

    /// <summary>Creates a user-generated skill proposal. IsApproved = false always.</summary>
    public static SkillSet ProposeCustom(int categoryId, string skillName, decimal basicPrice,
        ServiceUnit unit, string createdByUserId)
    {
        return new SkillSet
        {
            CategoryId = categoryId,
            SkillName = Guard.NotNullOrWhiteSpace(skillName, nameof(skillName)),
            BasicPrice = Guard.PositiveOrZero(basicPrice, nameof(basicPrice)),
            ServiceUnit = unit,
            IsUserGenerated = true,
            CreatedByUserId = Guard.NotNullOrWhiteSpace(createdByUserId, nameof(createdByUserId)),
            IsApproved = false, // always false regardless of what the caller sends
            IsActive = false
        };
    }

    public void Approve(string adminId)
    {
        IsApproved = true;
        IsActive = true;
    }

    public void Reject(string adminId)
    {
        IsApproved = false;
        IsActive = false;
    }

    public void Update(string skillName, decimal basicPrice, ServiceUnit unit, bool isActive)
    {
        SkillName = Guard.NotNullOrWhiteSpace(skillName, nameof(skillName));
        BasicPrice = Guard.PositiveOrZero(basicPrice, nameof(basicPrice));
        ServiceUnit = unit;
        IsActive = isActive;
    }
}
