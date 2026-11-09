namespace SkillCommerce.Domain.Enums;

public enum ProviderStatus
{
    Pending,
    Approved,
    Suspended,
    Deactivated
}

public enum DocumentType
{
    NID,
    TradeLicense,
    Certificate
}

public enum ReviewStatus
{
    Pending,
    Approved,
    Rejected
}

public enum ServiceUnit
{
    PerHour,
    PerJob
}

public enum JobStatus
{
    Open,
    Matched,
    Cancelled,
    Expired
}

public enum ProposalStatus
{
    Pending,
    Accepted,
    Rejected,
    Withdrawn
}

public enum BookingStatus
{
    Accepted,
    OnTheWay,
    Arrived,
    InProgress,
    Completed,
    Cancelled
}

public enum PartApprovalStatus
{
    Pending,
    Approved,
    Rejected
}

public enum PaidStatus
{
    Unpaid,
    PartiallyPaid,
    Paid
}

public enum PaymentType
{
    UpfrontLabor,
    FinalSettlement,
    Refund
}

public enum PaymentMethod
{
    Cash,
    BKash,
    Nagad,
    Card
}

public enum PaymentStatus
{
    Pending,
    Succeeded,
    Failed
}

public enum NotificationType
{
    ProposalReceived,
    ProposalAccepted,
    ProposalRejected,
    DirectRequestReceived,
    BookingStatusChanged,
    PartAdded,
    PartDecided,
    ProviderApproved,
    ProviderSuspended,
    ReviewReceived
}
