using SkillCommerce.Domain.Common;
using SkillCommerce.Domain.Enums;

namespace SkillCommerce.Domain.Jobs;

/// <summary>
/// A bid on a job by a provider. One per provider per job (unique index).
/// At most one accepted proposal per job (filtered unique index).
/// QuotedLabor is the fixed amount the provider will charge for labor.
/// </summary>
public sealed class Proposal : AuditableEntity
{
    public int Id { get; private set; }
    public int JobId { get; private set; }
    public int ProfileId { get; private set; }
    public decimal QuotedLabor { get; private set; }
    public string? Message { get; private set; }
    public ProposalStatus Status { get; private set; } = ProposalStatus.Pending;

    // Navigation
    public Job? Job { get; private set; }
    public Providers.ProviderProfile? Profile { get; private set; }

    // For EF Core
    private Proposal() { }

    public static Proposal Create(int jobId, int profileId, decimal quotedLabor, string? message)
    {
        return new Proposal
        {
            JobId = jobId,
            ProfileId = profileId,
            QuotedLabor = Guard.PositiveOrZero(quotedLabor, nameof(quotedLabor)),
            Message = message,
            Status = ProposalStatus.Pending
        };
    }

    public void UpdateQuote(decimal quotedLabor, string? message)
    {
        if (Status != ProposalStatus.Pending)
            throw new DomainException("proposal.not_pending",
                "Can only edit a pending proposal.");
        QuotedLabor = Guard.PositiveOrZero(quotedLabor, nameof(quotedLabor));
        Message = message;
    }

    public void Accept()
    {
        if (Status != ProposalStatus.Pending)
            throw new DomainException("proposal.not_pending",
                "Can only accept a pending proposal.");
        Status = ProposalStatus.Accepted;
    }

    public void Reject()
    {
        if (Status == ProposalStatus.Accepted || Status == ProposalStatus.Withdrawn)
            throw new DomainException("proposal.invalid_transition",
                $"Cannot reject a proposal in status {Status}.");
        Status = ProposalStatus.Rejected;
    }

    public void Withdraw()
    {
        if (Status != ProposalStatus.Pending)
            throw new DomainException("proposal.not_pending",
                "Can only withdraw a pending proposal.");
        Status = ProposalStatus.Withdrawn;
    }
}
