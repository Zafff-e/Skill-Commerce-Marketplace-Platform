using SkillCommerce.Domain.Common;

namespace SkillCommerce.Domain.Reviews;

/// <summary>
/// Verified customer review for a completed service booking.
/// Only one review per booking is permitted.
/// </summary>
public sealed class Review : AuditableEntity
{
    public int Id { get; private set; }
    public int BookingId { get; private set; }
    public string CustomerId { get; private set; } = string.Empty;
    public int ProfileId { get; private set; }
    public int Rating { get; private set; }
    public string? Comment { get; private set; }

    // For EF Core
    private Review() { }

    public static Review Create(int bookingId, string customerId, int profileId, int rating, string? comment)
    {
        if (rating is < 1 or > 5)
            throw new DomainException("review.invalid_rating", "Rating must be between 1 and 5.");

        return new Review
        {
            BookingId = bookingId,
            CustomerId = Guard.NotNullOrWhiteSpace(customerId, nameof(customerId)),
            ProfileId = profileId,
            Rating = rating,
            Comment = comment
        };
    }
}

