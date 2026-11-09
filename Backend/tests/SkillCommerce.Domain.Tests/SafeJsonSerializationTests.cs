using System.Text.Json;
using Xunit;

namespace SkillCommerce.Domain.Tests;

public class SafeJsonSerializationTests
{
    [Fact]
    public void Serialize_PartWithSpecialCharactersAndUnicode_ProducesValidJson()
    {
        // Inputs containing quotes, backslashes, tabs, and Bengali script
        var partName = "45uF \"Inverter\" Dual Run \\ Capacitor & ফ্যান রেগুলেটর";
        var sku = "SKU-AC/\"45\"\\";
        var quantity = 2;
        var unitPrice = 750.50m;
        var lineTotal = 1501.00m;

        var snapshotObj = new
        {
            name = partName,
            sku = sku,
            quantity = quantity,
            unitPrice = unitPrice,
            lineTotal = lineTotal
        };

        var json = JsonSerializer.Serialize(snapshotObj);

        // Assert valid JSON by deserializing back
        using var doc = JsonDocument.Parse(json);
        var root = doc.RootElement;

        Assert.Equal(partName, root.GetProperty("name").GetString());
        Assert.Equal(sku, root.GetProperty("sku").GetString());
        Assert.Equal(quantity, root.GetProperty("quantity").GetInt32());
        Assert.Equal(unitPrice, root.GetProperty("unitPrice").GetDecimal());
        Assert.Equal(lineTotal, root.GetProperty("lineTotal").GetDecimal());
    }
}

