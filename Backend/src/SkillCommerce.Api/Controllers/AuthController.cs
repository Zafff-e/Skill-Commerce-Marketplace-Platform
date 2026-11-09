using Microsoft.AspNetCore.Mvc;
using SkillCommerce.Infrastructure.Services;

namespace SkillCommerce.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
public class AuthController(ISkillCommerceDbService dbService) : ControllerBase
{
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        var auth = await dbService.AuthenticateAsync(request.EmailOrPhone, request.Password);
        if (auth == null)
        {
            return Unauthorized(new { message = "Invalid email/phone or account not active" });
        }

        return Ok(auth);
    }
}

public sealed record LoginRequest(string EmailOrPhone, string Password);

