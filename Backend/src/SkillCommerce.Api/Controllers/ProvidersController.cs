using Microsoft.AspNetCore.Mvc;
using SkillCommerce.Domain.Taxonomy;
using SkillCommerce.Infrastructure.Services;

namespace SkillCommerce.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
public class ProvidersController(ISkillCommerceDbService dbService) : ControllerBase
{
    [HttpGet("search")]
    public async Task<IActionResult> Search(
        [FromQuery] decimal? lat,
        [FromQuery] decimal? lng,
        [FromQuery] decimal radiusKm = 15.0m,
        [FromQuery] int? skillId = null,
        [FromQuery] string? zoneId = null)
    {
        var providers = await dbService.SearchProvidersAsync(lat, lng, radiusKm, skillId, zoneId);
        return Ok(providers);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(string id)
    {
        var provider = await dbService.GetProviderByIdAsync(id);
        if (provider == null) return NotFound(new { message = "Provider not found" });
        return Ok(provider);
    }

    [HttpPut("{profileId}/coverage")]
    public async Task<IActionResult> UpdateCoverage(string profileId, [FromBody] ProviderCoverageUpdate update)
    {
        var ok = await dbService.UpdateProviderCoverageAsync(profileId, update);
        if (!ok) return BadRequest(new { message = "Failed to update provider coverage." });
        return Ok(new { message = "Service coverage updated successfully", update });
    }

    [HttpPut("{profileId}/tasks")]
    public async Task<IActionResult> UpdateTaskOfferings(string profileId, [FromBody] ProviderTaskOfferingUpdate update)
    {
        var ok = await dbService.UpdateProviderTaskOfferingsAsync(profileId, update);
        if (!ok) return BadRequest(new { message = "Failed to update provider task offerings." });
        return Ok(new { message = "Standard task offerings updated successfully", optedCount = update.OptedTaskIds.Count });
    }
}
