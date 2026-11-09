using Microsoft.AspNetCore.Mvc;
using SkillCommerce.Infrastructure.Services;

namespace SkillCommerce.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
public class AdminController(ISkillCommerceDbService dbService) : ControllerBase
{
    [HttpGet("verifications")]
    public async Task<IActionResult> GetPendingVerifications()
    {
        var providers = await dbService.GetPendingVerificationProvidersAsync();
        return Ok(providers);
    }

    [HttpPost("verifications/{profileId}/decision")]
    public async Task<IActionResult> MakeDecision(
        string profileId,
        [FromBody] VerificationDecisionRequest request)
    {
        var ok = await dbService.SetProviderVerificationStatusAsync(
            profileId,
            request.Status,
            request.Reason
        );

        if (!ok)
        {
            return NotFound(new { message = $"Provider profile {profileId} not found." });
        }

        return Ok(new
        {
            profileId,
            status = request.Status,
            reason = request.Reason,
            updatedAt = DateTime.UtcNow
        });
    }
}

public sealed record VerificationDecisionRequest(string Status, string? Reason);

