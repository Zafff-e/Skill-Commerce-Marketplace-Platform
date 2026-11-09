using SkillCommerce.Domain.Common;
using SkillCommerce.Domain.Enums;

namespace SkillCommerce.Domain.Bookings;

/// <summary>
/// Immutable audit record of every booking state transition.
/// Written by ServiceBooking entity methods; never written externally.
/// </summary>
public sealed class BookingStatusHistory
{
    public int Id { get; private set; }
    public int BookingId { get; private set; }
    public BookingStatus? FromStatus { get; private set; }
    public BookingStatus ToStatus { get; private set; }
    public string ChangedByUserId { get; private set; } = string.Empty;
    public string? Notes { get; private set; }
    public DateTime ChangedAtUtc { get; private set; }

    // Navigation
    public ServiceBooking? Booking { get; private set; }

    // For EF Core
    private BookingStatusHistory() { }

    internal static BookingStatusHistory Create(
        BookingStatus? fromStatus, BookingStatus toStatus,
        string changedByUserId, string? notes, DateTime changedAtUtc)
    {
        return new BookingStatusHistory
        {
            FromStatus = fromStatus,
            ToStatus = toStatus,
            ChangedByUserId = changedByUserId,
            Notes = notes,
            ChangedAtUtc = changedAtUtc
        };
    }
}
