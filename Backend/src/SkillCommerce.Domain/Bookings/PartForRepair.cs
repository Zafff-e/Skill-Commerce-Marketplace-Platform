using SkillCommerce.Domain.Common;
using SkillCommerce.Domain.Enums;

namespace SkillCommerce.Domain.Bookings;

/// <summary>
/// A repair part or material proposed by the provider during a booking.
/// LineTotal is a computed column = Quantity * UnitPrice.
/// SnapshotJson freezes the part details at approval time.
/// </summary>
public sealed class PartForRepair
{
    public int Id { get; private set; }
    public int BookingId { get; private set; }
    public int? ProductId { get; private set; }
    public string ItemDescription { get; private set; } = string.Empty;
    public int Quantity { get; private set; }
    public decimal UnitPrice { get; private set; }
    // LineTotal is computed by SQL; private setter for EF
    public decimal LineTotal { get; private set; }
    public PartApprovalStatus ApprovalStatus { get; private set; } = PartApprovalStatus.Pending;
    public string? SnapshotJson { get; private set; }
    public DateTime AddedAtUtc { get; private set; }
    public DateTime? DecidedAtUtc { get; private set; }

    // Navigation
    public ServiceBooking? Booking { get; private set; }
    public Taxonomy.Product? Product { get; private set; }

    // For EF Core
    private PartForRepair() { }

    internal static PartForRepair Create(int bookingId, int? productId, string itemDescription,
        int quantity, decimal unitPrice, DateTime utcNow)
    {
        if (quantity <= 0)
            throw new DomainException("part.invalid_quantity", "Quantity must be greater than 0.");

        return new PartForRepair
        {
            BookingId = bookingId,
            ProductId = productId,
            ItemDescription = Guard.NotNullOrWhiteSpace(itemDescription, nameof(itemDescription)),
            Quantity = quantity,
            UnitPrice = Guard.PositiveOrZero(unitPrice, nameof(unitPrice)),
            ApprovalStatus = PartApprovalStatus.Pending,
            AddedAtUtc = utcNow
        };
    }

    public void Approve(DateTime utcNow, string snapshotJson)
    {
        if (ApprovalStatus != PartApprovalStatus.Pending)
            throw new DomainException("part.already_decided", "Part has already been approved or rejected.");
        ApprovalStatus = PartApprovalStatus.Approved;
        SnapshotJson = snapshotJson; // freeze the snapshot at approval time
        DecidedAtUtc = utcNow;
    }

    public void Reject(DateTime utcNow)
    {
        if (ApprovalStatus != PartApprovalStatus.Pending)
            throw new DomainException("part.already_decided", "Part has already been approved or rejected.");
        ApprovalStatus = PartApprovalStatus.Rejected;
        DecidedAtUtc = utcNow;
    }
}
