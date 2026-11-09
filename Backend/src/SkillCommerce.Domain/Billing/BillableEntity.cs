using SkillCommerce.Domain.Common;

namespace SkillCommerce.Domain.Billing;

/// <summary>
/// Base billing entity shared by ServiceBookings (and later Orders in Phase B).
/// Unifies invoices and payments under a single billable reference.
/// </summary>
public sealed class BillableEntity
{
    public Guid Id { get; private set; }
    public string EntityType { get; private set; } = string.Empty;
    public string CustomerId { get; private set; } = string.Empty;
    public DateTime CreatedAtUtc { get; set; }

    // Navigation
    public Invoice? Invoice { get; private set; }
    public IReadOnlyCollection<PaymentTransaction> Payments => _payments.AsReadOnly();
    private readonly List<PaymentTransaction> _payments = [];

    // For EF Core
    private BillableEntity() { }

    public static BillableEntity CreateForBooking(string customerId)
    {
        return new BillableEntity
        {
            Id = Guid.NewGuid(),
            EntityType = "ServiceBooking",
            CustomerId = Guard.NotNullOrWhiteSpace(customerId, nameof(customerId))
        };
    }
}
