namespace SkillCommerce.Domain.LegalErrands;

public enum LegalMilestoneStep
{
    RequestSubmitted = 1,
    DocumentsReviewed = 2,
    ServiceInProgress = 3,
    CompletedAndDelivered = 4
}

public static class LegalMilestoneStatus
{
    public const string RequestSubmitted = "REQUEST_SUBMITTED";
    public const string DocumentsReviewed = "DOCUMENTS_REVIEWED";
    public const string ServiceInProgress = "SERVICE_IN_PROGRESS";
    public const string CompletedAndDelivered = "COMPLETED_DELIVERED";
    
    // Exception / hold statuses
    public const string AwaitingDocuments = "AWAITING_DOCUMENTS";
    public const string OnHold = "ON_HOLD";
    public const string Rejected = "REJECTED";
    public const string Cancelled = "CANCELLED";
    public const string DeliveryDisputed = "DELIVERY_DISPUTED";

    public static readonly string[] OrderedSteps = [
        RequestSubmitted,
        DocumentsReviewed,
        ServiceInProgress,
        CompletedAndDelivered
    ];

    public static bool CanTransition(string current, string next)
    {
        if (current == next) return true;
        if (next == Cancelled || next == OnHold || next == AwaitingDocuments || next == Rejected || next == DeliveryDisputed)
            return current != CompletedAndDelivered && current != Cancelled;

        return current switch
        {
            RequestSubmitted => next is DocumentsReviewed or AwaitingDocuments or Rejected or Cancelled,
            DocumentsReviewed => next is ServiceInProgress or OnHold or Cancelled,
            ServiceInProgress => next is CompletedAndDelivered or OnHold or Cancelled,
            OnHold => next is DocumentsReviewed or ServiceInProgress or Cancelled,
            AwaitingDocuments => next is DocumentsReviewed or Cancelled,
            _ => false
        };
    }
}

public sealed record SupportedCourt(string Id, string NameEn, string NameBn, string District, string Division);

public sealed record LegalServiceTask(
    string TaskId,
    string NameEn,
    string NameBn,
    string DescriptionEn,
    string DescriptionBn,
    decimal BaseFee,
    string EstimatedDays,
    string RequiredDocuments,
    string Restrictions
);

public sealed record LegalDocumentMetadata(
    string DocumentId,
    string BookingId,
    string FileName,
    string ContentType,
    long FileSizeBytes,
    string DocumentCategory,
    DateTime UploadedAtUtc,
    string UploaderUserId
);

public sealed record LegalErrandDetails(
    string BookingId,
    string TaskId,
    string CourtId,
    string CourtName,
    string Instructions,
    string CurrentMilestone,
    DateTime CreatedAtUtc,
    DateTime? CompletedAtUtc,
    List<LegalMilestoneHistoryItem> MilestoneHistory,
    List<LegalDocumentMetadata> Documents
);

public sealed record LegalMilestoneHistoryItem(
    int Id,
    string BookingId,
    string FromMilestone,
    string ToMilestone,
    string ChangedByUserId,
    string? Notes,
    DateTime TimestampUtc
);

