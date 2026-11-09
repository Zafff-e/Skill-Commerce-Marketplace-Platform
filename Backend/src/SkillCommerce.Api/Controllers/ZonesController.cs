using Microsoft.AspNetCore.Mvc;
using SkillCommerce.Infrastructure.Services;

namespace SkillCommerce.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
public class ZonesController(ISkillCommerceDbService dbService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetZones()
    {
        var zones = await dbService.GetServiceZonesAsync();
        return Ok(zones);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetZoneById(string id)
    {
        var zone = await dbService.GetServiceZoneByIdAsync(id);
        if (zone == null) return NotFound(new { message = $"Zone {id} not found." });
        return Ok(zone);
    }
}

[ApiController]
[Route("api/v1/service-tasks")]
public class ServiceTasksController(ISkillCommerceDbService dbService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetServiceTasks([FromQuery] int? categoryId)
    {
        var tasks = await dbService.GetStandardServiceTasksAsync(categoryId);
        return Ok(tasks);
    }
}

