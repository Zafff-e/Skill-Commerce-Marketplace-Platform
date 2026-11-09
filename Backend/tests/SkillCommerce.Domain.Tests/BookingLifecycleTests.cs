using SkillCommerce.Domain.Bookings;
using Xunit;

namespace SkillCommerce.Domain.Tests;

public class BookingLifecycleTests
{
    [Theory]
    [InlineData("REQUESTED", "EN_ROUTE")]
    [InlineData("REQUESTED", "ACCEPTED")]
    [InlineData("REQUESTED", "CANCELLED")]
    [InlineData("ACCEPTED", "EN_ROUTE")]
    [InlineData("ACCEPTED", "ON_THE_WAY")]
    [InlineData("EN_ROUTE", "ARRIVED")]
    [InlineData("ON_THE_WAY", "ARRIVED")]
    [InlineData("ARRIVED", "IN_PROGRESS")]
    [InlineData("IN_PROGRESS", "COMPLETED")]
    [InlineData("IN_PROGRESS", "CANCELLED")]
    public void CanTransition_ValidTransitions_ReturnsTrue(string current, string next)
    {
        var result = BookingLifecycle.CanTransition(current, next);
        Assert.True(result, $"Expected transition from {current} to {next} to be valid.");
    }

    [Theory]
    [InlineData("REQUESTED", "COMPLETED")]
    [InlineData("REQUESTED", "ARRIVED")]
    [InlineData("COMPLETED", "EN_ROUTE")]
    [InlineData("COMPLETED", "REQUESTED")]
    [InlineData("COMPLETED", "CANCELLED")]
    [InlineData("CANCELLED", "IN_PROGRESS")]
    [InlineData("CANCELLED", "COMPLETED")]
    [InlineData("ARRIVED", "REQUESTED")]
    [InlineData("IN_PROGRESS", "EN_ROUTE")]
    public void CanTransition_InvalidTransitions_ReturnsFalse(string current, string next)
    {
        var result = BookingLifecycle.CanTransition(current, next);
        Assert.False(result, $"Expected transition from {current} to {next} to be rejected.");
    }

    [Fact]
    public void IsTerminal_CompletedAndCancelled_ReturnsTrue()
    {
        Assert.True(BookingLifecycle.IsTerminal("COMPLETED"));
        Assert.True(BookingLifecycle.IsTerminal("completed"));
        Assert.True(BookingLifecycle.IsTerminal("CANCELLED"));
        Assert.False(BookingLifecycle.IsTerminal("IN_PROGRESS"));
        Assert.False(BookingLifecycle.IsTerminal("EN_ROUTE"));
    }
}

