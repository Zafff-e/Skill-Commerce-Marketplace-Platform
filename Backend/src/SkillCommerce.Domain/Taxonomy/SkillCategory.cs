using SkillCommerce.Domain.Common;

namespace SkillCommerce.Domain.Taxonomy;

/// <summary>
/// Top-level skill category managed by admins (e.g., Air Conditioning, Electrical, Plumbing).
/// </summary>
public sealed class SkillCategory : AuditableEntity
{
    public int Id { get; private set; }
    public string CategoryName { get; private set; } = string.Empty;
    public string? IconUrl { get; private set; }
    public string? Description { get; private set; }
    public bool IsActive { get; private set; } = true;

    public IReadOnlyCollection<SkillSet> Skills => _skills.AsReadOnly();
    private readonly List<SkillSet> _skills = [];

    // For EF Core
    private SkillCategory() { }

    public static SkillCategory Create(string categoryName, string? iconUrl, string? description)
    {
        return new SkillCategory
        {
            CategoryName = Guard.NotNullOrWhiteSpace(categoryName, nameof(categoryName)),
            IconUrl = iconUrl,
            Description = description,
            IsActive = true
        };
    }

    public void Update(string categoryName, string? iconUrl, string? description, bool isActive)
    {
        CategoryName = Guard.NotNullOrWhiteSpace(categoryName, nameof(categoryName));
        IconUrl = iconUrl;
        Description = description;
        IsActive = isActive;
    }
}
