using Microsoft.AspNetCore.SignalR;

namespace SkillCommerce.Api.Hubs;

public class BookingHub : Hub
{
    public async Task JoinBookingGroup(string bookingId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"booking_{bookingId}");
    }

    public async Task LeaveBookingGroup(string bookingId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"booking_{bookingId}");
    }

    public async Task SendLocationUpdate(string bookingId, double latitude, double longitude)
    {
        var payload = new
        {
            bookingId,
            latitude,
            longitude,
            updatedAt = DateTime.UtcNow
        };

        // Emit to both legacy and unified event contracts for backward compatibility
        await Clients.Group($"booking_{bookingId}").SendAsync("ProviderLocationUpdated", payload);
        await Clients.Group($"booking_{bookingId}").SendAsync("OnLocationUpdated", payload);
    }

    public async Task SendStatusUpdate(string bookingId, string status)
    {
        var payload = new
        {
            bookingId,
            status,
            updatedAt = DateTime.UtcNow
        };

        // Emit to both legacy and unified event contracts for backward compatibility
        await Clients.Group($"booking_{bookingId}").SendAsync("BookingStatusChanged", payload);
        await Clients.Group($"booking_{bookingId}").SendAsync("OnStatusChanged", payload);
    }
}
