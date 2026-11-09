using NetTopologySuite.Geometries;
using SkillCommerce.Domain.Billing;
using SkillCommerce.Domain.Common;
using SkillCommerce.Domain.Enums;
using SkillCommerce.Domain.Jobs;

namespace SkillCommerce.Domain.Bookings;

/// <summary>
/// A service booking. Created when a proposal is accepted or a direct request is accepted.
/// Starts at Accepted; the provider drives all forward transitions.
/// TotalAmount is a computed column = LaborAmount + UrgencyFee + MaterialsAmount.
/// RowVersion prevents concurrent state transition races.
/// </summary>
public sealed class ServiceBooking : AuditableEntity
{
    public int Id { get; private set; }
    public Guid BillableEntityId { get; private set; }
    public int? JobId { get; private set; }
    public int? ProposalId { get; private set; }
    public string CustomerId { get; private set; } = string.Empty;
    public int ProfileId { get; private set; }
    public int SkillId { get; private set; }
    public Point ServiceLocation { get; private set; } = null!;
    public string AddressText { get; private set; } = string.Empty;
    public DateTime ScheduledAtUtc { get; private set; }
    public BookingStatus Status { get; private set; } = BookingStatus.Accepted;
    public decimal LaborAmount { get; private set; }
    public decimal UrgencyFee { get; private set; }
    public decimal CommissionRate { get; private set; }
    public decimal PlatformFee { get; private set; }
    public decimal MaterialsAmount { get; private set; }
    // TotalAmount is a database computed column; private setter for EF
    public decimal TotalAmount { get; private set; }
    public string? CancelledByUserId { get; private set; }
    public string? CancellationReason { get; private set; }
    public DateTime? CompletedAtUtc { get; private set; }
    public byte[]? RowVersion { get; private set; }

    // Navigation
    public Billing.BillableEntity? BillableEntity { get; private set; }
    public IReadOnlyCollection<BookingStatusHistory> StatusHistory => _history.AsReadOnly();
    public IReadOnlyCollection<PartForRepair> Parts => _parts.AsReadOnly();

    private readonly List<BookingStatusHistory> _history = [];
    private readonly List<PartForRepair> _parts = [];

    // For EF Core
    private ServiceBooking() { }

    /// <summary>
    /// Creates a booking from an accepted proposal. Sets up BillableEntity, copies commission rate,
    /// sets LaborAmount and UrgencyFee. Also transitions the job to Matched.
    /// </summary>
    public static ServiceBooking CreateFromProposal(
        Proposal proposal, Job job, Billing.BillableEntity billableEntity,
        decimal commissionRate, decimal urgencyFee, string actorId, DateTime utcNow)
    {
        proposal.Accept();
        job.MarkMatched();

        var booking = new ServiceBooking
        {
            BillableEntityId = billableEntity.Id,
            JobId = job.Id,
            ProposalId = proposal.Id,
            CustomerId = job.CustomerId,
            ProfileId = proposal.ProfileId,
            SkillId = job.SkillId,
            ServiceLocation = job.ServiceLocation,
            AddressText = job.AddressText,
            ScheduledAtUtc = job.ScheduledAtUtc,
            Status = BookingStatus.Accepted,
            LaborAmount = proposal.QuotedLabor,
            UrgencyFee = job.IsUrgent ? urgencyFee : 0m,
            CommissionRate = commissionRate,
            PlatformFee = 0m, // recalculated at completion
            MaterialsAmount = 0m,
            TotalAmount = 0m  // computed column
        };

        booking._history.Add(BookingStatusHistory.Create(
            null, BookingStatus.Accepted, actorId, "Booking created from accepted proposal.", utcNow));

        return booking;
    }

