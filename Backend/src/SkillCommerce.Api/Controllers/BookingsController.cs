using System.Collections.Concurrent;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using SkillCommerce.Api.Hubs;
using SkillCommerce.Infrastructure.Services;

namespace SkillCommerce.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
public class BookingsController(ISkillCommerceDbService dbService, IHubContext<BookingHub> hubContext) : ControllerBase
{
    private static readonly ConcurrentDictionary<string, BookingDetailsDto> _idempotentCache = new();

    [HttpPost]
    public async Task<IActionResult> Create(
        [FromBody] CreateBookingRequest request,
        [FromHeader(Name = "Idempotency-Key")] string? idempotencyKey)
    {
        try
        {
            if (!string.IsNullOrWhiteSpace(idempotencyKey) && _idempotentCache.TryGetValue(idempotencyKey, out var existing))
            {
                return Ok(existing);
            }

            var booking = await dbService.CreateBookingAsync(request);
            if (booking == null) return BadRequest(new { message = "Failed to create booking" });

            if (!string.IsNullOrWhiteSpace(idempotencyKey))
            {
                _idempotentCache[idempotencyKey] = booking;
            }

            // Notify provider via SignalR
            await hubContext.Clients.All.SendAsync("OnNewBookingRequest", booking);

            return CreatedAtAction(nameof(GetById), new { id = booking.BookingId }, booking);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error processing booking", detail = ex.Message });
        }
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(string id)
    {
        var booking = await dbService.GetBookingByIdAsync(id);
        if (booking == null) return NotFound(new { message = "Booking not found" });
        return Ok(booking);
    }

    [HttpPost("{id}/start-travel")]
    public async Task<IActionResult> StartTravel(string id)
    {
        var ok = await dbService.UpdateBookingStatusAsync(id, "EN_ROUTE", "Provider started traveling to customer location");
        if (!ok) return BadRequest(new { message = "Invalid status transition to EN_ROUTE" });

        var payload = new { bookingId = id, status = "EN_ROUTE", updatedAt = DateTime.UtcNow };
        await hubContext.Clients.Group($"booking_{id}").SendAsync("BookingStatusChanged", payload);
        await hubContext.Clients.Group($"booking_{id}").SendAsync("OnStatusChanged", payload);
        return Ok(new { status = "EN_ROUTE" });
    }

    [HttpPost("{id}/arrive")]
    public async Task<IActionResult> Arrived(string id)
    {
        var ok = await dbService.UpdateBookingStatusAsync(id, "ARRIVED", "Provider arrived at service address");
        if (!ok) return BadRequest(new { message = "Invalid status transition to ARRIVED" });

        var payload = new { bookingId = id, status = "ARRIVED", updatedAt = DateTime.UtcNow };
        await hubContext.Clients.Group($"booking_{id}").SendAsync("BookingStatusChanged", payload);
        await hubContext.Clients.Group($"booking_{id}").SendAsync("OnStatusChanged", payload);
        return Ok(new { status = "ARRIVED" });
    }

    [HttpPost("{id}/start-work")]
    public async Task<IActionResult> StartWork(string id)
    {
        var ok = await dbService.UpdateBookingStatusAsync(id, "IN_PROGRESS", "Provider initiated service inspection/labor");
        if (!ok) return BadRequest(new { message = "Invalid status transition to IN_PROGRESS" });

        var payload = new { bookingId = id, status = "IN_PROGRESS", updatedAt = DateTime.UtcNow };
        await hubContext.Clients.Group($"booking_{id}").SendAsync("BookingStatusChanged", payload);
        await hubContext.Clients.Group($"booking_{id}").SendAsync("OnStatusChanged", payload);
        return Ok(new { status = "IN_PROGRESS" });
    }

    [HttpPost("{id}/complete")]
    public async Task<IActionResult> Complete(string id)
    {
        var ok = await dbService.UpdateBookingStatusAsync(id, "COMPLETED", "Service work completed successfully");
        if (!ok) return BadRequest(new { message = "Invalid status transition to COMPLETED" });

        var payload = new { bookingId = id, status = "COMPLETED", updatedAt = DateTime.UtcNow };
        await hubContext.Clients.Group($"booking_{id}").SendAsync("BookingStatusChanged", payload);
        await hubContext.Clients.Group($"booking_{id}").SendAsync("OnStatusChanged", payload);
        return Ok(new { status = "COMPLETED" });
    }

    [HttpPost("{id}/cancel")]
    public async Task<IActionResult> Cancel(string id, [FromBody] CancelBookingRequest? body)
    {
        var reason = body?.Reason ?? "Cancelled by user";
        var ok = await dbService.UpdateBookingStatusAsync(id, "CANCELLED", reason);
        if (!ok) return BadRequest(new { message = "Cannot cancel booking in current status" });

        var payload = new { bookingId = id, status = "CANCELLED", updatedAt = DateTime.UtcNow, reason };
        await hubContext.Clients.Group($"booking_{id}").SendAsync("BookingStatusChanged", payload);
        await hubContext.Clients.Group($"booking_{id}").SendAsync("OnStatusChanged", payload);
        return Ok(new { status = "CANCELLED" });
    }

    [HttpPost("{id}/parts")]
    public async Task<IActionResult> AddPart(string id, [FromBody] AddPartRequest request)
    {
        try
        {
            var part = await dbService.AddPartForRepairAsync(id, request.PartName, request.PartSku, request.Quantity, request.UnitPrice);
            if (part == null) return NotFound(new { message = "Booking not found" });

            await hubContext.Clients.Group($"booking_{id}").SendAsync("OnPartAdded", part);
            return Ok(part);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Failed to add part", detail = ex.Message });
        }
    }
}

public sealed record AddPartRequest(string PartName, string? PartSku, int Quantity, decimal UnitPrice);
public sealed record CancelBookingRequest(string? Reason);
