using Microsoft.AspNetCore.Mvc;
using SkillCommerce.Infrastructure.Services;

namespace SkillCommerce.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
public class CategoriesController(ISkillCommerceDbService dbService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetCategories()
    {
        var categories = await dbService.GetCategoriesAsync();
        return Ok(categories);
    }

    [HttpGet("{id:int}/skills")]
    public async Task<IActionResult> GetCategorySkills(int id)
    {
        var skills = await dbService.GetSkillsAsync(id);
        return Ok(skills);
    }
}

[ApiController]
[Route("api/v1/[controller]")]
public class SkillsController(ISkillCommerceDbService dbService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetSkills([FromQuery] int? categoryId)
    {
        var skills = await dbService.GetSkillsAsync(categoryId);
        return Ok(skills);
    }
}