    /// <summary>Creates a booking directly from a direct-request acceptance at the provider's listed rate.</summary>
    public static ServiceBooking CreateFromDirectAccept(
        Job job, int profileId, decimal laborAmount, Billing.BillableEntity billableEntity,
        decimal commissionRate, decimal urgencyFee, string actorId, DateTime utcNow)
    {
        job.MarkMatched();

        var booking = new ServiceBooking
        {
            BillableEntityId = billableEntity.Id,
            JobId = job.Id,
            CustomerId = job.CustomerId,
            ProfileId = profileId,
            SkillId = job.SkillId,
            ServiceLocation = job.ServiceLocation,
            AddressText = job.AddressText,
            ScheduledAtUtc = job.ScheduledAtUtc,
            Status = BookingStatus.Accepted,
            LaborAmount = laborAmount,
            UrgencyFee = job.IsUrgent ? urgencyFee : 0m,
            CommissionRate = commissionRate,
            PlatformFee = 0m,
            MaterialsAmount = 0m,
            TotalAmount = 0m
        };

        booking._history.Add(BookingStatusHistory.Create(
            null, BookingStatus.Accepted, actorId, "Booking created from direct request acceptance.", utcNow));

        return booking;
    }

    private void Transition(BookingStatus from, BookingStatus to, string actorId, DateTime utcNow, string? notes = null)
    {
        if (Status != from)
            throw new DomainException("booking.invalid_transition",
                $"Cannot transition from {Status} to {to}. Expected {from}.");
        Status = to;
        _history.Add(BookingStatusHistory.Create(from, to, actorId, notes, utcNow));
    }

    public void StartTravel(string providerUserId, DateTime utcNow) =>
        Transition(BookingStatus.Accepted, BookingStatus.OnTheWay, providerUserId, utcNow);

    public void Arrive(string providerUserId, DateTime utcNow) =>
        Transition(BookingStatus.OnTheWay, BookingStatus.Arrived, providerUserId, utcNow);

    public void StartWork(string providerUserId, DateTime utcNow) =>
        Transition(BookingStatus.Arrived, BookingStatus.InProgress, providerUserId, utcNow);

    public void Complete(string providerUserId, DateTime utcNow, decimal commissionRate)
    {
        if (Status != BookingStatus.InProgress)
            throw new DomainException("booking.invalid_transition",
                $"Cannot complete a booking in status {Status}.");

        // Refuse completion while any part is still Pending
        if (_parts.Any(p => p.ApprovalStatus == PartApprovalStatus.Pending))
            throw new DomainException("booking.parts_pending",
                "Cannot complete: some parts are still awaiting customer approval.");

        // Compute final amounts
        var approvedPartsTotal = _parts
            .Where(p => p.ApprovalStatus == PartApprovalStatus.Approved)
            .Sum(p => p.LineTotal);

        MaterialsAmount = approvedPartsTotal;
        var commissionable = LaborAmount + UrgencyFee;
        PlatformFee = Math.Round(commissionable * commissionRate, 2, MidpointRounding.AwayFromZero);
        // TotalAmount will be computed by SQL; freeze the individual components here
        CompletedAtUtc = utcNow;

        Status = BookingStatus.Completed;
        _history.Add(BookingStatusHistory.Create(
            BookingStatus.InProgress, BookingStatus.Completed, providerUserId,
            $"Completed. Materials: {MaterialsAmount}, PlatformFee: {PlatformFee}", utcNow));
    }

    public void Cancel(string cancelledByUserId, string? reason, DateTime utcNow, bool isAdmin)
    {
        if (!isAdmin && Status != BookingStatus.Accepted)
            throw new DomainException("booking.cancel_forbidden",
                "Only an Admin can cancel a booking after it has started travel.");

        if (Status is BookingStatus.Completed or BookingStatus.Cancelled)
            throw new DomainException("booking.invalid_transition",
                $"Cannot cancel a booking in status {Status}.");

        CancelledByUserId = cancelledByUserId;
        CancellationReason = reason;
        Status = BookingStatus.Cancelled;
        _history.Add(BookingStatusHistory.Create(
            Status, BookingStatus.Cancelled, cancelledByUserId,
            reason ?? "Cancelled.", utcNow));
    }

    public PartForRepair AddPart(int? productId, string itemDescription, int quantity,
        decimal unitPrice, DateTime utcNow)
    {
        if (Status is not (BookingStatus.Arrived or BookingStatus.InProgress))
            throw new DomainException("booking.parts_not_allowed",
                "Parts can only be added while the booking is Arrived or InProgress.");

        var part = PartForRepair.Create(Id, productId, itemDescription, quantity, unitPrice, utcNow);
        _parts.Add(part);
        return part;
    }
}
