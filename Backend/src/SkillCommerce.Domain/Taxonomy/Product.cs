using SkillCommerce.Domain.Common;

namespace SkillCommerce.Domain.Taxonomy;

/// <summary>
/// Reference catalog of common repair parts/products.
/// Used when a provider adds parts to a booking.
/// SpecsJson holds flexible product specifications.
/// </summary>
public sealed class Product : AuditableEntity
{
    public int Id { get; private set; }
    public int CategoryId { get; private set; }
    public string Name { get; private set; } = string.Empty;
    public string? Brand { get; private set; }
    public string? Unit { get; private set; }
    public decimal ReferencePrice { get; private set; }
    public string? SpecsJson { get; private set; }
    public bool IsActive { get; private set; } = true;

    // Navigation
    public SkillCategory? Category { get; private set; }

    // For EF Core
    private Product() { }

    public static Product Create(int categoryId, string name, string? brand, string? unit,
        decimal referencePrice, string? specsJson = null)
    {
        return new Product
        {
            CategoryId = categoryId,
            Name = Guard.NotNullOrWhiteSpace(name, nameof(name)),
            Brand = brand,
            Unit = unit,
            ReferencePrice = Guard.PositiveOrZero(referencePrice, nameof(referencePrice)),
            SpecsJson = specsJson,
            IsActive = true
        };
    }

    public void Update(string name, string? brand, string? unit, decimal referencePrice,
        string? specsJson, bool isActive)
    {
        Name = Guard.NotNullOrWhiteSpace(name, nameof(name));
        Brand = brand;
        Unit = unit;
        ReferencePrice = Guard.PositiveOrZero(referencePrice, nameof(referencePrice));
        SpecsJson = specsJson;
        IsActive = isActive;
    }
}
