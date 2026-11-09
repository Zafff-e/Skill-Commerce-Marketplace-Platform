namespace SkillCommerce.Domain.Common;

/// <summary>
/// Factory helper for creating NTS Point values with correct SRID and coordinate order.
/// NetTopologySuite uses X = Longitude, Y = Latitude — swapping them is the most common bug.
/// Always construct points through this helper.
/// </summary>
public static class GeoPoint
{
    private const int Srid = 4326;

    /// <summary>Creates a geographic point from human-readable (latitude, longitude) inputs.</summary>
    /// <param name="latitude">Y axis. Range: -90 to 90.</param>
    /// <param name="longitude">X axis. Range: -180 to 180.</param>
    public static NetTopologySuite.Geometries.Point Create(double latitude, double longitude)
    {
        if (latitude < -90 || latitude > 90)
            throw new ArgumentOutOfRangeException(nameof(latitude), "Latitude must be between -90 and 90.");
        if (longitude < -180 || longitude > 180)
            throw new ArgumentOutOfRangeException(nameof(longitude), "Longitude must be between -180 and 180.");

        // NTS: X = longitude, Y = latitude
        return new NetTopologySuite.Geometries.Point(longitude, latitude) { SRID = Srid };
    }
}
