using SkillCommerce.Domain.Common;
using SkillCommerce.Domain.Enums;

namespace SkillCommerce.Domain.Billing;

/// <summary>
/// A payment transaction attached to a BillableEntity.
/// IdempotencyKey ensures duplicate webhook or retry protection.
/// </summary>
public sealed class PaymentTransaction : AuditableEntity
{
    public int Id { get; private set; }
    public Guid BillableEntityId { get; private set; }
    public decimal Amount { get; private set; }
    public PaymentType Type { get; private set; }
    public PaymentMethod Method { get; private set; }
    public PaymentStatus Status { get; private set; }
    public string? GatewayReference { get; private set; }
    public string IdempotencyKey { get; private set; } = string.Empty;

    // Navigation
    public BillableEntity? BillableEntity { get; private set; }

    // For EF Core
    private PaymentTransaction() { }

    public static PaymentTransaction Create(
        Guid billableEntityId, decimal amount, PaymentType type,
        PaymentMethod method, string idempotencyKey, string? gatewayReference = null)
    {
        if (amount <= 0)
            throw new DomainException("payment.invalid_amount", "Payment amount must be greater than zero.");

        return new PaymentTransaction
        {
            BillableEntityId = billableEntityId,
            Amount = amount,
            Type = type,
            Method = method,
            Status = PaymentStatus.Pending,
            IdempotencyKey = Guard.NotNullOrWhiteSpace(idempotencyKey, nameof(idempotencyKey)),
            GatewayReference = gatewayReference
        };
    }

    public void MarkSucceeded(string? gatewayReference = null)
    {
        Status = PaymentStatus.Succeeded;
        if (!string.IsNullOrWhiteSpace(gatewayReference))
            GatewayReference = gatewayReference;
    }

    public void MarkFailed(string? gatewayReference = null)
    {
        Status = PaymentStatus.Failed;
        if (!string.IsNullOrWhiteSpace(gatewayReference))
            GatewayReference = gatewayReference;
    }
}

