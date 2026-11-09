using Microsoft.AspNetCore.Mvc;
using SkillCommerce.Domain.LegalErrands;
using SkillCommerce.Infrastructure.Services;

namespace SkillCommerce.Api.Controllers;

[ApiController]
[Route("api/v1/legal-errands")]
public class LegalErrandsController(ISkillCommerceDbService dbService) : ControllerBase
{
    [HttpGet("services")]
    public async Task<IActionResult> GetServices()
    {
        var services = await dbService.GetLegalServiceTasksAsync();
        return Ok(services);
    }

    [HttpGet("courts")]
    public async Task<IActionResult> GetCourts()
    {
        var courts = await dbService.GetSupportedCourtsAsync();
        return Ok(courts);
    }

    [HttpGet("bookings/{bookingId}")]
    public async Task<IActionResult> GetErrandDetails(string bookingId)
    {
        var details = await dbService.GetLegalErrandByBookingIdAsync(bookingId);
        if (details == null) return NotFound(new { message = "Legal errand record not found" });
        return Ok(details);
    }

    [HttpPost("bookings/{bookingId}/milestones")]
    public async Task<IActionResult> TransitionMilestone(
        string bookingId,
        [FromBody] TransitionMilestoneRequest request)
    {
        var ok = await dbService.TransitionLegalMilestoneAsync(
            bookingId,
            request.NewMilestone,
            request.Notes,
            request.ActorUserId ?? "System"
        );

        if (!ok)
        {
            return BadRequest(new { message = $"Invalid milestone transition to {request.NewMilestone}" });
        }

        var updated = await dbService.GetLegalErrandByBookingIdAsync(bookingId);
        return Ok(updated);
    }

    [HttpPost("bookings/{bookingId}/documents")]
    public async Task<IActionResult> UploadDocumentMetadata(
        string bookingId,
        [FromBody] UploadDocumentRequest request)
    {
        try
        {
            var meta = await dbService.AddLegalDocumentAsync(
                bookingId,
                request.FileName,
                request.ContentType,
                request.FileSizeBytes,
                request.Category,
                request.UserId ?? "Customer"
            );

            return Ok(meta);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}

public sealed record TransitionMilestoneRequest(string NewMilestone, string? Notes, string? ActorUserId);
public sealed record UploadDocumentRequest(string FileName, string ContentType, long FileSizeBytes, string Category, string? UserId);

