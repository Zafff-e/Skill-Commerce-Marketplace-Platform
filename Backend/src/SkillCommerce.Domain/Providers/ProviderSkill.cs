using SkillCommerce.Domain.Common;
using SkillCommerce.Domain.Enums;

namespace SkillCommerce.Domain.Providers;

/// <summary>
/// A skill offering by a provider — connects a profile to a SkillSet with custom rate.
/// Exactly one skill per provider must have IsPrimary = true (enforced by filtered unique index).
/// </summary>
public sealed class ProviderSkill : AuditableEntity
{
    public int Id { get; private set; }
    public int ProfileId { get; private set; }
    public int SkillId { get; private set; }
    public int ExperienceYears { get; private set; }
    public decimal? CustomRate { get; private set; }
    public bool IsPrimary { get; private set; }

    // Navigation
    public ProviderProfile? Profile { get; private set; }
    public Taxonomy.SkillSet? Skill { get; private set; }

    // For EF Core
    private ProviderSkill() { }

    public static ProviderSkill Create(int profileId, int skillId, int experienceYears,
        decimal? customRate, bool isPrimary)
    {
        return new ProviderSkill
        {
            ProfileId = profileId,
            SkillId = skillId,
            ExperienceYears = experienceYears,
            CustomRate = customRate.HasValue ? Guard.PositiveOrZero(customRate.Value, nameof(customRate)) : null,
            IsPrimary = isPrimary
        };
    }

    public void Update(int experienceYears, decimal? customRate, bool isPrimary)
    {
        ExperienceYears = experienceYears;
        CustomRate = customRate.HasValue ? Guard.PositiveOrZero(customRate.Value, nameof(customRate)) : null;
        IsPrimary = isPrimary;
    }

    public void SetPrimary(bool isPrimary) => IsPrimary = isPrimary;
}
