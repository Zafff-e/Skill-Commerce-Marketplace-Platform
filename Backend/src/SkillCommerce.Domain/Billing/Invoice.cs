using SkillCommerce.Domain.Common;
using SkillCommerce.Domain.Enums;

namespace SkillCommerce.Domain.Billing;

/// <summary>
/// Immutable invoice issued at booking completion. Never edited after issue.
/// Number format: SC-{yyyy}-{000001}. One per BillableEntity.
/// ProviderPayout = TotalPayable - PlatformFee.
/// </summary>
public sealed class Invoice
{
    public int Id { get; private set; }
    public Guid BillableEntityId { get; private set; }
    public string InvoiceNumber { get; private set; } = string.Empty;
    public decimal LaborAmount { get; private set; }
    public decimal UrgencyFee { get; private set; }
    public decimal MaterialsAmount { get; private set; }
    public decimal PlatformFee { get; private set; }
    public decimal TotalPayable { get; private set; }
    public decimal ProviderPayout { get; private set; }
    public PaidStatus PaidStatus { get; private set; } = PaidStatus.Unpaid;
    public DateTime IssuedAtUtc { get; private set; }

    // Navigation
    public BillableEntity? BillableEntity { get; private set; }

    // For EF Core
    private Invoice() { }

    public static Invoice Issue(Guid billableEntityId, string invoiceNumber,
        decimal laborAmount, decimal urgencyFee, decimal materialsAmount,
        decimal platformFee, DateTime issuedAtUtc)
    {
        var totalPayable = laborAmount + urgencyFee + materialsAmount;
        var providerPayout = totalPayable - platformFee;

        return new Invoice
        {
            BillableEntityId = billableEntityId,
            InvoiceNumber = Guard.NotNullOrWhiteSpace(invoiceNumber, nameof(invoiceNumber)),
            LaborAmount = Guard.PositiveOrZero(laborAmount, nameof(laborAmount)),
            UrgencyFee = Guard.PositiveOrZero(urgencyFee, nameof(urgencyFee)),
            MaterialsAmount = Guard.PositiveOrZero(materialsAmount, nameof(materialsAmount)),
            PlatformFee = Guard.PositiveOrZero(platformFee, nameof(platformFee)),
            TotalPayable = totalPayable,
            ProviderPayout = providerPayout,
            PaidStatus = PaidStatus.Unpaid,
            IssuedAtUtc = issuedAtUtc
        };
    }

    /// <summary>Updates paid status after payment(s) recorded. Invoice amounts are never changed.</summary>
    public void UpdatePaidStatus(PaidStatus status)
    {
        PaidStatus = status;
    }
}
