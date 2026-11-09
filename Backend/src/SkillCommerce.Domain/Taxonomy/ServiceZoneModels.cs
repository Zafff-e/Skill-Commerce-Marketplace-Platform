namespace SkillCommerce.Domain.Taxonomy;

public sealed record ServiceZone(
    string ZoneId,
    string NameEn,
    string NameBn,
    decimal Latitude,
    decimal Longitude,
    decimal RadiusKm,
    int ActiveProvidersCount
);

public sealed record StandardServiceTask(
    string TaskId,
    int CategoryId,
    string NameEn,
    string NameBn,
    decimal FixedPrice,
    int DurationMinutes,
    string RequiredQualifications,
    string DescriptionEn,
    string DescriptionBn
);

public sealed record ProviderCoverageUpdate(
    string BaseZoneId,
    decimal ServiceRadiusKm,
    List<string> SecondaryZoneIds
);

public sealed record ProviderTaskOfferingUpdate(
    List<string> OptedTaskIds
);

