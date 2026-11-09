namespace SkillCommerce.Domain.Billing;

/// <summary>
/// Pure calculation domain logic for commission settlement.
/// Formula:
/// Commissionable = LaborAmount + UrgencyFee
/// PlatformFee = round(Commissionable * CommissionRate, 2)
/// MaterialsAmount = sum(LineTotal of Approved parts)
/// TotalPayable = LaborAmount + UrgencyFee + MaterialsAmount
/// ProviderPayout = TotalPayable - PlatformFee
/// </summary>
public static class BookingPricing
{
    public static (decimal platformFee, decimal totalPayable, decimal providerPayout) Calculate(
        decimal laborAmount, decimal urgencyFee, decimal commissionRate, decimal materialsAmount)
    {
        var commissionable = laborAmount + urgencyFee;
        var platformFee = Math.Round(commissionable * commissionRate, 2, MidpointRounding.AwayFromZero);
        var totalPayable = laborAmount + urgencyFee + materialsAmount;
        var providerPayout = totalPayable - platformFee;

        return (platformFee, totalPayable, providerPayout);
    }
}

