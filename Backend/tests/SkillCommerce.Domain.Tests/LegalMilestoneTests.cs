using SkillCommerce.Domain.LegalErrands;
using Xunit;

namespace SkillCommerce.Domain.Tests;

public class LegalMilestoneTests
{
    [Theory]
    [InlineData(LegalMilestoneStatus.RequestSubmitted, LegalMilestoneStatus.DocumentsReviewed)]
    [InlineData(LegalMilestoneStatus.DocumentsReviewed, LegalMilestoneStatus.ServiceInProgress)]
    [InlineData(LegalMilestoneStatus.ServiceInProgress, LegalMilestoneStatus.CompletedAndDelivered)]
    [InlineData(LegalMilestoneStatus.RequestSubmitted, LegalMilestoneStatus.AwaitingDocuments)]
    [InlineData(LegalMilestoneStatus.DocumentsReviewed, LegalMilestoneStatus.OnHold)]
    [InlineData(LegalMilestoneStatus.ServiceInProgress, LegalMilestoneStatus.Cancelled)]
    public void CanTransition_ValidMilestoneTransitions_ReturnsTrue(string current, string next)
    {
        Assert.True(LegalMilestoneStatus.CanTransition(current, next));
    }

    [Theory]
    [InlineData(LegalMilestoneStatus.RequestSubmitted, LegalMilestoneStatus.CompletedAndDelivered)]
    [InlineData(LegalMilestoneStatus.CompletedAndDelivered, LegalMilestoneStatus.RequestSubmitted)]
    [InlineData(LegalMilestoneStatus.CompletedAndDelivered, LegalMilestoneStatus.ServiceInProgress)]
    public void CanTransition_InvalidMilestoneTransitions_ReturnsFalse(string current, string next)
    {
        Assert.False(LegalMilestoneStatus.CanTransition(current, next));
    }
}

